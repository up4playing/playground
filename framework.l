unit Framework
	Object[] objects
	Object[] selectedObjects
	
	clear
		objects.clear
		
	tick
		for <- objects: tick
		for objects: updateBoard
		// Input.onTouchUp: touch.user.selectedObject = null
		Input.onTouchUp: selectedObjects[touch.userId] = null
		
	isVisibleFor: float2 pos, int userId
		let board = getBoardAt pos
		return !board or board.isVisibleFor userId
			
	getBoardAt: float2 pos
		for object -> Framework.objects
			if object.type == Board
				Board b = cast object
				if pos >= b.position - b.size/2 && pos < b.position + b.size/2
					return b
		return null
		
	debugString
		let result = ""
		for objects: result+= o.debugString
		return result
		
	checksum
		let result = 0
		for objects: result += o.checksum
		// We ensure that we never return 0
		// because a checksum of 0 is used to indicate that we don't have a checksum for this frame yet
		if result == 0: return 1
		return result		
			
// class NetworkUser
// 	Object selectedObject = null
		
enum Side: Front, Back
		
class Object
	const float2 stackOffset = {8,8}
	const minSize = 75
	
	Image image = null
	float2 position
	float scale = 1
	float angle
	
	bool stackable
	bool movable = true
	bool rotatable
	bool flipable
	
	Image backImage = null
	Side side
	int frame
	
	// Move
	private Touch moveTouch = null
	private float2 touchOffset
	private bool isBeingMoved
	private Object overStackable = null
	
	// Rotate
	private Touch rotateTouch = null
	private float rotateOffset
	private float targetAngle
	private bool rotatedOverThreshold
	
	visible float2 size
	public Board board = null, nextBoard = null
	public float2 targetPos = float2.none
	private int interactingUserId
	
	private siblings := board ? board.objects : Framework.objects
	onBoardChanged
	
	Object
		siblings.add this
		size = image ? image.size * scale : {}
		if size.x < minSize: size.x = minSize
		if size.y < minSize: size.y = minSize
		this.targetAngle = angle
		this.nextBoard = board
		
	debugString := "(Object pos:{position.x} {position.y} frame:{frame} side:{side} image:{image?.file} board:{board.toBool})"
	
	checksum := position.x + position.y + frame + scale + angle + cast side
		
	remove
		siblings.remove this
		
	tick
		// Move
		if movable
			Input.onTouchDownWithin position, size
				moveTouch = touch
				touchOffset = position - touch.position
				siblings.moveToBack this
				isBeingMoved = false
				
			Input.onTouchMove moveTouch
				Network.smooth moveTouch.userId
					position = touch.position + touchOffset
				if touch.position - touch.startPosition > 8: isBeingMoved = true
				if board
					let closestSpotPos = board.getSpotAt touch.position, threshold:size
					if closestSpotPos
						position = closestSpotPos
				// overSpot = getSpotAt touch.position, threshold:size
				// if overSpot && (overSpot.object.type == Stack || overSpot.object.type == type || overSpot.object.spots.length > 1)
				// 	Network.touchLog += " [over spot] "+touch.position.x+" "+touch.position.y
				// 	position = overSpot.object.position + overSpot.pos
				// 	if overSpot.object.stackable: position += stackOffset*3
				checkBoardsWhileMoving touch
								
			Input.onTouchUp moveTouch
				// if overSpot
				// 	if overSpot.object.type == Stack
				// 		Network.touchLog += " [add to stack] "+touch.position.x+" "+touch.position.y
				// 		Stack stack = cast overSpot.object
				// 		stack.add this
				// 	else
				// 	if stackable && overSpot.object.type == type && overSpot.object.stackable
				// 		Network.touchLog += " [create stack] "+touch.position.x+" "+touch.position.y
				// 		Stack.create overSpot.object, this
					
				// touch.user.selectedObject = this
				Framework.selectedObjects[touch.userId] = this
				moveTouch = null
		
		// Rotate	
		if Framework.selectedObjects.contains(this) && rotatable
			if !rotateTouch || !rotatedOverThreshold
				drawButton rotateIcon, position:position+image.size/2*{1,-1}*scale+{8, -8}, touchMargin:{50,50}
					rotateTouch = touch
					rotateOffset = angle - Math.atan2(touch.position - position)
					rotatedOverThreshold = false
				
			Input.onTouchMove rotateTouch
				Network.smooth touch.userId
					angle = targetAngle = Math.atan2(touch.position - position) + rotateOffset
				if (touch.position - touch.startPosition).length > 4: rotatedOverThreshold = true
				
			Input.onTouchUp rotateTouch
				targetAngle = Math.round(angle / (Math.PI/2)) * Math.PI/2
				rotateTouch = null
				if !rotatedOverThreshold: targetAngle -= Math.PI/2
				interactingUserId = touch.userId
		
		// Flip	
		if Framework.selectedObjects.contains(this) && flipable
			drawButton flipIcon, position:position+image.size/2*{-1,1}*scale-{8, -8}, touchMargin:{50,50}
				side = side == Back ? Front : Back
		
		Network.smooth interactingUserId
			if angle != targetAngle: angle = Math.moveTowards(angle, targetAngle, .2)
			
		// Draw
		if image
			if side == Front || !backImage: drawImage image, position, frame:frame%image.frames.length, scale, angle
			else                            drawImage backImage, position, frame:frame%backImage.frames.length, scale, angle
		
	private checkBoardsWhileMoving: Touch touch
		float2 pos = position
		if board: pos = position * board.matrix
		nextBoard = Framework.getBoardAt pos
		
	updateBoard
		if nextBoard != board
			if board: board.objects.remove this; position = position * board.matrix; touchOffset = touchOffset * board.matrix.scaleVector
			else      Framework.objects.remove this
			board = nextBoard
			if board: board.objects.add this;    position = position / board.matrix; touchOffset = touchOffset / board.matrix.scaleVector
			else      Framework.objects.add this
			onBoardChanged
					
Object Stack
	private Object[] objects
	Side sideWhenRemoving = Front
	
	private int visibleObjects
	private float2 basePosition
	private int shownObjectCount
	
	stackable = true
	
	Stack: float2 position, Side side = Back
		basePosition = position
	
	static create: Object a, Object b, Side side = Front
		Stack stack = {position:a.position, side:side}
		stack.add a
		stack.add b
						
	add: Object a
		a.side = side
		objects.add a
		Framework.objects.remove a
		updatePositions
		
	private pop
		let topObject = objects.pop
		Framework.objects.add topObject
		topObject.position += stackOffset
		topObject.side = sideWhenRemoving
		if objects.length == 0: Framework.objects.remove this
		else                    updatePositions
		return topObject
		
	private updatePositions
		if objects.length == 0: return
		shownObjectCount = Math.min(3, objects.length)
		position = basePosition + (shownObjectCount-1)/2 * stackOffset
		for shownObjectCount: objects[objects.length-shownObjectCount+i].position = basePosition + i * stackOffset
			
		let a = objects[objects.length-shownObjectCount]
		let b = objects[objects.length-1]
		size = (b.position+{b.size.x/2, -b.image.size.y/2}) - (a.position-{a.size.x/2, -a.size.y/2})
	
	tick
		Input.onTouchDownWithin position, size
			let obj = pop
			obj.moveTouch = touch
			obj.touchOffset = obj.position - touch.position
			
		for i = Math.limit(objects.length-shownObjectCount, min:0) <- objects.length
			let obj = objects[i]
			drawImage obj.backImage, obj.position, scale:obj.scale
	
	shuffle
		objects.shuffle
		updatePositions

enum BoardVisiblity: Never, Off, On, Always		

Object Board
	Object[] objects
	Matrix2D matrix
	Color color = null
	BoardVisiblity visibleForOthers = Always
	int owner
	bool panable
	bool zoomable
	
	private Spot[] spots
	private Spot overSpot = null
	
	private Touch panTouch = null
	private Matrix2D downMatrix
	
	const zoomLookupTable = [
		0.9608086423320881,0.96176945097442,0.9627312204253944,0.9636939516458196,0.9646576455974654,0.9656223032430628,0.9665879255463057,0.9675545134718518,0.9685220679853236,0.9694905900533088,0.9704600806433621,0.9714305407240054,0.9724019712647292,0.9733743732359939,0.9743477476092297,0.9753220953568389,0.9762974174521956,0.9772737148696476,0.9782509885845172,0.9792292395731016,
		0.9802084688126746,0.9811886772814872,0.9821698659587685,0.9831520358247272,0.9841351878605519,0.9851193230484123,0.9861044423714606,0.9870905468138319,0.9880776373606457,0.9890657149980062,0.9900547807130041,0.991044835493717,0.9920358803292106,0.9930279162095397,0.9940209441257492,0.9950149650698747,0.9960099800349446,0.9970059900149794,0.9980029960049942,0.9990009990009991,
		1,1.001,1.0020009999999997,1.0030030009999997,1.0040060040009995,1.0050100100050003,1.0060150200150053,1.0070210350350202,1.0080280560700552,1.009036084126125,1.0100451202102512,1.0110551653304611,1.0120662204957915,1.0130782867162873,1.0140913650030035,1.0151054563680064,1.0161205618243743,1.0171366823861985,1.0181538190685846,1.0191719728876532,
		1.0201911448605405,1.021211336005401,1.0222325473414062,1.0232547798887477,1.0242780346686362,1.0253023127033047,1.0263276150160079,1.0273539426310239,1.0283812965736547,1.0294096778702282,1.0304390875480984,1.0314695266356464,1.032500996162282,1.033533497158444,1.0345670306556025,1.0356015976862578,1.036637199283944,1.0376738364832279,1.038711510319711,1.0397502218300305
	]
	Board: float2 size
		this.size = size
		
	debugString
		string children
		for objects: children += o.debugString
		return "(Board pos:{position.x} {position.y} children:{children})"
		
	checksum
		let result = position.x + position.y + cast(visibleForOthers) + matrix.m0 + matrix.m1 + matrix.m2 + matrix.m3 + matrix.m4 + matrix.m5
		for objects: result += o.checksum
		return result
		
	add: Object object
		objects.add object
		object.board = object.nextBoard = this
		Framework.objects.remove object
		
	addSpot: Spot spot
		spots.add spot
		
	isVisibleFor: int userId
		return visibleForOthers == Always or visibleForOthers == On or owner == userId
		
	tick
		// Children
		graphics.visibleFor visibleForOthers == Never or visibleForOthers == Off ? owner : -1
			graphics.applyMatrix matrix
				for <- objects: tick
		
		// Pan
		if panable	
			Input.onTouchDownWithin position, size
				panTouch = touch
				downMatrix = matrix
			Input.onTouchMove panTouch
				matrix = downMatrix
				matrix.move touch.position - touch.startPosition
			Input.onTouchUp panTouch
				panTouch = null
				
		// Zoom
		if zoomable	
			Input.onWheelWithin position, size
				float factor = zoomLookupTable[Math.limit event.delta+40 min:0 max:zoomLookupTable.length-1]
				Network.touchLog += "[{Network.frame}] zoom value:{event.delta} factor:{factor} matrix:{matrix}"
				matrix.move event.position
				matrix.scale {factor, factor}
				matrix.move event.position*{-1,-1}
				Network.touchLog += " -> {matrix}"
			
		// Visiblity icon
		if visibleForOthers == On or visibleForOthers == Off
			Image icon =  visibleForOthers == On ? visibleIcon : hiddenIcon
			drawButton icon, position:position+{size.x/2-32, -size.y/2+32}, clickableBy:owner
				visibleForOthers = visibleForOthers == On ? Off : On
				
		if color: drawRectangle position, size, fillColor:color, layer:-1
		if image: drawImage image, position, scale
			
	updateBoard
		for objects: updateBoard
			
	getSpotAt: float2 position, float2 threshold
		float2 closestSpotPos = float2.none
		float minDistance = int.maxValue
		for spot -> spots
			let spotPos = spot.getClosestPoint position, this.position
			let delta = (spotPos - position).abs
			let distance = delta.length
			if delta < threshold and distance < minDistance and !objects.find.position == spotPos
				minDistance = distance
				closestSpotPos = spotPos
		return closestSpotPos
		
class Spot
	float2 pos
	getClosestPoint(float2 touchPos, float2 boardPos) := pos + boardPos
	
Spot SpotGrid
	float2 cellSize
	getClosestPoint: float2 touchPos, float2 boardPos
		return ((touchPos-boardPos)/cellSize).rounded*cellSize + boardPos
		
Object RectangleObject
	Color color = White
	float2 size
	RectangleObject: float2 position, float2 size, Color color
	tick
		drawRectangle position, size, color
	
struct Particle
	float2 pos, speed
	float size
	int frame
	float angle

Object ParticleSystem
	private Particle[] particles
	Image particleImage
	
	ParticleSystem: float minSpeed = 15, float maxSpeed = 30
		for 20
			let r = (Math.randomFloat) * Math.PI
			let speedFactor = Math.randomFloat*(maxSpeed-minSpeed) + minSpeed
			particles.add Particle
				position
				speed: {Math.cos(r), Math.sin(r)} * speedFactor
				size: 50
				frame: Math.randomInteger(particleImage.frames.length)
				angle: Math.randomFloat*Math.PI*2
		
	tick
		for i,p <- particles
			graphics.move p.pos
				graphics.rotate p.angle
					drawImage particleImage, frame:p.frame, scale
			p.pos += p.speed
			p.speed.y -= 1
			p.angle += .05
			if p.pos.y < -Platform.size.y/2
				particles.removeAt i
		
		if particles.length == 0	
			remove
			
enum closestCoinType: None, Neighbor, Over
Object Coin
	const Color darkColor = {"642C00"}
	const Color lightColor = {"F7C947"}
	
	int value
	bool isInfinate
	bool allowZero
	image = Coin
	
	private Coin closestCoin = null
	private closestCoinType closestCoinType
	private float distanceToClosest
	
	debugString := "(Coin {value} pos:{position.x} {position.y} dis:{distanceToClosest})"
	checksum := position.x + position.y + frame + value
	
	tick
		if movable
			Input.onTouchDownWithin position, radius:40
				moveTouch = touch
				touchOffset = position - touch.position
				siblings.moveToBack this
				isBeingMoved = false
			
			Input.onTouchMove moveTouch
				Network.smooth touch.userId
					position = touch.position + touchOffset
				if touch.position - touch.startPosition > 8: isBeingMoved = true
				updateNeighbors siblings, isBeingMoved
				checkBoardsWhileMoving touch
			
			Input.onTouchUp moveTouch
				// touch.user.selectedObject = this
				Framework.selectedObjects[touch.userId] = this
				moveTouch = null
				
				if closestCoinType == Over: mergeWith closestCoin; else
				if !isBeingMoved:           transferToNeighbor closestCoin
		else
			Input.onTouchUpWithin position, radius:64
				transferToNeighbor closestCoin
			
		if isInfinate or value or allowZero
			if closestCoinType == Neighbor 
				drawCircle (position + closestCoin.position)/2, radius:6, fillColor:darkColor, outlineColor:lightColor, outlineWidth:5
			if !isInfinate
				if value < 10:  drawText cast value, position+{0, 3}, color:darkColor, size:42, style:Bold, font:"Shadowed Serif"; else
				if value < 100: drawText cast value, position+{0, 2}, color:darkColor, size:34, style:Bold, font:"Shadowed Serif"; else
				                drawText cast value, position+{0, 2}, color:darkColor, size:24, style:Bold, font:"Shadowed Serif"
			
			drawImage image, position, frame:closestCoinType == Over ? 1 : 0
			
	private static updateNeighbors: Object[] siblings, bool isBeingMoved
		for object -> siblings
			if object.type == Coin
				Coin c = cast object
				c.clearClosestCoin
				
		for object -> siblings
			if object.type == Coin
				Coin c = cast object
				let closestCoin = getClosestCoin c, threshold:90
				if closestCoin and c.closestCoin != closestCoin
					let distance = closestCoin.position distanceTo object.position
					if distance < closestCoin.distanceToClosest
						if c.closestCoin: c.closestCoin.clearClosestCoin
						if closestCoin.closestCoin: closestCoin.closestCoin.clearClosestCoin
							
						c.distanceToClosest = distance
						c.closestCoin = closestCoin
						c.closestCoinType = distance > 65 ? Neighbor : isBeingMoved ? Over : None
						
						closestCoin.distanceToClosest = distance
						closestCoin.closestCoin = c
						closestCoin.closestCoinType = c.closestCoinType

	private static getClosestCoin: Coin source, float threshold = float.infinity
		Coin closestCoin = null
		float minDistance = threshold
		for object -> source.siblings
			if object.type == Coin and object != source and object.image == source.image
				Coin c = cast object
				let distance = (c.position - source.position).length
				if distance < minDistance
					minDistance = distance
					closestCoin = c
					
		return closestCoin
		
	onBoardChanged
		if closestCoin: closestCoin.clearClosestCoin
		clearClosestCoin		
		
	clearClosestCoin:
		closestCoin = null
		distanceToClosest = float.infinity
		closestCoinType = None		
		
	private mergeWith: Coin coin
		coin.value += value
		remove
		updateNeighbors siblings, isBeingMoved:false
	
	private transferToNeighbor: Coin coin, int amount = 1
		Coin neighbor = coin
		if !neighbor
			if value <= amount and !isInfinate: return
			neighbor = {position:position+{45,58}, board:board, image:image}
		value -= amount
		neighbor.value += amount
		if !isInfinate and !allowZero and value <= 0: remove
		updateNeighbors siblings, isBeingMoved:false
			
		



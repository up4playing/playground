unit Framework
	Object[] objects
	Object[] selectedObjects
	
	// Evaluate: Immediately remove objects to avoid problems in
	// - graphics.setUserVideo (updating video object that will be removed)
	// - Coin.transferToNeighbor (the just removed coin is still their in updateNeighbors)
	// Object[] toBeRemoved
	
	clear
		// toBeRemoved.addRange objects
		objects.clear
		
	tick
		// if toBeRemoved
		// 	toBeRemoved.each.siblings.remove .
		// 	toBeRemoved.clear
		fx.tick
		objects.each <- .tick
		objects.each.update
		Input.onTouchUp:  deselect touch.userId
		
	isVisibleFor: Vector2 pos, int userId
		let board = getBoardAt pos
		return !board or board.isVisibleFor userId
			
	getBoardAt: Vector2 pos
		for Framework.objects -> object
			if object.type == Board
				Board b = cast object
				if pos >= b.position - b.size/2 && pos < b.position + b.size/2
					return b
		return null
		
	deselect: int userId
		selectedObjects[userId] = null
		
	debugString
		let result = ""
		for objects: result+= .debugString
		return result
		
	private js float appChecksum()
		return window.app_checksum ? window.app_checksum() : 0.0
		
	checksum
		float result = appChecksum
		for objects: result += .checksum
		// We ensure that we never return 0
		// because a checksum of 0 is used to indicate that we don't have a checksum for this frame yet
		if result == 0: return 1.0
		return result
			
transient global unit graphics
	setUserVideo: int userId = 0, Vector2 pos = {}, float width = 440, float radius = 0
		VideoObject videoObject = cast Framework.objects.find
			if .type == VideoObject
				VideoObject v = cast .
				return v.userId == userId
			return false
		// if !videoObject or Framework.toBeRemoved.contains(videoObject): videoObject = VideoObject(userId)
		if !videoObject: videoObject = VideoObject(userId)
		videoObject.position = pos
		videoObject.radius = radius
		videoObject.size = {width, width*3/4}
		
enum Side: Front, Back
		
class Object
	Vector2 position
	float scale = 1
	float alpha = 1
	int visibleFor = -1
	
	visible siblings := Framework.objects
	internal checksum := 0
	internal debugString := "(Object pos:{position.x} {position.y})"
	internal tick
	internal update
	
	Object
		siblings.add this
		
	remove
		siblings.remove this
		// Framework.toBeRemoved.add this
		
	moveTo: Vector2 pos
		    int duration = 1000
		    int delay = 0
		    bool smooth = false
		Vector2 startValue = position
		let startTime = Time.now + delay
		
		// When chaining serveral move effects together, continue where the last one left off
		let effect = fx.effects[fx.effects.length-1]
			if effect.type == MoveEffect
				MoveEffect moveEffect = cast effect
				if moveEffect.object == this
					startValue = moveEffect.startValue + moveEffect.delta
					startTime = moveEffect.startTime + moveEffect.duration
					
		let delta = pos - startValue
		fx.add MoveEffect startTime, duration, smooth, this, startValue, delta
		return this
		
	moveTo: Vector2 pos
		    float speed = 1
		    int delay = 0
		    bool smooth = false
		let delta = pos - position
		let duration = Math.floor(delta.length / speed)
		fx.add MoveEffect startTime:Time.now+delay, duration, smooth, this, startValue:position, delta
		return this
		
	fadeIn: int duration = 1000
		    int delay = 0
		    bool smooth = false
		alpha = 0
		fx.add FadeEffect startTime:Time.now+delay, duration, smooth, this, startValue:0, delta:1
		return this
		
	fadeOut: int duration = 1000
		     int delay = 0
		     bool removeWhenDone = true
		     bool smooth = false
		fx.add FadeEffect startTime:Time.now+delay, duration, smooth, this, startValue:1, delta:-1, removeWhenDone
		return this
		
	scaleTo: float scale 
		     int duration = 1000
		     int delay = 0
		     bool smooth = false
		fx.add ScaleEffect startTime:Time.now+delay, duration, smooth, this, startValue:this.scale, delta:scale-this.scale
		return this
	
	fadeAndScaleIn: int duration = 200
		            float startScale = 3
		            int delay = 0
		            bool smooth = false
		alpha = 0
		fx.add ScaleEffect startTime:Time.now+delay, duration, smooth, this, startValue:startScale, delta:1-startScale
		fx.add FadeEffect  startTime:Time.now+delay, duration, smooth, this, startValue:0, delta:1
		return this
		
Object RectangleObject
	Vector2 size
	Color color = White
	tick
		drawRectangle position, size, color, visibleFor

Object CircleObject
	float radius = 10
	Color color = White
	tick
		drawCircle position, radius, fillColor:color, visibleFor
		
	radiusTo: float value
		      int duration = 200
		      int delay = 0
		      bool smooth = false
		fx.add RadiusEffect startTime:Time.now+delay, duration, smooth, this, startValue:radius, delta:value-radius

Object TextObject
	string text
	int size
	Font font
	Color color = White
	HorizontalAlignment align = Center // The horizontal alignment of the text
	VerticalAlignment valign = Middle  // The vertical alignment of the text
	tick
		drawText text, position, size*scale, color, align, valign, font, alpha, visibleFor
		
Object ImageObject
	Image image
	tick
		drawImage image, position, scale, alpha, visibleFor
		
Object VideoObject
	int userId
	Vector2 size = {440, 330}
	float radius
	tick
		if radius: drawVideo userId, position, radius
		else       drawVideo userId, position, size
			
Object Button
	Image image                      // The image of the button
    text = ""                        // The text of the button
    Vector2 position = {}            // The position to draw to
    Color textColor                  // The color of the text
    frame = 0                        // The frame of the image
    scale = 1.0                      // Scale the image by this factor
    fontSize = 18                    // The font size in pixels   
    touchMargin = Vector2(16,16)     // The margin around the button within which it is touchable
    textOffset = Vector2(0,-2)
    showTouchArea = false            // Show the area within which the button is touchable
    visibleFor = -1                  // Only this user will see the button
    clickableBy = -1                 // Only this user can click the button
    implicit layer = 0               // Higher layers are drawn in front of lower layers
    alpha = 1.0                      // The opacity of the button 0: fully transpart, 1: fully visible)
	int hotkey
    void(Touch touch) onClick        // Execute this code when the user clicks the button
	tick
		drawButton image, text, position, textColor, frame, scale, fontSize, touchMargin, textOffset, showTouchArea, visibleFor, clickableBy, hotkey, layer, alpha, onClick(touch)

		
Object Piece
	const Vector2 stackOffset = {8,8}
	const minSize = 75
	
	Image image
	float angle
	
	bool stackable
	bool movable = true
	bool rotatable
	bool flipable
	
	Image backImage
	Side side
	int frame
	
	// Move
	private Touch moveTouch
	private Vector2 touchOffset
	private bool isBeingMoved
	private Object overStackable
	
	// Rotate
	private Touch rotateTouch
	private float rotateOffset
	private float targetAngle
	private bool rotatedOverThreshold
	
	visible Vector2 size
	public Board board, nextBoard
	private int interactingUserId
	
	private siblings := board ? board.objects : Framework.objects
	onBoardChanged
	
	Piece
		size = image ? image.size : {}
		if size.x < minSize: size.x = minSize
		if size.y < minSize: size.y = minSize
		this.targetAngle = angle
		this.nextBoard = board
		
	debugString := "(Piece pos:{position.x} {position.y} frame:{frame} side:{side} image:{image?.file} board:{board.toBool})"
	
	checksum := position.x + position.y + frame + scale + angle + cast side
		
	tick
		// Move
		if movable
			Input.onTouchDownWithin position, size * scale, angle
				moveTouch = touch
				touchOffset = position - touch.position
				siblings.moveToBack this
				isBeingMoved = false
				
			Input.onTouchMove moveTouch
				Network.smooth moveTouch.userId
					position = touch.position + touchOffset
					if touch.position - touch.startPosition > 8: isBeingMoved = true
					if board
						let closestSpotPos = board.getSpotAt touch.position, threshold:size * scale, currentObject:this
						if closestSpotPos
							position = closestSpotPos
					checkBoardsWhileMoving touch
								
			Input.onTouchUp moveTouch
				Framework.selectedObjects[touch.userId] = this
				moveTouch = null
		
		// Rotate	
		Vector2 iconPos = rotatable ? {(image.size.x+image.size.y)/4, (image.size.x+image.size.y)/4} : image.size/2
		if Framework.selectedObjects.contains(this) && rotatable
			if !rotateTouch || !rotatedOverThreshold
				drawButton rotateIcon, position:position+iconPos*{1,-1}*scale, touchMargin:{50,50}
					rotateTouch = touch
					rotateOffset = angle - Math.getAngleForVector(touch.position - position)
					rotatedOverThreshold = false
				
			Input.onTouchMove rotateTouch
				Network.smooth touch.userId
					angle = targetAngle = Math.getAngleForVector(touch.position - position) + rotateOffset
				if (touch.position - touch.startPosition).length > 16: rotatedOverThreshold = true
				
			Input.onTouchUp rotateTouch
				targetAngle = Math.round(angle / (Math.PI/2)) * Math.PI/2
				rotateTouch = null
				if !rotatedOverThreshold: targetAngle -= Math.PI/2
				interactingUserId = touch.userId
		
		// Flip	
		if Framework.selectedObjects.contains(this) && flipable
			drawButton flipIcon, position:position+iconPos*{-1,1}*scale, touchMargin:{50,50}
				side = side == Back ? Front : Back
		
		Network.smooth interactingUserId
			if angle != targetAngle: angle = Math.moveTowards(angle, targetAngle, .2)
			
		// Draw
		if image
			if side == Front || !backImage: drawImage image, position, frame:frame%image.frames.length, scale, angle
			else                            drawImage backImage, position, frame:frame%backImage.frames.length, scale, angle
		
	private checkBoardsWhileMoving: Touch touch
		Vector2 pos = position
		if board: pos = position * board.matrix
		nextBoard = Framework.getBoardAt pos
		
	update
		if nextBoard != board
			if board: board.objects.remove this; position = position * board.matrix; touchOffset = touchOffset * board.matrix.scaleVector
			else      Framework.objects.remove this
			board = nextBoard
			if board: board.objects.add this;    position = position / board.matrix; touchOffset = touchOffset / board.matrix.scaleVector
			else      Framework.objects.add this
			onBoardChanged
					
Piece Stack
	private Piece[] objects
	Side sideWhenRemoving = Front
	
	private int visibleObjects
	private Vector2 basePosition
	private int shownObjectCount
	
	stackable = true
	
	Stack: Vector2 position, Side side = Back
		basePosition = position
	
	static create: Piece a, Piece b, Side side = Front
		Stack stack = {position:a.position, side:side}
		stack.add a
		stack.add b
						
	add: Piece a
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
		for Math.limit(objects.length-shownObjectCount, min:0) to objects.length <- i
			let obj = objects[i]
			let image = obj.backImage || obj.image
			drawImage image, obj.position, frame:obj.frame%image.frames.length, scale:obj.scale
	
		// We pop after drawing, because the newly created card won't be drawn until the next frame
		// and we don't want to draw the new, smaller stack without drawing the popped card as well
		Input.onTouchDownWithin position, size
			let obj = pop
			obj.moveTouch = touch
			obj.touchOffset = obj.position - touch.position
			
	shuffle
		objects.shuffle
		updatePositions

enum BoardVisiblity: Never, Off, On, Always		

Piece Board
	Object[] objects
	Matrix2D matrix
	Color color
	BoardVisiblity visibleForOthers = Always
	int owner
	bool panable
	bool zoomable
	
	private Spot[] spots
	private Spot overSpot
	
	private Touch panTouch
	private Matrix2D downMatrix
	
	const zoomLookupTable = [
		0.9608086423320881,0.96176945097442,0.9627312204253944,0.9636939516458196,0.9646576455974654,0.9656223032430628,0.9665879255463057,0.9675545134718518,0.9685220679853236,0.9694905900533088,0.9704600806433621,0.9714305407240054,0.9724019712647292,0.9733743732359939,0.9743477476092297,0.9753220953568389,0.9762974174521956,0.9772737148696476,0.9782509885845172,0.9792292395731016,
		0.9802084688126746,0.9811886772814872,0.9821698659587685,0.9831520358247272,0.9841351878605519,0.9851193230484123,0.9861044423714606,0.9870905468138319,0.9880776373606457,0.9890657149980062,0.9900547807130041,0.991044835493717,0.9920358803292106,0.9930279162095397,0.9940209441257492,0.9950149650698747,0.9960099800349446,0.9970059900149794,0.9980029960049942,0.9990009990009991,
		1,1.001,1.0020009999999997,1.0030030009999997,1.0040060040009995,1.0050100100050003,1.0060150200150053,1.0070210350350202,1.0080280560700552,1.009036084126125,1.0100451202102512,1.0110551653304611,1.0120662204957915,1.0130782867162873,1.0140913650030035,1.0151054563680064,1.0161205618243743,1.0171366823861985,1.0181538190685846,1.0191719728876532,
		1.0201911448605405,1.021211336005401,1.0222325473414062,1.0232547798887477,1.0242780346686362,1.0253023127033047,1.0263276150160079,1.0273539426310239,1.0283812965736547,1.0294096778702282,1.0304390875480984,1.0314695266356464,1.032500996162282,1.033533497158444,1.0345670306556025,1.0356015976862578,1.036637199283944,1.0376738364832279,1.038711510319711,1.0397502218300305
	]
	Board: Vector2 size
		this.size = size
		
	debugString
		string children
		for objects: children += .debugString
		return "(Board pos:{position.x} {position.y} children:{children})"
		
	checksum
		let result = position.x + position.y + cast(visibleForOthers) + matrix.m0 + matrix.m1 + matrix.m2 + matrix.m3 + matrix.m4 + matrix.m5
		for objects: result += .checksum
		return result
		
	add: Piece object
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
				objects.each <- .tick
		
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
				Framework.deselect touch.userId
				
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
			
	update
		objects.each.update
			
	getSpotAt: Vector2 position, Vector2 threshold, Object currentObject
		Vector2 closestSpotPos = Vector2.none
		float minDistance = int.maxValue
		for spots -> spot
			let spotPos = spot.getClosestPoint position, this.position
			let delta = (spotPos - position).abs
			let distance = delta.length
			if delta < threshold and distance < minDistance and !objects.find.position == spotPos and . != currentObject
				minDistance = distance
				closestSpotPos = spotPos
		return closestSpotPos
		
class Spot
	Vector2 pos
	getClosestPoint(Vector2 touchPos, Vector2 boardPos) := pos + boardPos
	
Spot SpotGrid
	Vector2 cellSize
	getClosestPoint: Vector2 touchPos, Vector2 boardPos
		return ((touchPos-boardPos)/cellSize).rounded*cellSize + boardPos
		
struct Particle
	Vector2 pos, speed
	int frame
	float angle
	float scale = 1

Object ParticleSystem
	private Particle[] particles
	Image particleImage = starParticle
	minSpeed = 10.0
	maxSpeed = 25.0
	particlesPerBurst = 30
	burstInterval = 500
	nextBurst = -1
	bursts = 10
	
	private int burst
	
	tick
		if Time.now > nextBurst
			for particlesPerBurst
				let r = -(Math.randomFloat) * Math.PI*2
				let speedFactor = Math.randomFloat*(maxSpeed-minSpeed) + minSpeed
				particles.add Particle
					pos: position
					speed: {Math.cos(r), Math.sin(r)} * speedFactor
					frame: Math.randomInteger(particleImage.frames.length)
					angle: Math.randomFloat*Math.PI*2
			nextBurst = ++burst < bursts ? Time.now + burstInterval : int.maxValue

		for particles <-
			graphics.move .pos
				graphics.rotate .angle
					drawImage particleImage, frame:.frame, scale:.scale
			.pos += .speed
			.speed.y += 1
			.angle += .05
			if .pos.y < -Platform.size.y/2
				particles.removeAt i
		
		if particles.length == 0	
			remove
			
enum closestCoinType: None, Neighbor, Over
Piece Coin
	const Color darkColor = {"642C00"}
	const Color lightColor = {"F7C947"}
	
	int value
	bool isInfinate
	bool allowZero
	int valueVisibleFor = -1
	int userId = -1
	image = Coin
	
	private Coin closestCoin
	private closestCoinType closestCoinType
	private float distanceToClosest
	
	debugString := "(Coin {value} pos:{position.x} {position.y} dis:{distanceToClosest})"
	checksum := position.x + position.y + frame + value
	
	tick
		if movable
			Input.onTouchDownWithin position, radius:40, userId
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
				Framework.selectedObjects[touch.userId] = this
				moveTouch = null
				
				if closestCoinType == Over: mergeWith closestCoin; else
				if !isBeingMoved:           transferToNeighbor closestCoin
		else
			Input.onTouchUpWithin position, radius:64, userId
				transferToNeighbor closestCoin
			
		if isInfinate or value or allowZero
			if closestCoinType == Neighbor 
				drawCircle (position + closestCoin.position)/2, radius:6, fillColor:darkColor, outlineColor:lightColor, outlineWidth:5
			if !isInfinate
				if value < 10:  drawText cast value, position+{0, 3}, color:darkColor, size:42, style:Bold, font:ShadowedSerif, visibleFor:valueVisibleFor; else
				if value < 100: drawText cast value, position+{0, 2}, color:darkColor, size:34, style:Bold, font:ShadowedSerif, visibleFor:valueVisibleFor; else
				                drawText cast value, position+{0, 2}, color:darkColor, size:24, style:Bold, font:ShadowedSerif, visibleFor:valueVisibleFor;
			
			drawImage image, position, frame:closestCoinType == Over ? 1 : 0
			
	private static updateNeighbors: Object[] siblings, bool isBeingMoved
		for siblings -> object
			if object.type == Coin
				Coin c = cast object
				c.clearClosestCoin
				
		for siblings -> object
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
		for source.siblings -> object
			if object.type == Coin and object != source
				Coin c = cast object
				if c.image == source.image
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
		if !isInfinate and value - amount < 0: return
		Coin neighbor = coin
		if !neighbor
			if value <= amount and !isInfinate: return
			neighbor = {position:position+{45,58}, image:image, userId}
			if board: board.add neighbor
		value -= amount
		neighbor.value += amount
		if !isInfinate and !allowZero and value <= 0: remove
		updateNeighbors siblings, isBeingMoved:false
			


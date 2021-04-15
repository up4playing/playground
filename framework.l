unit framework
	Object[] objects
	
	clear
		objects.clear
		
	tick
		Physics.step
		graphics.matrix = Platform.baseMatrix
		graphics.appMatrix.clear
		graphics.clearScreen
		if Network.inLobby
			lobby.tick
		else
			Timeline.tick
			app.tick
			
			if objects.length
				for <- objects: tickIcons
				for <- objects: tick
				for -> objects: draw 
				for -> objects: drawIcons
					
			Input.onTouchUp: touch.user.selectedObject = null
				
		for user -> Input.users
			if !local
				drawImage finger, touchPos+{11,38}, frame:user.id
				
		Network.updateVideoScreen
		drawSafeArea
		
	private js void drawSafeArea
		Platform_context.fillStyle = "#404040"
		Platform_context.setTransform(1,0,0,1,0,0)
		if(Platform_showSafeArea) {
			if(Platform_effectiveScaleMode == 1) {
				// Fixed width
				let ratio = Platform_pixelSize.x / Platform_referenceSize.x
				let margin = (Platform_pixelSize.y-Platform_referenceSize.y*ratio)/2
				Platform_context.fillRect(0,0,Platform_pixelSize.x, margin)
				Platform_context.fillRect(0,Platform_pixelSize.y-margin,Platform_pixelSize.x, margin)
			} else if(Platform_effectiveScaleMode == 2) {
				// Fixed height
				let ratio = Platform_pixelSize.y / Platform_referenceSize.y
				let margin = (Platform_pixelSize.x-Platform_referenceSize.x*ratio)/2
				Platform_context.fillRect(0, 0, margin, Platform_pixelSize.y)
				Platform_context.fillRect(Platform_pixelSize.x-margin, 0, margin, Platform_pixelSize.y)
			}
		}
		
class NetworkUser
	Object selectedObject = null
		
enum Side: Front, Back
		
class Spot: Vector2 pos; Object object = null

class Object
	static Vector2 stackOffset = {8,8}
	static minSize = 75
	
	Image image = null
	Vector2 position
	float scale = 1
	
	bool stackable
	bool movable = true
	bool rotatable
	bool flipable
	
	Image backImage = null
	Side side
	int frame
	float z
	
	Touch currentTouch = null
	Vector2 touchOffset
	
	private Touch rotateTouch = null
	private float rotateOffset
	private float targetAngle
	
	private Spot[] spots
	private Spot overSpot = null
	visible Vector2 size
	public float angle
	public Board board = null
	
	Vector2 targetPos = Vector2.none
	
	private parentObjects := board ? board.objects : framework.objects
	
	Object
		framework.objects.add this
		if stackable: spots.add {{}, this}
		size = image ? image.size * scale : {}
		if size.x < minSize: size.x = minSize
		if size.y < minSize: size.y = minSize
		this.targetAngle = angle
	
	remove
		framework.objects.remove this
	
	tickIcons
		if rotatable
			Input.onTouchDownWithin position+image.size/2*{1,-1}*scale+{8, -8}, {100,100}
				if touch.user.selectedObject == this
					rotateTouch = touch
					rotateOffset = angle + Math.atan2(touch.position - this.position)
					touch.markAsHandled
				
			Input.onTouchMove rotateTouch
				angle = targetAngle = rotateOffset - Math.atan2(touch.position - this.position)
				
			Input.onTouchUp rotateTouch
				targetAngle = Math.round(angle / (Math.PI/2)) * Math.PI/2
				rotateTouch = null
				touch.markAsHandled
				if (position - startPosition).length < 8
					targetAngle = angle - Math.PI/2
		
		if angle != targetAngle: angle = Math.moveTowards(angle, targetAngle, .2)
				
	tick
		if !movable: return
		Input.onTouchDownWithin position, size
			currentTouch = touch
			touchOffset = this.position - touch.position
			touch.markAsHandled
			parentObjects.moveToEnd this
			
		Input.onTouchMove currentTouch
			this.position = touch.position + touchOffset
			overSpot = getSpotAt position, threshold:size/2
			if overSpot && (overSpot.object.type == Stack || overSpot.object.type == type || overSpot.object.spots.length > 1)
				Network.touchLog += " [over spot] "+touch.position.x+" "+touch.position.y
				this.position = overSpot.object.position + overSpot.pos
				if overSpot.object.stackable: this.position += stackOffset*2
			checkBoardsWhileMoving touch
							
		Input.onTouchUp currentTouch
			if stackable && overSpot
				if overSpot.object.type == Stack
					Network.touchLog += " [create stack] "+touch.position.x+" "+touch.position.y
					Stack stack = cast overSpot.object
					stack.add this
				else
				if overSpot.object.type == type && overSpot.object.stackable
					Network.touchLog += " [add to stack] "+touch.position.x+" "+touch.position.y
					Stack.create overSpot.object, this
				
			touch.user.selectedObject = this
			// if touchId == 3 && backImage: side = side == Front ? Back : Front
			currentTouch = null
			touch.markAsHandled
		
	private checkBoardsWhileMoving: Touch touch
		Vector2 pos = position
		if board
			pos = position * board.matrix
		Board overBoard = null
		for framework.objects
			if type == Board
				Board b = cast o
				if pos >= b.position - b.size/2 && pos < b.position + b.size/2
					overBoard = b
					break
					
		if overBoard != board
			if board: board.objects.remove this;    position = position * board.matrix; touchOffset = touchOffset * board.matrix.scaleVector
			else      framework.objects.remove this
			board = overBoard
			if board: board.objects.add this;       position = position / board.matrix; touchOffset = touchOffset / board.matrix.scaleVector
			else      framework.objects.add this
					
	private getSpotAt: Vector2 position, Vector2 threshold
		Spot closestSpot = null
		float minDistance = int.maxValue
		for obj <- parentObjects if obj != this
			for spot -> obj.spots
				let delta = (obj.position + spot.pos - position).abs
				let distance = delta.length
				if delta < threshold && distance < minDistance
					minDistance = distance
					closestSpot = spot
			if closestSpot: return closestSpot
		return null
			
	draw
		if !image: return
		graphics.move position
			graphics.rotate angle
				if side == Front || !backImage: drawImage image, frame, scale
				else                            drawImage backImage, scale
				
	drawIcons
		if Input.users.any(selectedObject == this) && rotatable && !rotateTouch
			graphics.move position
				drawImage rotateIcon, image.size/2*{1,-1}*scale+{8, -8}
		
Object Stack
	private Object[] objects
	Side sideWhenRemoving = Front
	
	private int visibleObjects
	private Vector2 basePosition
	private int shownObjectCount
	
	stackable = true
	
	Stack: Vector2 position, Side side = Back
		// stackable = true
		// base position, stackable:true, side
		basePosition = position
	
	static create: Object a, Object b, Side side = Front
		Stack stack = {position:a.position, side:side}
		stack.add a
		stack.add b
						
	add: Object a
		a.side = side
		objects.add a
		framework.objects.remove a
		updatePositions
		
	private pop
		let topObject = objects.pop
		framework.objects.add topObject
		topObject.position += stackOffset
		topObject.side = sideWhenRemoving
		if objects.length == 0
			framework.objects.remove this
		else
			updatePositions
		return topObject
		
	private updatePositions
		if objects.length == 0: return
		shownObjectCount = Math.min(3, objects.length)
		// spots[0].pos = stackOffset * (shownObjectCount + 1)
		// int offsetStartIndex = cast Math.max(0, objects.length-3)
		// for objects: object.position = position + stackOffset * Math.max(0, i-offsetStartIndex)
		position = basePosition + (shownObjectCount-1)/2 * stackOffset
		for shownObjectCount: objects[objects.length-shownObjectCount+i].position = basePosition + i * stackOffset
			
		let a = objects[objects.length-shownObjectCount]
		let b = objects[objects.length-1]
		size = (b.position+{b.size.x/2, -b.image.size.y/2}) - (a.position-{a.size.x/2, -a.size.y/2})
		// size = (topObject.image.size * topObject.scale) + (shownObjectCount-1)*stackOffset.abs
	
	draw
		for i = (objects.length-shownObjectCount) -> objects.length: objects[i].draw
	
	tick
		Input.onTouchDownWithin position, size
			let obj = pop
			obj.currentTouch = touch
			obj.touchOffset = obj.position - touch.position
			touch.markAsHandled
	
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
	
	private Touch currentTouch = null
	private Matrix2D downMatrix
	static zoomLookupTable = [
		0.9608086423320881,0.96176945097442,0.9627312204253944,0.9636939516458196,0.9646576455974654,0.9656223032430628,0.9665879255463057,0.9675545134718518,0.9685220679853236,0.9694905900533088,0.9704600806433621,0.9714305407240054,0.9724019712647292,0.9733743732359939,0.9743477476092297,0.9753220953568389,0.9762974174521956,0.9772737148696476,0.9782509885845172,0.9792292395731016,
		0.9802084688126746,0.9811886772814872,0.9821698659587685,0.9831520358247272,0.9841351878605519,0.9851193230484123,0.9861044423714606,0.9870905468138319,0.9880776373606457,0.9890657149980062,0.9900547807130041,0.991044835493717,0.9920358803292106,0.9930279162095397,0.9940209441257492,0.9950149650698747,0.9960099800349446,0.9970059900149794,0.9980029960049942,0.9990009990009991,
		1,1.001,1.0020009999999997,1.0030030009999997,1.0040060040009995,1.0050100100050003,1.0060150200150053,1.0070210350350202,1.0080280560700552,1.009036084126125,1.0100451202102512,1.0110551653304611,1.0120662204957915,1.0130782867162873,1.0140913650030035,1.0151054563680064,1.0161205618243743,1.0171366823861985,1.0181538190685846,1.0191719728876532,
		1.0201911448605405,1.021211336005401,1.0222325473414062,1.0232547798887477,1.0242780346686362,1.0253023127033047,1.0263276150160079,1.0273539426310239,1.0283812965736547,1.0294096778702282,1.0304390875480984,1.0314695266356464,1.032500996162282,1.033533497158444,1.0345670306556025,1.0356015976862578,1.036637199283944,1.0376738364832279,1.038711510319711,1.0397502218300305
	]
	Board: Vector2 size
		this.size = size
		
	add: Object object
		objects.add object
		object.board = this
		framework.objects.remove object
		
	tick
		graphics.multiply matrix
			for <- objects: tick
			
		if panable	
			Input.onTouchDownWithin position, size
				currentTouch = touch
				downMatrix = matrix
			Input.onTouchMove currentTouch
				matrix = downMatrix
				matrix.move touch.position - currentTouch.position
			Input.onTouchUp currentTouch
				currentTouch = null
				
		if zoomable	
			Input.onWheelWithin position, size
				float factor = zoomLookupTable[Math.limit delta+40 min:0 max:zoomLookupTable.length-1]
				Network.touchLog += "[{Network.logicFrame}] zoom value:{delta} factor:{factor} matrix:{matrix}"
				matrix.move position
				matrix.scale {factor, factor}
				matrix.move position*{-1,-1}
				Network.touchLog += " -> {matrix}"
			
	draw
		if color: drawRectangle position, size, fill:color
		graphics.visibleFor visibleForOthers == Never or visibleForOthers == Off ? owner : -1
			graphics.multiply matrix
				for objects: draw
				
	tickIcons
		graphics.multiply matrix
			for objects: tickIcons
		Input.onTouchDownWithin position+{size.x/2-32, -size.y/2+32}, size:{50,50}, userId:owner
			visibleForOthers = visibleForOthers == On ? Off : On
			
	drawIcons
		graphics.multiply matrix
			for objects: drawIcons
		Vector2 iconPos = position+{size.x/2-32, -size.y/2+32}
		if visibleForOthers == Off: drawButton hiddenIcon,  position:iconPos; else
		if visibleForOthers == On:  drawButton visibleIcon, position:iconPos

Object RectangleObject
	Color color = White
	Vector2 size
	RectangleObject: Vector2 position, Vector2 size, Color color
	draw
		drawRectangle position, size, color
	
				
struct Particle
	Vector2 pos, speed
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

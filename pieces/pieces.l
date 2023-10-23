unit Framework
	isVisibleFor: Vector2 pos, Player player
		let board = getBoardAt pos, player
		return !board or board.isVisibleFor player
			
	getBoardAt: Vector2 pos, Player player
		for Framework.objects -> object
			if object is Board
				Board b = cast object
				if (b.visibleFor == null or b.visibleFor.any.id == player.id)
				and pos >= b.position - b.size/2 and pos < b.position + b.size/2
					return b
		return null
		
	deselectAndFinishTouches
		selectedObjects.clear
		for objects
			if . is Piece
				Piece piece = cast .
				piece.finishTouch
	
Object Piece
	const Vector2 stackOffset = {8,8}
	// const minSize = 75 // EVAL
	
	Image image // The image of the piece
	Angle angle // The rotation of the piece in turns (one full rotation is 1)
	
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
	private Angle rotateOffset
	private Angle targetAngle
	private bool rotatedOverThreshold
	
	Vector2 iconPos = Vector2.none
	Vector2 touchMargin = {50,50}
	
	public Board board
	private Player interactingPlayer
	
	private siblings := board ? board.objects : Framework.objects
	onBoardChanged
		
	// Snap
	visible Vector2 snappedAt = Vector2.none
	onSnap
	onUnsnap
	onRotate
	onDrop
	
	Piece
		if image and size == {0,0}
			size = image.size
			// EVAL
			// if size.x < minSize: size.x = minSize
			// if size.y < minSize: size.y = minSize
		this.targetAngle = angle
		
	debugString := "(Piece pos:{position.x} {position.y} frame:{frame} side:{side} image:{image?.file} board:{board.toBool})"
	
	finishTouch
		rotateTouch = null
		if moveTouch: moveTouch = null; onDrop
		
	override tick
		// Complete size if one or both components aren't specified
		if image
			if size.x == 0: size.x = image.size.x; size.y = image.size.y; else
			if size.y == 0: size.y = size.x * image.size.y / image.size.x;
				
		// Rotate	
		Vector2 iconPos = this.iconPos ? this.iconPos : (rotatable ? {(size.x+size.y)*.29, (size.x+size.y)*.29}*{1,-1} : size/2*{1,-1})
		if rotatable and Framework.selectedObjects.contains(this)
			onTouchDownWithin position:position+iconPos, size:Image.rotateIcon.size+touchMargin, by:visibleFor
				rotateTouch = touch
				rotateOffset = angle - math.getAngleForVector(touch.position - position)
				rotatedOverThreshold = false
				
			onTouchMove rotateTouch
				core.smooth touch.by
					angle = targetAngle = math.getAngleForVector(touch.position - position) + rotateOffset
				if (touch.position - touch.startPosition).length > 16: rotatedOverThreshold = true
				
			onTouchUp rotateTouch
				targetAngle = math.round(angle / .25) * .25
				rotateTouch = null
				if !rotatedOverThreshold: targetAngle += .25
				interactingPlayer = touch.by
				if angle == targetAngle: onRotate
		
		// Move
		onTouchDownWithin position, size, angle, by:visibleFor
			if movable
				moveTouch = touch
				touchOffset = position - touch.position
				siblings.moveToFront this
				isBeingMoved = false
			
		onTouchMove moveTouch
			core.smooth moveTouch.by
				position = touch.position + touchOffset
				if touch.position - touch.startPosition > 8: isBeingMoved = true
				if board: board.snap this, touch.position
				checkBoardsWhileMoving touch
							
		onTouchUp moveTouch
			Framework.selectedObjects[touch.by.id] = this
			moveTouch = null
			onDrop
		
		// Flip	
		if Framework.selectedObjects.contains(this) && flipable
			drawButton flipIcon, position:position+iconPos*{-1,1}, touchMargin:{50,50}
				side = side == Back ? Front : Back
		
		// Animate rotation
		if angle != targetAngle
			core.smooth interactingPlayer
				angle = math.moveTowards(angle, targetAngle, .03)
				if angle == targetAngle: onRotate
		
		// Draw rotation icon
		if rotatable and Framework.selectedObjects.contains(this) and not (rotateTouch and rotatedOverThreshold)
			drawImage rotateIcon, position:position+iconPos, layer:10000, visibleFor
		
		draw
				
	draw
		if image
			if side == Front || !backImage: drawImage image, position, size, frame:frame%image.frames.length, angle, location
			else                            drawImage backImage, position, size, frame:frame%backImage.frames.length, angle, location
		
	private checkBoardsWhileMoving: Touch touch
		Vector2 pos = position
		if board: pos = position * board.matrix
		let nextBoard = Framework.getBoardAt pos, touch.by
		if nextBoard != board
			delay
				if board: board.objects.remove this; position = position * board.matrix; touchOffset = touchOffset * board.matrix.scaleVector
				else      Framework.objects.remove this
				board = nextBoard
				if board: board.objects.insert this; position = position / board.matrix; touchOffset = touchOffset / board.matrix.scaleVector
				else      Framework.objects.insert this
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
		Framework.objects.insert topObject
		topObject.position += stackOffset
		topObject.side = sideWhenRemoving
		if objects.length == 0: Framework.objects.remove this
		else                    updatePositions
		return topObject
		
	private updatePositions
		if objects.length == 0: return
		shownObjectCount = math.min(3, objects.length)
		position = basePosition + (shownObjectCount-1)/2 * stackOffset
		for shownObjectCount: objects[objects.length-shownObjectCount+i].position = basePosition + i * stackOffset
			
		let a = objects[objects.length-shownObjectCount]
		let b = objects[objects.length-1]
		size = (b.position+{b.size.x/2, b.image.size.y/2}) - (a.position-{a.size.x/2, a.size.y/2})
	
	override tick
		for math.limit(objects.length-shownObjectCount, min:0) to objects.length <- i
			let obj = objects[i]
			let image = obj.backImage || obj.image
			drawImage image, obj.position, frame:obj.frame%image.frames.length, size:obj.size
			
		// We pop after drawing, because the newly created card won't be drawn until the next frame
		// and we don't want to draw the new, smaller stack without drawing the popped card as well
		onTouchDownWithin position, size
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
	BoardVisiblity contentVisibleForOthers = Always
	Player owner
	bool panable
	bool zoomable
	
	private Touch panTouch
	private Matrix2D downMatrix
	
	const zoomLookupTable = [
		0.9608086423320881,0.96176945097442,0.9627312204253944,0.9636939516458196,0.9646576455974654,0.9656223032430628,0.9665879255463057,0.9675545134718518,0.9685220679853236,0.9694905900533088,0.9704600806433621,0.9714305407240054,0.9724019712647292,0.9733743732359939,0.9743477476092297,0.9753220953568389,0.9762974174521956,0.9772737148696476,0.9782509885845172,0.9792292395731016,
		0.9802084688126746,0.9811886772814872,0.9821698659587685,0.9831520358247272,0.9841351878605519,0.9851193230484123,0.9861044423714606,0.9870905468138319,0.9880776373606457,0.9890657149980062,0.9900547807130041,0.991044835493717,0.9920358803292106,0.9930279162095397,0.9940209441257492,0.9950149650698747,0.9960099800349446,0.9970059900149794,0.9980029960049942,0.9990009990009991,
		1,1.001,1.0020009999999997,1.0030030009999997,1.0040060040009995,1.0050100100050003,1.0060150200150053,1.0070210350350202,1.0080280560700552,1.009036084126125,1.0100451202102512,1.0110551653304611,1.0120662204957915,1.0130782867162873,1.0140913650030035,1.0151054563680064,1.0161205618243743,1.0171366823861985,1.0181538190685846,1.0191719728876532,
		1.0201911448605405,1.021211336005401,1.0222325473414062,1.0232547798887477,1.0242780346686362,1.0253023127033047,1.0263276150160079,1.0273539426310239,1.0283812965736547,1.0294096778702282,1.0304390875480984,1.0314695266356464,1.032500996162282,1.033533497158444,1.0345670306556025,1.0356015976862578,1.036637199283944,1.0376738364832279,1.038711510319711,1.0397502218300305
	]
		
	debugString
		string children
		for objects: children += .debugString
		return "(Board pos:{position.x} {position.y} children:{children})"
		
	finishTouch
		for objects
			if . is Piece
				Piece piece = cast .
				piece.finishTouch
						
	add: Piece object
		objects.add object
		object.board = this
		Framework.objects.remove object
		
	isVisibleFor: Player player
		return contentVisibleForOthers == Always or contentVisibleForOthers == On or owner.id == player.id
		
	override tick
		// Children
		graphics.visibleFor contentVisibleForOthers == Never or contentVisibleForOthers == Off ? owner : null
			graphics.applyMatrix matrix
				objects.eachChangable.tick
		
		// Pan
		if panable	
			onTouchDownWithin position, size, by:visibleFor
				panTouch = touch
				downMatrix = matrix
			onTouchMove panTouch
				matrix = downMatrix
				matrix.move touch.position - touch.startPosition
			onTouchUp panTouch
				panTouch = null
				Framework.deselect touch.by
				
		// Zoom
		if zoomable	
			onScrolllWithin position, size, by:visibleFor
				float factor = zoomLookupTable[math.limit math.round(event.delta.y)+40, min:0, max:zoomLookupTable.length-1]
				if core.logging: core.touchLog += "[{core.frame}] zoom value:{event.delta} factor:{factor} matrix:{matrix}"
				matrix.move event.position
				matrix.scale {factor, factor}
				matrix.move event.position*{-1,-1}
				if core.logging: core.touchLog += " -> {matrix}"
			
		// Visiblity icon
		if contentVisibleForOthers == On or contentVisibleForOthers == Off
			Image icon =  contentVisibleForOthers == On ? visibleIcon : hiddenIcon
			drawButton icon, position:position+{size.x/2-32, -size.y/2+32}, touchableBy:owner
				contentVisibleForOthers = contentVisibleForOthers == On ? Off : On
				
		if color: drawRectangle position, size, color:color, layer:-1, visibleFor
		if image: drawImage image, position, size
		
	snap: Piece currentObject, Vector2 position
		
Board SmartBoard
	Grid<Piece> grid = {{8, 8}}
	Vector2 cellSize = {150, 150}

	Vector2[] getValidPositions: Piece currentObject
		return []
			
	snap: Piece currentObject, Vector2 position
		Vector2 closestSpotPos = Vector2.none
		float minDistance = int.maxValue
		let positions = getValidPositions currentObject
		
		let snapToPosition = (positions.withMin (. - position).length, cellSize.length) or Vector2.none
			currentObject.position = snapToPosition
			
		if snapToPosition != currentObject.snappedAt
			if currentObject.snappedAt
				grid[(currentObject.snappedAt/cellSize).rounded] = null
				currentObject.onUnsnap
				
			currentObject.snappedAt = snapToPosition
				
			if snapToPosition
				grid[(snapToPosition/cellSize).rounded] = currentObject
				currentObject.onSnap
				
		
Board SpotBoard
	threshold = 100
	private Spot[] spots
	private Spot overSpot
	
	addSpot: Spot spot
		spots.add spot
	
	snap: Piece currentObject, Vector2 position
		Vector2 closestSpotPos = Vector2.none
		float minDistance = int.maxValue
		for spots -> spot
			let spotPos = spot.getClosestPoint position, this.position
			let delta = (spotPos - position).abs
			let distance = delta.length
			if delta < threshold and distance < minDistance
				minDistance = distance
				closestSpotPos = spotPos
				while objects.find.position == closestSpotPos and . != currentObject
					closestSpotPos += {6,10}
					
		if closestSpotPos
			currentObject.position = closestSpotPos
		
class Spot
	Vector2 pos
	getClosestPoint(Vector2 touchPos, Vector2 boardPos) := pos + boardPos
	
Spot SpotGrid
	Vector2 cellSize
	getClosestPoint: Vector2 touchPos, Vector2 boardPos
		return ((touchPos-boardPos)/cellSize).rounded*cellSize + boardPos
		
Spot SpotHexGrid
	Vector2 cellSize
	getClosestPoint: Vector2 touchPos, Vector2 boardPos
		let cellX = ((touchPos.x-boardPos.x)/cellSize.x).round
		let x = cellX * cellSize.x + boardPos.x
		let a = cellX%2 == 0 ? cellSize.y/2 : 0
		let cellY = ((touchPos.y-boardPos.y-a)/cellSize.y).round
		let y = cellY * cellSize.y + boardPos.y+a
		return Vector2(x, y)
		
enum closestCoinType: None, Neighbor, Over
Piece Coin
	const Color darkColor = {"#642C00"}
	const Color lightColor = {"#F7C947"}
	
	int value
	bool isInfinate
	bool allowZero
	Player valueVisibleFor
	Player owner
	Vector2 transferNeighborOffset = {45,58}
	image = Coin
	
	private Coin closestCoin
	private closestCoinType closestCoinType
	private float distanceToClosest
	
	debugString := "(Coin {value} pos:{position.x} {position.y} dis:{distanceToClosest})"
	
	override tick
		if movable
			onTouchDownWithin position, radius:40, by:owner
				moveTouch = touch
				touchOffset = position - touch.position
				siblings.moveToFront this
				isBeingMoved = false
			
			onTouchMove moveTouch
				core.smooth touch.by
					position = touch.position + touchOffset
				if touch.position - touch.startPosition > 8: isBeingMoved = true
				updateNeighbors siblings, isBeingMoved
				checkBoardsWhileMoving touch
			
			onTouchUp moveTouch
				Framework.selectedObjects[touch.by.id] = this
				moveTouch = null
				
				if closestCoinType == Over: mergeWith closestCoin; else
				if !isBeingMoved:           transferToNeighbor closestCoin
		else
			onTouchUpWithin position, radius:64, by:owner
				transferToNeighbor closestCoin
			
		if isInfinate or value or allowZero
			if closestCoinType == Neighbor 
				drawCircle (position + closestCoin.position)/2, size:12, color:darkColor, outlineColor:lightColor, outlineWidth:5
			if !isInfinate
				if value < 10:  drawText cast value, position+{0, -4}, color:darkColor, size:42, style:Bold, font:ShadowedSerif, visibleFor:valueVisibleFor; else
				if value < 100: drawText cast value, position+{0, -4}, color:darkColor, size:30, style:Bold, font:ShadowedSerif, visibleFor:valueVisibleFor; else
				                drawText cast value, position+{0, -4}, color:darkColor, size:22, style:Bold, font:ShadowedSerif, visibleFor:valueVisibleFor;
			
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
		removeImmediately
		updateNeighbors siblings, isBeingMoved:false
	
	private transferToNeighbor: Coin coin, int amount = 1
		if !isInfinate and value - amount < 0: return
		Coin neighbor = coin
		if !neighbor
			if value <= amount and !isInfinate: return
			neighbor = {position:position+transferNeighborOffset, image:image}
			if board: board.add neighbor
			neighbor.moveToFront
		value -= amount
		neighbor.value += amount
		if !isInfinate and !allowZero and value <= 0: removeImmediately
		updateNeighbors siblings, isBeingMoved:false


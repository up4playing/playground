This is an example of a game written in LiveTime:
```
app
	// Member variable syntax: <type> <name>
	int round
	// Lists
	const string[] words = ["Example", "Word"]
	IntVector2 boardSize = {3,3}
	// 2 dimensinal list (3x3)
	int[][] board = [[0,0,0],[0,0,0],[0,0,0]]
	ExamplePhase phase
	ExamplePlayer[] players
	ExamplePlayer currentPlayer
	ExampleBox[] boxes
	ExampleItem[] items
	Grid<ExampleItem> grid
	
	// Method syntax: <return type> <method name>: <parameters>
	int[] getNumbers: int start, int end
		int[] list
		// For loop with numbers syntax: for <inclusive start> to <exclusive end>
		// Use . to access the iteration variable
		for start to end
			if . % 2 == 0: list.add .
		return list
		
		// The following example prints: 0 1 2
		for 0 to 3
			print . + " "
		
		// The following example prints: 1 2 3
		for [1,2,3]
			print . + " "
		
	int getSum: int[] list
		int sum
		// For loop with lists syntax: for <list>
		// Use . to access the iteration variable (the current item in the list)
		for list
			sum += .
		return sum
		
	resetBoard
		// For loop with named iteration variable syntax: for <list> -> <iteration variable name>
		for boardSize.x -> x
			for boardSize.y -> y
				board[x][y] = 0
				
	getNeighbors: IntVector2 position
		ExampleItem[] neighbors = []
		for Direction.primaryDirections
			IntVector2 pos = position + .vector
			let item = grid[pos]
			if item: neighbors.add item
		return neighbors
				
	lambdaExample: ExamplePlayer winner, int targetScore
		// List have an "any" method that accepts a lambda predicate
		// Use . to access the current item in the lambda
		let isAnyPlayerTheWinner = players.any . == winner
		
		// Use .<field> to access fields of the current item in lambda
		let haveAllPlayersTheTargetScore = players.all.score == targetScore
		
		// When you want to chain multiple calls, you have to use parenthesis
		let totalScoreOfAlivePlayer = players.where(.alive).total.score
				
	getWinner
		return players.withMax.score
	
	init
		Platform.userCount = 4
		
	start
		Menu()
		statistics.setup {0, 460}, {850,150}
		
		// Create players
		for Input.users
			players.add {id:.id, index:.index}
		startGame
		
	startGame
		for Direction.diagonalDirections
			boxes.add {rect:{position:{220,280}*.vector, size:{420,440}}}
			
		nextRound
		
	nextRound
		round++
		boxes.each.itemInBox = null
		words.shuffle
		items.clear
			
	tick
		items.each.tick
		boxes.each.tick
		players.each.tick
		
		// If all items are dropped into boxes, show "Next Round button"
		if items.all.droppedInBox != null
			drawButton image:Button, text:"Next Round", position:{0,0}, visibleFor:currentPlayer.id
				nextRound
		
ExampleItem
	const Vector2 size = {300,60}
	bool moveable = true
	Vector2 position, originalPosition
	Touch moveTouch
	Vector2 touchOffset
	ExampleBox droppedInBox
	string word
	
	tick
		if moveable
			// Drag items
			Input.onTouchDown position, size, userId:exampleApp.currentPlayer.id
				// Start dragging item
				moveTouch = .
				originalPosition = position
				touchOffset = position - .position
				if droppedInBox
					droppedInBox.itemInBox = null
					droppedInBox = null
					
			Input.onTouchMove moveTouch
				// Drag item
				position = .position + touchOffset
				
			Input.onTouchUp moveTouch
				// Drop item
				let droppedInBox = exampleApp.boxes.find.rect.contains position
				if droppedInBox and droppedInBox.itemInBox == null
					this.droppedInBox = droppedInBox
					droppedInBox.itemInBox = this
					position = droppedInBox.rect.position
				else
					// Box is full, revert to original position
					position = originalPosition
				moveTouch = null
		
		// Draw red text in the foreground
		drawText word, position, size:40, font:OpenSans, color:{"ff0000"}
		
		// Draw blue circle with a radius of 200 with a red outline
		drawCircle position, size:400, fillColor:{"0000ff"}, outlineColor:{"ff0000"}, outlineWidth:5

enum ExamplePhase: EnterClue, Guess, Score, Reveal
		
ExampleBox
	Rect rect
	ExampleItem itemInBox
	tick
		// Draw blue box with white outline
		drawRectangle rect.position, rect.size, fillColor:{"0000ff"}, outlineColor:{"ffffff"}, outlineWidth:5
		
ExamplePlayer
	int id, index
	int score
	bool alive
	string name
	
	visible Color playerColor = graphics.defaultColors[index]
	visible Direction dir = Direction.diagonalDirections[index]
	visible Vector2 videoPos = dir.vector * {700,270}
	
	tick
		// Draw round video of player with cirlce outline
		const radius = 220
		drawVideo id, videoPos, size:radius*2, shape:Circle
		drawCircle videoPos, size:radius*2+50, outlineColor:playerColor, outlineWidth:12

// The LiveTime API		
unit Math
	int randomInteger: int min, int max
	float randomFloat
	float min: float a, float b
	float max: float a, float b
	float map: float value, float fromStart = 0, float fromEnd = 1, float toStart = 0, float toEnd = 1

class List<T>
	void insert: T item, index = 0
	void remove: T item
	void removeAt: int index
	void removeRange: int index, int count
	T removeFirstWhere: bool(T a) condition
	removeWhere: bool(T a) condition
	ensure: T item // The item to add
	addRange: T[] items
	bool contains: T item
	int indexOf: T item
	setList: T[] list
	setFilteredList: T[] list, bool(T a) condition
	T pop
	T popAt: int index
	T[] popRange: int index, int count
	T popWhere: bool(T a) condition
	T popFront
	int length
	int setLength: int value
	clear
	T[] clone
	string toString()
	T random
	T popRandom
	T next: T currentItem
	T prev: T currentItem
	T[] reverse
	T[] distinct
	T moveToBack: T item
	T moveToFront: T item
	T[] orderBy: float(T a) expression
	T[] orderBy: float(T it) expression, label nocolon float(T it) thenBy
	T[] orderBy: float(T a) expression, SortingOrder order
	bool any: bool(T a) predicate
	bool none: bool(T a) predicate
	bool all: bool(T a) predicate
	TValue[] select: TValue(T it) selector
	T find: bool(T a) condition
	int indexWhere: bool(T a) condition
	T[] where: bool(T a) condition
	T[] take: int count
	int total: int(T it) selector
	int sum
	float average
	string joinToString: string(T a) selector, string separator = ", "
	shuffle
	T percentile: int value
	T min: float(T a) selector, float threshold = float.maxValue, float default = 0, label bool(T a) where
	T max: float(T a) selector, float threshold = float.minValue, float default = 0, label bool(T a) where
	minIndex: float(T a) selector, float threshold = float.maxValue
	maxIndex: float(T a) selector, float threshold = float.minValue
	withMin: float(T a) selector, float threshold = float.maxValue, label bool(T a) where
	withMax: float(T a) selector, float threshold = float.minValue, label bool(T a) where
	popMax: float(T a) selector
	count: bool(T a) predicate
	countNot: bool(T a) predicate
	rotate
	T[] intersectWith: T[] other

unit graphics
	void drawImage: Image image, Vector2 position, frame = 0, Vector2 size = {}, clickableMargin = Vector2(16,16), visibleFor = -1, clickableBy = -1, hotkey = Key.None, layer = 0, alpha = 1.0, void(Touch touch) onClick
	void drawText: string text, Vector2 position = {}, implicit Vector2 size = {}, Color color = null, HorizontalAlignment align = , VerticalAlignment valign = Middle, FontStyle style = Normal, Font font = null, Color outlineColor = null, outlineWidth = 0, visibleFor = -1, implicit layer = 0, alpha = 1.0
	void drawButton: Image image = null, text = "", Vector2 position = {}, Color textColor = null, frame = 0, implicit Vector2 size = {}, fontSize = 18, clickableMargin = Vector2(16,16), textOffset = Vector2(0,0), showClickableArea = false, visibleFor = -1, implicit layer = 0, alpha = 1.0, void(Touch touch) onClic
	void drawRectangle: position = Vector2(), implicit size = Vector2(256,256), Color fillColor = null, Color outlineColor = null, outlineWidth = 0, visibleFor = -1, implicit layer = 0, alpha = 1.0, HorizontalAlignment align = Center, VerticalAlignment valign = Middle
	void drawCircle: position = Vector2(), implicit Vector2 size = {256,256}, Color fillColor = null, Color outlineColor = null, outlineWidth = 0, Angle startAngle = 0.0, Angle endAngle = 1.0, RotationDirection direction = Clockwise, visibleFor = -1, implicit layer = 0, alpha = 1.0
	void drawPolygon: Vector2[] points, Vector2 position = {0,0}, Color fillColor = null, Color outlineColor = null, outlineWidth = 0, smooth = false, visibleFor = -1, implicit int layer = 0, alpha = 1.0

struct Direction
	global const Direction Front, Right, Back, Left, Up, Down, FrontRight, BackRight, BackLeft, FrontLeft
	const Direction[] primaryDirections = [Front, Right, Back, Left]
	const Direction[] diagonalDirections = [FrontRight, BackRight, BackLeft, FrontLeft]
	const Direction[] allDirections = [Front, FrontRight, Right, BackRight, Back, BackLeft, Left, FrontLeft]
	string name
	int index
	IntVector3 vector
	Angle angle
	Quaternion quaternion
```	
Please change the following game written in LiveTime and output the changes in the git diff format so that: 
when setting up the level, no two tiles are next to each other.
```
app
	const int tilesInPalette = 2
	
	Worker[] workers
	Grid<Tile> tiles = {size:{10,10}}
	Tile[] possibleTiles = [LowerStraight, LowerCurve, Stairs, UpperStraight, UpperCurve]
	Tile[] palette
	
	start
		for tilesInPalette: palette.add null
		refillPalette
		setupLevel
		
	setupLevel
		IntVector2[] possiblePosition
		for tiles.size: possiblePosition.add .
		possiblePosition.shuffle
		for 10
			// let pos = possiblePosition.pop
			IntVector2 pos
			do pos = possiblePosition.pop
			while (tiles[pos + {1, 0}] or tiles[pos + {-1, 0}] or tiles[pos + {0, 1}] or tiles[pos + {0, -1}]) and possiblePosition.length > 0
			let tile = tiles[pos] = clone possibleTiles.random
			..position = pos
			..gems = [{tile}]
			
	tick
		for tiles.size
			drawModel Floor, position:.
		tiles.each.tick
		workers.each.tick
		forChangeable palette .tick
		
	refillPalette
		for tilesInPalette
			if not palette[.]
				let tile = palette[.] = clone possibleTiles.random
				tile.position = {-1.5, 0, i*1.5}
				
Gem
	Tile tile
	tick
		drawModel Gem, {tile.position.x, tile.startLevel, tile.position.z}

Tile
	const rotationSpeed = 1
	const Vector3 size = {1,3,1}
	Vector3 position
	Gem[] gems
	
	visible int index
	visible int startLevel, endLevel
	
	private Touch moveTouch
	private bool hasMoved
	private float angle, targetAngle
	private Vector3 originalPosition
	private Quaternion rotation
	
	tick
		Input.onTouchDown position, size
			moveTouch = .
			originalPosition = position
			hasMoved = false
		Input.onTouchMove moveTouch
			position = .position
			if (position distanceTo .startPosition) > .25: hasMoved = true
		Input.onTouchUp moveTouch
			moveTouch = null
			if not hasMoved
				position = originalPosition
				targetAngle += .25
			else
				position = position.rounded
				IntVector2 gridPos = {cast position.x, cast position.z}
				if app.tiles.isValid(gridPos)
					app.tiles[gridPos] = this
					let index = app.palette.indexOf(this)
					if index != -1
						app.palette[index] = null
						app.refillPalette
				else
					position = originalPosition
					
		angle moveTowards targetAngle, speed:rotationSpeed*Time.deltaTime
		drawModel Tile[index], position, Quaternion.Euler(0,angle*360,0)
		gems.each.tick

Tile LowerStraight: index = 0; startLevel = 0; endLevel = 0
Tile LowerCurve:    index = 1; startLevel = 0; endLevel = 0
Tile Stairs:        index = 2; startLevel = 0; endLevel = 1
Tile UpperStraight: index = 3; startLevel = 1; endLevel = 1
Tile UpperCurve:    index = 4; startLevel = 1; endLevel = 1
	
Player
	tick
	
Worker
	Vector3 position
	tick
		drawModel Guy, position, animation:Idle, rotation:Direction.Right
```

# We use the LiveTime programming language. LiveTime uses indentation with tabs to indicate a block of code. Always use tabs for indentation, never spaces.
# Example app implementing the board game "Go" in the LiveTime programming language

enum Phase: PlacePiece, GameOver

app
	// In LiveTime, the total screen size is always {1920, 1080}
	// The background is black by default
	// We need to display the player video at the left and right side of the screen
	// That leave a usable area of {700,700} in the middle of the screen
	const Vector2 totalBoardSize = {700,700}
	const IntVector2 cellCount = {9,9}
	
	// We use a two dimensional grid of Cell for the cells of the game board
	// We can later access the individual cells with cell[x,y]
	Grid<Cell> cells = {size:cellCount}
	
	Player currentPlayer
	Phase phase = PlacePiece
	
	// This defines the function "start" of the class "app". All functions need to part of a class.
	// There are no top-level functions in LiveTime.
	// The "start" function is called when the game starts
	start
		graphics.drawingOrder = ItemsDrawnFirstWillBeInTheBack

		// We always need to display the standard menu
		Menu()
		
		// Create empty grid cells
		for cellCount.x as x
			for cellCount.y as y
				cells[x,y] = Cell(player:null)
		
		// In LiveTime, the global variable "players" always contains a list of players
		// We pick a random player as the start player
		currentPlayer = players.random
		
		// If you divide an integer by an integer in LiveTime, you always get a float
		float fraction = 1 / 2
		
		// If you divide an IntVector2 (interger vector) by a value, you always get a Vector2 (float vector)
		IntVector2 gridPos = {0,0}
		Vector2 startPos = gridPos / 2
		
		// Use "rounded" to round an integer vector (IntVector2) to a float vector (Vector2)
		Direction dir = Up
		IntVector2 centerGridPos = (startPos - dir.vector * (cellCount.x - 1) / 2).rounded
		
		// Use a "for" loop to iterate over a list
		// Use "." to get the current item while iterating
		// Use "i" to get the index of the current item while iterating
		// In LiveTime, each player always has an "index", a "color" and a "score" by default.
		for players
			print "The Player with the index {i} has the color {.color} and the score {.score}"

		// In a for loop, we can also specify the lower inclusiv bound and the upper exclusive bound. This will iterate from 0 to 7:
		for 0 to 8 as i
			print i

		// In a for loop, the lower bound is 0 by default, and the current index is named "i" by default, so we can leave them out. This will iterate from 0 to 7:
		for 8
			print i

		// This iterates from -1 (inclusive) to 2 (exclusiv), so it prints -1, 0, 1,
		for -1 to 2
			print "{i}, "

		// We can slice a list like this
		Player[] theFirstTwoPlayers = players[..2]
		Player[] theLastThreePlayers = players[-3..]
		
		// We can order a list like this
		Player[] playersOrderedByScore = players.orderBy.score

		// If you need a IntVector2, you need to declare the type, otherwise you will get a IntVector2
		IntVector2 originGridPos = {0,0}

		// Vector2 and IntVector2 are structs and therefore value types, so they can't be null. But you can set them to Vector2.none or IntVector2.none
		IntVector2 currentGridPos = IntVector2.none

		phase = PlacePiece
		
	// The "tick" function is called on every frame (30 times per second)
	tick
		// In LiveTime, the center of the screen has the coordinates {0,0}
		// The x-coordinate ranges from -960 to 960
		// The y-coordinate ranges from -540 to 540
		// So the top-left corner is {-960,-540}, the bottom-right corner is {960,540}
		Vector2 cellSize = totalBoardSize / (cellCount-{1,1})
		Vector2 cellOffset = totalBoardSize / -2
		for cellCount.x as x
			for cellCount.y as y
				IntVector2 gridPos = {x,y}
				Vector2 pixelPos = cellOffset + gridPos * cellSize
				Cell cell = cells[gridPos]
				
				if cell.player
					// Draw a circle in the player's color
					// The background is black in LiveTime, so we need to make sure we use colors that are different from black.
					drawCircle pixelPos, size:60, color:cell.player.color
					drawText "{cell.liberties}", pixelPos, size:30					
				else
					drawCircle pixelPos, size:8
					
					// When the current player clicks on an empty cell, place a piece
					// We use "by:currentPlayer" to only consider touches by the current player
					onTouchDown position:pixelPos by:currentPlayer size:cellSize
						placePiece gridPos, cell, player:currentPlayer
		
		// Call the tick function for each player
		players.each.tick
		
	placePiece: IntVector2 gridPos, Cell cell, Player player
		watch "Player {player} places a piece at {gridPos}"
		cell.player = player
		captureSurroundedPieces gridPos, player
		
		// Set current player to the next player
		currentPlayer = players next currentPlayer
		
	captureSurroundedPieces: IntVector2 originPos, Player attacker
		for Direction.primaryDirections as dir
			IntVector2 neighborPos = originPos + dir.vector
			Cell neighborCell = cells[neighborPos]
			
			if neighborCell and neighborCell.player and neighborCell.player != attacker
				Cell[] surroundesCells = collectSurroundesCells neighborPos, attacker
				if surroundesCells
					watch "Player {attacker} captured {surroundesCells.length} cells"
					surroundesCells.each.player = null
		
	// We write the return type in front of the function.
	// The function collectSurroundesCells takes an integer vector and a player and returns a list of cells
	Cell[] collectSurroundesCells: IntVector2 originPos, Player attacker
		IntVector2[] queue = [ originPos ]
		Cell[] surroundedCells = [ cells[originPos] ]
		
		// For each player, set the visited variable to false
		cells.each.visited = false
		
		while queue
			IntVector2 pos = queue.pop
			Cell cell = cells[pos]
			surroundedCells.add cell
			cell.visited = true
			
			for Direction.primaryDirections as dir
				IntVector2 neighborPos = pos + dir.vector
				Cell neighborCell = cells[neighborPos]
				if neighborCell and not neighborCell.visited
					if neighborCell.player == null
						return []
					if neighborCell.player != attacker
						queue.add neighborPos
						
		return surroundedCells
		
	finishGame
		Player winner = players.withMax.score
		ParticleSystem(position:winner.pos)
		
class Cell
	Player player
	int liberties
	bool visited
		
class Player
	// In LiveTime, each player always has an "index", a "color" and a "score" by default. We don't need to declare them.

	Direction dir = Direction.horizontalDirections[index]
	Vector2 pos = dir.vector * {690,265}
		
	tick
		// In LiveTime, we always show a video feed for each player. Each LiveTime game need to contain this code.
		float radius = 255
		drawCircle pos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo me, pos, size:radius*2-75, shape:Circle
		
		// Draw the score
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = pos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText score, scorePos, size:31



---



# This is an another example game in the LiveTime programming language
enum Role: Offence, Defence
enum Phase: DragItems, Reveal, GameOver
		
app
	int round
	Player currentPlayer
	Phase phase
	
	init
		graphics.drawingOrder = ItemsDrawnFirstWillBeInTheBack
		
	// List of words
	const string[] words = ["Apple", "Banana", "Orange"]
	Box[] boxes
	Item[] items
		
	int[] getNumbers: int start, int end
		int[] list
		// For loop for numbers syntax: for <start> to <end>
		// Use . to access the current value
		for start to end
			if . % 2 == 0: list.add .
		return list
		
	// We write the return type in front of the function.
	// The function getSum takes a list of integers and returns an integer
	int getSum: int[] list
		int sum
		// Use . to access the current value
		for list
			sum += .
		return sum
		
	startGame
		for Direction.diagonalDirections
			boxes.add {rect:{position:{220,280}*.vector, size:{420,440}}}
		nextRound

		// When assigning an enum value to a variable, the enum name must be omitted
		// Write "phase = DrawItems" instead of "phase = Phase.DrawItems"
		phase = DragItems
		
	nextRound
		round++
		boxes.each.itemInBox = null
		words.shuffle
		items.clear
		
		Box[] top3OpenBoxes = boxes.where.isOpen | orderBy.rect.position.y | take 3
		
		string[] namesOfAlivePlayers = players.where.alive | orderBy.score | select.name

		// Create item for each word, center them at {0,10} with {400,0} pixels between them
		forPositions words, center:{0,10}, delta:{400,0}
			items.add {position:pos, word:.}
			
		// Make the next player the current player
		currentPlayer = players next currentPlayer
			
	tick
		items.each.tick
		boxes.each.tick
		players.each.tick
		
		switch phase
			DragItems
				// If all items are dropped into boxes, show "Next Round button"
				if items.all.droppedInBox != null
					drawButton "Next Round", image:Button, position:{0,0}, visibleFor:currentPlayer
						Player playerWhoClickedTheButton = touch.by
						phase = Reveal
						nextRound
			Reveal
				// Draw yellow text thats visible for everybody
				drawText "Reveal", size:32, Color("#ffff00"), visibleFor:everybody
				
			GameOver
				tickGameOver
				
				// Draw green text thats visible for everybody
				drawText "Game Over", size:32, Color("#00ff00"), visibleFor:everybody
				
	tickGameOver
		phase = GameOver
		
		Player offencePlayer = players.find.role == Offence
			print "Found offence player: {offencePlayer}"
		else
			print "No offence player"
		
		Player defencePlayer = players.find.role == Defence
			print "Found defence player: {defencePlayer}"
		else
			print "No defence player"
		
		// Order players by score
		players.orderBy.score order:Descending
		
		// Print name and score of first 2 players
		for 2
			Player player = players[.]
			print "{player.name}: {player.score}"
			
		// Create a list of all scores of all players
		int[] listOfScores = players.select.score
		
		// Are all players alive?
		bool areAllPlayersAlive = players.all.alive
		
		// Iterate players in reverse order and print player names
		for players backwards
			print .name
			
		// Create a list of all number between 10 and 100
		int[] numbers = for 10..100 .
		
		// Get players with even index and a score more than 3
		Player[] evenPlayers = players.where.index % 2 == 0 and .score > 3
		
		int totalScoreOfAlivePlayer = players.where.alive | total.score
		
		// Find player with highest score
		Player winner = players.withMax.score
		
		int maxScore = math.max players[0].score, players[1].score
		
		Player[] firstThreePlayers = players[..3]
		
		Player[] lastFourPlayers = players[-4..]
		
		Player[] top3Players = players.orderBy.score | take 3
		
		delay 1 seconds
			print "1 second later"
				
class Player
	bool alive
	Role role
	
	visible Direction dir = Direction.diagonalDirections[index]
	visible Vector2 videoPos = dir.vector * {700,270}
	
	tick
		// In LiveTime, we always show a video feed for each player. Each LiveTime game need to contain this code.
		float radius = 255
		drawCircle videoPos, size:radius*2, outlineColor:color, outlineWidth:12
		drawVideo me, videoPos, size:radius*2-75, shape:Circle
		
		// Draw the score
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		Vector2 scorePos = videoPos + math.getVectorForAngle(-45°)*radius
		drawCircle scorePos, color:Black, outlineColor:color, size:60
		drawText score, scorePos, size:31

		
		// Draw yellow player name that's visible the current player instance
		// When drawing the player's UI, we need to make sure it doesn't overlap with the board
		drawText name, size:32, Color("#ffff00"), visibleFor:me
	
class Item
	const Vector2 size = {300,60}
	bool moveable = true
	Vector2 position, originalPosition
	Touch moveTouch
	Vector2 touchOffset
	Box droppedInBox
	string word
	
	tick
		switch app.phase
			DragItems
				// The current player can drag item around with the mouse
				// Use "by:app.currentPlayer" to ensure only the current player can drag items
				onTouchDown position, size, by:app.currentPlayer
					// Start dragging item
					Player playerWhoClicked = touch.by
					moveTouch = .
					originalPosition = position
					touchOffset = position - .position
					if droppedInBox
						droppedInBox.itemInBox = null
						droppedInBox = null
						
				onTouchMove moveTouch
					// Drag item
					position = .position + touchOffset
					
				onTouchUp moveTouch
					// Drop item
					Box droppedInBox = app.boxes.find.rect.contains position
					if droppedInBox and droppedInBox.itemInBox == null
						this.droppedInBox = droppedInBox
						droppedInBox.itemInBox = this
						position = droppedInBox.rect.position
					else
						// Box is full, revert to original position
						position = originalPosition
					moveTouch = null
					
			GameOver
				// Draw red text
				// The background is black in LiveTime, so we need to make sure we use colors that are different from black.
				drawText "Game Over", position, size:40, Color("#ff0000"), font:OpenSans
				
		// Draw blue circle with a radius of 200 with a green outline
		drawCircle position, size:400, Color("#0000ff"), outlineColor:Color("#00ff00"), outlineWidth:5
		
class Box
	Rect rect
	Item itemInBox
	bool isOpen
	
	tick
		// Draw blue box with white outline
		drawRectangle rect.position, rect.size, Color("#0000ff"), outlineColor:Color("#ffffff"), outlineWidth:5



---


	
# This is the LiveTime API
# ONLY call functions that are in the LiveTime API. Don't call any other functions.
class Touch
	int userId
	Vector2 referencePosition
	Vector2 referenceStartPosition
	
input
	onTouchDown: Vector2 position, Vector2 size, Player[] by = null, Cursor cursor = Auto, bool showClickableArea = false, bool markAsHandled = true, HorizontalAlignment align = Center, VerticalAlignment valign = Middle, def(Touch touch) do
	onTouchMove: Touch touch, triggeredOnTouchDown = true, def(Touch touch) do
	onTouchMove: Player[] by = null, def(Touch touch) do
	onTouchUp: Touch touch, markAsHandled = true, def(Touch touch) do
	onTouchUp: Player[] by = null, bool markAsHandled = true, def(Touch touch) do
		
math
	int randomInteger: int min, int max
	float randomFloat
	float min: float a, float b
	float max: float a, float b

class List<T>
	int length
	
	each: inline def(T it, int i) do
	add: T item
	insert: T item, index = 0
	remove: T item
	removeAt: int index
	removeWhere: bool(T a) condition
	ensure: T item
	bool contains: T item
	T pop
	clear
	T random
	T popRandom
	T next: T currentItem
	moveToBack: T item
	moveToFront: T item
	T[] orderBy: float(T a) expression
	bool any: bool(T a) predicate
	bool none: bool(T a) predicate
	bool all: bool(T a) predicate
	TValue[] select: TValue(T it) selector
	T find: bool(T a) condition
	T[] where: bool(T a) condition
	int total: int(T it) selector
	shuffle
	T min: float(T a) selector, float threshold = float.maxValue, float default = 0
	T max: float(T a) selector, float threshold = float.minValue, float default = 0
	
graphics
	drawImage: Image image, Vector2 position = {}, frame = 0, implicit Vector2 size = {}, Angle angle = 0.0, clickableMargin = Vector2(16,16), showClickableArea = false, implicit Player[] visibleFor = null, implicit Player[] clickableBy = null, hotkey = Key.None, implicit layer = 0, alpha = 1.0, Color color = White, def(Touch touch) onClick
	drawText: implicit string text, Vector2 position = {}, implicit Vector2 size = {}, Color color = null, HorizontalAlignment align = Center, VerticalAlignment valign = Middle, FontStyle style = Normal, Font font = null, Color outlineColor = null, outlineWidth = 0, implicit Player[] visibleFor = null, implicit layer = 0, alpha = 1.0
	drawButton: Image image = null, text = "", Vector2 position = {}, implicit Vector2 size = {}, frame = 0, Color textColor = null, textSize = 18, textOffset = Vector2(0,0), clickableMargin = Vector2(16,16), showClickableArea = false, implicit Player[] visibleFor = null, implicit Player[] clickableBy = null, hotkey = Key.None, implicit layer = 0, alpha = 1.0, enabled = true, alphaWhenDisabled = .5, def(Touch touch) onClick = null
	drawRectangle: position = Vector2(), implicit size = Vector2(256,256), Color color = null, Color outlineColor = null, outlineWidth = 0, implicit Player[] visibleFor = null, implicit layer = 0, alpha = 1.0, HorizontalAlignment align = Center, VerticalAlignment valign = Middle
	drawCircle: position = Vector2(), implicit Vector2 size = {256,256}, Color color = null, Color outlineColor = null, outlineWidth = 0, Angle startAngle = -.25, Angle angle = 1.0, RotationDirection direction = Clockwise, implicit Player[] visibleFor = null, implicit layer = 0, alpha = 1.0



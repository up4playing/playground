// EXAMPLE CODE: Start of an example of the LiveTime programming language.
class app
	int round
	Player currentPlayer
	Phase phase
	
	def start
		players.each.start
		
	def tick
		players.each.tick
		
class Player
	int score
	bool alive
	string name
	Role role
	
	visible color = Color("#ffffff")
	visible Direction dir = Direction.diagonalDirections[index]
	visible Vector2 videoPos = dir.vector * {700,270}
	
	def tick
		// Draw round video of player with cirlce outline
		const radius = 220
		drawVideo me, videoPos, size:radius*2, shape:Circle
		drawCircle videoPos, size:radius*2+50, Color("#000000"), outlineColor:color, outlineWidth:12, visibleFor:me
		
		// Draw yellow player name that's visible the current player instance
		drawText name, size:32, Color("#ffff00"), visibleFor:me
	
enum Role: Offence, Defence
		
enum Phase: DragItems, Reveal, GameOver
		
class example
	// List of words
	const string[] words = ["Apple", "Banana", "Orange"]
	Box[] boxes
	Item[] items
		
	def int[] getNumbers: int start, int end
		int[] list
		// For loop for numbers syntax: for <start> to <end>
		// Use . to access the current value
		for start to end
			if . % 2 == 0: list.add .
		return list
		
	def int getSum: int[] list
		int sum
		// For loop for lists syntax: for <list>
		// Use . to access the current value
		for list
			sum += .
		return sum
		
	def startGame
		for Direction.diagonalDirections
			boxes.add {rect:{position:{220,280}*.vector, size:{420,440}}}
		nextRound

		// When assigning an enum value to a variable, the enum name must be omitted
		// Write "phase = DrawItems" instead of "phase = Phase.DrawItems"
		phase = DragItems
		
	def nextRound
		round++
		boxes.each.itemInBox = null
		words.shuffle
		items.clear
		
		let top3OpenBoxes = boxes.where.isOpen | orderBy.rect.position.y | take 3
		
		let namesOfAlivePlayers = players.where.alive | orderBy.score | select.name

		// Create item for each word, center them at {0,10} with {400,0} pixels between them
		forPositions words, center:{0,10}, delta:{400,0}
			items.add {position:pos, word:.}
			
		// Make the next player the current player
		currentPlayer = players next currentPlayer
			
	def tick
		items.each.tick
		boxes.each.tick
		players.each.tick
		
		switch phase
			DragItems
				// If all items are dropped into boxes, show "Next Round button"
				if items.all.droppedInBox != null
					drawButton "Next Round", image:Button, position:{0,0}, visibleFor:currentPlayer
						let playerWhoClickedTheButton = touch.by
						phase = Reveal
						nextRound
			Reveal
				// Draw yellow text thats visible for everybody
				drawText "Reveal", size:32, Color("#ffff00"), visibleFor:everybody
				
			GameOver
				tickGameOver
				
				// Draw green text thats visible for everybody
				drawText "Game Over", size:32, Color("#00ff00"), visibleFor:everybody
				
	def tickGameOver
		phase = GameOver
		
		let offencePlayer = players.find.role == Offence
			print "Found offence player: {offencePlayer}"
		else
			print "No offence player"
		
		let defencePlayer = players.find.role == Defence
			print "Found defence player: {defencePlayer}"
		else
			print "No defence player"
		
		// Order players by score
		players.orderBy.score order:Descending
		
		// Print name and score of first 2 players
		for 2
			let player = players[.]
			print "{player.name}: {player.score}"
			
		// Iterate players in reverse order and print player names
		for players <-
			print .name
			
		// Create a list of all number between 10 and 100
		int[] numbers = for 10..100 .
		
		// Get players with even index and a score more than 3
		Player[] evenPlayers = players.where.index % 2 == 0 and .score > 3
		
		let totalScoreOfAlivePlayer = players.where.alive | total.score
		
		// Find player with highest score
		let winner = players.withMax.score
		
		let maxScore = math.max players[0].score, players[1].score
		
		let firstThreePlayers = players[..3]
		
		let lastFourPlayers = players[-4..]
		
		let top3Players = players.orderBy.score | take 3
		
		delay 1 seconds
			print "1 second later"
		
class Item
	const Vector2 size = {300,60}
	bool moveable = true
	Vector2 position, originalPosition
	Touch moveTouch
	Vector2 touchOffset
	Box droppedInBox
	string word
	
	def tick
		switch app.phase
			DragItems
				// Drag items
				onTouchDownWithin position, size, by:app.currentPlayer
					// Start dragging item
					let playerWhoClicked = touch.by
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
					let droppedInBox = app.boxes.find.rect.contains position
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
				drawText "Game Over", position, size:40, Color("#ff0000"), font:OpenSans
				
		// Draw blue circle with a radius of 200 with a green outline
		drawCircle position, size:400, Color("#0000ff"), outlineColor:Color("#00ff00"), outlineWidth:5
		
class Box
	Rect rect
	Item itemInBox
	bool isOpen
	
	def tick
		// Draw blue box with white outline
		drawRectangle rect.position, rect.size, Color("#0000ff"), outlineColor:Color("#ffffff"), outlineWidth:5
		
// Start of LiveTime API. ONLY call functions that are in the LiveTime API
class Touch
	int userId
	Vector2 referencePosition
	Vector2 referenceStartPosition
	
class input
	def onTouchDownWithin: Vector2 position, Vector2 size, Player[] by = null, Cursor cursor = Auto, bool showTouchArea = false, bool markAsHandled = true, HorizontalAlignment align = Center, VerticalAlignment valign = Middle, def(Touch touch) do
	def onTouchMove: Touch touch, triggeredOnTouchDown = true, def(Touch touch) do
	def onTouchMove: Player[] by = null, def(Touch touch) do
	def onTouchUp: Touch touch, markAsHandled = true, def(Touch touch) do
	def onTouchUp: Player[] by = null, bool markAsHandled = true, def(Touch touch) do
		
class math
	def int randomInteger: int min, int max
	def float randomFloat
	def float min: float a, float b
	def float max: float a, float b

class List<T>
	int length
	
	def each: inline def(T it, int i) do
	def add: T item
	def insert: T item, index = 0
	def remove: T item
	def removeAt: int index
	def removeWhere: bool(T a) condition
	def ensure: T item
	def bool contains: T item
	def T pop
	def clear
	def T random
	def T popRandom
	def T next: T currentItem
	def moveToBack: T item
	def moveToFront: T item
	def T[] orderBy: float(T a) expression
	def bool any: bool(T a) predicate
	def bool none: bool(T a) predicate
	def bool all: bool(T a) predicate
	def TValue[] select: TValue(T it) selector
	def T find: bool(T a) condition
	def T[] where: bool(T a) condition
	def int total: int(T it) selector
	def shuffle
	def T min: float(T a) selector, float threshold = float.maxValue, float default = 0
	def T max: float(T a) selector, float threshold = float.minValue, float default = 0

class graphics
	def drawImage: Image image, Vector2 position = {}, frame = 0, implicit Vector2 size = {}, Angle angle = 0.0, touchMargin = Vector2(16,16), showTouchArea = false, implicit Player[] visibleFor = null, implicit Player[] touchableBy = null, hotkey = Key.None, implicit layer = 0, alpha = 1.0, Color color = White, def(Touch touch) onTouch
	def drawText: implicit string text, Vector2 position = {}, implicit Vector2 size = {}, Color color = null, HorizontalAlignment align = Center, VerticalAlignment valign = Middle, FontStyle style = Normal, Font font = null, Color outlineColor = null, outlineWidth = 0, implicit Player[] visibleFor = null, implicit layer = 0, alpha = 1.0
	def drawButton: Image image = null, text = "", Vector2 position = {}, implicit Vector2 size = {}, frame = 0, Color textColor = null, textSize = 18, textOffset = Vector2(0,0), touchMargin = Vector2(16,16), showTouchArea = false, implicit Player[] visibleFor = null, implicit Player[] touchableBy = null, hotkey = Key.None, implicit layer = 0, alpha = 1.0, enabled = true, alphaWhenDisabled = .5, def(Touch touch) onTouch = null
	def drawRectangle: position = Vector2(), implicit size = Vector2(256,256), Color color = null, Color outlineColor = null, outlineWidth = 0, implicit Player[] visibleFor = null, implicit layer = 0, alpha = 1.0, HorizontalAlignment align = Center, VerticalAlignment valign = Middle
	def drawCircle: position = Vector2(), implicit Vector2 size = {256,256}, Color color = null, Color outlineColor = null, outlineWidth = 0, Angle startAngle = -.25, Angle angle = 1.0, RotationDirection direction = Clockwise, implicit Player[] visibleFor = null, implicit layer = 0, alpha = 1.0


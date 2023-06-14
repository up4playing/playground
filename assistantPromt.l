[System]
Output the next line of code.
Do NOT output explanations or comments.
Only call functions that are present in the given code.
[Example]
exampleApp
	int round
	// Lists
	const string[] words = ["Example", "Word"]
	ExamplePhase phase
	ExamplePlayer[] players
	ExamplePlayer currentPlayer
	ExampleBox[] boxes
	ExampleItem[] items
	
	int getNumbers(int start, int end)
		int[] list
		// For loop for numbers syntax: for <start> to <end>
		// Use . to access the current value
		for start to end
			if . % 2 == 0: list.add .
		return list
		
	int getSum(int[] list)
		int sum
		// For loop for lists syntax: for <list>
		// Use . to access the current value
		for list
			sum += .
		return sum
		
	void getWinner()
		return players.withMax.score
	
	void init()
		Platform.userCount = 4
		
	void start()
		Menu()
		statistics.setup {0, 460}, {850,150}
		// Create players
		for input.users
			players.add {id:.id, index:.index}
		startGame
		
	void startGame()
		for Direction.diagonalDirections
			boxes.add {rect:{position:{220,280}*.vector, size:{420,440}}}
		nextRound
		
	void nextRound()
		round++
		boxes.each.itemInBox = null
		words.shuffle
		items.clear
		
		// Create item for each word, center them at {0,10} with {400,0} pixels between them
		forPositions words, center:{0,10}, delta:{400,0}
			items.add {position:pos, word:.}
			
		// Make the next player the current player
		currentPlayer = players next currentPlayer
			
	void tick()
		items.each.tick
		boxes.each.tick
		players.each.tick
		
		// If all items are dropped into boxes, show "Next Round button"
		if items.all.droppedInBox != null
			drawButton image:Button, text:"Next Round", position:{0,0}, visibleFor:currentPlayer.id
				let userIdWhoClicked = touch.userId
				nextRound
				
	gameOver()
		// Order players by score
		players.orderBy.score order:Descending
		
		// Print name and score of first 2 players
		for 2
			let player = players[.]
			print "{player.name}: {player.score}"
			
		// Iterate players in reverse order and print player names
		for players <-
			print .name
		
		// Get players with even index and a score more than 3
		ExamplePlayer[] evenPlayers = players.where.index % 2 == 0 and .score > 3
		
		let totalScoreOfAlivePlayer = players.where(.alive).total.score
		
		// Find player with highest score from all alive players
		let winner = players.withMax.score where .alive
		
		let maxScore = math.max players[0].score, players[1].score
		
		let firstThreePlayers = players[..3]
		
		let top3Players = players.orderBy(.score).take 3
		
ExampleItem
	const Vector2 size = {300,60}
	bool moveable = true
	Vector2 position, originalPosition
	Touch moveTouch
	Vector2 touchOffset
	ExampleBox droppedInBox
	string word
	
	void tick()
		if moveable
			// Drag items
			onTouchDownWithin position, size, userId:exampleApp.currentPlayer.id
				// Start dragging item
				let idOfUserWhoClicked = touch.userId
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
		drawCircle position, size:400, color:{"0000ff"}, outlineColor:{"ff0000"}, outlineWidth:5

enum ExamplePhase: EnterClue, Guess, Score, Reveal
		
ExampleBox
	Rect rect
	ExampleItem itemInBox
	void tick()
		// Draw blue box with white outline
		drawRectangle rect.position, rect.size, color:{"0000ff"}, outlineColor:{"ffffff"}, outlineWidth:5
		
ExamplePlayer
	int id, index
	int score
	bool alive
	string name
	
	visible Color playerColor = graphics.defaultColors[index]
	visible Direction dir = Direction.diagonalDirections[index]
	visible Vector2 videoPos = dir.vector * {700,270}
	
	void tick()
		// Draw round video of player with cirlce outline
		const radius = 220
		drawVideo id, videoPos, size:radius*2, shape:Circle
		drawCircle videoPos, size:radius*2+50, outlineColor:playerColor, outlineWidth:12

// The LiveTime API. Do NOT call functions that are not in the LiveTime API.
class Touch
	int userId
	Vector2 referencePosition
	Vector2 referenceStartPosition
	
unit input
	void onTouchDownWithin(Vector2 position = {}, Vector2 size, int userId = -1, string cursor = "", bool showTouchArea = false, bool markAsHandled = true, HorizontalAlignment align = Center, VerticalAlignment valign = Middle, void(Touch touch) do)
	onTouchMove(Touch touch, triggeredOnTouchDown = true, void(Touch touch) do)
	onTouchMove(int userId = -1, void(Touch touch) do)
	onTouchUp(Touch touch, markAsHandled = true, void(Touch touch) do)
	onTouchUp(int userId = -1, bool markAsHandled = true, void(Touch touch) do)
		
unit math
	int randomInteger(int min, int max)
	float randomFloat()
	float min(float a, float b)
	float max(float a, float b)

class List<T>
	void insert(T item, index = 0)
	void remove(T item)
	void removeAt(int index)
	void removeRange(int index, int count)
	T removeFirstWhere(bool(T a) condition)
	void removeWhere(bool(T a) condition)
	void ensure(T item)
	void addRange(T[] items)
	bool contains(T item)
	int indexOf(T item)
	void setList(T[] list)
	void setFilteredList(T[] list, bool(T a) condition)
	T pop()
	T popAt(int index)
	T[] popRange(int index, int count)
	T popWhere(bool(T a) condition)
	T popFront()
	int length
	int setLength(int value)
	void clear()
	T[] clone()
	string toString()
	T random()
	T popRandom()
	T next(T currentItem)
	T prev(T currentItem)
	T[] reverse()
	T[] distinct()
	T moveToBack(T item)
	T moveToFront(T item)
	T[] orderBy(float(T a) expression)
	T[] orderBy(float(T it) expression, label nocolon float(T it) thenBy)
	T[] orderBy(float(T a) expression, SortingOrder order)
	bool any(bool(T a) predicate)
	bool none(bool(T a) predicate)
	bool all(bool(T a) predicate)
	TValue[] select(TValue(T it) selector)
	T find(bool(T a) condition)
	int indexWhere(bool(T a) condition)
	T[] where(bool(T a) condition)
	T[] take(int count)
	int total(int(T it) selector)
	int sum()
	float average()
	string joinToString(string(T a) selector, string separator = ", ")
	void shuffle()
	T percentile(int value)
	T min(float(T a) selector, float threshold = float.maxValue, float default = 0, label bool(T a) where)
	T max(float(T a) selector, float threshold = float.minValue, float default = 0, label bool(T a) where)
	int minIndex(float(T a) selector, float threshold = float.maxValue)
	int maxIndex(float(T a) selector, float threshold = float.minValue)
	T withMin(float(T a) selector, float threshold = float.maxValue, label bool(T a) where)
	T withMax(float(T a) selector, float threshold = float.minValue, label bool(T a) where)
	T popMax(float(T a) selector)
	int count(bool(T a) predicate)
	int countNot(bool(T a) predicate)
	void rotate()
	T[] intersectWith(T[] other)
	
// Draw graphics on the screen
unit graphics
	void drawImage(Image image, Vector2 position, frame = 0, Vector2 size = {}, touchMargin = Vector2(16,16), visibleFor = -1, clickableBy = -1, hotkey = Key.None, layer = 0, alpha = 1.0, void(Touch touch) onClick)
	void drawText(string text, Vector2 position = {}, implicit Vector2 size = {}, Color color = null, HorizontalAlignment align = , VerticalAlignment valign = Middle, FontStyle style = Normal, Font font = null, Color outlineColor = null, outlineWidth = 0, visibleFor = -1, implicit layer = 0, alpha = 1.0)
	void drawButton(Image image = null, text = "", Vector2 position = {}, Color textColor = null, frame = 0, implicit Vector2 size = {}, fontSize = 18, touchMargin = Vector2(16,16), textOffset = Vector2(0,0), showTouchArea = false, visibleFor = -1, implicit layer = 0, alpha = 1.0, void(Touch touch) onClic)
	void drawRectangle(position = Vector2(), implicit size = Vector2(256,256), Color color = null, Color outlineColor = null, outlineWidth = 0, visibleFor = -1, implicit layer = 0, alpha = 1.0, HorizontalAlignment align = Center, VerticalAlignment valign = Middle)
	void drawCircle(position = Vector2(), implicit Vector2 size = {256,256}, Color color = null, Color outlineColor = null, outlineWidth = 0, Angle startAngle = 0.0, Angle endAngle = 1.0, RotationDirection direction = Clockwise, visibleFor = -1, implicit layer = 0, alpha = 1.0)
	void drawPolygon(Vector2[] points, Vector2 position = {0,0}, Color color = null, Color outlineColor = null, outlineWidth = 0, smooth = false, visibleFor = -1, implicit int layer = 0, alpha = 1.0)

[Context]

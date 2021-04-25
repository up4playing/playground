class NetworkUser
	int id
	bool local
	Color color = null
	
	int acknowledgedFrames
	int frames
	int[][] inputs = [[]]
	
	float2 touchPos = {0,0}
	visible Touch[] downTouches, movingTouches, upTouches
	visible Touch[] startingTouches
	visible WheelEvent[] wheelEvents
	visible int[] downKeys, upKeys
	
	string textComposition
	visible string[] textInputs, textCompositions
	
	int lastTextInputIndex = -1
	int[] lastTouchMoveIndex
	
	startInputFrame: int index
		inputs[index] = []
		lastTouchMoveIndex.clear
		lastTextInputIndex = -1
		frames = index
	
	clearEvent:
		downTouches.clear
		movingTouches.clear
		upTouches.clear
		wheelEvents.clear
		textCompositions.clear
		textInputs.clear
		downKeys.clear
		upKeys.clear
	
enum InputType: None, TouchDown, TouchMove, TouchUp, Wheel, KeyDown, KeyUp, TextComposition, TextInput, Stick, Trigger, Grip, ButtonDown, ButtonUp, ControllerTransform, HeadTransform, DeviceRotation
		
// Phase of a touch or a click
enum TouchPhase: Stationary, Down, Move, Up, Handled
		
enum MouseButton: Left, Middle, Right

// A touch or a click
class Touch
	int id
	NetworkUser user
	TouchPhase phase
	MouseButton button
	float2 referencePosition
	float2 referenceStartPosition
	bool isDown
	float2 position
	float2 startPosition
	
	markAsHandled() phase = Handled
	
class WheelEvent
	NetworkUser user
	int delta
	float2 referencePosition
	float2 position
	bool handled
	
	markAsHandled() handled = true

// A collection of methods to receive user input
unit Input
	NetworkUser[] users
	string cursor

	internal init
		initHandlers
	
	private js float2 logicalToPixelPosition: float2 pos
		let p = pos.getTransformed(graphics_totalMatrix)
		return new float2(p.x/Platform_pixelRatio, p.y/Platform_pixelRatio, null)

	private js void initHandlers
		window.onpointerdown = e => {
			if(e.button == 0 && Platform_mode == 0 && !Platform_slideMode)
				Platform_record()
			Input_handleTouchEvent(1, e.pageX, e.pageY, e.pointerId, e.button);
		}
		window.onpointermove = e => {
			let id = e.pointerType == "mouse" && e.button == -1 ? e.pointerId : e.pointerId
			Input_handleTouchEvent(2, e.pageX, e.pageY, id, e.button);
		}
		window.onpointerup = e => {
			Input_handleTouchEvent(3, e.pageX, e.pageY, e.pointerId, e.button);
			if(e.button == 2 && Platform_mode == 0) {
				if(!Platform_slideMode) Platform_enterSlideMode()
				else                    Platform_stop()
			}
		}
		window.oncontextmenu = e => {
			e.preventDefault();
			e.stopPropagation();
			return false;
		}
		window.onwheel = e => {
			e.preventDefault();
			e.stopPropagation();
			Input_handleWheelEvent(e.pageX, e.pageY, e.deltaY)
			return false;			
		}
		window.onkeydown = e => {
			let keyCode = e.keyCode
			if(window.require && e.key == "T" && e.ctrlKey && e.metaKey && e.shiftKey)
				require("electron").remote.getCurrentWindow().toggleDevTools()
			else
			if(keyCode >= 49 && keyCode <= 52 && Network_simulateConnection)
				Network_userId = Math.min(keyCode-49, Input_users.length-1);
			else
				Input_handleKeyEvent(5, keyCode)
		}
		window.onkeyup = e => Input_handleKeyEvent(6, e.keyCode)
		window.onkeypress = e => {
			Input_handleTextInput(8, e.key)
		}
		
	private getInputList
		let user = users[Network.userId]
		return user.inputs.getOrSet(Network.inputFrame, [])
		
	private setLastTouchMoveIndex: int id, int index
		let lastMoveIndex = users[Network.userId].lastTouchMoveIndex
		lastMoveIndex.add id
		lastMoveIndex.add index
	
	private getLastTouchMoveIndex: int id
		let lastMoveIndex = users[Network.userId].lastTouchMoveIndex
		let i = 0
		while i < lastMoveIndex.length
			if lastMoveIndex[i] == id: return lastMoveIndex[i+1]
			i += 2
		return 0
	
	private handleTextCompositionEnd
		if Network.mode == None || Platform.mode != Record: return
		let inputs = getInputList
		InputType type = TextInput
		let user = users[Network.userId]
		// alert user.lastTextInputIndex
		if user.lastTextInputIndex > -1
			inputs[user.lastTextInputIndex] = cast type
		
	private handleTextInput: InputType type, string text
		if Network.mode == None || Platform.mode != Record: return
		let inputs = getInputList
		users[Network.userId].lastTextInputIndex = inputs.length
		inputs.add cast type
		inputs.add text.length
		for text.length: inputs.add text.getCharCodeAt(i)
			
	private handleKeyEvent: InputType type, int keyCode
		if Network.mode == None || Platform.mode != Record: return
		let inputs = getInputList
		inputs.add cast type
		inputs.add keyCode
		
	private handleTouchEvent: InputType type, float x, float y, int id, int button
		float2 pixelPos = {x*Platform.pixelRatio, y*Platform.pixelRatio}
		float2 referencePos = pixelPos.getRelativeTo(Platform.baseMatrix)
		Platform.handleSider type, id, pixelPos, referencePos
		
		if Network.mode == None || Platform.mode != Record: return
		let inputs = getInputList
		
		if type == TouchMove
			int index = getLastTouchMoveIndex id
			if index
				// We already moved the pointer this input frame, so just update the last move
				inputs[index]   = Math.round(referencePos.x)
				inputs[index+1] = Math.round(referencePos.y)
				return
			else
				setLastTouchMoveIndex id, inputs.length+1
			
		int composite = cast(type)                                              // type:   0 -      32 ( 5 bit)
		              + Math.shiftLeft(button < 0 ? 0 : button%8, 5)            // button: 0 -       8 ( 3 bit)
		              + Math.shiftLeft(Math.floor(int Math.abs(id))%4194304, 8) // id:     0 - 4194304 (22 bit)
		inputs.add composite
		inputs.add Math.round(referencePos.x)
		inputs.add Math.round(referencePos.y)
		
	private handleWheelEvent: float x, float y, float delta
		if Network.mode == None || Platform.mode != Record: return
		let inputs = getInputList
		
		float2 referencePos = {x*Platform.pixelRatio, y*Platform.pixelRatio}.getRelativeTo(Platform.baseMatrix)
		InputType type = Wheel
		inputs.add cast type
		inputs.add Math.round(referencePos.x)
		inputs.add Math.round(referencePos.y)
		inputs.add Math.round(delta)
		
	internal parseInputs(int frame)
		for userIndex, user -> users if user
			Network.parseLog += " ["+frame+"]"
			let inputs = user.inputs[frame]
			if inputs
				for i -> inputs.length
					let value = inputs[i]
					Network.parseLog += " "+value
					InputType type = cast value % 32
					
					if type >= TouchDown && type <= Wheel
						MouseButton button = cast Math.shiftRight(value, 5) % 8
						int id = Math.shiftRight(value, 8)
						float2 touchPos = {inputs[++i], inputs[++i]}
						user.touchPos = touchPos
						
						if type == TouchDown
							Network.parseLog += " touchDown id:"+id+""+touchPos.x+" "+touchPos.y
							Touch touch = {id, user, cast type, button, touchPos, touchPos, isDown:true}
							user.downTouches.add touch
							user.startingTouches.add touch
						else
						if type == TouchMove
							Network.parseLog += " touchMove "+touchPos.x+" "+touchPos.y
							let startingTouch = user.startingTouches.find a.id == id
							let isDown = startingTouch != null
							float2 referenceStartPosition
							if isDown: referenceStartPosition = startingTouch.referencePosition
							else       referenceStartPosition = float2.none; id = 0
							// let referenceStartPosition = isDown ? startingTouch.referencePosition : float2.none
							user.movingTouches.add {id, user, cast type, button, touchPos, referenceStartPosition, isDown}
							cursor = "auto"
						else
						if type == TouchUp
							Network.parseLog += " touchUp "+touchPos.x+" "+touchPos.y
							let startingTouch = user.startingTouches.removeWhere a.id == id
							let referenceStartPosition = startingTouch ? startingTouch.referencePosition : float2.none
							user.upTouches.add {id, user, cast type, button, user.touchPos, referenceStartPosition}
						else
						if type == Wheel
							let delta = inputs[++i]
							user.wheelEvents.add {user, delta, referencePosition:user.touchPos}
					else
					if type == TextComposition || type == TextInput
						let length = inputs[++i]
						let text = ""
						for length: text += string.fromCharCode(inputs[++i])
						if type == TextInput
							user.textInputs.add text
							user.textComposition = ""
						else
							user.textCompositions.add text
							user.textComposition = text
					else
					if type == KeyDown
						user.downKeys.add inputs[++i]
					else
					if type == KeyUp
						user.upKeys.add inputs[++i]
				
	// Executes code when the user touches or clicks within a rectangle
	onTouchDownWithin: float2 position       // The center of the rectangle
		               float2 size           // The size of the rectangle
		               void(Touch touch) code // The code to execute for each touch or click
		               int userId = -1        // Only consider touches or clicks from this user      
		               string cursor = ""
		               bool visualize = false
		               bool markAsHandled = true
		float2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			NetworkUser user = users[userId]
			for touch -> user.downTouches
				if touch.phase != Handled && touch.referencePosition.isInsidePoygon(poly)
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					Network.touchLog += " onTouchDownWithin "+touch.position.x+" "+touch.position.y
					code touch
					if markAsHandled: touch.markAsHandled
		else
			for user -> users if user
				for touch -> user.downTouches
					if touch.phase != Handled && touch.referencePosition.isInsidePoygon(poly)
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						Network.touchLog += " onTouchDownWithin "+touch.position.x+" "+touch.position.y
						code touch
						if markAsHandled: touch.markAsHandled
			if cursor
				NetworkUser user = users[Network.userId]
				for touch -> user.movingTouches
					if touch.phase != Handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if visualize: drawRectangle position, size, fill:{"ff000080"}

	// Executes code when the user touches or clicks within a rectangle
	onTouchUpWithin: float2 position       // The center of the rectangle
		             float2 size           // The size of the rectangle
		             void(Touch touch) code // The code to execute for each touch or click
		             int userId = -1        // Only consider touches or clicks from this user
		             bool visualize = false
		             bool markAsHandled = true
		float2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			NetworkUser user = users[userId]
			for touch -> user.upTouches
				if touch.phase != Handled && touch.referencePosition.isInsidePoygon(poly)
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					Network.touchLog += " onTouchDownWithin "+touch.position.x+" "+touch.position.y
					code touch
					if markAsHandled: touch.markAsHandled
		else
			for user -> users if user
				for touch -> user.upTouches
					if touch.phase != Handled && touch.referencePosition.isInsidePoygon(poly)
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						Network.touchLog += " onTouchDownWithin "+touch.position.x+" "+touch.position.y
						code touch
						if markAsHandled: touch.markAsHandled
		if visualize: drawRectangle position, size, fill:{"ff000080"}

	// Executes code when the user touches or clicks
	onTouchDown: void(Touch touch) code // The code to execute for each touch or click
		         int userId = -1        // Only consider touches or clicks from this user
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			NetworkUser user = users[userId]
			for touch -> user.downTouches
				if touch.phase != Handled
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					Network.touchLog += " onTouchDown "+touch.position.x+" "+touch.position.y
					code touch
		else
			for user -> users if user
				for touch -> user.downTouches
					if touch.phase != Handled
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						Network.touchLog += " onTouchDown "+touch.position.x+" "+touch.position.y
						code touch

	// Executes code when the user touches, even if the touch is already handled
	onTouchDownAny: void(Touch touch) code // The code to execute for each touch or click
		            int userId = -1        // Only consider touches or clicks from this user
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			NetworkUser user = users[userId]
			for touch -> user.downTouches
				touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
				Network.touchLog += " onTouchDown "+touch.position.x+" "+touch.position.y
				code touch
		else
			for user -> users if user
				for touch -> user.downTouches
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					Network.touchLog += " onTouchDown "+touch.position.x+" "+touch.position.y
					code touch
			
	// Executes code when a touch or click moves
	onTouchMove: Touch touch 
		         void(Touch touch) code // The code to execute when the given touch moves
		if !touch: return
		let touchId = touch.id, user = touch.user
		for t -> user.movingTouches
			if t.id == touchId && t.phase != Handled
				t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
				t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
				Network.touchLog += " onTouchMove ref:{t.referencePosition} matrix:{graphics.localMatrix} pos:{t.position}"
				code t
	
	// Executes code when a touch or click moves
	onTouchMove: void(Touch touch) code // The code to execute when the given touch moves
		         int userId = -1
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			NetworkUser user = users[userId]
			for t -> user.movingTouches
				if t.phase != Handled
					t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
					t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
					Network.touchLog += " onTouchMove ref:{t.referencePosition} matrix:{graphics.localMatrix} pos:{t.position}"
					code t
		else
			for user -> users if user
				for t -> user.movingTouches
					if t.phase != Handled
						t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
						t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
						Network.touchLog += " onTouchMove "+t.position.x+" "+t.position.y
						code t
					
	onTouchUp: Touch touch
		       void(Touch touch) code // The code to execute for each touch or click
		if !touch: return
		let touchId = touch.id, user = touch.user
		for t -> user.upTouches
			if t.id == touchId && t.phase != Handled
				t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
				t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
				Network.touchLog += " ### onTouchUp "+t.position.x+" "+t.position.y
				code t
				
	// Executes code when a touch or click ends
	onTouchUp: void(Touch touch) code // The code to execute for each touch or click
		for user -> users if user
			for t -> user.upTouches
				if t.phase != Handled
					t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
					t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
					Network.touchLog += " ### onTouchUp "+t.position.x+" "+t.position.y
					code t

	// Executes code when a touch or click ends
	onWheel: void(WheelEvent event) code // The code to execute for each touch or click
		for user -> users if user
			for value -> user.wheelEvents
				code value
	
	// Executes code when a user moves the mouse wheel within a given rectangle
	onWheelWithin: float2 position            // The center of the rectangle
		           float2 size                // The size of the rectangle
		           void(WheelEvent event) code // The code to execute
		           int userId = -1             // Only consider wheel movments from this user
		           Color fill = null
		           bool markAsHandled = true
		float2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			NetworkUser user = users[userId]
			for event -> user.wheelEvents
				if !event.handled && event.referencePosition.isInsidePoygon(poly)
					event.position = event.referencePosition.getRelativeTo(graphics.localMatrix)
					Network.touchLog += " onWheel {delta} {event.position}"
					code event
					if markAsHandled: event.markAsHandled
		else
			for user -> users if user
				for event -> user.wheelEvents
					if !event.handled && event.referencePosition.isInsidePoygon(poly)
						event.position = event.referencePosition.getRelativeTo(graphics.localMatrix)
						Network.touchLog += " onWheel {delta} {event.position}"
						code event
						if markAsHandled: event.markAsHandled
		if fill: drawRectangle position, size, fill
	
	js void showKeyboard
		if(!Platform_isMobile) return
		if(!window._input) {
			window._input = document.createElement("input")
			_input.type = "text"
			_input.style.position = "absolute"
			_input.style.left = -10000
			_input.width = 0
			_input.height = 0
			_input.style.width = "0px"
			_input.style.height = "0px"
			_input.style.backgroundColor = "#000000"
			if(Platform_isMobile) {
				
				_input.addEventListener('compositionstart',e => {
					// app_filter += "start~"+e.data+" "
					// if(e.inputType == "insertCompositionText" || e.inputType == "insertText")
						// Input_handleKeyPressEvent(7, e.data)
				})
				_input.addEventListener('compositionend', e => {
					Input_handleTextCompositionEnd()
					// app_filter += "end~"+e.data+" "
					// if(e.inputType == "insertCompositionText" || e.inputType == "insertText")
						// Input_handleKeyPressEvent(7, e.data)
				})
				_input.oninput = e => {
					// app_filter += e.inputType+"~"+e.data+" "
					let type = e.inputType == "insertCompositionText" ? 7 : 8
					Input_handleTextInput(type, e.data || "")
				}
				_input.addEventListener("blur", e => {
					Input_handleTextInput(7, "")
				})
			}
			document.body.appendChild(_input)
			setTimeout(() => _input.focus(), 100)
		} else {
			_input.focus()
		}
		
	js void updateCursor
		document.body.style.cursor = Input_cursor

	textComposition := users[Network.userId].textComposition
	
	onTextComposition: void(string text) code
		for user -> users if user
			for text -> user.textCompositions
				code text
				
	onTextInput: void(string characters) code
		for user -> users if user
			for text -> user.textInputs
				code text
				
	onKeyDown: int key, void(int key) code
		for user -> users if user
			for k -> user.downKeys
				if k == key
					code key
				
	onKeyDown: void(int key) code
		for user -> users if user
			for key -> user.downKeys
				code key
				
	onKeyUp: void(int key) code
		for user -> users if user
			for key -> user.upKeys
				code key

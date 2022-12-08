// The internal state of a user that isn't serialized and shoudn't be accessed by the application
transient class InternalUser
	int id              // The userId stays the same when a user reconnects
	bool local          // Is this the local user?
	int connectionId    // The connectionId increases with every connection, even if the same user reconnects
	int index
	
	bool collectInputs  // When we are done pinging, we add a join event and start collecting inputs
	int inputFrame      // We got all inputs from this player up to and including this frame
	int bufferFrames
	int inputsSentPos
	
	visible Touch[] downTouches, movingTouches, upTouches
	visible WheelEvent[] wheelEvents
	visible Key[] downKeys, upKeys
	visible string[] pressedKeys, textInputs, textCompositions
	visible string[] navigations
	
	int[] lastTouchMoveIndex
	
	Buffer inputs         // The stream of inputs of this user
	int uncertainReadPos  // The buffer position where we haven't received inputs from all users
	
	object mediaStream
	object[] videoElements
	object audioElement
	int videoElementIndex = 0
	
	object peerConnection
	object dataChannel
	object recreateDataChannelInterval
	string connectionType
	bool offerByMe
	int nextLostMessageAtFrame
	
	startInputFrame: int index
		lastTouchMoveIndex.clear
		inputFrame = index
	
	clearEvent:
		downTouches.clear
		movingTouches.clear
		upTouches.clear
		wheelEvents.clear
		textCompositions.clear
		textInputs.clear
		downKeys.clear
		upKeys.clear
		pressedKeys.clear
		navigations.clear
	
// The public state of a user. This is the same accross all clients.
class NetworkUser
	int id
	int index
	Color color = null
	bool isReady
	string textInput
	
	// Touch
	visible Touch[] touches
	bool enableTouch = true
	
	// Controller
	visible GameController controller = {}
	Key[] mapKeyToController = [Right, Down, Left, Up, Space, X, Alt, Ctrl]
	int[] controllerKeyDownFrame = [0, 0, 0, 0, 0, 0]
	
	// If a user was lost by anybody and nobody who is still connected to that user
	// disagrees within a certrain time, we will remove this user in "handleLost"
	int lostAtFrame
	
	NetworkUser
		controller.a.name = "SPACE"
		controller.b.name = "X"
		controller.x.name = "ALT"
		controller.y.name = "CTRL"

	internal clearEvents
		bool hasToch = touches.any.type == Touch
		for touches <-
			if (.phase == Up and .type >= Touch) or (hasToch and .type != Touch)
				touches.remove .
	
enum InputType: None, TouchDown, TouchMove, TouchUp, Wheel, KeyDown, KeyUp, TextInput, Stick, Trigger, Grip, ButtonDown, ButtonUp, ControllerTransform, HeadTransform, DeviceRotation, Join, Lost, StillConnected, SetState, Navigate, GameController, String, Json, Object
		
// Phase of a touch or a click
enum TouchPhase: Still, Down, Move, Up
		
enum TouchType: Left, Middle, Right, Touch, Pen

// A touch or a click
class Touch
	int id
	int userId
	TouchPhase phase
	TouchType type
	Vector2 referencePosition
	Vector2 referenceStartPosition
	Vector2 smoothPosition
	bool isDown
	bool handled
	
	// Calculate position and startPositio dynamically to ensure it is always valid and relative to the current matrix
	// even if we never check the touch with a Input.onTouch method
	
	Vector2 position := referencePosition.getRelativeTo(graphics.localMatrix)
	Vector2 startPosition := referenceStartPosition.getRelativeTo(graphics.localMatrix)
	
	Touch clone := {id, userId, phase, type, referencePosition, referenceStartPosition, smoothPosition, isDown}
	markAsHandled() handled = true
	
transient class WheelEvent
	NetworkUser user
	int delta
	Vector2 referencePosition
	bool handled
	
	Vector2 position := referencePosition.getRelativeTo(graphics.localMatrix)
	
	markAsHandled() handled = true
	
enum Key
	None         =   0
	Backspace    =   8
	Tab          =   9
	Enter        =  13
	Shift        =  16
	Ctrl         =  17
	Alt          =  18
	Pause        =  19
	CapsLock     =  20
	Escape       =  27
	Space        =  32
	PageUp       =  33
	PageDown     =  34
	End          =  35
	Home         =  36
	Left         =  37
	Up           =  38
	Right        =  39
	Down         =  40
	Insert       =  45
	Delete       =  46
	A            =  65
	B            =  66
	C            =  67
	D            =  68
	E            =  69
	F            =  70
	G            =  71
	H            =  72
	I            =  73
	J            =  74
	K            =  75
	L            =  76
	M            =  77
	N            =  78
	O            =  79
	P            =  80
	Q            =  81
	R            =  82
	S            =  83
	T            =  84
	U            =  85
	V            =  86
	W            =  87
	X            =  88
	Y            =  89
	Z            =  90
	LeftMetaKey  =  91
	RightMetaKey =  92
	Select       =  93
	Numpad0      =  96
	Numpad1      =  97
	Numpad2      =  98
	Numpad3      =  99
	Numpad4      = 100
	Numpad5      = 101
	Numpad6      = 102
	Numpad7      = 103
	Numpad8      = 104
	Numpad9      = 105
	Multiply     = 106
	Add          = 107
	Subtract     = 109
	DecimalPoint = 110
	Divide       = 111
	F1           = 112
	F2           = 113
	F3           = 114
	F4           = 115
	F5           = 116
	F6           = 117
	F7           = 118
	F8           = 119
	F9           = 120
	F10          = 121
	F11          = 122
	F12          = 123
	F13          = 124
	F14          = 125
	F15          = 126
	F16          = 127
	F17          = 128
	F18          = 129
	F19          = 130
	F20          = 131
	F21          = 132
	F22          = 133
	F23          = 134
	F24          = 135
	NumLock      = 144
	ScrollLock   = 145
	SemiColon    = 186
	EqualSign    = 187
	Comma        = 188
	Dash         = 189
	Period       = 190
	ForwardSlash = 191
	GraveAccent  = 192
	OpenBracket  = 219
	BackSlash    = 220
	CloseBraket  = 221
	SingleQuote  = 222
	
class DigitalButton
	bool state, prevState
	bool down := state and not prevState
	bool up   := not state and prevState
	string name
	
	internal startFrame
		prevState = state
		state = false
	
enum GameControllerType: Keyboard, Xbox, PlayStation
	
class GameController
	static deadZone = .1
	
	Vector2 leftStick
	Vector2 rightStick
	DigitalButton a = {}
	DigitalButton b = {}
	DigitalButton x = {}
	DigitalButton y = {}
	bool inMotion
	GameControllerType type
	
	internal startFrame
		leftStick.x = 0
		leftStick.y = 0
		rightStick.x = 0
		rightStick.y = 0
		a.startFrame
		b.startFrame
		x.startFrame
		y.startFrame
	
class InternetGamePadButton
	bool pressed, touched
	float value
	
class InternetGamePad
	float[] axes
	InternetGamePadButton[] buttons
	string id
	
// A collection of methods to receive user input
skipInit unit Input
	transient visible InternalUser[] internalUsers
	transient bool isCertain
	transient InternalUser localUser

	NetworkUser[] users
	internal NetworkUser[] usersById
	string cursor
	
	bool showLocalPointer = false
	bool showPointers = true
	
	string textInput
		let localUser = usersById[Input.localUser.id]
		return localUser.textInput
	
	internal init
		initHandlers
	
	internal js Vector2 logicalToPixelPosition: Vector2 pos
		let p = pos.getTransformed(graphics_totalMatrix)
		return new Vector2(p.x/Platform_pixelRatio, p.y/Platform_pixelRatio, null)

	private js void initHandlers
		window.onpointerdown = e => {
			if(e.button == 0 && Platform_mode == 0) Platform_record();
			Input_handleTouchEvent(1, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button, e.shiftKey, e.altKey, e.ctrlKey || e.metaKey);
		}
		window.onpointermove = e => {
			Input_handleTouchEvent(2, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button, e.shiftKey, e.altKey, e.ctrlKey || e.metaKey);
		}
		window.onpointerup = e => {
			Input_handleTouchEvent(3, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button, e.shiftKey, e.altKey, e.ctrlKey || e.metaKey);
		}
		window.oncontextmenu = e => {
			e.preventDefault();
			e.stopPropagation();
			return false;
		}
		window.onwheel = e => {
			e.preventDefault();
			e.stopPropagation();
			if(e.button == 0 && Platform_mode == 0) Platform_record();
			Input_handleWheelEvent(e.pageX, e.pageY, e.deltaY)
			return false;			
		}
		window.onkeydown = e => {
			let keyCode = e.keyCode
			let key = e.key
			let ctrlOrCmd = e.ctrlKey || e.metaKey
			if(window.require && key == "t" && e.metaKey && e.shiftKey)
				require("electron").remote.getCurrentWindow().toggleDevTools()
			else
			if(ctrlOrCmd && key == "o") {
				// Open event stream
				Network_openEventStream();
				e.preventDefault();
			}
			else
			if(ctrlOrCmd && key == "s") {
				// Save event steam
				Network_saveEventStream();
				e.preventDefault();
			}
			else
			if(ctrlOrCmd && key == "l") {
				// Save logs
				Network_saveLogs();
				e.preventDefault();
			}
			else
			if((key >= "F1" && key <= "F4") && !ctrlOrCmd && Platform_isDebug) {
				let index = key[1] - "1"
				Network_switchUser(index);
				e.preventDefault();
			}
			else
			if(key >= "1" && key <= "0") {
				let index = key - "0"
				if(e.altKey)  { Network_save(index); e.preventDefault(); } else
				if(e.ctrlKey) { Network_restore(index); e.preventDefault(); }
			}
			else
			// Reload
			if(ctrlOrCmd && key == "F1") {/*keep room, keep userId, keep master*/ ServerNetwork_sendReload(false, false, true ); e.preventDefault();} else
			if(ctrlOrCmd && key == "F2") {/*keep room, keep userId, everybody*/   ServerNetwork_sendReload(false, false, false); e.preventDefault();} else
			if(ctrlOrCmd && key == "F3") {/*new  room, keep userId, everybody*/   ServerNetwork_sendReload(true,  false, false); e.preventDefault();} else
			if(ctrlOrCmd && key == "F4") {/*new  room, new  userId, everybody*/   ServerNetwork_sendReload(true,  true,  false);  e.preventDefault();} else
			
			// Switch send interval
			if(ctrlOrCmd && key == "F5") {Network_switchSendInterval( 3); e.preventDefault();} else
			if(ctrlOrCmd && key == "F6") {Network_switchSendInterval(10); e.preventDefault();} else
			if(ctrlOrCmd && key == "F7") {Network_switchSendInterval(20); e.preventDefault();} else
			if(ctrlOrCmd && key == "F8") {Network_switchSendInterval(30); e.preventDefault();} else
			if(ctrlOrCmd && key == "F9") {Network_switchSendInterval(40); e.preventDefault();} else
				
			if(ctrlOrCmd && key == "F10") {Network_switchSendInputMode(1); e.preventDefault();} else
			if(ctrlOrCmd && key == "F11") {Network_switchSendInputMode(2); e.preventDefault();} else
				
			if(key == "F9") {
				if(e.shiftKey) { Network_saveLogs(); }
				else           { Platform_toggleDebugInfo(); Network_debugString = "" }
				e.preventDefault();
			} else {
				Input_handleKeyEvent(5, keyCode, key?.length == 1 ? key : "")
				if(keyCode == 9) e.preventDefault();
			}
		}
		window.onkeyup = e => {
			// if(e.key == "F1")
			// 	// TEMP for testing
			// 	Network_skipAnimationFrame = false;
			// else
			// if(e.key == "F2")
			// 	// TEMP for testing
			// 	Network_skipSending = false;
			// else
			Input_handleKeyEvent(6, e.keyCode)
		}
			
		// Handles the user navigating back or forward in the browser	
		window.onpopstate = e => {
			Input_handleNavigate(location.pathname);
		}
		
		if(window._input) window._input.value = ""
		
	private setLastTouchMoveIndex: int id, int index
		let lastMoveIndex = localUser.lastTouchMoveIndex
		lastMoveIndex.add id
		lastMoveIndex.add index
	
	private getLastTouchMoveIndex: int id
		let lastMoveIndex = localUser.lastTouchMoveIndex
		let i = 0
		while i < lastMoveIndex.length
			if lastMoveIndex[i] == id: return lastMoveIndex[i+1]
			i += 2
		return 0
		
	private handleTextInput: InputType type, string text
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast type
		inputs.writeString text
			
	private handleKeyEvent: InputType type, int keyCode, string key
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast type
		inputs.writeInt32 keyCode
		if type == KeyDown: inputs.writeString key
		
	internal handleTouchEvent: InputType inputType, float x, float y, string pointerType, int pointerId, int button, shift = false, alt = false, cmdOrCtrl = false
		int touchType, id
		if pointerType == "mouse": touchType = button.limit(min:0, max:2); else
		if pointerType == "touch": touchType = 3; id = pointerId; else
			                       touchType = 4
		
		Vector2 pixelPos = {x*Platform.pixelRatio, y*Platform.pixelRatio}
		Vector2 referencePos = pixelPos.getRelativeTo(Platform.baseMatrix)
		gizmo.onTouch inputType, id, pixelPos, referencePos, shift, alt, cmdOrCtrl
		
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs

		if inputType == TouchMove
			int index = getLastTouchMoveIndex id
			if index
				// We already moved the pointer this input frame, so just update the last move
				inputs.setInt16 index, Math.round(referencePos.x)
				inputs.setInt16 index+2, Math.round(referencePos.y)
				if Network.logging: Network.writeLog += " #{localUser.inputFrame} override {id} at {index} to {Math.round(referencePos.x)} {Math.round(referencePos.y)}"
				return
			else
				setLastTouchMoveIndex id, inputs.writePos+6
				if Network.logging: Network.writeLog += " save {id} at {inputs.writePos+6}"
			
		int composite = cast(inputType)                                 // inputType: 0 -  31 (5 bit)
		              + Math.shiftLeft(touchType, 5)                    // touchType: 0 -   7 (3 bit)
		              + Math.shiftLeft(Math.floor(Math.abs(id))%128, 8) // id:        0 - 127 (7 bit)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 Math.round(referencePos.x)
		inputs.writeInt16 Math.round(referencePos.y)
		if Network.logging: Network.writeLog += " #{localUser.inputFrame} {composite} {Math.round(referencePos.x)} {Math.round(referencePos.y)} ({inputs.readPos}/{inputs.writePos})"
		
	private handleWheelEvent: float x, float y, float delta
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		
		Vector2 referencePos = {x*Platform.pixelRatio, y*Platform.pixelRatio}.getRelativeTo(Platform.baseMatrix)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast InputType.Wheel
		inputs.writeInt16 Math.round(referencePos.x)
		inputs.writeInt16 Math.round(referencePos.y)
		inputs.writeInt16 Math.round(delta)
		if Network.logging: Network.writeLog += " [{localUser.inputFrame}] wheel {Math.round(referencePos.x)} {Math.round(referencePos.y)} {Math.round(delta)} \{r:{inputs.readPos} w:{inputs.writePos}\}"
		
	internal handleSetState: Buffer buffer
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast InputType.SetState
		inputs.writeBuffer buffer
		
	internal handleJoin: int frame
		let inputs = localUser.inputs
		inputs.writeInt32 frame
		inputs.writeInt16 cast InputType.Join
				
	// Handles the user navigating back or forward in the browser	
	internal handleNavigate: string url
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.Navigate
		inputs.writeString url
		
	// Post lost messages and remove users if nobody disagrees
	internal handleLost
		if Network.mode != Connected or !lobby.inLobby: return
		for users <- user
			let internalUser = internalUsers[.id]
				if user.lostAtFrame and Network.frame > user.lostAtFrame + Network.targetFps * 3
					// If a user was lost by anybody and nobody who is still connected to that user
					// disagrees within a certrain time, we remove this user
					Network.log "Removing user {user.id} at frame {Network.frame}, user was lost at frame {user.lostAtFrame} and nobody disagreed", isCertain
					users.remove user
					usersById[user.id] = null
					updateUserIndices
				else	
				if Network.frame > internalUser.inputFrame + Network.targetFps * 8
				and Network.frame > internalUser.nextLostMessageAtFrame
					// If we lost the connection to a user, we post a lost message to everybody every 5 seconds
					Network.log "Sending lost message for user {user.id} at frame {Network.frame}", internalUser.inputFrame
					let inputs = localUser.inputs
					inputs.writeInt32 localUser.inputFrame
					inputs.writeInt16 cast InputType.Lost
					inputs.writeInt16 user.id
					internalUser.nextLostMessageAtFrame = Network.frame + Network.targetFps * 12
	
	private handleStillConnected: int userId
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.StillConnected
		inputs.writeInt16 userId
				
	internal handleString: int id, string data
		if !data || Network.mode == None || Network.frames > Network.frame || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.String
		inputs.writeInt id
		inputs.writeString data
		
	internal handleJson: int id, string data
		if !data || Network.mode == None || Network.frames > Network.frame || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.Json
		inputs.writeInt id
		inputs.writeString data
		
	internal handleObject: int id, string data
		if !data || Network.mode == None || Network.frames > Network.frame || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.Object
		inputs.writeInt id
		inputs.writeString data
		
	// Returns a "GamepadList" (which doesn't have the functions of a LiveTime list)
	private inline js dynamic getGamepads() navigator.getGamepads()
	
	internal updateGameControllers
		let gamepads = getGamepads
		if gamepads == null: return
		InternetGamePad gp = gamepads[0]
		if !gp or gp.axes.length < 2: return
			
		let isPlayStation = gp.id.contains("54c") or gp.id.contains("810")
		
		// Controller axis
		let axes = gp.axes
		let leftStickX = axes[0]
		let leftStickY = axes[1]
		
		// Controller buttons
		let buttons = (gp.buttons[ 0].pressed ?     1:0)
		            + (gp.buttons[ 1].pressed ?     2:0)
		            + (gp.buttons[ 2].pressed ?     4:0)
		            + (gp.buttons[ 3].pressed ?     8:0)
		
		            + (gp.buttons[ 4].pressed ?    16:0)
		            + (gp.buttons[ 5].pressed ?    32:0)
		            + (gp.buttons[ 8].pressed ?    64:0)
		            + (gp.buttons[ 9].pressed ?   128:0)
		
		            + (gp.buttons[10].pressed ?   256:0)
		            + (gp.buttons[11].pressed ?   512:0)
		            + (gp.buttons[12].pressed ?  1024:0)
		            + (gp.buttons[13].pressed ?  2048:0)
		
		            + (gp.buttons[14].pressed ?  4096:0)
		            + (gp.buttons[15].pressed ?  8192:0)
		            + (isPlayStation          ? 16384:0)
		
		// Write to event stream
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.GameController
		inputs.writeFloat32 abs(leftStickX) > GameController.deadZone ? leftStickX : 0
		inputs.writeFloat32 abs(leftStickY) > GameController.deadZone ? leftStickY : 0
		inputs.writeUnsignedInt16 buttons
			
	internal parseInputs(int frame, bool isCertain)
		this.isCertain = isCertain
		if Network.logging: if isCertain: Network.parseLog += " c"
		for internalUsers -> internalUser if internalUser
			let inputs = internalUser.inputs
			let userId = internalUser.id
			let user = usersById[userId]
			if Network.logging: Network.parseLog += " <{userId}>"
			user?.controller.startFrame
			
			while true
				int nextFrame = inputs.canRead ? inputs.peekInt32 : int.maxValue
				if Network.logging: 
					Network.parseLog += " ({inputs.readPos}/{inputs.writePos})"
					if inputs.canRead: Network.parseLog += " *{nextFrame}"
				if nextFrame > frame: break
				inputs.readPos += 4
				
				// We create the user as soon as receive the first input from that user,
				// which is typically the "Join" message that is sent in "startConnected",
				// but could also be a user reconnecting that was previously kicked out
				if not user
					Network.log "Adding user {userId}"
					users.add user = {id:userId, index:users.length}
					usersById[userId] = user
					updateUserIndices
				
				let value = inputs.readUnsignedInt16
				if Network.logging: Network.parseLog += " "+value
				InputType inputType = cast(value % 32)
				
				if inputType >= TouchDown && inputType <= Wheel
					if !user: Network.log " ERROR: userId {userId} not in usersById"
					TouchType type = cast((value shiftRight 5) % 8)
					int id = (value shiftRight 8) % 128
					Vector2 referencePos = {inputs.readInt16, inputs.readInt16}
					bool isSmoothPosition = !Network.smoothTouchPosition or Network.isSmooth or localUser.id == userId
					if Network.logging: Network.parseLog += " "+id
					
					if inputType == TouchDown
						let touch = user.touches.find.id == id
						if touch
							// Update the touch in user.touches
							touch.phase = cast inputType
							touch.referencePosition = referencePos
							touch.referenceStartPosition = referencePos
							touch.type = type
							touch.isDown = true
							// When we touch down, we start a new touch and reset the "handled" flag
							// This flag is preserved throughout "TouchMove" and "TouchUp", so if we mark the touch
							// as handled at any point, the flags stays set to "true" until we touch down again
							touch.handled = false
							if Network.logging: Network.parseLog += " down {id} {referencePos} {type}"
							if isSmoothPosition: touch.smoothPosition = referencePos
						else
							touch = {id, userId, cast inputType, type, referencePos, referencePos, referencePos, isDown:true}
							user.touches.add touch
							if Network.logging: Network.parseLog += " down(new) {id} {referencePos} {type}"
							
						internalUser.downTouches.add touch
					else
					if inputType == TouchMove
						let touch = user.touches.find.id == id
						if touch
							// Update the touch in user.touches
							touch.phase = cast inputType
							touch.referencePosition = referencePos
							touch.type = type
							if isSmoothPosition: touch.smoothPosition = referencePos
							if Network.logging: Network.parseLog += " move {id} {referencePos} {type}"
						else
							touch = {id, userId, cast inputType, type, referencePos, referenceStartPosition:Vector2.none, referencePos, isDown:false}
							user.touches.add touch
							if Network.logging: Network.parseLog += " move(new) {id} {referencePos} {type}"

						internalUser.movingTouches.add touch
						cursor = "auto"
					else
					if inputType == TouchUp
						let touch = user.touches.find.id == id
						if touch
							// Update the touch in user.touches
							touch.phase = cast inputType
							touch.referencePosition = referencePos
							touch.type = type
							touch.isDown = false
							if isSmoothPosition: touch.smoothPosition = referencePos
							if Network.logging: Network.parseLog += " up {id} {referencePos} {type}"
						else
							touch = {id, userId, cast inputType, type, referencePos, referenceStartPosition:Vector2.none, referencePos, isDown:false}
							user.touches.add touch
							if Network.logging: Network.parseLog += " up(new) {id} {referencePos} {type}"
							
						internalUser.upTouches.add touch
					else
					if inputType == Wheel
						let delta = inputs.readInt16
						internalUser.wheelEvents.add {user, delta, referencePosition:referencePos}
				else
				if inputType == TextInput
					let textInput = inputs.readString
					user.textInput = textInput
					internalUser.textInputs.add textInput
				else
				if inputType == KeyDown
					Key key = cast inputs.readInt32
					let keyPressed = inputs.readString
					internalUser.downKeys.add key
					if keyPressed: internalUser.pressedKeys.add keyPressed
					let keyIndex = user.mapKeyToController.indexOf(key)
					if keyIndex != -1: user.controllerKeyDownFrame[keyIndex] = frame
					
				else
				if inputType == KeyUp
					Key key = cast inputs.readInt32
					internalUser.upKeys.add key
					let keyIndex = user.mapKeyToController.indexOf(key)
					if keyIndex != -1: user.controllerKeyDownFrame[keyIndex] = 0
				else
				if inputType == Navigate
					internalUser.navigations.add inputs.readString
				else
				if inputType == GameController
					GameController c = user.controller
					
					// Controller axix
					c.leftStick.x = inputs.readFloat32
					c.leftStick.y = inputs.readFloat32
					
					// Controller buttons
					let buttons = inputs.readUnsignedInt16
					c.a.state = (buttons bitwiseAnd 1) != 0
					c.b.state = (buttons bitwiseAnd 2) != 0
					c.x.state = (buttons bitwiseAnd 4) != 0
					c.y.state = (buttons bitwiseAnd 8) != 0
					c.type = (buttons bitwiseAnd 16384) != 0 ? PlayStation : Xbox
					
					// Controller button names
					if c.type == Xbox
						c.a.name = "A"
						c.b.name = "B"
						c.x.name = "X"
						c.y.name = "Y"
					else
						c.a.name = "X"
						c.b.name = "O"
						c.x.name = "SQUARE"
						c.y.name = "TRIANGLE"
						
				else
				if inputType == Join
					// We created the user above as soon as received the first input from that user,
					// which is typically the "Join" message that is sent in "startConnected",
					// but could also be a user reconnecting that was previously kicked out
					Network.log "Join {userId}", isCertain
				else
				if inputType == Lost
					let lostUserId = inputs.readInt16
					let lostInternalUser = internalUsers[lostUserId]
						let lostUser = usersById[lostUserId]
						
						// If a user was lost by anybody and nobody who is still connected to that user
						// disagrees within a certrain time, we will remove this user in "handleLost"
						if lostUser and lostUser.lostAtFrame == 0
							lostUser.lostAtFrame = frame
							Network.log "Lost {lostUserId} by {userId} -> Set lostAtFrame to {lostUser.lostAtFrame}"
							
						// If we are still connected to that user, we disagree to their removal
						// by posting the "StillConnected" message
						if Network.frame < lostInternalUser.inputFrame + Network.targetFps * 5
							Network.log "Lost {lostUserId} by {userId} -> We are still connected, sending StillConnected"
							handleStillConnected lostUserId
						else
							Network.log "Lost {lostUserId} by {userId} -> We also aren't connected"
					else
						Network.log "Lost {lostUserId} by {userId} -> No internal user!"
				else
				if inputType == StillConnected
					// Somebody disagreed with the removal of that user because they are still connected,
					// so we cancel the removal
					let lostUserId = inputs.readInt16
					Network.log "Still connected to {lostUserId} by {userId}"
					let lostUser = usersById[lostUserId]
						lostUser.lostAtFrame = 0
				else
				if inputType == SetState
					if Network.logging: Network.parseLog += " setState"
					Network.snapshotBuffer.reset
					inputs.readBuffer Network.snapshotBuffer
					Snapshot.deserialize Network.snapshotBuffer
					Math.recreateRandomValues
				else
				if inputType == String
					int id = inputs.readInt
					string value = inputs.readString
					if Network.logging: Network.parseLog += " string {id}: {value}"
					networkData.call id, value
				else
				if inputType == Json
					int id = inputs.readInt
					string value = inputs.readString
					if Network.logging: Network.parseLog += " json {id}: {value}"
					dynamic object = Json.parse value
					networkData.call id, object
				else
				if inputType == Object
					int id = inputs.readInt
					string value = inputs.readString
					if Network.logging: Network.parseLog += " object {id}: {value}"
					dynamic object = Json.parse value
					networkData.call id, object
	
		for users
			let internalUser = internalUsers[.id]
			if frame <= internalUser.inputFrame
				let right = .controllerKeyDownFrame[0]
				let down  = .controllerKeyDownFrame[1]
				let left  = .controllerKeyDownFrame[2]
				let up    = .controllerKeyDownFrame[3]
				if right or left: .controller.leftStick.x = right >= left ? 1 : -1
				if down  or up:   .controller.leftStick.y = down  >= up   ? 1 : -1
				if .controllerKeyDownFrame[4]: .controller.a.state = true
				if .controllerKeyDownFrame[5]: .controller.b.state = true
				if .controllerKeyDownFrame[6]: .controller.x.state = true
				if .controllerKeyDownFrame[7]: .controller.y.state = true
				.controller.inMotion = abs(.controller.leftStick.x) >= GameController.deadZone
				                    or abs(.controller.leftStick.y) >= GameController.deadZone
						
	updateUserIndices
		users.orderBy.id
		for users
			.index = i
			internalUsers[.id].index = i
				
	// Do something when the user touches or clicks within a given area
	onTouchDownWithin: Vector2 position = {}      // The center of the touch area
		               Vector2 size               // The size of a rectangular touch area
		               int userId = -1            // Only consider touches or clicks from this user  
		               string cursor = ""         // Change the mouse cursor image when hovering over this area
		               bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) do       // Do this for each touch or click
		Vector2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	onTouchDownWithin: Vector2 position           // The center of the touch area
		               Vector2 size               // The size of a rectangular touch area
		               int[] userId               // Only consider touches or clicks from this user  
		               string cursor = ""         // Change the mouse cursor image when hovering over this area
		               bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) do       // Do this for each touch or click
		Vector2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if not (Network.mode == Connected || Network.simulateConnection)
			userId = null
			
		for users -> user
			if userId == null or userId.contains(.id)
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						do touch
						if markAsHandled: touch.handled = true
		if cursor
			for localUser.movingTouches -> touch
				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
					this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Do something when the user touches or clicks within a given area
	onTouchDownWithin: Vector2 position           // The center of the touch area
		               Vector2 size               // The size of a rectangular touch area
		               Angle angle                // Rotate the touch area by this angle
		               int userId = -1            // Only consider touches or clicks from this user  
		               string cursor = ""         // Change the mouse cursor image when hovering over this area
		               bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) do       // Do this for each touch or click
		Vector2[] poly = [
			(position + Vector2( -size.x/2, -size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
			(position + Vector2( +size.x/2, -size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
			(position + Vector2( +size.x/2, +size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
			(position + Vector2( -size.x/2, +size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch) 
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	onTouchDownWithin: Vector2 position           // The center of the touch area
		               Vector2 size               // The size of a rectangular touch area
		               Angle angle                // Rotate the touch area by this angle
		               int[] userId               // Only consider touches or clicks from this user  
		               string cursor = ""         // Change the mouse cursor image when hovering over this area
		               bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) do       // Do this for each touch or click
		Vector2[] poly = [
			(position + Vector2( -size.x/2, -size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
			(position + Vector2( +size.x/2, -size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
			(position + Vector2( +size.x/2, +size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
			(position + Vector2( -size.x/2, +size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
		]
		if not (Network.mode == Connected || Network.simulateConnection)
			userId = null
			
		for users -> user
			if userId == null or userId.contains(.id)
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Do something when the user touches or clicks within a given circle
	onTouchDownWithin: Vector2 position           // The center of the touch area
		               float radius               // The radius of a round touch area
		               int userId = -1            // Only consider touches or clicks from this user  
		               string cursor = ""         // Change the mouse cursor image when hovering over this circle
		               bool showTouchArea = false // Draw a red circle to visualize that area to touch
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) do       // Do this for each touch or click
		let referencePosition = position.getTransformed(graphics.localMatrix)
		let referenceRadius = radius * graphics.localMatrix.scaleVector.x
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if !touch.handled  and (user.enableTouch or touch.type != Touch)
					and (touch.referencePosition distanceTo referencePosition) <= referenceRadius
						log "down", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and (touch.referencePosition distanceTo referencePosition) <= referenceRadius
						log "down", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && (touch.referencePosition distanceTo position) <= radius
						this.cursor = cursor
				
		if showTouchArea: drawCircle position, radius*2, fillColor:{"ff000080"}

	// Do something when the user touches or clicks within a given polygon
	onTouchDownWithin: Vector2 position           // The center of the touch area
		               Vector2[] points           // The points that define the touch area
		               int userId = -1            // Only consider touches or clicks from this user  
		               string cursor = ""         // Change the mouse cursor image when hovering over this polygon
		               bool showTouchArea = false // Draw a red polygon to visualize that area to touch
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) do       // Do this for each touch or click
		Vector2[] poly
		for points: poly.add (position + .).transform(graphics.localMatrix)
			
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawPolygon position, points, fillColor:{"ff0000b0"}

	// Do something when the user touches or clicks within a given area
	onTouchUpWithin: Vector2 position           // The center of the touch area
		             Vector2 size               // The size of a rectangular touch area
		             int userId = -1            // Only consider touches or clicks from this user
		             bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		             bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		             void(Touch touch) do       // Do this for each touch or click
		Vector2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.upTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						log "up", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
						Snapshot.autoSave
		else
			for users -> user
				for internalUsers[user.id].upTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						log "up", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
						Snapshot.autoSave
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	onTouchUpWithin: Vector2 position           // The center of the touch area
		             Vector2 size               // The size of a rectangular touch area
		             int[] userId               // Only consider touches or clicks from this user
		             bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		             bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		             void(Touch touch) do       // Do this for each touch or click
		Vector2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if not (Network.mode == Connected || Network.simulateConnection)
			userId = null
		for internalUsers -> user
			if user and (userId == null or userId.contains(.id))
				for user.upTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						log "up", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
						Snapshot.autoSave
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Do something when the user touches or clicks within a given area
	onTouchUpWithin: Vector2 position           // The center of the touch area
		             float radius               // The radius of a round touch area
		             int userId = -1            // Only consider touches or clicks from this user  
		             string cursor = ""         // Change the mouse cursor image when hovering over this area
		             bool showTouchArea = false // Draw a red circle to visualize that area to touch
		             bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		             void(Touch touch) do       // Do this for each touch or click
		let referencePosition = position.transform(graphics.localMatrix)
		let referenceRadius = radius * graphics.localMatrix.scaleVector.x
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.upTouches -> touch
					if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
						log "up", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
						Snapshot.autoSave
		else
			for users -> user
				for internalUsers[user.id].upTouches -> touch
					if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
						log "up", touch.referencePosition
						do touch
						if markAsHandled: touch.handled = true
						Snapshot.autoSave
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && (touch.referencePosition distanceTo position) <= radius
						this.cursor = cursor
				
		if showTouchArea: drawCircle position, radius*2, fillColor:{"ff000080"}

	onTouchOver: Vector2 position           // The center of the touch area
		         Vector2 size               // The size of a rectangular touch area
		         int userId = -1            // Only consider touches or clicks from this user  
		         string cursor = ""         // Change the mouse cursor image when hovering over this area
		         bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		         bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		         void(Touch touch) do       // Do this for each touch or click
		Vector2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for user.touches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						log "over", touch.referencePosition
						do touch
		else
			for users -> user
				for user.touches -> touch
					if touch.referencePosition.isInsidePoygon(poly)
						log "over", touch.referencePosition
						do touch
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Do something when the user touches or clicks
	onTouchDown: int userId = -1      // Only consider touches or clicks from this user
		         void(Touch touch) do // Do this for each touch or click
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
						log "down", touch.referencePosition
						do touch
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
						log "down", touch.referencePosition
						do touch

	// Do something when the user touches, even if the touch is already handled
	onTouchDownAny: int userId = -1      // Only consider touches or clicks from this user
		            void(Touch touch) do // Do this for each touch or click
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if user.enableTouch or touch.type != Touch
						log "down", touch.referencePosition
						do touch
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if user.enableTouch or touch.type != Touch
						log "down", touch.referencePosition
						do touch
			
	// Do something when a touch or click moves
	onTouchMove: Touch touch          // Only do this if this particular touch or click moves
		         void(Touch touch) do // Do this for each touch or click
		if !touch: return
		let touchId = touch.id
		let user = internalUsers[touch.userId]
			for user.movingTouches
				if .id == touchId
					log "move", .referencePosition
					do .
	
	// Do something when a touch or click moves
	onTouchMove: int userId = -1      // Only consider touches or clicks from this user
		         void(Touch touch) do // Do this for each touch or click
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.movingTouches -> t
					log "move", t.referencePosition
					do t
		else
			for internalUsers -> user if .
				for user.movingTouches -> t
					log "move", t.referencePosition
					do t
					
	onTouchUp: Touch touch               // Only do this if this particular touch or click ended
		       bool markAsHandled = true // Mark the touch as handled so it won't trigger more touch events
		       void(Touch touch) do      // Do this for each touch or click
		if !touch: return
		let touchId = touch.id
		let user = internalUsers[touch.userId]
			for user.upTouches
				if .id == touchId
					log "up", .referencePosition
					do .
					Snapshot.autoSave
					if markAsHandled: .handled = true
				
	// Do something when a touch or click ends
	onTouchUp: int userId = -1
		       bool markAsHandled = true // Mark the touch as handled so it won't trigger more touch events
		       void(Touch touch) do      // Do this for each touch or click
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.upTouches -> t
					if !t.handled
						log "up", t.referencePosition
						do t
						Snapshot.autoSave
		else
			for internalUsers -> user if .
				for user.upTouches -> t
					if !t.handled
						log "up", t.referencePosition
						do t
						Snapshot.autoSave
						
	private log: string text, Vector2 pos
		if Network.logging: Network.touchLog += " #{Network.frame}{isCertain ? " c" : ""} {text} {pos}"

	// Do something when a user moves the mouse wheel
	onWheel: void(WheelEvent event) do // Do this for each mouse wheel movement
		for internalUsers -> user if .
			for user.wheelEvents
				do .
	
	// Do something when a user moves the mouse wheel within a given rectangle
	onWheelWithin: Vector2 position            // The center of the rectangle
		           Vector2 size                // The size of the rectangle
		           int userId = -1             // Only consider wheel movments from this user
		           bool showTouchArea = false  // Draw a red rectangle to visualize that area to touch
		           bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
		           void(WheelEvent event) do   // Do this for each mouse wheel movement
		Vector2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.wheelEvents -> event
					if !event.handled && event.referencePosition.isInsidePoygon(poly)
						log "wheel", event.referencePosition
						do event
						if markAsHandled: event.markAsHandled
		else
			for internalUsers -> user if .
				for user.wheelEvents -> event
					if !event.handled && event.referencePosition.isInsidePoygon(poly)
						log "wheel", event.referencePosition
						do event
						if markAsHandled: event.markAsHandled
		if showTouchArea: drawRectangle position, size, Red
			
	onWheelWithin: Vector2 position            // The center of the rectangle
		           Vector2 size                // The size of the rectangle
		           int[] userId               // Only consider wheel movments from this user
		           bool showTouchArea = false  // Draw a red rectangle to visualize that area to touch
		           bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
		           void(WheelEvent event) do   // Do this for each mouse wheel movement
		Vector2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if not (Network.mode == Connected || Network.simulateConnection)
			userId = null

		for internalUsers -> user
			if user and (userId == null or userId.contains(.id))
				for user.wheelEvents -> event
					if !event.handled && event.referencePosition.isInsidePoygon(poly)
						log "wheel", event.referencePosition
						do event
						if markAsHandled: event.markAsHandled
		if showTouchArea: drawRectangle position, size, Red
			
	bool isTextInputActive = false
	
	private js object getOrCreateInputField
		if(!window._input) {
			window._input = document.createElement("input")
			_input.type = "text"
			_input.style.position = "absolute"
			_input.style.left = "-10000px" 
			_input.style.width = "1px"
			_input.style.height = "1px"
			_input.style.fontSize = "1px"
			_input.style.backgroundColor = "#000000"
			_input.oninput = e => Input_handleTextInput(7, _input.value)
			_input.onblur = e => {
				if(Input_isTextInputActive) {
					_input.focus()
				}
			}
			document.body.appendChild(_input)
		}
		return _input
				
	js void startTextInput: string initalValue = null, int forUser = -1
		if(forUser == -1 || Input_localUser?.id == forUser) {
			let input = Input_getOrCreateInputField()
			if(initalValue != null) { 
				input.value = initalValue
			}
			_input.focus()
			Input_isTextInputActive = true
		}
		
	js void stopTextInput
		Input_isTextInputActive = false
		
	js void setTextInput: string value
		let input = Input_getOrCreateInputField()
		input.value = value
		Input_handleTextInput(7, value)
		
	js void updateCursor
		document.body.style.cursor = Input_cursor

	onTextComposition: void(string characters) do
		for internalUsers -> user if .
			for user.textCompositions -> text
				do text
				
	onTextInput: int userId = -1, void(string textInput) do
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.textInputs -> text
					do text
		else
			for internalUsers -> user if .
				for user.textInputs -> text
					do text
				
	onKeyDown: Key key
		       int userId = -1
		       void(Key key, int keyUserId) do
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.downKeys
					if . == key
						do key, userId
		else
			for internalUsers -> user if .
				for user.downKeys
					if . == key
						do key, user.id
				
	onKeyDown: Key key
		       int[] userId
		       void(Key key, int keyUserId) do
		if not (Network.mode == Connected || Network.simulateConnection)
			userId = null
		for internalUsers -> user
			if user and (userId == null or userId.contains(.id))
				for user.downKeys
					if . == key
						do key, user.id
				
	onKeyDown: int userId = -1, void(Key key, int keyUserId) do
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.downKeys -> key
					do key, userId
		else
			for internalUsers -> user if .
				for user.downKeys -> key
					do key, user.id
				
	onKeyUp: int userId = -1, void(Key key, int keyUserId) do
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.upKeys -> key
					do key, userId
		else
			for internalUsers -> user if .
				for user.upKeys -> key
					do key, user.id
					
	onKeyPressed: int userId = -1, void(string key, int keyUserId) do
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.pressedKeys -> key
					do key, userId
		else
			for internalUsers -> user if .
				for user.pressedKeys -> key
					do key, user.id
			
	// Do something when the user navigates back or forward in the browser	
	onNavigate: int userId = -1
		        void(string url) do
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.navigations -> url
					do url
		else
			for internalUsers -> user if .
				for user.navigations -> url
					do url
				

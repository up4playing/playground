// The internal state of a user that isn't serialized and shoudn't be accessed by the application
transient class InternalUser
	int id              // This id stays the same when a user reconnects
	bool local          // Is this the local user?
	int connectionId    // The connectionId increases with every connection, even if the same user reconnects
	int index
	bool active
	
	// Event Stream
	bool collectInputs       // When we are done pinging, we add a join event and start collecting inputs
	int inputFrame = -1      // We got all inputs from this player up to and including this frame
	int inputsSentPos
	int[] lastTouchMoveIndex
	Buffer inputs = {}       // The stream of inputs of this user
	
	// List of inputs filled by parseInput and used by onTouchDown, onWheel, onKeyDown, ...
	visible Touch[] downTouches, movingTouches, upTouches
	visible WheelEvent[] wheelEvents
	visible Key[] downKeys, upKeys
	visible string[] pressedKeys, textInputs, textCompositions
	visible string[] navigations

	// Video + Audio
	object mediaStream
	object[] videoElements
	object audioElement
	int videoElementIndex = 0
	
	// Connection
	object peerConnection
	object dataChannel
	object recreateDataChannelInterval
	string connectionType
	bool offerByMe
	bool receivedAnswer
	int nextLostMessageAtFrame
	
	// Statistics
	private int[] aheads                   // Rolling buffer of ahead values, used to calculate bufferFrames
	private int[] aheadsMax                // Rolling buffer of aheadMax values
	visible int bufferFrames               // The average of all aheadMax values
	visible int smoothFrame = int.maxValue
	
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
		
	collectStatistics: int frame
		int ahead = frame - inputFrame
		if ahead < 50: aheads.add ahead, maxLength:200
		int aheadMax = aheads.max .
		aheadsMax.add aheadMax maxLength:600
		bufferFrames = Math.ceil(aheadsMax.average)
		// bufferFrames = 10
		smoothFrame = frame - bufferFrames
		
	simulateRollback: int frame
		bufferFrames = 5
		smoothFrame = frame - bufferFrames		
		
// The public state of a player. This is the same accross all clients.
class Player
	int id
	int index
	Color color = null
	
	toString := color ? color.name : ""
	
	// Touch input
	internal Touch[] touches
	internal bool enableTouch = true
	
	// Text input
	internal string textInput
	internal Key[] keysCurrentlyDown
	
	// Controller input
	visible GameController controller = {}
	internal int[] controllerKeyDownFrame = [0, 0, 0, 0, 0, 0]
	
	// If a player was lost by anybody and nobody who is still connected to that player
	// disagrees within a certrain time, we will remove this player in "handleLost"
	internal int lostAtFrame
	
	internal bool isReadyInLobby
	
	// The current player instance, equivalent to "this"
	inline js Player me() this

	internal clearEvents
		bool hasTouch = touches.any.type == Touch
		for touches <-
			if (.phase == Up and .type >= Touch) or (hasTouch and .type != Touch)
				touches.remove .
	
enum InputType: None, TouchDown, TouchMove, TouchUp, Wheel, KeyDown, KeyUp, TextInput, Stick, Trigger, Grip, ButtonDown, ButtonUp, ControllerTransform, HeadTransform, DeviceRotation, Join, Lost, StillConnected, SetState, Navigate, GameController, String, Json, Object
		
// Phase of a touch or a click
enum TouchPhase: Still, Down, Move, Up
		
enum TouchType: Left, Middle, Right, Touch, Pen

// A touch or a click
class Touch
	int id
	Player by
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
	
	markAsHandled() handled = true
	
transient class WheelEvent
	int userId
	Vector2 delta
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
	
struct DigitalButton
	string name
	Key key
	
	bool state, prevState
	bool down := state and not prevState
	bool up   := not state and prevState
	
	toString := name
	
	internal assign: string name, Key key
		this.name = name
		this.key = key
		state = false
		prevState = false
	
	internal startFrame
		prevState = state
		state = false
		
transient struct ControllerButtonPlayerAndIndex
	int userId
	int buttonIndex
	
enum GameControllerType: Keyboard, Xbox, PlayStation
class GameController
	static deadZone = .1
	
	visible Vector2 leftStick
	visible Vector2 rightStick
	visible DigitalButton right
	visible DigitalButton down
	visible DigitalButton left
	visible DigitalButton up
	visible DigitalButton a
	visible DigitalButton b
	visible DigitalButton x
	visible DigitalButton y
	visible DigitalButton[] buttons = [right, down, left, up, a, b, x, y]
	
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
	
enum ShowPointersMode
	None   // Never show the mouse pointer
	Remote // Show the mouse pointer only for remote players
	Local  // Show the mouse pointer only for the local player
	All    // Show the mouse pointers of all players
	
// A collection of methods to receive input
skipInit global unit Input
	transient visible InternalUser[] internalUsers
	transient InternalUser localUser
	transient internal Player localPlayer
	transient bool isCertain
	transient ControllerButtonPlayerAndIndex[Key] controllerButtonMap

	global Player[] players
	internal Player[] playersById
	string cursor
	
	ShowPointersMode showPointers = Remote
	bool ignoreFirstClick
	
	string textInput
		let localPlayer = playersById[Input.localUser.id]
		return localPlayer.textInput
	
	internal init
		initHandlers
	
	internal js Vector2 logicalToPixelPosition: Vector2 pos
		let p = pos.getTransformed(graphics_totalMatrix)
		return new Vector2(p.x/Platform_pixelRatio, p.y/Platform_pixelRatio, null)

	private js void initHandlers
		window.onpointerdown = e => {
			if(e.button == 0 && Platform_mode == 0) {
				Platform_record();
				if(Input_ignoreFirstClick) return;
			}
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
			Input_handleWheelEvent(e.pageX, e.pageY, -e.deltaX, -e.deltaY)
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
				statistics_manuallyTriggerSend(-2, /*clear*/false);
				Network_saveLogs();
				e.preventDefault();
			}
			else
			if((key == "F1" || key == "F2" || key == "F3" || key == "F4") && !ctrlOrCmd && Platform_isDebug) {
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
				else           { Platform_toggleDebugInfo(); }
				e.preventDefault();
			} else if(key == "F10") { 
				Platform_toggleSmallScreen();
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
			
		// Handles navigating back or forward in the browser	
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
			
	internal handleKeyEvent: InputType inputType, Key keyCode, string key
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		int composite = cast inputType                                  // inputType:   0 - 31 (5 bit)
		
		let controllerButton = controllerButtonMap[keyCode]
			composite += (controllerButton.buttonIndex + 1) shiftLeft 5 // buttonIndex: 0 - 15 (4 bit)
			if Network.mode == Local and not Network.simulateConnection
				inputs = internalUsers[controllerButton.userId].inputs
			
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt32 cast keyCode
		if inputType == KeyDown: inputs.writeString key
		
	internal handleTouchEvent: InputType inputType, float x, float y, string pointerType, int pointerId, int button, shift = false, alt = false, cmdOrCtrl = false
		int touchType, id
		if pointerType == "mouse": touchType = button.limit(0..2); else
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
	
	internal handleUpdateTouchAfterSwitchingUser: int id, Vector2 referencePos
		let inputs = localUser.inputs
		int composite = cast(InputType.TouchMove)                       // inputType: 0 -  31 (5 bit)
		              + Math.shiftLeft(cast TouchType.Left, 5)          // touchType: 0 -   7 (3 bit)
		              + Math.shiftLeft(Math.floor(Math.abs(id))%128, 8) // id:        0 - 127 (7 bit)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 Math.round(referencePos.x)
		inputs.writeInt16 Math.round(referencePos.y)
	
	private handleWheelEvent: float x, float y, float deltaX, float deltaY
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		
		Vector2 referencePos = {x*Platform.pixelRatio, y*Platform.pixelRatio}.getRelativeTo(Platform.baseMatrix)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast InputType.Wheel
		inputs.writeInt16 Math.round(referencePos.x)
		inputs.writeInt16 Math.round(referencePos.y)
		inputs.writeInt16 Math.round(deltaX)
		inputs.writeInt16 Math.round(deltaY)
		if Network.logging: Network.writeLog += " [{localUser.inputFrame}] wheel {Math.round(referencePos.x)} {Math.round(referencePos.y)} {deltaX} {deltaY} \{r:{inputs.readPos} w:{inputs.writePos}\}"
		
	internal handleSetState: Buffer buffer
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast InputType.SetState
		inputs.writeBuffer buffer
		
	internal handleJoin: int frame
		let inputs = localUser.inputs
		inputs.writeInt32 frame
		inputs.writeInt16 cast InputType.Join
				
	// Handles navigating back or forward in the browser	
	internal handleNavigate: string url
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.Navigate
		inputs.writeString url
		
	// Post lost messages and remove players if nobody disagrees
	internal handleLost
		if Network.mode < Local or !lobby.inLobby: return
		for players <- player
			let internalUser = internalUsers[.id]
				if player.lostAtFrame and Network.frame > player.lostAtFrame + Network.targetFps * 3
					// If a player was lost by anybody and nobody who is still connected to that player
					// disagrees within a certrain time, we remove this player
					Network.log "Removing player {player.id} at frame {Network.frame}, player was lost at frame {player.lostAtFrame} and nobody disagreed", isCertain
					players.remove player
					playersById[player.id] = null
					internalUser.active = false
					updatePlayers
				else	
				if Network.frame > internalUser.inputFrame + Network.targetFps * 8
				and Network.frame > internalUser.nextLostMessageAtFrame
					// If we lost the connection to a player, we post a lost message to everybody every 12 seconds
					Network.log "Sending lost message for player {player.id} at frame {Network.frame}", internalUser.inputFrame
					let inputs = localUser.inputs
					inputs.writeInt32 localUser.inputFrame
					inputs.writeInt16 cast InputType.Lost
					inputs.writeInt16 player.id
					internalUser.nextLostMessageAtFrame = Network.frame + Network.targetFps * 12
					
					// Send logfiles to server
					Platform.setTimeout 7 seconds: statistics.manuallyTriggerSend -3, clear:false
	
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
		inputs.writeFloat32 Math.abs(leftStickX) > GameController.deadZone ? leftStickX : 0
		inputs.writeFloat32 Math.abs(leftStickY) > GameController.deadZone ? leftStickY : 0
		inputs.writeUnsignedInt16 buttons
			
	internal parseInputs: int frame
		for internalUsers -> internalUser if internalUser
			let inputs = internalUser.inputs
			let userId = internalUser.id
			let player = playersById[userId]
			if Network.logging: Network.parseLog += " <{userId}>"
			player?.controller.startFrame
			
			while true
				int nextFrame = inputs.canRead ? inputs.peekInt32 : int.maxValue
				if Network.logging: 
					Network.parseLog += " ({inputs.readPos}/{inputs.writePos})"
					if inputs.canRead: Network.parseLog += " *{nextFrame}"
				if nextFrame > frame: break
				inputs.readPos += 4
				
				// We create the player as soon as we receive the first input from that player,
				// which is typically the "Join" message that is sent in "startConnected",
				// but could also be a player reconnecting that was previously kicked out
				if not player
					Network.log "#{frame} Add {userId}"
					if Network.logging: Network.parseLog += " Add {userId}"
					players.add player = {id:userId, index:players.length}
					playersById[userId] = player
					if internalUser.local: localPlayer = player
					internalUser.active = true
					updatePlayers
				
				let value = inputs.readUnsignedInt16
				InputType inputType = cast(value % 32)
				
				if inputType >= TouchDown && inputType <= Wheel
					if !player: Network.log " ERROR: userId {userId} not in playersById"
					TouchType type = cast((value shiftRight 5) % 8)
					int id = (value shiftRight 8) % 128
					Vector2 referencePos = {inputs.readInt16, inputs.readInt16}
					bool isSmoothPosition = !Network.smoothTouchPosition or internalUser.local or frame <= internalUser.smoothFrame
					if Network.logging: Network.parseLog += " "+id
					
					if inputType == TouchDown
						let touch = player.touches.find.id == id
						if touch
							// Update the touch in player.touches
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
							touch = {id, player, cast inputType, type, referencePos, referencePos, referencePos, isDown:true}
							player.touches.add touch
							if Network.logging: Network.parseLog += " down(new) {id} {referencePos} {type}"
							
						internalUser.downTouches.add touch
					else
					if inputType == TouchMove
						let touch = player.touches.find.id == id
						if touch
							// Update the touch in player.touches
							touch.phase = cast inputType
							touch.referencePosition = referencePos
							touch.type = type
							if isSmoothPosition: touch.smoothPosition = referencePos
							if Network.logging: Network.parseLog += " move {id} {referencePos} {type}"
						else
							touch = {id, player, cast inputType, type, referencePos, referenceStartPosition:Vector2.none, referencePos, isDown:false}
							player.touches.add touch
							if Network.logging: Network.parseLog += " move(new) {id} {referencePos} {type}"

						internalUser.movingTouches.add touch
						cursor = "auto"
					else
					if inputType == TouchUp
						let touch = player.touches.find.id == id
						if touch
							// Update the touch in player.touches
							touch.phase = cast inputType
							touch.referencePosition = referencePos
							touch.type = type
							touch.isDown = false
							if isSmoothPosition: touch.smoothPosition = referencePos
							if Network.logging: Network.parseLog += " up {id} {referencePos} {type}"
						else
							touch = {id, player, cast inputType, type, referencePos, referenceStartPosition:Vector2.none, referencePos, isDown:false}
							player.touches.add touch
							if Network.logging: Network.parseLog += " up(new) {id} {referencePos} {type}"
							
						internalUser.upTouches.add touch
					else
					if inputType == Wheel
						Vector2 delta = {inputs.readInt16, inputs.readInt16}
						internalUser.wheelEvents.add {player.id, delta, referencePosition:referencePos}
				else
				if inputType == TextInput
					let textInput = inputs.readString
					player.textInput = textInput
					internalUser.textInputs.add textInput
				else
				if inputType == KeyDown
					Key key = cast inputs.readInt32
					let keyPressed = inputs.readString
					internalUser.downKeys.add key
					player.keysCurrentlyDown.ensure key
					if keyPressed: internalUser.pressedKeys.add keyPressed
						
					int controllerButtonIndex = cast((value shiftRight 5) % 16)
						player.controllerKeyDownFrame[controllerButtonIndex-1] = frame
					
					if Network.logging: Network.parseLog += " KeyDown {key}"
				else
				if inputType == KeyUp
					Key key = cast inputs.readInt32
					internalUser.upKeys.add key
					player.keysCurrentlyDown.remove key
					
					int controllerButtonIndex = cast((value shiftRight 5) % 16)
						player.controllerKeyDownFrame[controllerButtonIndex-1] = 0
					
					if Network.logging: Network.parseLog += " KeyUp {key}"
				else
				if inputType == Navigate
					internalUser.navigations.add inputs.readString
				else
				if inputType == GameController
					GameController c = player.controller
					
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
					// We created the player above as soon as received the first input from that player,
					// which is typically the "Join" message that is sent in "startConnected",
					// but could also be a player reconnecting that was previously kicked out
					Network.log "#{frame} Join {userId}", isCertain
					if Network.logging: Network.parseLog += " Join {userId}"
				else
				if inputType == Lost
					let lostUserId = inputs.readInt16
					let lostInternalUser = internalUsers[lostUserId]
						let lostPlayer = playersById[lostUserId]
						
						// If a player was lost by anybody and nobody who is still connected to that player
						// disagrees within a certrain time, we will remove this player in "handleLost"
						if lostPlayer and lostPlayer.lostAtFrame == 0
							lostPlayer.lostAtFrame = frame
							Network.log "Lost {lostUserId} by {userId} -> Set lostAtFrame to {lostPlayer.lostAtFrame}"
							
						// If we are still connected to that player, we disagree to their removal
						// by posting the "StillConnected" message
						if lostInternalUser.dataChannel and Network.frame < lostInternalUser.inputFrame + Network.targetFps * 5
							Network.log "Lost {lostUserId} by {userId} -> We are still connected, sending StillConnected", lostInternalUser.dataChannel, Network.frame, lostInternalUser.inputFrame, isCertain
							handleStillConnected lostUserId
						else
							Network.log "Lost {lostUserId} by {userId} -> We also aren't connected", lostInternalUser.dataChannel, Network.frame, lostInternalUser.inputFrame, isCertain
					else
						Network.log "Lost {lostUserId} by {userId} -> No internal user!"
				else
				if inputType == StillConnected
					// Somebody disagreed with the removal of that player because they are still connected,
					// so we cancel the removal
					let lostUserId = inputs.readInt16
					Network.log "Still connected to {lostUserId} by {userId}"
					let lostPlayer = playersById[lostUserId]
						lostPlayer.lostAtFrame = 0
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
					if Platform.waitingForInitialData > 0: Platform.waitingForInitialData--
				else
				if inputType == Json
					int id = inputs.readInt
					string value = inputs.readString
					if Network.logging: Network.parseLog += " json {id}: {value}"
					dynamic object = Json.parse value
					networkData.call id, object
					if Platform.waitingForInitialData > 0: Platform.waitingForInitialData--
				else
				if inputType == Object
					int id = inputs.readInt
					string value = inputs.readString
					if Network.logging: Network.parseLog += " object {id}: {value}"
					dynamic object = Json.parse value
					networkData.call id, object
					if Platform.waitingForInitialData > 0: Platform.waitingForInitialData--
	
		for players
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
				.controller.inMotion = Math.abs(.controller.leftStick.x) >= GameController.deadZone
				                    or Math.abs(.controller.leftStick.y) >= GameController.deadZone
						
	internal updatePlayers
		players.orderBy.id
		for players
			.index = i
			.color = graphics.defaultColors[i]
			internalUsers[.id].index = i
			
		if Network.mode == Local and not Network.simulateConnection
			if players.length >= 1
				GameController c = players[0].controller
				if c.type == Keyboard
					c.right.assign "→"     Right
					c.down.assign  "↓"     Down
					c.left.assign  "←"     Left
					c.up.assign    "↑"     Up
					c.a.assign     "SPACE" Space
					c.b.assign     "B"     B
			
			if players.length >= 2
				GameController c = players[1].controller
				if c.type == Keyboard
					c.right.assign "D"     D
					c.down.assign  "S"     S
					c.left.assign  "A"     A
					c.up.assign    "W"     W
					c.a.assign     "F"     F
					c.b.assign     "G"     G
			
			if players.length >= 3
				GameController c = players[2].controller
				if c.type == Keyboard
					c.right.assign "L"     L
					c.down.assign  "K"     K
					c.left.assign  "J"     J
					c.up.assign    "I"     I
					c.a.assign     "O"     O
					c.b.assign     "P"     P
			
			controllerButtonMap.clear
			for players -> player
				for .controller.buttons
					controllerButtonMap[.key] = {userId:player.id, buttonIndex:i}
		else
			controllerButtonMap.clear
			for players
				GameController c = .controller
				if c.type == Keyboard
					c.right.assign "→"     Right
					c.down.assign  "↓"     Down
					c.left.assign  "←"     Left
					c.up.assign    "↑"     Up
					c.a.assign     "SPACE" Space
					c.b.assign     "B"     B
			
			controllerButtonMap.clear
			for localPlayer.controller.buttons
				controllerButtonMap[.key] = {userId:localPlayer.id, buttonIndex:i}
				
			controllerButtonMap[D] = {userId:localUser.id, buttonIndex:0}
			controllerButtonMap[S] = {userId:localUser.id, buttonIndex:1}
			controllerButtonMap[A] = {userId:localUser.id, buttonIndex:2}
			controllerButtonMap[W] = {userId:localUser.id, buttonIndex:3}
			
		
	// Returns true if given key is currently held down
	isKeyDown: Key key          // The key to check
		       Player by = null // Only consider key presses by this player 
		if (Network.mode == Connected || Network.simulateConnection) && by
			let player = playersById[by.id]
				return player.keysCurrentlyDown.contains key
		else
			return players.any.keysCurrentlyDown.contains key
		return false
		
	private log: string text, Vector2 pos
		if Network.logging: Network.touchLog += " #{Network.frame}{isCertain ? " c" : ""} {text} {pos}"

	private getTargetedPlayers: Player[] by
		return (Network.mode == Connected || Network.simulateConnection) && by ? by : players
		
	// ---------------------------------------------- Touch Down ----------------------------------------------
	
	// Do something when the player touches or clicks within a given area
	onTouchDownWithin: Vector2 position                   // The center of the touch area
		               Vector2 size                       // The size of a rectangular touch area
		               implicit nocolon Player[] by = null        // Only consider touches or clicks by this player of list of players  
		               string cursor = ""                 // Change the mouse cursor image when hovering over this area
		               bool showTouchArea = false         // Draw a red rectangle to visualize that area to touch
		               bool markAsHandled = true          // Mark the touch as handled so it won't trigger more touch events
		               HorizontalAlignment align = Center // The horizontal alignment of the touch area
		               VerticalAlignment valign = Middle  // The vertical alignment of the touch area
		               void(Touch touch) do               // Do this for each touch or click
		let sizeX = size.x
		let sizeY = size.y || size.x
		let x = align == Left ? position.x : align  == Center ? position.x-sizeX/2 : position.x-sizeX
		let y = valign == Top ? position.y : valign == Middle ? position.y-sizeY/2 : position.y-sizeY
		Vector2[] poly = [
			{ x,         y         }.transform(graphics.localMatrix),
			{ x + sizeX, y         }.transform(graphics.localMatrix),
			{ x + sizeX, y + sizeY }.transform(graphics.localMatrix),
			{ x,         y + sizeY }.transform(graphics.localMatrix),
		]
		
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].downTouches -> touch
				if !touch.handled and (player.enableTouch or touch.type != Touch)
				and touch.referencePosition.isInsidePoygon(poly)
					do touch
					if markAsHandled: touch.handled = true
						
		if cursor
			for localUser.movingTouches -> touch
				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
					this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}, align, valign, layer:10000000

	// Do something when the player touches or clicks within a given rotated rectangle
	onTouchDownWithin: Vector2 position                   // The center of the touch area
		               Vector2 size                       // The size of a rectangular touch area
		               Angle angle                        // Rotate the touch area by this angle
		               implicit nocolon Player[] by = null        // Only consider touches or clicks by this player of list of players
		               string cursor = ""                 // Change the mouse cursor image when hovering over this area
		               bool showTouchArea = false         // Draw a red rectangle to visualize that area to touch
		               bool markAsHandled = true          // Mark the touch as handled so it won't trigger more touch events
		               HorizontalAlignment align = Center // The horizontal alignment of the touch area
		               VerticalAlignment valign = Middle  // The vertical alignment of the touch area
		               void(Touch touch) do               // Do this for each touch or click
		let halfSizeX = size.x/2
		let halfSizeY = (size.y || size.x)/2
		let x = align == Left ? position.x+halfSizeX : align  == Center ? position.x : position.x-halfSizeX
		let y = valign == Top ? position.y+halfSizeY : valign == Middle ? position.y : position.y-halfSizeY
		Vector2[] poly = [
			{ -halfSizeX, -halfSizeY }.rotate(angle).move(x,y).transform(graphics.localMatrix),
			{ +halfSizeX, -halfSizeY }.rotate(angle).move(x,y).transform(graphics.localMatrix),
			{ +halfSizeX, +halfSizeY }.rotate(angle).move(x,y).transform(graphics.localMatrix),
			{ -halfSizeX, +halfSizeY }.rotate(angle).move(x,y).transform(graphics.localMatrix),
		]
		
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].downTouches -> touch
				if !touch.handled and (player.enableTouch or touch.type != Touch)
				and touch.referencePosition.isInsidePoygon(poly)
					log "down", touch.referencePosition
					do touch
					if markAsHandled: touch.handled = true
						
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		// if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}, align, valign, layer:10000000
		if showTouchArea: drawPolygon poly, fillColor:{"ff000080"}, layer:10000000

	// Do something when the player touches or clicks within a given circle
	onTouchDownWithin: Vector2 position            // The center of the touch area
		               float radius                // The radius of a round touch area
		               implicit nocolon Player[] by = null // Only consider touches or clicks by this player of list of players  
		               string cursor = ""          // Change the mouse cursor image when hovering over this circle
		               bool showTouchArea = false  // Draw a red circle to visualize that area to touch
		               bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) do        // Do this for each touch or click
		let referencePosition = position.getTransformed(graphics.localMatrix)
		let referenceRadius = radius * graphics.localMatrix.scaleVector.x
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].downTouches -> touch
				if !touch.handled and (player.enableTouch or touch.type != Touch)
				and (touch.referencePosition distanceTo referencePosition) <= referenceRadius
					log "down", touch.referencePosition
					do touch
					if markAsHandled: touch.handled = true
						
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && (touch.referencePosition distanceTo position) <= radius
						this.cursor = cursor
				
		if showTouchArea: drawCircle position, radius*2, fillColor:{"ff000080"}

	// Do something when the player touches or clicks within a given polygon
	onTouchDownWithin: Vector2 position            // The center of the touch area
		               Vector2[] points            // The points that define the touch area
		               implicit nocolon Player[] by = null // Only consider touches or clicks by this player of list of players  
		               string cursor = ""          // Change the mouse cursor image when hovering over this polygon
		               bool showTouchArea = false  // Draw a red polygon to visualize that area to touch
		               bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) do        // Do this for each touch or click
		Vector2[] poly
		for points: poly.add (position + .).transform(graphics.localMatrix)
			
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].downTouches -> touch
				if !touch.handled and (player.enableTouch or touch.type != Touch)
				and touch.referencePosition.isInsidePoygon(poly)
					log "down", touch.referencePosition
					do touch
					if markAsHandled: touch.handled = true
						
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawPolygon position, points, fillColor:{"ff0000b0"}

	// ---------------------------------------------- Touch Up ----------------------------------------------
	
	// Do something when the player ends a touch or click within a given area
	onTouchUpWithin: Vector2 position            // The center of the touch area
		             Vector2 size                // The size of a rectangular touch area
		             implicit nocolon Player[] by = null // Only consider touches or clicks by this player of list of players
		             bool showTouchArea = false  // Draw a red rectangle to visualize that area to touch
		             bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
		             void(Touch touch) do        // Do this for each touch or click
		Vector2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].upTouches -> touch
				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
					log "up", touch.referencePosition
					do touch
					if markAsHandled: touch.handled = true
					Snapshot.autoSave
						
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Do something when the player touches or clicks within a given circle
	onTouchUpWithin: Vector2 position            // The center of the touch area
		             float radius                // The radius of a round touch area
		             implicit nocolon Player[] by = null // Only consider touches or clicks by this player of list of players  
		             string cursor = ""          // Change the mouse cursor image when hovering over this area
		             bool showTouchArea = false  // Draw a red circle to visualize that area to touch
		             bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
		             void(Touch touch) do        // Do this for each touch or click
		let referencePosition = position.transform(graphics.localMatrix)
		let referenceRadius = radius * graphics.localMatrix.scaleVector.x
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].upTouches -> touch
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

	// ---------------------------------------------- Touch Over ----------------------------------------------
	
	// Do something when the mouse moves over a given area
	onTouchOver: Vector2 position            // The center of the touch area
		         Vector2 size                // The size of a rectangular touch area
		         implicit nocolon Player[] by = null // Only consider the mouse from this player  
		         string cursor = ""          // Change the mouse cursor image when hovering over this area
		         bool showTouchArea = false  // Draw a red rectangle to visualize that area to touch
		         bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
		         void(Touch touch) do        // Do this for each touch or click
		Vector2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		for getTargetedPlayers(by) -> player
			for player.touches -> touch
				if touch.referencePosition.isInsidePoygon(poly)
					log "over", touch.referencePosition
					do touch
					
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// ---------------------------------------------- Touch Down ----------------------------------------------
	
	// Do something when the player touches or clicks
	onTouchDown: implicit nocolon Player[] by = null // Only consider touches or clicks by this player of list of players
		         void(Touch touch) do        // Do this for each touch or click
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].downTouches -> touch
				if !touch.handled and (player.enableTouch or touch.type != Touch)
					log "down", touch.referencePosition
					do touch

	// Do something when the player touches or clicks, even if the event is already handled
	onTouchDownAny: implicit nocolon Player[] by = null // Only consider touches or clicks by this player of list of players
		            void(Touch touch) do        // Do this for each touch or click
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].downTouches -> touch
				if player.enableTouch or touch.type != Touch
					log "down", touch.referencePosition
					do touch
			
	// ---------------------------------------------- Touch Move ----------------------------------------------
	
	// Do something when a touch or click moves
	onTouchMove: Touch touch                 // Only do this if this particular touch or click moves
		         triggeredOnTouchDown = true // Also trigger this event right after the player touches or clicks before moving
		         void(Touch touch) do        // Do this for each touch or click
		if !touch: return
		let touchId = touch.id
		let user = internalUsers[touch.by.id]
			if triggeredOnTouchDown
				for user.downTouches
					if .id == touchId
						log "down triggers move", .referencePosition
						do .
			for user.movingTouches
				if .id == touchId
					log "move", .referencePosition
					do .
	
	// Do something when a touch or click moves
	onTouchMove: implicit nocolon Player[] by = null // Only consider touches or clicks by this player of list of players
		         void(Touch touch) do        // Do this for each touch or click
		for getTargetedPlayers(by)
			for internalUsers[.id].movingTouches
				log "move", .referencePosition
				do .
					
	// ---------------------------------------------- Touch Up ----------------------------------------------
	
	// Do something when a touch or click ends
	onTouchUp: Touch touch          // Only do this if this particular touch or click ended
		       markAsHandled = true // Mark the touch as handled so it won't trigger more touch events
		       void(Touch touch) do // Do this for each touch or click
		if !touch: return
		let touchId = touch.id
		let user = internalUsers[touch.by.id]
			for user.upTouches
				if .id == touchId
					log "up", .referencePosition
					do .
					Snapshot.autoSave
					if markAsHandled: .handled = true
				
	// Do something when a touch or click ends
	onTouchUp: implicit nocolon Player[] by = null // Only consider touches or clicks by this player of list of players
		       bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
		       void(Touch touch) do        // Do this for each touch or click
		for getTargetedPlayers(by)
			for internalUsers[.id].upTouches
				if !.handled
					log "up", .referencePosition
					do .
					Snapshot.autoSave
						
	// ---------------------------------------------- Mouse Wheel ----------------------------------------------
	
	// Do something when a player moves the mouse wheel
	onWheel: implicit nocolon Player[] by = null // Only consider touches or clicks by this player of list of players
		     void(WheelEvent event) do   // Do this for each mouse wheel movement
		for getTargetedPlayers(by)
			for internalUsers[.id].wheelEvents
				do .
	
	// Do something when a player moves the mouse wheel within a given rectangle
	onWheelWithin: Vector2 position            // The center of the rectangle
		           Vector2 size                // The size of the rectangle
		           implicit nocolon Player[] by = null // Only consider wheel movments from this player of list of players
		           bool showTouchArea = false  // Draw a red rectangle to visualize that area to touch
		           bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
		           void(WheelEvent event) do   // Do this for each mouse wheel movement
		Vector2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		for getTargetedPlayers(by)
			for internalUsers[.id].wheelEvents
				if !.handled && .referencePosition.isInsidePoygon(poly)
					log "wheel", .referencePosition
					do .
					if markAsHandled: .markAsHandled
						
		if showTouchArea: drawRectangle position, size, Red
			
	// ---------------------------------------------- Text Input ----------------------------------------------
	
	private bool isTextInputActive = false
	
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
		// document.body.style.cursor = (Input_showPointers == 2 && Platform_mode == 4 ? "none" : Input_cursor)
		document.body.style.cursor = Input_cursor

	onTextComposition: void(string characters) do
		for internalUsers -> user if .
			for user.textCompositions -> characters
				do characters
				
	onTextInput: implicit nocolon Player[] by = null // Only consider keys pressed by this player of list of players
		         void(string textInput) do   // Do this for each key that is pressed
		for getTargetedPlayers(by)
			for internalUsers[.id].textInputs -> textInput
				do textInput
				
	// ---------------------------------------------- Keys ----------------------------------------------
	
	// Do something when a player pressed a key
	onKeyDown: Key key                     // The key that will trigger the event
		       implicit nocolon Player[] by = null // Only consider keys pressed by this player of list of players
		       void(Key key, Player pressedBy) do   // Do this for each key that is pressed
		for getTargetedPlayers(by) -> player
			for internalUsers[.id].downKeys
				if . == key
					do key, player
				
	// Do something when a player pressed a key
	onKeyDown: implicit nocolon Player[] by = null        // Only consider keys pressed by this player of list of players
		       void(Key key, Player pressedBy) do // Do this for each key that is pressed
		for getTargetedPlayers(by) -> player
			for internalUsers[.id].downKeys -> key
					do key, player
				
	// Do something when a player releases a key
	onKeyUp: implicit nocolon Player[] by = null        // Only consider keys pressed by this player of list of players
		     void(Key key, Player pressedBy) do // Do this for each key that is released
		for getTargetedPlayers(by) -> player
			for internalUsers[.id].upKeys -> key
				do key, player
					
	// Do something when a player types a character
	onType: implicit nocolon Player[] by = null                 // Only consider keys pressed by this player of list of players
		    void(string character, Player pressedBy) do // Do this for each character that is typed
		for getTargetedPlayers(by) -> player
			for internalUsers[.id].pressedKeys -> character
				do character, player
			
	// ---------------------------------------------- Navigate ----------------------------------------------
	
	// Do something when the user navigates back or forward in the browser	
	onNavigate: implicit nocolon Player[] by = null // Only consider events by this player of list of players
		        void(string url) do         // Do this for each event
		for getTargetedPlayers(by) -> player
			for internalUsers[.id].navigations -> url
				do url
				

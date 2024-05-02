// The internal state of a user that isn't serialized and shoudn't be accessed by the app
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
	visible ScrollEvent[] wheelEvents
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
	private int[] aheadHistory    // Rolling buffer of ahead values, used to calculate bufferFrames
	private int[] maxAheadHistory // Rolling buffer of maxAhead values
	visible int bufferFrames      // The average of all maxAhead values
	visible int smoothFrame = int.maxValue
	
	int certainFrame
	int prevCertainFrame
	
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
		
		// Get the maximum number of frames we were ahead in the last 10 seconds
		if ahead < 50: aheadHistory.add ahead, maxLength:10*core.targetFps
		// int maxAhead = aheadHistory.max .
		int maxAhead = aheadHistory.percentile 80
		
		// Calculate a rolling average of the last 10 minutes
		maxAheadHistory.add maxAhead maxLength:10*60*core.targetFps
		bufferFrames = math.ceil(maxAheadHistory.average)
		smoothFrame = frame - bufferFrames
		
		prevCertainFrame = certainFrame
		certainFrame = math.min inputFrame, smoothFrame
		
	simulateRollback: int frame
		bufferFrames = 5
		smoothFrame = frame - bufferFrames		
		
priority class Player
	int id
	int index
	Color color = null
	string name
	Vector2 pointerPosition
	
	toString := name or (color ? color.name : "")
	
	// Touch input
	internal Touch[] touches
	internal Touch[] downTouches
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
		for touches backwards
			if .phase == Up
				if .type >= Touch or (hasTouch and .type != Touch): touches.removeAt i
				else                                                .phase = Still
				downTouches.remove .
			else
			if .phase == Down
				.phase = Still
	
enum InputType: None, TouchDown, TouchMove, TouchUp, Scroll, KeyDown, KeyUp, TextInput, Stick, Trigger, Grip, ButtonDown, ButtonUp, ControllerTransform, HeadTransform, DeviceRotation, Join, Lost, StillConnected, SetState, Navigate, GameController, String, Json, Object
		
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
	// even if we never check the touch with a input.onTouch method
	
	Vector2 position := referencePosition.getRelativeTo(graphics.localMatrix)
	Vector2 startPosition := referenceStartPosition.getRelativeTo(graphics.localMatrix)
	
	markAsHandled() handled = true
	
transient class ScrollEvent
	immutable int userId
	immutable Vector2 delta
	immutable bool isPinch
	immutable Vector2 referencePosition
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
	Number0      =  48
	Number1      =  49
	Number2      =  50
	Number3      =  51
	Number4      =  52
	Number5      =  53
	Number6      =  54
	Number7      =  55
	Number8      =  56
	Number9      =  57
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
	
enum Cursor
	Pointer = "pointer" // The cursor is a pointer that indicates a link, typically an image of a pointing hand
	Default = "default" // The platform-dependent default cursor, typically an arrow
	Grab = "grab" // Something can be grabbed (dragged to be moved)
	Grabbing = "grabbing" // Something is being grabbed (dragged to be moved)
	NoDrop = "no-drop" // An item may not be dropped at the current location
	NotAllowed = "not-allowed" // The requested action will not be carried out
	Move = "move" // Something is to be moved
	Copy = "copy" // Something is to be copied
	ContextMenu = "context-menu" // A context menu is available
	Help = "help" // Help information is available
	Progress = "progress" // The program is busy in the background, but the user can still interact with the interface
	Wait = "wait" // The program is busy, and the user can't interact with the interface
	Cell = "cell" // The table cell or set of cells can be selected
	Crosshair = "crosshair" // Cross cursor, often used to indicate selection in a bitmap
	Text = "text" // The text can be selected Typically the shape of an I-beam
	VerticalText = "vertical-text" // The vertical text can be selected, typically the shape of a sideways I-beam
	Alias = "alias" // An alias or shortcut is to be created
	AllScroll = "all-scroll" // Something can be scrolled in any direction (on Windows, all-scroll is the same as move)
		
	ResizeCol = "col-resize" // The column can be resized horizontally, typically an left-right arrow with a vertial line
	ResizeRow = "row-resize" // The row can be resized vertically, typically an up-down arrow with a horizontal line
	ResizeN = "n-resize" // The top of of box can be moved
	ResizeE = "e-resize" // The right of of box can be moved
	ResizeS = "s-resize" // The bottom of of box can be moved
	ResizeW = "w-resize" // The left of of box can be moved
	ResizeNE = "ne-resize" // The top right corner of a box can be moved
	ResizeNW = "nw-resize" // The top left corner of a box can be moved
	ResizeSE = "se-resize" // The bottom right corner of a box can be moved
	ResizeSW = "sw-resize" // The bottom left corner of a box can be moved
	ResizeEW = "ew-resize" // Something can be moved left and right
	ResizeNS = "ns-resize" // Something can be moved up and down
	ResizeNESW = "nesw-resize" // Something can be moved diagonally from the bottom left to the top right
	ResizeNWSE = "nwse-resize" // Something can be moved diagonally from the top left to the bottom right
	
	ZoomIn = "zoom-in" // Something can be zoomed in
	ZoomOut = "zoom-out" // Something can be zoomed out	
	
	Auto = "auto" // The cursor will be based on the current context, for example "text" when hovering text
	None = "none" // No cursor is rendered
	
class DigitalButton
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
		
transient immutable struct ControllerButtonPlayerAndIndex
	int userId
	int buttonIndex
	
enum ControllerButton: None, Up, Right, Down, Left, A, B, X, Y, L, R, L2, R2, Select, Start, Menu
	
enum GameControllerType: Keyboard, Xbox, PlayStation
class GameController
	const deadZone = .1
	
	// Sticks
	visible Vector2 leftStick
	visible Vector2 rightStick
	
	// DPad
	visible DigitalButton up = {}
	visible DigitalButton right = {}
	visible DigitalButton down = {}
	visible DigitalButton left = {}
	
	// Buttons
	visible DigitalButton a = {}
	visible DigitalButton b = {}
	visible DigitalButton x = {}
	visible DigitalButton y = {}
	
	visible DigitalButton menu = {}
	
	visible DigitalButton[] buttons = [DigitalButton("None"), up, right, down, left, a, b, x, y, menu]
	
	bool inMotion
	GameControllerType type
	
	internal startFrame
		leftStick.x = 0
		leftStick.y = 0
		rightStick.x = 0
		rightStick.y = 0
		buttons.each.startFrame
	
enum ShowPointersMode
	None           // Don't show the mouse pointers or draw them manually
	Local          // Show the mouse pointer only for the local player
	Remote         // Show the mouse pointer only for remote players
	LocalAndRemote // Show the mouse pointers of all players
	
immutable class InternetGamePadButton
	bool pressed, touched
	float value
	
immutable class InternetGamePad
	float[] axes
	InternetGamePadButton[] buttons
	string id
	
// Collect user input
skipInit global unit input
	transient visible InternalUser[] internalUsers
	transient InternalUser localUser
	transient internal Player localPlayer
	transient bool isCertain
	transient ControllerButtonPlayerAndIndex[Key] controllerButtonMap
	

	// A list of all players
	global Player[] players
		
	// The player hosting the current session
	global Player host
		
	// Do something for every player
	global inline js void everybody: void(Player it) do
		for(let i=0, _len=input.players.length; i<_len; ++i) { let it = input.players[i]; do()}
		
	// Returns true if the given condition is true for every player
	global inline js bool everybody: bool(Player it) predicate
		input.players.every(predicate)
		
	// Returns true if the given condition is true for any player
	global inline js bool anybody: bool(Player it) predicate
		input.players.some(predicate)
		
	// Returns true if the given condition is true for no player
	global inline js bool nobody: bool(Player it) predicate
		!input.players.some(predicate)
		
	// All players
	global inline js Player[] everybody() input.players
		
	internal Player[] playersById
	Cursor cursor
	
	bool showPointers = true
	ShowPointersMode showPointersMode = Remote
	ShowPointersMode showPointersDuringPlaybackMode = LocalAndRemote
	
	bool enableClickingWithAltKey
	bool ignoreFirstClick
	
	string textInput
		let localPlayer = playersById[input.localUser.id]
		return localPlayer.textInput
	
	internal init
		initHandlers
	
	internal js Vector2 logicalToPixelPosition: Vector2 pos
		let p = pos.getTransformed(graphics.totalMatrix)
		return new Vector2(p.x/Platform.pixelRatio, p.y/Platform.pixelRatio, null)

	private js void initHandlers
		let pointerX = 0, pointerY = 0, clickWithAltKeyX = 0, clickWithAltKeyY = 0
		window.onpointerdown = e => {
			if(e.button == 0 && Platform.mode == 0) {
				Platform.record();
				if(input.ignoreFirstClick) return;
			}
			input.handleTouchEvent(1, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button, e.shiftKey, e.altKey, e.ctrlKey || e.metaKey);
		}
		window.onpointermove = e => {
			pointerX = e.pageX; pointerY = e.pageY;
			input.handleTouchEvent(2, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button, e.shiftKey, e.altKey, e.ctrlKey || e.metaKey);
		}
		window.onpointerup = e => {
			input.handleTouchEvent(3, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button, e.shiftKey, e.altKey, e.ctrlKey || e.metaKey);
		}
		window.oncontextmenu = e => {
			e.preventDefault();
			e.stopPropagation();
			return false;
		}
		window.onkeydown = e => {
			let keyCode = e.keyCode
			let key = e.key
			let ctrlOrCmd = e.ctrlKey || e.metaKey
			if(window.require && key == "t" && e.metaKey && e.shiftKey)
				Platform.openDevTools();
			else
			if(ctrlOrCmd && key == "s") {
				// Save event steam
				core.saveEventStream();
				e.preventDefault();
			}
			else
			if(ctrlOrCmd && key == "l") {
				// Save logs
				statistics.saveStatistics()
				core.saveLogs();
				e.preventDefault();
			}
			else
			if((key == "F1" || key == "F2" || key == "F3" || key == "F4") && !ctrlOrCmd && Platform.isDebug) {
				let index = key[1] - "1"
				core.switchPerspectiveTo(input.players[index]);
				e.preventDefault();
			}
			else
			if((key >= "1" && key <= "0") && (e.altKey || e.ctrlKey)) {
				let index = key - "0"
				if(e.altKey)  { core.save(index); e.preventDefault(); } else
				if(e.ctrlKey) { core.restore(index); e.preventDefault(); }
			}
			else
			// Reload
			if(ctrlOrCmd && key == "F1") {/*keep room, keep userId, keep master*/ ServerCore.sendReload(false, false, true ); e.preventDefault();} else
			if(ctrlOrCmd && key == "F2") {/*keep room, keep userId, everybody*/   ServerCore.sendReload(false, false, false); e.preventDefault();} else
			if(ctrlOrCmd && key == "F3") {/*new  room, keep userId, everybody*/   ServerCore.sendReload(true,  false, false); e.preventDefault();} else
			if(ctrlOrCmd && key == "F4") {/*new  room, new  userId, everybody*/   ServerCore.sendReload(true,  true,  false);  e.preventDefault();} else
			
			// Switch send interval
			if(ctrlOrCmd && key == "F5") {core.switchSendInterval( 3); e.preventDefault();} else
			if(ctrlOrCmd && key == "F6") {core.switchSendInterval(10); e.preventDefault();} else
			if(ctrlOrCmd && key == "F7") {core.switchSendInterval(20); e.preventDefault();} else
			if(ctrlOrCmd && key == "F8") {core.switchSendInterval(30); e.preventDefault();} else
			if(ctrlOrCmd && key == "F9") {core.switchSendInterval(40); e.preventDefault();} else
				
			if(ctrlOrCmd && key == "F10") {core.switchSendInputMode(1); e.preventDefault();} else
			if(ctrlOrCmd && key == "F11") {core.switchSendInputMode(2); e.preventDefault();} else
				
			if(key == "F9") {
				if(e.shiftKey) { core.saveLogs(); }
				else           { Platform.toggleDebugInfo(); }
				e.preventDefault();
			} else if(key == "F10") { 
				Platform.toggleSmallScreen();
			} else if(key == "F11") { 
				graphics.copyScreenshotToClipboard();
			} else if(key == "Alt" && input.enableClickingWithAltKey) {
				clickWithAltKeyX = pointerX; clickWithAltKeyY = pointerY;
				input.handleTouchEvent(1, clickWithAltKeyX, clickWithAltKeyY, "touch", /*pointerId*/127, /*button*/0, /*shift*/false, /*alt*/false, /*ctrl*/false);
			} else {
				let typedKey = key && key.length == 1  && !e.ctrlKey && !e.metaKey && !e.altKey? key : ""
				input.handleKeyEvent(5, keyCode, typedKey)
				if(keyCode == 9) e.preventDefault();
			}
		}
		window.onkeyup = e => {
			if(e.key == "Alt" && input.enableClickingWithAltKey) {
				input.handleTouchEvent(3, clickWithAltKeyX, clickWithAltKeyY, "touch", /*pointerId*/127, /*button*/0, /*shift*/false, /*alt*/false, /*ctrl*/false);
			} else {
				input.handleKeyEvent(6, e.keyCode)
			}
		}
			
		// Handles navigating back or forward in the browser	
		window.onpopstate = e => {
			input.handleNavigate(location.pathname);
		}
		if(!window._isWheelHandlerSet) {
			window._isWheelHandlerSet = true
			window.addEventListener('wheel', e => {
				e.preventDefault();
				e.stopPropagation();
				if(e.button == 0 && Platform.mode == 0) Platform.record();
				input.handleWheelEvent(e.pageX, e.pageY, -e.deltaX, -e.deltaY, e.ctrlKey)
				return false;			
			}, {passive: false})
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
		if core.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast type
		inputs.writeString text
			
	internal handleKeyEvent: InputType inputType, Key keyCode, string key
		if core.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		int composite = cast inputType                                  // inputType:   0 - 31 (5 bit)
		
		let controllerButton = controllerButtonMap[keyCode]
			composite += controllerButton.buttonIndex shiftLeft 5 // buttonIndex: 0 - 15 (4 bit)
			if core.mode == Local and not core.simulateConnection
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
		
		Vector2 pixelPos = {x*graphics.pixelRatio, y*graphics.pixelRatio}
		Vector2 referencePos = pixelPos.getRelativeTo(graphics.baseMatrix)
		gizmo.onTouch inputType, id, pixelPos, referencePos, shift, alt, cmdOrCtrl
		
		if core.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs

		if inputType == TouchMove
			int index = getLastTouchMoveIndex id
			if index
				// We already moved the pointer this input frame, so just update the last move
				inputs.setInt16 index, math.round(referencePos.x)
				inputs.setInt16 index+2, math.round(referencePos.y)
				if core.logging: core.writeLog += " #{localUser.inputFrame} override {id} at {index} to {math.round(referencePos.x)} {math.round(referencePos.y)}"
				return
			else
				setLastTouchMoveIndex id, inputs.writePos+6
				if core.logging: core.writeLog += " save {id} at {inputs.writePos+6}"
			
		int composite = cast(inputType)                                 // inputType: 0 -  31 (5 bit)
		              + math.shiftLeft(touchType, 5)                    // touchType: 0 -   7 (3 bit)
		              + math.shiftLeft(math.floor(math.abs(id))%128, 8) // id:        0 - 127 (7 bit)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 math.round(referencePos.x)
		inputs.writeInt16 math.round(referencePos.y)
		if core.logging: core.writeLog += " #{localUser.inputFrame} {composite} {math.round(referencePos.x)} {math.round(referencePos.y)} ({inputs.readPos}/{inputs.writePos})"
	
	internal handleUpdateTouchAfterSwitchingUser: int id, Vector2 referencePos
		let inputs = localUser.inputs
		int composite = cast(InputType.TouchMove)                       // inputType: 0 -  31 (5 bit)
		              + math.shiftLeft(cast TouchType.Left, 5)          // touchType: 0 -   7 (3 bit)
		              + math.shiftLeft(math.floor(math.abs(id))%128, 8) // id:        0 - 127 (7 bit)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 math.round(referencePos.x)
		inputs.writeInt16 math.round(referencePos.y)
		
	private handleWheelEvent: float x, float y, float deltaX, float deltaY, bool isPinch
		if core.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		
		int composite = cast(InputType.Scroll)                       // inputType: 0 -  31 (5 bit)
		              + math.shiftLeft(isPinch ? 1:0, 5)             // isPinch:   0 -   1 (1 bit)
		
		Vector2 referencePos = {x*graphics.pixelRatio, y*graphics.pixelRatio}.getRelativeTo(graphics.baseMatrix)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 math.round(referencePos.x)
		inputs.writeInt16 math.round(referencePos.y)
		inputs.writeInt16 math.round(deltaX)
		inputs.writeInt16 math.round(deltaY)
		if core.logging: core.writeLog += " [{localUser.inputFrame}] wheel {math.round(referencePos.x)} {math.round(referencePos.y)} {deltaX} {deltaY} \{r:{inputs.readPos} w:{inputs.writePos}\}"
		
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
		if core.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.Navigate
		inputs.writeString url
		
	// Post lost messages and remove players if nobody disagrees
	internal handleLost
		if core.mode < Local or !lobby.inLobby: return
		for players <- player
			let internalUser = internalUsers[.id]
				if player.lostAtFrame and core.frame > player.lostAtFrame + core.targetFps * 3
					// If a player was lost by anybody and nobody who is still connected to that player
					// disagrees within a certrain time, we remove this player
					core.log "Removing player {player.id} at frame {core.frame}, player was lost at frame {player.lostAtFrame} and nobody disagreed", isCertain
					players.remove player
					playersById[player.id] = null
					internalUser.active = false
					updatePlayers
				else	
				if core.frame > internalUser.inputFrame + core.targetFps * 8
				and core.frame > internalUser.nextLostMessageAtFrame
					// If we lost the connection to a player, we post a lost message to everybody every 12 seconds
					core.log "Sending lost message for player {player.id} at frame {core.frame}", internalUser.inputFrame
					let inputs = localUser.inputs
					inputs.writeInt32 localUser.inputFrame
					inputs.writeInt16 cast InputType.Lost
					inputs.writeInt16 player.id
					internalUser.nextLostMessageAtFrame = core.frame + core.targetFps * 12
					
					// Send logfiles to server
					Platform.setTimeout 7 seconds: statistics.saveStatistics
	
	private handleStillConnected: int userId
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.StillConnected
		inputs.writeInt16 userId
				
	internal handleString: int id, string data
		if !data || core.mode == None || core.frames > core.frame || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.String
		inputs.writeInt id
		inputs.writeString data
		
	internal handleJson: int id, string data
		if !data || core.mode == None || core.frames > core.frame || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeInt16 cast InputType.Json
		inputs.writeInt id
		inputs.writeString data
		
	internal handleObject: int id, string data
		if !data || core.mode == None || core.frames > core.frame || !localUser || !localUser.collectInputs: return
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
		inputs.writeFloat32 math.abs(leftStickX) > GameController.deadZone ? leftStickX : 0
		inputs.writeFloat32 math.abs(leftStickY) > GameController.deadZone ? leftStickY : 0
		inputs.writeUnsignedInt16 buttons
			
	internal parseInputs: int frame
		for internalUsers -> internalUser if internalUser
			let inputs = internalUser.inputs
			let userId = internalUser.id
			let player = playersById[userId]
			if core.logging: core.parseLog += " <{userId}>"
			player?.controller.startFrame
			
			while true
				int nextFrame = inputs.canRead ? inputs.peekInt32 : int.maxValue
				if core.logging: 
					core.parseLog += " ({inputs.readPos}/{inputs.writePos})"
					if inputs.canRead: core.parseLog += " *{nextFrame}"
				if nextFrame > frame: break
				inputs.readPos += 4
				
				// We create the player as soon as we receive the first input from that player,
				// which is typically the "Join" message that is sent in "startConnected",
				// but could also be a player reconnecting that was previously kicked out
				if not player
					if core.logging: core.parseLog += " Add {userId}"
					players.add player = {id:userId, index:players.length}
					playersById[userId] = player
					if internalUser.local: localPlayer = player
					internalUser.active = true
					updatePlayers
				
				let value = inputs.readUnsignedInt16
				InputType inputType = cast(value % 32)
				
				if inputType >= TouchDown && inputType <= Scroll
					if !player: core.log " ERROR: userId {userId} not in playersById"
					TouchType type = cast((value shiftRight 5) % 8)
					int id = (value shiftRight 8) % 128
					Vector2 referencePos = {inputs.readInt16, inputs.readInt16}
					bool isSmoothPosition = !core.smoothTouchPosition or internalUser.local or frame <= internalUser.smoothFrame
					if core.logging: core.parseLog += " "+id
					
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
							if core.logging: core.parseLog += " down {id} {referencePos} {type}"
							if isSmoothPosition: touch.smoothPosition = referencePos
						else
							touch = {id, player, cast inputType, type, referencePos, referencePos, referencePos, isDown:true}
							player.touches.add touch
							if core.logging: core.parseLog += " down(new) {id} {referencePos} {type}"
								
						player.downTouches.add touch
						player.pointerPosition = referencePos
						internalUser.downTouches.add touch
					else
					if inputType == TouchMove
						let touch = player.touches.find.id == id
						if touch
							// Update the touch in player.touches
							if touch.phase == Still: touch.phase = cast inputType
							touch.referencePosition = referencePos
							touch.type = type
							if isSmoothPosition: touch.smoothPosition = referencePos
							if core.logging: core.parseLog += " move {id} {referencePos} {type}"
						else
							touch = {id, player, cast inputType, type, referencePos, referenceStartPosition:Vector2.none, referencePos, isDown:false}
							player.touches.add touch
							if core.logging: core.parseLog += " move(new) {id} {referencePos} {type}"
								
						player.pointerPosition = referencePos
						internalUser.movingTouches.add touch
						cursor = Auto
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
							if core.logging: core.parseLog += " up {id} {referencePos} {type}"
						else
							touch = {id, player, cast inputType, type, referencePos, referenceStartPosition:Vector2.none, referencePos, isDown:false}
							player.touches.add touch
							if core.logging: core.parseLog += " up(new) {id} {referencePos} {type}"
								
						player.pointerPosition = referencePos
						internalUser.upTouches.add touch
					else
					if inputType == Scroll
						Vector2 delta = {inputs.readInt16, inputs.readInt16}
						bool isPinch = (value shiftRight 5) == 1
						internalUser.wheelEvents.add {player.id, delta, isPinch, referencePosition:referencePos}
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
						player.controllerKeyDownFrame[controllerButtonIndex] = frame
					
					if core.logging: core.parseLog += " KeyDown {key}"
				else
				if inputType == KeyUp
					Key key = cast inputs.readInt32
					internalUser.upKeys.add key
					player.keysCurrentlyDown.remove key
					
					int controllerButtonIndex = cast((value shiftRight 5) % 16)
						player.controllerKeyDownFrame[controllerButtonIndex] = 0
					
					if core.logging: core.parseLog += " KeyUp {key}"
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
					if core.logging: core.parseLog += " Join {userId}"
				else
				if inputType == Lost
					let lostUserId = inputs.readInt16
					let lostInternalUser = internalUsers[lostUserId]
						let lostPlayer = playersById[lostUserId]
						
						// If a player was lost by anybody and nobody who is still connected to that player
						// disagrees within a certrain time, we will remove this player in "handleLost"
						if lostPlayer and lostPlayer.lostAtFrame == 0
							lostPlayer.lostAtFrame = frame
							core.log "Lost {lostUserId} by {userId} -> Set lostAtFrame to {lostPlayer.lostAtFrame}"
							
						// If we are still connected to that player, we disagree to their removal
						// by posting the "StillConnected" message
						if lostInternalUser.dataChannel and core.frame < lostInternalUser.inputFrame + core.targetFps * 5
							core.log "Lost {lostUserId} by {userId} -> We are still connected, sending StillConnected", lostInternalUser.dataChannel, core.frame, lostInternalUser.inputFrame, isCertain
							handleStillConnected lostUserId
						else
							core.log "Lost {lostUserId} by {userId} -> We also aren't connected", lostInternalUser.dataChannel, core.frame, lostInternalUser.inputFrame, isCertain
					else
						core.log "Lost {lostUserId} by {userId} -> No internal user!"
				else
				if inputType == StillConnected
					// Somebody disagreed with the removal of that player because they are still connected,
					// so we cancel the removal
					let lostUserId = inputs.readInt16
					core.log "Still connected to {lostUserId} by {userId}"
					let lostPlayer = playersById[lostUserId]
						lostPlayer.lostAtFrame = 0
				else
				if inputType == SetState
					if core.logging: core.parseLog += " setState"
					core.snapshotBuffer.reset
					inputs.readBuffer core.snapshotBuffer
					Snapshot.deserialize core.snapshotBuffer
					math.recreateRandomValues
				else
				if inputType == String
					int id = inputs.readInt
					string valueString = inputs.readString
					if core.logging: core.parseLog += " string {id}: {valueString}"
					networkData.call id, valueString
					if Platform.waitingForInitialData > 0: Platform.waitingForInitialData--
				else
				if inputType == Json
					int id = inputs.readInt
					string valueString = inputs.readString
					if core.logging: core.parseLog += " json {id}: {valueString}"
					dynamic object = valueString.toJson
					networkData.call id, object
					if Platform.waitingForInitialData > 0: Platform.waitingForInitialData--
				else
				if inputType == Object
					int id = inputs.readInt
					string valueString = inputs.readString
					if core.logging: core.parseLog += " object {id}: {valueString}"
					dynamic object = valueString.toJson
					networkData.call id, object
					if Platform.waitingForInitialData > 0: Platform.waitingForInitialData--
	
		// for players
		// 	let internalUser = internalUsers[.id]
		// 	if frame <= internalUser.inputFrame
		// 		let right = .controllerKeyDownFrame[0]
		// 		let down  = .controllerKeyDownFrame[1]
		// 		let left  = .controllerKeyDownFrame[2]
		// 		let up    = .controllerKeyDownFrame[3]
		// 		if right or left: .controller.leftStick.x = right >= left ? 1 : -1
		// 		if down  or up:   .controller.leftStick.y = down  >= up   ? 1 : -1
		// 		if .controllerKeyDownFrame[4]: .controller.a.state = true
		// 		if .controllerKeyDownFrame[5]: .controller.b.state = true
		// 		if .controllerKeyDownFrame[6]: .controller.x.state = true
		// 		if .controllerKeyDownFrame[7]: .controller.y.state = true
		// 		.controller.inMotion = math.abs(.controller.leftStick.x) >= GameController.deadZone
		// 		                    or math.abs(.controller.leftStick.y) >= GameController.deadZone
				
		for players -> p
			// Left stick
			let right = .controllerKeyDownFrame[ControllerButton.Right]
			let down  = .controllerKeyDownFrame[ControllerButton.Down]
			let left  = .controllerKeyDownFrame[ControllerButton.Left]
			let up    = .controllerKeyDownFrame[ControllerButton.Up]
			if right or left: .controller.leftStick.x = right >= left ? 1 : -1
			if down  or up:   .controller.leftStick.y = down  >= up   ? 1 : -1
			.controller.inMotion = math.abs(.controller.leftStick.x) >= GameController.deadZone
			                    or math.abs(.controller.leftStick.y) >= GameController.deadZone
			
			// Buttons
			for .controller.buttons
				if p.controllerKeyDownFrame[i]: 
					.state = true
					
		if Platform.receivedInitialData
			Platform.waitingForInitialData -= Platform.receivedInitialData
			Platform.receivedInitialData = 0
						
	internal updatePlayers
		players.orderBy.id
		for players
			.index = i
			.color = graphics.defaultColors[i]
			internalUsers[.id].index = i
			
		if core.mode == Local and not core.simulateConnection
			if players.length >= 1
				GameController c = players[0].controller
				if c.type == Keyboard
					c.up.assign    "↑"     Up
					c.right.assign "→"     Right
					c.down.assign  "↓"     Down
					c.left.assign  "←"     Left
					c.a.assign     "SPACE" Space
					c.b.assign     "X"     X
			
			if players.length >= 2
				GameController c = players[1].controller
				if c.type == Keyboard
					c.up.assign    "W"     W
					c.right.assign "D"     D
					c.down.assign  "S"     S
					c.left.assign  "A"     A
					c.a.assign     "F"     F
					c.b.assign     "G"     G
			
			if players.length >= 3
				GameController c = players[2].controller
				if c.type == Keyboard
					c.up.assign    "I"     I
					c.right.assign "L"     L
					c.down.assign  "K"     K
					c.left.assign  "J"     J
					c.a.assign     "O"     O
					c.b.assign     "P"     P
			
			controllerButtonMap.clear
			for players -> player
				player.controllerKeyDownFrame.clear
				for .controller.buttons
					controllerButtonMap[.key] = {userId:player.id, buttonIndex:i}
					player.controllerKeyDownFrame.add 0
		else
			controllerButtonMap.clear
			for players
				GameController c = .controller
				if c.type == Keyboard
					c.up.assign    "↑"     Up
					c.right.assign "→"     Right
					c.down.assign  "↓"     Down
					c.left.assign  "←"     Left
					c.a.assign     "SPACE" Space
					c.b.assign     "X"     X
			
			controllerButtonMap.clear
			// TODO: Research why this is sometimes called before we have a local player
			if localPlayer
				for localPlayer.controller.buttons
					controllerButtonMap[.key] = {userId:localPlayer.id, buttonIndex:i}
				
			controllerButtonMap[W] = {userId:localUser.id, buttonIndex:1}
			controllerButtonMap[D] = {userId:localUser.id, buttonIndex:2}
			controllerButtonMap[S] = {userId:localUser.id, buttonIndex:3}
			controllerButtonMap[A] = {userId:localUser.id, buttonIndex:4}
			
		
	private log: string text, Vector2 pos
		if core.logging: core.touchLog += " #{core.frame}{isCertain ? " c" : ""} {text} {pos}"

	private getTargetedPlayers: Player[] by
		return (core.mode == Connected || core.simulateConnection) and by and by.length > 0 and by[0] ? by : players
		
	// ---------------------------------------------- Touch Down ----------------------------------------------
	
	// Do something when the player touches or clicks within a given area
	// Example: Draw an OK button and print "Clicked OK" when the user touches it.
	//     app
	//         tick
	//             drawText "OK", position:{0,0}, size:40, color:White
	//             drawRoundedRectangle position:{0,0}, size:{300,100}, color:Blue
	//             
	//             onTouchDown position:{0,0}, size:{300,100}
	//                 print "Clicked OK"
	// Image: onTouchDown1.png
	global onTouchDown: Vector2 position                    // The center of the touch area
		                Vector2 size                        // The size of the rectangular touch area
		                implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players  
		                Cursor cursor = Auto                // Change the mouse cursor image when hovering over this area
		                bool showClickableArea = false      // Highlight the clickable area for debugging
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                HorizontalAlignment align = Center  // The horizontal alignment of the touch area
		                VerticalAlignment valign = Middle   // The vertical alignment of the touch area
		                void(Touch touch) do                // Do this for each touch or click
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
						
		if cursor != Auto
			for localUser.movingTouches -> touch
				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
					this.cursor = cursor
				
		if showClickableArea: drawRectangle position, size, color:{"#ff000080"}, align, valign, layer:10000000

	// Do something when the player touches or clicks within a given rotated rectangle
	// Example: Draw a the image "Character" rotated by 45 degrees and print "Clicked character" when the player touches within its rotated rectangle.
	//     app
	//         tick
	//             let pos = {0,0}
	//             let size = {100,200}
	//             let angle = 45°
	//             
	//             drawImage Character, pos, size, angle
	//             onTouchDown pos, size, angle
	//                 print "Clicked character"
	// Image: onTouchDown2.png
	global onTouchDown: Vector2 position                    // The center of the touch area
		                Vector2 size                        // The size of the rectangular touch area
		                Angle angle                         // Rotate the touch area by this angle
		                implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		                Cursor cursor = Auto                // Change the mouse cursor image when hovering over this area
		                bool showClickableArea = false      // Highlight the clickable area for debugging
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                HorizontalAlignment align = Center  // The horizontal alignment of the touch area
		                VerticalAlignment valign = Middle   // The vertical alignment of the touch area
		                void(Touch touch) do                // Do this for each touch or click
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
						
			if cursor != Auto
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showClickableArea: drawPolygon poly, color:{"#ff000080"}, layer:10000000

	// Do something when the player touches or clicks within a given circle
	// Example: Draw the image "Ball" and print "Clicked ball" when the player touches it.
	//     Ball
	//         Vector2 pos
	//         tick
	//             drawImage Ball, pos, size:100
	//             onTouchDown pos, radius:50
	//                 print "Clicked ball"
	// Image: onTouchDown3.png
	global onTouchDown: Vector2 position                    // The center of the circle
		                float radius                        // The radius of the circle
		                implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players  
		                Cursor cursor = Auto                // Change the mouse cursor image when hovering over this circle
		                bool showClickableArea = false      // Highlight the clickable area for debugging
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                void(Touch touch) do                // Do this for each touch or click
		let referencePosition = position.getTransformed(graphics.localMatrix)
		let referenceRadius = radius * graphics.localMatrix.scaleVector.x
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].downTouches -> touch
				if !touch.handled and (player.enableTouch or touch.type != Touch)
				and (touch.referencePosition distanceTo referencePosition) <= referenceRadius
					log "down", touch.referencePosition
					do touch
					if markAsHandled: touch.handled = true
						
			if cursor != Auto
				for localUser.movingTouches -> touch
					if !touch.handled && (touch.referencePosition distanceTo position) <= radius
						this.cursor = cursor
				
		if showClickableArea: drawCircle position, radius*2, color:{"#ff000080"}

	// Do something when the player touches or clicks within a given polygon
	// Example: Draw a polygon and print "Clicked OK" when the player touches it.
	//     app
	//         tick
	//             let polygon = [{-200,-50}, {-250,50}, {200,50}, {250,-50}]
	//             
	//             drawText "OK", size:50
	//             drawPolygon polygon, color:Blue
	//             
	//             onTouchDown polygon
	//                 print "Clicked OK"
	// Image: onTouchDown4.png
	global onTouchDown: Vector2[] points                    // The points that define the clickable polygon
		                Vector2 position = {0,0}            // The position all polygon points are relative to
		                implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players  
		                Cursor cursor = Auto                // Change the mouse cursor image when hovering over this polygon
		                bool showClickableArea = false      // Highlight the clickable area for debugging
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                void(Touch touch) do                // Do this for each touch or click
		Vector2[] poly
		for points: poly.add (position + .).transform(graphics.localMatrix)
			
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].downTouches -> touch
				if !touch.handled and (player.enableTouch or touch.type != Touch)
				and touch.referencePosition.isInsidePoygon(poly)
					log "down", touch.referencePosition
					do touch
					if markAsHandled: touch.handled = true
						
			if cursor != Auto
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showClickableArea: drawPolygon position, points, color:{"#ff0000b0"}
			
	// Do something when the player touches or clicks anywhere on the screen
	// Example: When the current player instance touches the screen, we print out the exact touch position.
	//     Player
	//         tick
	//             onTouchDown by me
	//                 print "Click at {touch.position}"
	// Image: onTouchDown0.png
	global onTouchDown: implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                void(Touch touch) do                // Do this for each touch or click
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].downTouches -> touch
				if !touch.handled and (player.enableTouch or touch.type != Touch)
					log "down", touch.referencePosition
					do touch
					if markAsHandled: touch.handled = true

	// Do something when the player touches or clicks, even if the event is already handled
	global onTouchDownAny: implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		                   void(Touch touch) do                // Do this for each touch or click, even those that are already marked as handled
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].downTouches -> touch
				if player.enableTouch or touch.type != Touch
					log "down", touch.referencePosition
					do touch

	// ---------------------------------------------- Touch Over ----------------------------------------------
	
	// Do something when the mouse moves over a given area
	// Example: Draw a blue rectangle. When the current player instance hovers over the rectangle with the mouse, we draw a black outline around it.
	//     Player
	//         tick
	//             let pos = {0,0}
	//             let size = {200,100}
	//             
	//             drawRectangle pos, size, color:Blue
	//             onTouchOver pos, size, by:me
	//                 drawRectangle pos, size+{32,32}, outlineColor:Black, outlineWidth:8
	// Image: onTouchOver.png
	global onTouchOver: Vector2 position                    // The center of the touch area
		                Vector2 size                        // The size of the rectangular touch area
		                implicit nocolon Player[] by = null // Only consider the mouse from this player  
		                Cursor cursor = Auto                // Change the mouse cursor image when hovering over this area
		                bool showClickableArea = false      // Highlight the area for debugging
		                bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		                void(Touch touch) do                // Do this for each mouse that is hovering over the given area
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
					
			if cursor != Auto
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showClickableArea: drawRectangle position, size, color:{"#ff000080"}

			
	// ---------------------------------------------- Touch Move ----------------------------------------------
	
	// Do something when a touch or click moves
	// Example: The players can drag PuzzlePieces around with support for multi-touch and multiple players
	//     PuzzlePiece
	//         private Vector2 pos
	//         private Vector2 moveOffset
	//         private Touch moveTouch
	//     	
	//         tick
	//             onTouchDown pos, app.pieceSize
	//                 moveTouch = touch
	//                 moveOffset = pos - touch.position
	//             
	//             onTouchMove moveTouch
	//                 pos = touch.position + moveOffset
	//             	
	//             onTouchUp moveTouch
	//                 moveTouch = null
	global onTouchMove: Touch touch                 // Only consider this particular touch or click
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
	
	// Do something when a touch or click of the given player moves
	// Example: Print the touch or mouse position of the current player instance everytime it moves
	//     Player
	//         trick
	//             onTouchMove by me
	//                 print "Touch moved to {touch.position}"
	global onTouchMove: implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		                void(Touch touch) do                // Do this for each touch or click
		for getTargetedPlayers(by)
			for internalUsers[.id].movingTouches
				log "move", .referencePosition
				do .
					
	// ---------------------------------------------- Touch Up ----------------------------------------------
	
	// Do something when a touch or click ends
	// Example: The players can drag PuzzlePieces around with support for multi-touch and multiple players
	//     PuzzlePiece
	//         private Vector2 pos
	//         private Vector2 moveOffset
	//         private Touch moveTouch
	//     	
	//         tick
	//             onTouchDown pos, app.pieceSize
	//                 moveTouch = touch
	//                 moveOffset = pos - touch.position
	//             
	//             onTouchMove moveTouch
	//                 pos = touch.position + moveOffset
	//             	
	//             onTouchUp moveTouch
	//                 moveTouch = null
	global onTouchUp: Touch touch          // Only consider this particular touch or click
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
				
	// Do something when a given player ends a touch or click
	// Example: Print the touch or mouse position of the current player instance when the touch ends or the mouse button is released
	//     Player
	//         trick
	//             onTouchUp by me
	//                 print "Touch ended at {touch.position}"
	global onTouchUp: implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		              bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		              void(Touch touch) do                // Do this for each touch or click
		for getTargetedPlayers(by)
			for internalUsers[.id].upTouches
				if !.handled
					log "up", .referencePosition
					do .
					Snapshot.autoSave
					
	// Do something when the player ends a touch or click within a given area
	// Example: Draw an OK button and print "Clicked OK" when the player ends a touch or releases the mouse button over this button
	//     app
	//         tick
	//             drawText "OK", position:{0,0}, size:40, color:White
	//             drawRoundedRectangle position:{0,0}, size:{300,100}, color:Blue
	//             
	//             onTouchUp position:{0,0}, size:{300,100}
	//                 print "Clicked OK"
	// Image: onTouchDown1.png
	global onTouchUp: Vector2 position                    // The center of the touch area
		              Vector2 size                        // The size of the rectangular touch area
		              implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players
		              bool showClickableArea = false      // Highlight the clickable area for debugging
		              bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		              void(Touch touch) do                // Do this for each touch or click
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
						
		if showClickableArea: drawRectangle position, size, color:{"#ff000080"}

	// Do something when the player ends a touch or click within a given circle
	// Example: Draw the image "Ball" and print "Clicked ball" when the player ends a touch or releases the mouse button over this button
	//     Ball
	//         Vector2 pos
	//         tick
	//             drawImage Ball, pos, size:100
	//             onTouchUp pos, radius:50
	//                 print "Clicked ball"
	// Image: onTouchDown3.png
	global onTouchUp: Vector2 position                    // The center of the circle
		              float radius                        // The radius of the circle
		              implicit nocolon Player[] by = null // Only consider touches or clicks by this player or list of players  
		              Cursor cursor = Auto                // Change the mouse cursor image when hovering over this area
		              bool showClickableArea = false      // Highlight the clickable area for debugging
		              bool markAsHandled = true           // Mark the touch as handled so it won't trigger more touch events
		              void(Touch touch) do                // Do this for each touch or click
		let referencePosition = position.transform(graphics.localMatrix)
		let referenceRadius = radius * graphics.localMatrix.scaleVector.x
		for getTargetedPlayers(by) -> player
			for internalUsers[player.id].upTouches -> touch
				if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
					log "up", touch.referencePosition
					do touch
					if markAsHandled: touch.handled = true
					Snapshot.autoSave
					
			if cursor != Auto
				for localUser.movingTouches -> touch
					if !touch.handled && (touch.referencePosition distanceTo position) <= radius
						this.cursor = cursor
				
		if showClickableArea: drawCircle position, radius*2, color:{"#ff000080"}
						
	// ---------------------------------------------- Scroll ----------------------------------------------
	
	// Do something when a player scrolls with the touch pad or mouse wheel
	global onScroll: implicit nocolon Player[] by = null // Only consider events by this player or list of players
		             void(ScrollEvent event) do          // Do this for each event
		for getTargetedPlayers(by)
			for internalUsers[.id].wheelEvents
				do .
	
	// Do something when a player scrolls with the touch pad or mouse wheel over a rectangle
	global onScrolllWithin: Vector2 position                    // The center of the rectangle
		                    Vector2 size                        // The size of the rectangle
		                    implicit nocolon Player[] by = null // Only consider events by this player or list of players
		                    bool showClickableArea = false      // Highlight the rectangle for debugging
		                    bool markAsHandled = true           // Mark the touch as handled so it won't trigger more events
		                    void(ScrollEvent event) do          // Do this for each event
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
						
		if showClickableArea: drawRectangle position, size, Red
			
	// ---------------------------------------------- Text Input ----------------------------------------------
	
	visible bool isTextInputActive = false
	
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
			_input.oninput = e => input.handleTextInput(7, _input.value)
			_input.onblur = e => {
				if(input.isTextInputActive) {
					_input.focus()
				}
			}
			document.body.appendChild(_input)
		}
		return _input
				
	js void startTextInput: string initalValue = null, int forUser = -1
		if(forUser == -1 || input.localUser?.id == forUser) {
			let field = input.getOrCreateInputField()
			if(initalValue != null) { 
				field.value = initalValue
			}
			_input.focus()
			field.isTextInputActive = true
		}
		
	js void stopTextInput
		input.isTextInputActive = false
		
	js void setTextInput: string value
		let field = input.getOrCreateInputField()
		field.value = value
		field.handleTextInput(7, value)
		
	js void updateCursor
		// document.body.style.cursor = (input.showPointers == 2 && Platform.mode == 4 ? "none" : input.cursor)
		document.body.style.cursor = input.cursor

	onTextComposition: void(string characters) do
		for internalUsers -> user if .
			for user.textCompositions -> characters
				do characters
				
	onTextInput: implicit nocolon Player[] by = null // Only consider keys pressed by this player or list of players
		         void(string textInput) do           // Do this for each key that is pressed
		for getTargetedPlayers(by)
			for internalUsers[.id].textInputs -> textInput
				do textInput
				
	// ---------------------------------------------- Keys ----------------------------------------------
	
	// Do something when a player presses a key
	global onKeyDown: Key key                             // The key that will trigger the event
		              implicit nocolon Player[] by = null // Only consider keys pressed by this player or list of players
		              void(Key key, Player pressedBy) do  // Do this for each key that is pressed
		for getTargetedPlayers(by) -> player
			for internalUsers[.id].downKeys
				if . == key
					do key, player
				
	global onKeyDown: Key modifier 
		              Key key                             // The key that will trigger the event
		              implicit nocolon Player[] by = null // Only consider keys pressed by this player or list of players
		              void(Key key, Player pressedBy) do  // Do this for each key that is pressed
		for getTargetedPlayers(by) -> player
			if player.keysCurrentlyDown.contains modifier
				for internalUsers[.id].downKeys
					if . == key
						do key, player
				
	// Do something when a player presses a key
	global onKeyDown: implicit nocolon Player[] by = null // Only consider keys pressed by this player or list of players
		              void(Key key, Player pressedBy) do  // Do this for each key that is pressed
		for getTargetedPlayers(by) -> player
			for internalUsers[.id].downKeys -> key
					do key, player
				
	// Do something when a player releases a key
	global onKeyUp: implicit nocolon Player[] by = null // Only consider keys released by this player or list of players
		            void(Key key, Player pressedBy) do  // Do this for each key that is released
		for getTargetedPlayers(by) -> player
			for internalUsers[.id].upKeys -> key
				do key, player
					
	// Do something when a player types a character
	global onType: implicit nocolon Player[] by = null         // Only consider characters typed by this player or list of players
		           void(string character, Player pressedBy) do // Do this for each character that is typed
		for getTargetedPlayers(by) -> player
			for internalUsers[.id].pressedKeys -> character
				do character, player
			
	// Returns true if a given key is currently held down
	isKeyDown: Key key          // The key to check
		       Player by = null // Only consider keys pressed by this player 
		if (core.mode == Connected || core.simulateConnection) && by
			let player = playersById[by.id]
				return player.keysCurrentlyDown.contains key
		else
			return players.any.keysCurrentlyDown.contains key
		return false
		
	// ---------------------------------------------- Navigate ----------------------------------------------
	
	// Do something when the user navigates back or forward in the browser	
	global onNavigate: implicit nocolon Player[] by = null // Only consider events by this player or list of players
		               void(string url) do                 // Do this for each event
		for getTargetedPlayers(by) -> player
			for internalUsers[.id].navigations -> url
				do url
				

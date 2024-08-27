// The internal state of a user that isn't serialized and shoudn't be accessed by the application
transient class InternalUser
	int id              // The userId stays the same when a user reconnects
	bool local          // Is this the local user?
	bool active = true
	int index
	
	bool collectInputs  // When we are done pinging, we add a join event and start collecting inputs
	int inputFrame      // We got all inputs from this player up to and including this frame
	int bufferFrames
	int inputsSentPos
	
	visible Touch[] downTouches, movingTouches, upTouches

	Buffer inputs = {}        // The stream of inputs of this user

	startInputFrame: int index
		inputFrame = index
	
	clearEvent:
		downTouches.clear
		movingTouches.clear
		upTouches.clear
	
// The public state of a user. This is the same accross all clients.
class CoreUser
	int id
	int index
	Color color
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
	
	CoreUser
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
	Vector3 position
	Vector3 startPosition
	// Vector3 referencePosition
	// Vector3 referenceStartPosition
	Vector3 smoothPosition
	bool isDown
	bool handled
	
	// Calculate position and startPositio dynamically to ensure it is always valid and relative to the current matrix
	// even if we never check the touch with a Input.onTouch method
	
	// Vector3 position := referencePosition.getRelativeTo(graphics.localMatrix)
	// Vector3 startPosition := referenceStartPosition.getRelativeTo(graphics.localMatrix)
	
	// Touch clone := {id, userId, phase, type, referencePosition, referenceStartPosition, smoothPosition, isDown}
	
	markAsHandled() handled = true
	
transient class WheelEvent
	CoreUser user
	Vector3 delta
	Vector3 referencePosition
	bool handled
	
	// Vector3 position := referencePosition.getRelativeTo(graphics.localMatrix)
	
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

	CoreUser[] users
	internal CoreUser[int] usersById
	string cursor
	
	bool showLocalPointer = false
	bool showPointers = true
	
	private Vector3 prevMousePosition
		
	cs void collectMouseEvents
		var mousePosition = UnityEngine.Input.mousePosition;
		if(UnityEngine.Input.GetMouseButtonDown(0)) handleTouchEvent(InputType.TouchDown, TouchType.Left, 0, mousePosition);
		if(mousePosition != prevMousePosition)      handleTouchEvent(InputType.TouchMove, TouchType.Left, 0, mousePosition);
		if(UnityEngine.Input.GetMouseButtonUp(0))   handleTouchEvent(InputType.TouchUp,   TouchType.Left, 0, mousePosition);
		prevMousePosition = mousePosition;
		
	cs void collectTiltFiveEvents
		var mousePosition = TiltFive.Wand.GetPosition(controllerPosition: TiltFive.ControllerPosition.Aim, playerIndex: 0);
		if(TiltFive.Input.GetButtonDown(TiltFive.Input.WandButton.One, playerIndex: 0)) handleTouchEvent(InputType.TouchDown, TouchType.Left, 0, mousePosition);
		handleTouchEvent(InputType.TouchMove, TouchType.Left, 0, mousePosition);
		if(TiltFive.Input.GetButtonUp(TiltFive.Input.WandButton.One, playerIndex: 0)) handleTouchEvent(InputType.TouchUp, TouchType.Left, 0, mousePosition);
			
	private handleKeyEvent: InputType type, int keyCode, string key
		// if Core.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast type
		inputs.writeInt32 keyCode
		if type == KeyDown: inputs.writeString key
		
	internal handleTouchEvent: InputType inputType, TouchType touchType, int id, Vector2 screenPosition
		// if Core.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let worldPosition = graphics.toGroundPlane screenPosition
		let inputs = localUser.inputs
		int composite = cast(inputType)                   // inputType: 0 -  31 (5 bit)
		              + Math.shiftLeft(cast touchType, 5) // touchType: 0 -   7 (3 bit)
		              + Math.shiftLeft(id%128, 8)         // id:        0 - 127 (7 bit)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeFloat worldPosition.x
		inputs.writeFloat worldPosition.y
		inputs.writeFloat worldPosition.z

	internal parseInputs: int frame, bool isCertain
		// this.isCertain = isCertain
		// if Core.logging: if isCertain: Core.parseLog += " c"
		for internalUsers -> internalUser if internalUser
			let inputs = internalUser.inputs
			let userId = internalUser.id
			let user = usersById[userId]
			// if Core.logging: Core.parseLog += " <{userId}>"
			user?.controller.startFrame
			
			while true
				int nextFrame = inputs.canRead ? inputs.peekInt32 : int.maxValue
				// if Core.logging: 
				// 	Core.parseLog += " ({inputs.readPos}/{inputs.writePos})"
				// 	if inputs.canRead: Core.parseLog += " *{nextFrame}"
				if nextFrame > frame: break
				inputs.readPos += 4
				
				// We create the user as soon as receive the first input from that user,
				// which is typically the "Join" message that is sent in "startConnected",
				// but could also be a user reconnecting that was previously kicked out
				if not user
					// Core.log "Adding user {userId}"
					users.add user = {id:userId, index:users.length}
					usersById[userId] = user
					updateUserIndices
				
				let value = inputs.readUnsignedInt16
				// if Core.logging: Core.parseLog += " "+value
				InputType inputType = cast(value % 32)
				
				if inputType >= TouchDown && inputType <= Wheel
					// if !user: Core.log " ERROR: userId {userId} not in usersById"
					TouchType type = cast((value shiftRight 5) % 8)
					int id = (value shiftRight 8) % 128
					Vector3 position = {inputs.readFloat, inputs.readFloat, inputs.readFloat}
					// bool isSmoothPosition = !Core.smoothTouchPosition or Core.isSmooth or localUser.id == userId
					// if Core.logging: Core.parseLog += " "+id
					
					if inputType == TouchDown
						let touch = user.touches.find.id == id
						if touch
							// Update the touch in user.touches
							touch.phase = cast inputType
							touch.position = position
							// touch.referenceStartPosition = position
							touch.type = type
							touch.isDown = true
							// When we touch down, we start a new touch and reset the "handled" flag
							// This flag is preserved throughout "TouchMove" and "TouchUp", so if we mark the touch
							// as handled at any point, the flags stays set to "true" until we touch down again
							touch.handled = false
							// if Core.logging: Core.parseLog += " down {id} {position} {type}"
							// if isSmoothPosition: touch.smoothPosition = position
						else
							touch = {id, userId, cast inputType, type, position, startPosition:position, smoothPosition:position, isDown:true}
							user.touches.add touch
							// if Core.logging: Core.parseLog += " down(new) {id} {position} {type}"
							
						internalUser.downTouches.add touch
					else
					if inputType == TouchMove
						let touch = user.touches.find.id == id
						if touch
							// Update the touch in user.touches
							touch.phase = cast inputType
							touch.position = position
							touch.type = type
							// if isSmoothPosition: touch.smoothPosition = position
							// if Core.logging: Core.parseLog += " move {id} {position} {type}"
						else
							touch = {id, userId, cast inputType, type, position, startPosition:Vector3.none, smoothPosition:position, isDown:false}
							user.touches.add touch
							// if Core.logging: Core.parseLog += " move(new) {id} {position} {type}"

						internalUser.movingTouches.add touch
						cursor = "auto"
					else
					if inputType == TouchUp
						let touch = user.touches.find.id == id
						if touch
							// Update the touch in user.touches
							touch.phase = cast inputType
							touch.position = position
							touch.type = type
							touch.isDown = false
							// if isSmoothPosition: touch.smoothPosition = position
							// if Core.logging: Core.parseLog += " up {id} {position} {type}"
						else
							touch = {id, userId, cast inputType, type, position, startPosition:Vector3.none, smoothPosition:position, isDown:false}
							user.touches.add touch
							// if Core.logging: Core.parseLog += " up(new) {id} {position} {type}"
							
						internalUser.upTouches.add touch
					// else
					// if inputType == Wheel
					// 	Vector3 delta = {inputs.readInt16, inputs.readInt16}
					// 	internalUser.wheelEvents.add {user, delta, position}
		// 		else
		// 		if inputType == TextInput
		// 			let textInput = inputs.readString
		// 			user.textInput = textInput
		// 			internalUser.textInputs.add textInput
		// 		else
		// 		if inputType == KeyDown
		// 			Key key = cast inputs.readInt32
		// 			let keyPressed = inputs.readString
		// 			internalUser.downKeys.add key
		// 			if keyPressed: internalUser.pressedKeys.add keyPressed
		// 			let keyIndex = user.mapKeyToController.indexOf(key)
		// 			if keyIndex != -1: user.controllerKeyDownFrame[keyIndex] = frame
					
		// 		else
		// 		if inputType == KeyUp
		// 			Key key = cast inputs.readInt32
		// 			internalUser.upKeys.add key
		// 			let keyIndex = user.mapKeyToController.indexOf(key)
		// 			if keyIndex != -1: user.controllerKeyDownFrame[keyIndex] = 0
		// 		else
		// 		if inputType == Navigate
		// 			internalUser.navigations.add inputs.readString
		// 		else
		// 		if inputType == GameController
		// 			GameController c = user.controller
					
		// 			// Controller axix
		// 			c.leftStick.x = inputs.readFloat32
		// 			c.leftStick.y = inputs.readFloat32
					
		// 			// Controller buttons
		// 			let buttons = inputs.readUnsignedInt16
		// 			c.a.state = (buttons bitwiseAnd 1) != 0
		// 			c.b.state = (buttons bitwiseAnd 2) != 0
		// 			c.x.state = (buttons bitwiseAnd 4) != 0
		// 			c.y.state = (buttons bitwiseAnd 8) != 0
		// 			c.type = (buttons bitwiseAnd 16384) != 0 ? PlayStation : Xbox
					
		// 			// Controller button names
		// 			if c.type == Xbox
		// 				c.a.name = "A"
		// 				c.b.name = "B"
		// 				c.x.name = "X"
		// 				c.y.name = "Y"
		// 			else
		// 				c.a.name = "X"
		// 				c.b.name = "O"
		// 				c.x.name = "SQUARE"
		// 				c.y.name = "TRIANGLE"
						
		// 		else
		// 		if inputType == Join
		// 			// We created the user above as soon as received the first input from that user,
		// 			// which is typically the "Join" message that is sent in "startConnected",
		// 			// but could also be a user reconnecting that was previously kicked out
		// 			Core.log "Join {userId}", isCertain
		// 		else
		// 		if inputType == Lost
		// 			let lostUserId = inputs.readInt16
		// 			let lostInternalUser = internalUsers[lostUserId]
		// 				let lostUser = usersById[lostUserId]
						
		// 				// If a user was lost by anybody and nobody who is still connected to that user
		// 				// disagrees within a certrain time, we will remove this user in "handleLost"
		// 				if lostUser and lostUser.lostAtFrame == 0
		// 					lostUser.lostAtFrame = frame
		// 					Core.log "Lost {lostUserId} by {userId} -> Set lostAtFrame to {lostUser.lostAtFrame}"
							
		// 				// If we are still connected to that user, we disagree to their removal
		// 				// by posting the "StillConnected" message
		// 				if lostInternalUser.dataChannel and Core.frame < lostInternalUser.inputFrame + Core.targetFps * 5
		// 					Core.log "Lost {lostUserId} by {userId} -> We are still connected, sending StillConnected", lostInternalUser.dataChannel, Core.frame, lostInternalUser.inputFrame, isCertain
		// 					handleStillConnected lostUserId
		// 				else
		// 					Core.log "Lost {lostUserId} by {userId} -> We also aren't connected", lostInternalUser.dataChannel, Core.frame, lostInternalUser.inputFrame, isCertain
		// 			else
		// 				Core.log "Lost {lostUserId} by {userId} -> No internal user!"
		// 		else
		// 		if inputType == StillConnected
		// 			// Somebody disagreed with the removal of that user because they are still connected,
		// 			// so we cancel the removal
		// 			let lostUserId = inputs.readInt16
		// 			Core.log "Still connected to {lostUserId} by {userId}"
		// 			let lostUser = usersById[lostUserId]
		// 				lostUser.lostAtFrame = 0
		// 		else
		// 		if inputType == SetState
		// 			if Core.logging: Core.parseLog += " setState"
		// 			Core.snapshotBuffer.reset
		// 			inputs.readBuffer Core.snapshotBuffer
		// 			Snapshot.deserialize Core.snapshotBuffer
		// 			Math.recreateRandomValues
		// 		else
		// 		if inputType == String
		// 			int id = inputs.readInt
		// 			string value = inputs.readString
		// 			if Core.logging: Core.parseLog += " string {id}: {value}"
		// 			CoreData.call id, value
		// 		else
		// 		if inputType == Json
		// 			int id = inputs.readInt
		// 			string value = inputs.readString
		// 			if Core.logging: Core.parseLog += " json {id}: {value}"
		// 			dynamic object = Json.parse value
		// 			CoreData.call id, object
		// 		else
		// 		if inputType == Object
		// 			int id = inputs.readInt
		// 			string value = inputs.readString
		// 			if Core.logging: Core.parseLog += " object {id}: {value}"
		// 			dynamic object = Json.parse value
		// 			CoreData.call id, object
	
		// for users
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
		// 		.controller.inMotion = Math.abs(.controller.leftStick.x) >= GameController.deadZone
		// 		                    or Math.abs(.controller.leftStick.y) >= GameController.deadZone
						
	updateUserIndices
	// 	users.orderBy.id
	// 	for users
	// 		.index = i
	// 		internalUsers[.id].index = i
				
	// // Do something when the user touches or clicks within a given area
	// onTouchDown: Vector2 position = {}      // The center of the touch area
	// 	               Vector2 size               // The size of a rectangular touch area
	// 	               int userId = -1            // Only consider touches or clicks from this user  
	// 	               string cursor = ""         // Change the mouse cursor image when hovering over this area
	// 	               bool showClickableArea = false // Draw a red rectangle to visualize that area to touch
	// 	               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
	// 	               void(Touch touch) do       // Do this for each touch or click
	// 	Vector2[] poly = [
	// 		{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 	]
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = usersById[userId]
	// 			for internalUsers[userId].downTouches -> touch
	// 				if !touch.handled and (user.enableTouch or touch.type != Touch)
	// 				and touch.referencePosition.isInsidePoygon(poly)
	// 					log "down", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 	else
	// 		for users -> user
	// 			for internalUsers[user.id].downTouches -> touch
	// 				if !touch.handled and (user.enableTouch or touch.type != Touch)
	// 				and touch.referencePosition.isInsidePoygon(poly)
	// 					log "down", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 		if cursor
	// 			for localUser.movingTouches -> touch
	// 				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
	// 					this.cursor = cursor
				
	// 	if showClickableArea: drawRectangle position, size, fillColor:{"ff000080"}, layer:10000000

	// onTouchDown: Vector2 position           // The center of the touch area
	// 	               Vector2 size               // The size of a rectangular touch area
	// 	               int[] userId               // Only consider touches or clicks from this user  
	// 	               string cursor = ""         // Change the mouse cursor image when hovering over this area
	// 	               bool showClickableArea = false // Draw a red rectangle to visualize that area to touch
	// 	               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
	// 	               void(Touch touch) do       // Do this for each touch or click
	// 	Vector2[] poly = [
	// 		{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 	]
	// 	if not (Core.mode == Connected || Core.simulateConnection)
	// 		userId = null
			
	// 	for users -> user
	// 		if userId == null or userId.contains(.id)
	// 			for internalUsers[user.id].downTouches -> touch
	// 				if !touch.handled and (user.enableTouch or touch.type != Touch)
	// 				and touch.referencePosition.isInsidePoygon(poly)
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 	if cursor
	// 		for localUser.movingTouches -> touch
	// 			if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
	// 				this.cursor = cursor
				
	// 	if showClickableArea: drawRectangle position, size, fillColor:{"ff000080"}

	// // Do something when the user touches or clicks within a given area
	// onTouchDown: Vector2 position           // The center of the touch area
	// 	               Vector2 size               // The size of a rectangular touch area
	// 	               Angle angle                // Rotate the touch area by this angle
	// 	               int userId = -1            // Only consider touches or clicks from this user  
	// 	               string cursor = ""         // Change the mouse cursor image when hovering over this area
	// 	               bool showClickableArea = false // Draw a red rectangle to visualize that area to touch
	// 	               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
	// 	               void(Touch touch) do       // Do this for each touch or click
	// 	Vector2[] poly = [
	// 		(position + Vector2( -size.x/2, -size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
	// 		(position + Vector2( +size.x/2, -size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
	// 		(position + Vector2( +size.x/2, +size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
	// 		(position + Vector2( -size.x/2, +size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
	// 	]
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = usersById[userId]
	// 			for internalUsers[userId].downTouches -> touch
	// 				if !touch.handled and (user.enableTouch or touch.type != Touch) 
	// 				and touch.referencePosition.isInsidePoygon(poly)
	// 					log "down", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 	else
	// 		for users -> user
	// 			for internalUsers[user.id].downTouches -> touch
	// 				if !touch.handled and (user.enableTouch or touch.type != Touch)
	// 				and touch.referencePosition.isInsidePoygon(poly)
	// 					log "down", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 		if cursor
	// 			for localUser.movingTouches -> touch
	// 				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
	// 					this.cursor = cursor
				
	// 	if showClickableArea: drawRectangle position, size, fillColor:{"ff000080"}

	// onTouchDown: Vector2 position           // The center of the touch area
	// 	               Vector2 size               // The size of a rectangular touch area
	// 	               Angle angle                // Rotate the touch area by this angle
	// 	               int[] userId               // Only consider touches or clicks from this user  
	// 	               string cursor = ""         // Change the mouse cursor image when hovering over this area
	// 	               bool showClickableArea = false // Draw a red rectangle to visualize that area to touch
	// 	               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
	// 	               void(Touch touch) do       // Do this for each touch or click
	// 	Vector2[] poly = [
	// 		(position + Vector2( -size.x/2, -size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
	// 		(position + Vector2( +size.x/2, -size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
	// 		(position + Vector2( +size.x/2, +size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
	// 		(position + Vector2( -size.x/2, +size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
	// 	]
	// 	if not (Core.mode == Connected || Core.simulateConnection)
	// 		userId = null
			
	// 	for users -> user
	// 		if userId == null or userId.contains(.id)
	// 			for internalUsers[user.id].downTouches -> touch
	// 				if !touch.handled and (user.enableTouch or touch.type != Touch)
	// 				and touch.referencePosition.isInsidePoygon(poly)
	// 					log "down", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 		if cursor
	// 			for localUser.movingTouches -> touch
	// 				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
	// 					this.cursor = cursor
				
	// 	if showClickableArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Do something when the user touches or clicks within a given circle
	onTouchDown: Vector3 position           // The center of the touch area
		               float radius               // The radius of a round touch area
		               int userId = -1            // Only consider touches or clicks from this user  
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) do       // Do this for each touch or click
		if (Core.mode == Connected || Core.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.downTouches -> touch
					if !touch.handled and(touch.position distanceTo position) <= radius
						do touch
						if markAsHandled: touch.handled = true
		else
			for internalUsers -> user if .active
				for user.downTouches -> touch
					if !touch.handled and (touch.position distanceTo position) <= radius
						do touch
						if markAsHandled: touch.handled = true

	// Do something when the user touches or clicks within a given area
	onTouchDown: Vector3 position           // The center of the touch area
		               Vector3 size               // The size of the touch area
		               int userId = -1            // Only consider touches or clicks from this user  
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) do       // Do this for each touch or click
		if (Core.mode == Connected || Core.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.downTouches -> touch
					if !touch.handled and touch.position isInside position, size
						do touch
						if markAsHandled: touch.handled = true
		else
			for internalUsers -> user if .active
				for user.downTouches -> touch
					if !touch.handled and touch.position isInside position, size
						do touch
						if markAsHandled: touch.handled = true

	// // Do something when the user touches or clicks within a given polygon
	// onTouchDown: Vector2 position           // The center of the touch area
	// 	               Vector2[] points           // The points that define the touch area
	// 	               int userId = -1            // Only consider touches or clicks from this user  
	// 	               string cursor = ""         // Change the mouse cursor image when hovering over this polygon
	// 	               bool showClickableArea = false // Draw a red polygon to visualize that area to touch
	// 	               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
	// 	               void(Touch touch) do       // Do this for each touch or click
	// 	Vector2[] poly
	// 	for points: poly.add (position + .).transform(graphics.localMatrix)
			
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = usersById[userId]
	// 			for internalUsers[userId].downTouches -> touch
	// 				if !touch.handled and (user.enableTouch or touch.type != Touch)
	// 				and touch.referencePosition.isInsidePoygon(poly)
	// 					log "down", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 	else
	// 		for users -> user
	// 			for internalUsers[user.id].downTouches -> touch
	// 				if !touch.handled and (user.enableTouch or touch.type != Touch)
	// 				and touch.referencePosition.isInsidePoygon(poly)
	// 					log "down", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 		if cursor
	// 			for localUser.movingTouches -> touch
	// 				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
	// 					this.cursor = cursor
				
	// 	if showClickableArea: drawPolygon position, points, fillColor:{"ff0000b0"}

	// // Do something when the user touches or clicks within a given area
	// : Vector2 position           // The center of the touch area
	// 	             Vector2 size               // The size of a rectangular touch area
	// 	             int userId = -1            // Only consider touches or clicks from this user
	// 	             bool showClickableArea = false // Draw a red rectangle to visualize that area to touch
	// 	             bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
	// 	             void(Touch touch) do       // Do this for each touch or click
	// 	Vector2[] poly = [
	// 		{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 	]
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = internalUsers[userId]
	// 			for user.upTouches -> touch
	// 				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
	// 					log "up", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 					Snapshot.autoSave
	// 	else
	// 		for users -> user
	// 			for internalUsers[user.id].upTouches -> touch
	// 				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
	// 					log "up", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 					Snapshot.autoSave
	// 	if showClickableArea: drawRectangle position, size, fillColor:{"ff000080"}

	// : Vector2 position           // The center of the touch area
	// 	             Vector2 size               // The size of a rectangular touch area
	// 	             int[] userId               // Only consider touches or clicks from this user
	// 	             bool showClickableArea = false // Draw a red rectangle to visualize that area to touch
	// 	             bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
	// 	             void(Touch touch) do       // Do this for each touch or click
	// 	Vector2[] poly = [
	// 		{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 	]
	// 	if not (Core.mode == Connected || Core.simulateConnection)
	// 		userId = null
	// 	for internalUsers -> user
	// 		if user and (userId == null or userId.contains(.id))
	// 			for user.upTouches -> touch
	// 				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
	// 					log "up", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 					Snapshot.autoSave
	// 	if showClickableArea: drawRectangle position, size, fillColor:{"ff000080"}

	// // Do something when the user touches or clicks within a given area
	// : Vector2 position           // The center of the touch area
	// 	             float radius               // The radius of a round touch area
	// 	             int userId = -1            // Only consider touches or clicks from this user  
	// 	             string cursor = ""         // Change the mouse cursor image when hovering over this area
	// 	             bool showClickableArea = false // Draw a red circle to visualize that area to touch
	// 	             bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
	// 	             void(Touch touch) do       // Do this for each touch or click
	// 	let referencePosition = position.transform(graphics.localMatrix)
	// 	let referenceRadius = radius * graphics.localMatrix.scaleVector.x
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = internalUsers[userId]
	// 			for user.upTouches -> touch
	// 				if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
	// 					log "up", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 					Snapshot.autoSave
	// 	else
	// 		for users -> user
	// 			for internalUsers[user.id].upTouches -> touch
	// 				if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
	// 					log "up", touch.referencePosition
	// 					do touch
	// 					if markAsHandled: touch.handled = true
	// 					Snapshot.autoSave
	// 		if cursor
	// 			for localUser.movingTouches -> touch
	// 				if !touch.handled && (touch.referencePosition distanceTo position) <= radius
	// 					this.cursor = cursor
				
	// 	if showClickableArea: drawCircle position, radius*2, fillColor:{"ff000080"}

	// onTouchOver: Vector2 position           // The center of the touch area
	// 	         Vector2 size               // The size of a rectangular touch area
	// 	         int userId = -1            // Only consider touches or clicks from this user  
	// 	         string cursor = ""         // Change the mouse cursor image when hovering over this area
	// 	         bool showClickableArea = false // Draw a red rectangle to visualize that area to touch
	// 	         bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
	// 	         void(Touch touch) do       // Do this for each touch or click
	// 	Vector2[] poly = [
	// 		{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 	]
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = usersById[userId]
	// 			for user.touches -> touch
	// 				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
	// 					log "over", touch.referencePosition
	// 					do touch
	// 	else
	// 		for users -> user
	// 			for user.touches -> touch
	// 				if touch.referencePosition.isInsidePoygon(poly)
	// 					log "over", touch.referencePosition
	// 					do touch
	// 		if cursor
	// 			for localUser.movingTouches -> touch
	// 				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
	// 					this.cursor = cursor
				
	// 	if showClickableArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Do something when the user touches or clicks
	onTouchDown: int userId = -1      // Only consider touches or clicks from this user
		         void(Touch touch) do // Do this for each touch or click
		if (Core.mode == Connected || Core.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
						// log "down", touch.referencePosition
						do touch
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
						// log "down", touch.referencePosition
						do touch

	// // Do something when the user touches, even if the touch is already handled
	// onTouchDownAny: int userId = -1      // Only consider touches or clicks from this user
	// 	            void(Touch touch) do // Do this for each touch or click
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = usersById[userId]
	// 			for internalUsers[userId].downTouches -> touch
	// 				if user.enableTouch or touch.type != Touch
	// 					log "down", touch.referencePosition
	// 					do touch
	// 	else
	// 		for users -> user
	// 			for internalUsers[user.id].downTouches -> touch
	// 				if user.enableTouch or touch.type != Touch
	// 					log "down", touch.referencePosition
	// 					do touch
			
	// Do something when a touch or click moves
	onTouchMove: Touch touch          // Only do this if this particular touch or click moves
		         void(Touch touch) do // Do this for each touch or click
		if !touch: return
		let touchId = touch.id
		let user = internalUsers[touch.userId]
			for user.movingTouches
				if .id == touchId
					do .
	
	// Do something when a touch or click moves
	onTouchMove: int userId = -1      // Only consider touches or clicks from this user
		         void(Touch touch) do // Do this for each touch or click
		if (Core.mode == Connected || Core.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.movingTouches
					do .
		else
			for internalUsers -> user if .active
				for user.movingTouches
					do .
					
	onTouchUp: Touch touch               // Only do this if this particular touch or click ended
		       bool markAsHandled = true // Mark the touch as handled so it won't trigger more touch events
		       void(Touch touch) do      // Do this for each touch or click
		if !touch: return
		let touchId = touch.id
		let user = internalUsers[touch.userId]
			for user.upTouches
				if .id == touchId
					do .
					// Snapshot.autoSave
					if markAsHandled: .handled = true
				
	// Do something when a touch or click ends
	onTouchUp: int userId = -1
		       bool markAsHandled = true // Mark the touch as handled so it won't trigger more touch events
		       void(Touch touch) do      // Do this for each touch or click
		if (Core.mode == Connected || Core.simulateConnection) && userId != -1
			let user = internalUsers[userId]
				for user.upTouches -> t
					if !t.handled
						do t
						// Snapshot.autoSave
		else
			for internalUsers -> user if .active
				for user.upTouches -> t
					if !t.handled
						do t
						// Snapshot.autoSave
						
	// private log: string text, Vector2 pos
	// 	if Core.logging: Core.touchLog += " #{Core.frame}{isCertain ? " c" : ""} {text} {pos}"

	// // Do something when a user moves the mouse wheel
	// onWheel: int userId = -1
	// 	     void(WheelEvent event) do // Do this for each mouse wheel movement
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = internalUsers[userId]
	// 			for user.wheelEvents
	// 				do .
	// 	else
	// 		for internalUsers -> user if user
	// 			for user.wheelEvents
	// 				do .
	
	// // Do something when a user moves the mouse wheel within a given rectangle
	// onWheelWithin: Vector2 position            // The center of the rectangle
	// 	           Vector2 size                // The size of the rectangle
	// 	           int userId = -1             // Only consider wheel movments from this user
	// 	           bool showClickableArea = false  // Draw a red rectangle to visualize that area to touch
	// 	           bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
	// 	           void(WheelEvent event) do   // Do this for each mouse wheel movement
	// 	Vector2[] poly = [
	// 		{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 	]
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = internalUsers[userId]
	// 			for user.wheelEvents -> event
	// 				if !event.handled && event.referencePosition.isInsidePoygon(poly)
	// 					log "wheel", event.referencePosition
	// 					do event
	// 					if markAsHandled: event.markAsHandled
	// 	else
	// 		for internalUsers -> user if .
	// 			for user.wheelEvents -> event
	// 				if !event.handled && event.referencePosition.isInsidePoygon(poly)
	// 					log "wheel", event.referencePosition
	// 					do event
	// 					if markAsHandled: event.markAsHandled
	// 	if showClickableArea: drawRectangle position, size, Red
			
	// onWheelWithin: Vector2 position            // The center of the rectangle
	// 	           Vector2 size                // The size of the rectangle
	// 	           int[] userId               // Only consider wheel movments from this user
	// 	           bool showClickableArea = false  // Draw a red rectangle to visualize that area to touch
	// 	           bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
	// 	           void(WheelEvent event) do   // Do this for each mouse wheel movement
	// 	Vector2[] poly = [
	// 		{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 		{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
	// 	]
	// 	if not (Core.mode == Connected || Core.simulateConnection)
	// 		userId = null

	// 	for internalUsers -> user
	// 		if user and (userId == null or userId.contains(.id))
	// 			for user.wheelEvents -> event
	// 				if !event.handled && event.referencePosition.isInsidePoygon(poly)
	// 					log "wheel", event.referencePosition
	// 					do event
	// 					if markAsHandled: event.markAsHandled
	// 	if showClickableArea: drawRectangle position, size, Red
			
	// bool isTextInputActive = false
	
	// private js object getOrCreateInputField
	// 	if(!window._input) {
	// 		window._input = document.createElement("input")
	// 		_input.type = "text"
	// 		_input.style.position = "absolute"
	// 		_input.style.left = "-10000px" 
	// 		_input.style.width = "1px"
	// 		_input.style.height = "1px"
	// 		_input.style.fontSize = "1px"
	// 		_input.style.backgroundColor = "#000000"
	// 		_input.oninput = e => Input.handleTextInput(7, _input.value)
	// 		_input.onblur = e => {
	// 			if(Input.isTextInputActive) {
	// 				_input.focus()
	// 			}
	// 		}
	// 		document.body.appendChild(_input)
	// 	}
	// 	return _input
				
	// js void startTextInput: string initalValue = null, int forUser = -1
	// 	if(forUser == -1 || Input.localUser?.id == forUser) {
	// 		let input = Input.getOrCreateInputField()
	// 		if(initalValue != null) { 
	// 			input.value = initalValue
	// 		}
	// 		_input.focus()
	// 		Input.isTextInputActive = true
	// 	}
		
	// js void stopTextInput
	// 	Input.isTextInputActive = false
		
	// js void setTextInput: string value
	// 	let input = Input.getOrCreateInputField()
	// 	input.value = value
	// 	Input.handleTextInput(7, value)
		
	// js void updateCursor
	// 	document.body.style.cursor = Input.cursor

	// onTextComposition: void(string characters) do
	// 	for internalUsers -> user if .
	// 		for user.textCompositions -> text
	// 			do text
				
	// onTextInput: int userId = -1, void(string textInput) do
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = internalUsers[userId]
	// 			for user.textInputs -> text
	// 				do text
	// 	else
	// 		for internalUsers -> user if .
	// 			for user.textInputs -> text
	// 				do text
				
	// onKeyDown: Key key
	// 	       int userId = -1
	// 	       void(Key key, int keyUserId) do
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = internalUsers[userId]
	// 			for user.downKeys
	// 				if . == key
	// 					do key, userId
	// 	else
	// 		for internalUsers -> user if .
	// 			for user.downKeys
	// 				if . == key
	// 					do key, user.id
				
	// onKeyDown: Key key
	// 	       int[] userId
	// 	       void(Key key, int keyUserId) do
	// 	if not (Core.mode == Connected || Core.simulateConnection)
	// 		userId = null
	// 	for internalUsers -> user
	// 		if user and (userId == null or userId.contains(.id))
	// 			for user.downKeys
	// 				if . == key
	// 					do key, user.id
				
	// onKeyDown: int userId = -1, void(Key key, int keyUserId) do
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = internalUsers[userId]
	// 			for user.downKeys -> key
	// 				do key, userId
	// 	else
	// 		for internalUsers -> user if .
	// 			for user.downKeys -> key
	// 				do key, user.id
				
	// onKeyUp: int userId = -1, void(Key key, int keyUserId) do
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = internalUsers[userId]
	// 			for user.upKeys -> key
	// 				do key, userId
	// 	else
	// 		for internalUsers -> user if .
	// 			for user.upKeys -> key
	// 				do key, user.id
					
	// onKeyPressed: int userId = -1, void(string key, int keyUserId) do
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = internalUsers[userId]
	// 			for user.pressedKeys -> key
	// 				do key, userId
	// 	else
	// 		for internalUsers -> user if .
	// 			for user.pressedKeys -> key
	// 				do key, user.id
			
	// // Do something when the user navigates back or forward in the browser	
	// onNavigate: int userId = -1
	// 	        void(string url) do
	// 	if (Core.mode == Connected || Core.simulateConnection) && userId != -1
	// 		let user = internalUsers[userId]
	// 			for user.navigations -> url
	// 				do url
	// 	else
	// 		for internalUsers -> user if .
	// 			for user.navigations -> url
	// 				do url
				

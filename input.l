// The internal state of a user that isn't serialized and shoudn't be accessed by the application
transient class InternalUser
	int id              // The userId stays the same when a user reconnects
	bool local          // Is this the local user?
	
	bool collectInputs  // When we are done pinging, we add a join event and start collecting inputs
	int inputFrame      // We got all inputs from this player up to and including this frame
	int bufferFrames
	int inputsSentPos
	
	visible Touch[] downTouches, movingTouches, upTouches
	visible WheelEvent[] wheelEvents
	visible int[] downKeys, upKeys
	visible string[] textInputs, textCompositions
	
	int[] lastTouchMoveIndex
	
	Buffer inputs         // The stream of inputs of this user
	int uncertainReadPos  // The buffer position where we haven't received inputs from all users
	
	object mediaStream
	object[] videoElements
	int videoElementIndex = 0
	
	object peerConnection
	object dataChannel
	bool offerByMe
	
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
	
// The public state of a user
class NetworkUser
	int id
	int index
	Color color
	visible Touch[] touches
	string textInput
	bool enableTouch = true
	bool isReady
	
	internal int[] connectedTo

	internal clearEvents
		bool hasToch = touches.any.type == Touch
		for touches <-
			if (.phase == Up and .type >= Touch) or (hasToch and .type != Touch)
				touches.remove .
	
enum InputType: None, TouchDown, TouchMove, TouchUp, Wheel, KeyDown, KeyUp, TextInput, Stick, Trigger, Grip, ButtonDown, ButtonUp, ControllerTransform, HeadTransform, DeviceRotation, Join, Lost, SetState
		
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
	
// A collection of methods to receive user input
unit Input
	transient visible InternalUser[] internalUsers
	transient visible bool isCertain
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
			Input_handleTouchEvent(1, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button);
		}
		window.onpointermove = e => {
			Input_handleTouchEvent(2, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button);
		}
		window.onpointerup = e => {
			Input_handleTouchEvent(3, e.pageX, e.pageY, e.pointerType, e.pointerId, e.button);
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
			if(window.require && e.key == "t" && e.ctrlKey && e.metaKey && e.shiftKey)
				require("electron").remote.getCurrentWindow().toggleDevTools()
			else
			if(e.ctrlKey && e.key == "o") {
				// Open event stream
				Network_openEventStream();
				e.preventDefault();
			}
			else
			if(e.ctrlKey && e.key == "s") {
				// Save event steam
				Network_saveEventStream();
				e.preventDefault();
			}
			else
			if(e.ctrlKey && e.key == "l") {
				// Save logs
				Network_saveLogs();
				e.preventDefault();
			}
			else
			if(e.key >= "0" && e.key <= "9") {
				let index = e.key - "0"
				if(e.altKey)         { Network_save(index); e.preventDefault(); } else
				if(e.ctrlKey)        { Network_restore(index); e.preventDefault(); } else
				if(Platform_isDebug) { Network_switchUser(index-1); e.preventDefault(); } 
			}
			else
			// Reload
			if(e.ctrlKey && e.key == "F1") {/*keep room, keep userId*/ ServerNetwork_sendReload(false, false); e.preventDefault();} else
			if(e.ctrlKey && e.key == "F2") {/*new  room, keep userId*/ ServerNetwork_sendReload(true,  false); e.preventDefault();} else
			if(e.ctrlKey && e.key == "F3") {/*new  room, new  userId*/ ServerNetwork_sendReload(true,  true);  e.preventDefault();} else
			
			// Switch send interval
			if(e.ctrlKey && e.key == "F5") {Network_switchSendInterval( 3); e.preventDefault();} else
			if(e.ctrlKey && e.key == "F6") {Network_switchSendInterval(10); e.preventDefault();} else
			if(e.ctrlKey && e.key == "F7") {Network_switchSendInterval(20); e.preventDefault();} else
			if(e.ctrlKey && e.key == "F8") {Network_switchSendInterval(30); e.preventDefault();} else
			if(e.ctrlKey && e.key == "F9") {Network_switchSendInterval(40); e.preventDefault();} else
				
			if(e.ctrlKey && e.key == "F10") {Network_switchSendInputMode(1); e.preventDefault();} else
			if(e.ctrlKey && e.key == "F11") {Network_switchSendInputMode(2); e.preventDefault();} else
				
			if(e.key == "F9") {
				if(e.shiftKey) { Network_saveLogs(); }
				else           { Platform_toggleDebugInfo(); Network_debugString = "" }
				e.preventDefault();
			}
			else
				Input_handleKeyEvent(5, keyCode)
		}
		window.onkeyup = e => {
			if(e.key == "F1")
				// TEMP for testing
				Network_skipAnimationFrame = false;
			else
			if(e.key == "F2")
				// TEMP for testing
				Network_skipSending = false;
			else
				Input_handleKeyEvent(6, e.keyCode)
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
			
	private handleKeyEvent: InputType type, int keyCode
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast type
		inputs.writeInt32 keyCode
		
	internal handleTouchEvent: InputType inputType, float x, float y, string pointerType, int pointerId, int button
		int touchType, id
		if pointerType == "mouse": touchType = button.limit(min:0, max:2); else
		if pointerType == "touch": touchType = 3; id = pointerId; else
			                       touchType = 4
		
		Vector2 pixelPos = {x*Platform.pixelRatio, y*Platform.pixelRatio}
		Vector2 referencePos = pixelPos.getRelativeTo(Platform.baseMatrix)
		Platform.handleSlide inputType, id, pixelPos, referencePos
		
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs

		if inputType == TouchMove
			int index = getLastTouchMoveIndex id
			if index
				// We already moved the pointer this input frame, so just update the last move
				inputs.setInt16 index, Math.round(referencePos.x)
				inputs.setInt16 index+2, Math.round(referencePos.y)
				Network.writeLog += " #{localUser.inputFrame} override {id} at {index} to {Math.round(referencePos.x)} {Math.round(referencePos.y)}"
				return
			else
				setLastTouchMoveIndex id, inputs.writePos+6
				Network.writeLog += " save {id} at {inputs.writePos+6}"
			
		int composite = cast(inputType)                                 // inputType: 0 -  31 (5 bit)
		              + Math.shiftLeft(touchType, 5)                    // touchType: 0 -   7 (3 bit)
		              + Math.shiftLeft(Math.floor(Math.abs(id))%128, 8) // id:        0 - 127 (7 bit)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 Math.round(referencePos.x)
		inputs.writeInt16 Math.round(referencePos.y)
		Network.writeLog += " #{localUser.inputFrame} {composite} {Math.round(referencePos.x)} {Math.round(referencePos.y)} ({inputs.readPos}/{inputs.writePos})"
		
	private handleWheelEvent: float x, float y, float delta
		if Network.mode == None || Platform.mode != Record || !localUser || !localUser.collectInputs: return
		let inputs = localUser.inputs
		
		Vector2 referencePos = {x*Platform.pixelRatio, y*Platform.pixelRatio}.getRelativeTo(Platform.baseMatrix)
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast InputType.Wheel
		inputs.writeInt16 Math.round(referencePos.x)
		inputs.writeInt16 Math.round(referencePos.y)
		inputs.writeInt16 Math.round(delta)
		Network.writeLog += " [{localUser.inputFrame}] wheel {Math.round(referencePos.x)} {Math.round(referencePos.y)} {Math.round(delta)} \{r:{inputs.readPos} w:{inputs.writePos}\}"
		
	internal handleSetState: Buffer buffer
		let inputs = localUser.inputs
		inputs.writeInt32 localUser.inputFrame
		inputs.writeUnsignedInt16 cast InputType.SetState
		inputs.writeBuffer buffer
		
	internal parseInputs(int frame, bool isCertain)
		this.isCertain = isCertain
		if isCertain: Network.parseLog += " c"
		for internalUsers -> internalUser
			if internalUser
				let inputs = internalUser.inputs
				let userId = internalUser.id
				let user = usersById[userId]
				Network.parseLog += " <{userId}>"
				
				while true
					int nextFrame = inputs.canRead ? inputs.peekInt32 : int.maxValue
					Network.parseLog += " ({inputs.readPos}/{inputs.writePos})"
					if inputs.canRead: Network.parseLog += " *{nextFrame}"
					if nextFrame > frame: break
					inputs.readPos += 4
					
					let value = inputs.readUnsignedInt16
					Network.parseLog += " "+value
					InputType inputType = cast(value % 32)
					
					if inputType >= TouchDown && inputType <= Wheel
						if !user: Network.parseLog += " Error: user == null"
						TouchType type = cast((value shiftRight 5) % 8)
						int id = (value shiftRight 8) % 128
						Vector2 referencePos = {inputs.readInt16, inputs.readInt16}
						bool isSmoothPosition = !Network.smoothTouchPosition or isCertain or localUser.id == userId
						Network.parseLog += " "+id
						
						if inputType == TouchDown
							let touch = user.touches.find a.id == id
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
								Network.parseLog += " down {id} {referencePos} {type}"
								if isSmoothPosition: touch.smoothPosition = referencePos
							else
								touch = {id, userId, cast inputType, type, referencePos, referencePos, referencePos, isDown:true}
								user.touches.add touch
								Network.parseLog += " down(new) {id} {referencePos} {type}"
								
							internalUser.downTouches.add touch
						else
						if inputType == TouchMove
							let touch = user.touches.find a.id == id
							if touch
								// Update the touch in user.touches
								touch.phase = cast inputType
								touch.referencePosition = referencePos
								touch.type = type
								if isSmoothPosition: touch.smoothPosition = referencePos
								Network.parseLog += " move {id} {referencePos} {type}"
							else
								touch = {id, userId, cast inputType, type, referencePos, referenceStartPosition:Vector2.none, referencePos, isDown:false}
								user.touches.add touch
								Network.parseLog += " move(new) {id} {referencePos} {type}"
	
							internalUser.movingTouches.add touch
							cursor = "auto"
						else
						if inputType == TouchUp
							let touch = user.touches.find a.id == id
							if touch
								// Update the touch in user.touches
								touch.phase = cast inputType
								touch.referencePosition = referencePos
								touch.type = type
								touch.isDown = false
								if isSmoothPosition: touch.smoothPosition = referencePos
								Network.parseLog += " up {id} {referencePos} {type}"
							else
								touch = {id, userId, cast inputType, type, referencePos, referenceStartPosition:Vector2.none, referencePos, isDown:false}
								user.touches.add touch
								Network.parseLog += " up(new) {id} {referencePos} {type}"
								
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
						let keyCode = inputs.readInt32
						internalUser.downKeys.add keyCode
					else
					if inputType == KeyUp
						internalUser.upKeys.add inputs.readInt32
					else
					if inputType == Join
						// Add the user if the user doesn't already exist
						if users.none.id == userId
							users.add user = {id:userId, index:users.length}
							usersById[userId] = user
						
							// Update user.connectedTo and user.index
							for users
								if . and .id != userId
									.connectedTo.ensure userId
									user.connectedTo.ensure .id
							updateUserIndices
							Network.parseLog += " join {userId} connectedTo:{user.connectedTo} userCount:{users.length}"
							// TEMP logging
							// Network.log "#{nextFrame}{isCertain ? " certain":""} join {userId} connectedTo:{user.connectedTo} userCount:{users.length}"
						else
							Network.parseLog += "#{nextFrame}{isCertain ? " certain":""} join {userId} user already exists, userCount:{users.length}"
							// TEMP logging
							// Network.log " join {userId} user already exists, userCount:{users.length}"
					else
					if inputType == Lost
						let lostUserId = inputs.readInt16
						user.connectedTo.remove lostUserId
						let lostUser = usersById[lostUserId]
							lostUser.connectedTo.remove userId
							if lobby.inLobby and lostUser.connectedTo.length == 0
								// If all players have lost the connected to a user, we remove this user
								users.removeAllWhere.id == lostUserId
								usersById[lostUserId] = null
								// Network.removeVideoElement lostUserId
								updateUserIndices
								Network.parseLog += " lost {lostUserId} by {userId}, removed user, userCount:{users.length}"
								// TEMP logging
								Network.log " lost {lostUserId} by {userId}, removed user, userCount:{users.length}"
							else	
								Network.parseLog += " lost {lostUserId} by {userId}, remaining:{user.connectedTo.length} {user.connectedTo}"
								// TEMP logging
								Network.log " lost {lostUserId} by {userId}, removed user, userCount:{users.length}"
					else
					if inputType == SetState
						Network.parseLog += " setState"
						Network.snapshotBuffer.reset
						inputs.readBuffer Network.snapshotBuffer
						Snapshot.deserialize Network.snapshotBuffer
						Math.recreateRandomValues
						
	updateUserIndices
		users.orderBy.id
		for users: .index = i
				
	// Executes code when the user touches or clicks within a given area
	onTouchDownWithin: Vector2 position           // The center of the touch area
		               Vector2 size               // The size of a rectangular touch area
		               int userId = -1            // Only consider touches or clicks from this user  
		               string cursor = ""         // Change the mouse cursor image when hovering over this area
		               bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) code     // The code to execute for each touch or click
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
						code touch
						if markAsHandled: touch.handled = true
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						code touch
						if markAsHandled: touch.handled = true
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Executes code when the user touches or clicks within a given area
	onTouchDownWithin: Vector2 position           // The center of the touch area
		               Vector2 size               // The size of a rectangular touch area
		               float angle                // Rotate the touch area by this angle
		               int userId = -1            // Only consider touches or clicks from this user  
		               string cursor = ""         // Change the mouse cursor image when hovering over this area
		               bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) code     // The code to execute for each touch or click
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
						code touch
						if markAsHandled: touch.handled = true
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						code touch
						if markAsHandled: touch.handled = true
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Executes code when the user touches or clicks within a given circle
	onTouchDownWithin: Vector2 position           // The center of the touch area
		               float radius               // The radius of a round touch area
		               int userId = -1            // Only consider touches or clicks from this user  
		               string cursor = ""         // Change the mouse cursor image when hovering over this circle
		               bool showTouchArea = false // Draw a red circle to visualize that area to touch
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) code     // The code to execute for each touch or click
		let referencePosition = position.getTransformed(graphics.localMatrix)
		let referenceRadius = radius * graphics.localMatrix.scaleVector.x
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if !touch.handled  and (user.enableTouch or touch.type != Touch)
					and (touch.referencePosition distanceTo referencePosition) <= referenceRadius
						log "down", touch.referencePosition
						code touch
						if markAsHandled: touch.handled = true
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and (touch.referencePosition distanceTo referencePosition) <= referenceRadius
						log "down", touch.referencePosition
						code touch
						if markAsHandled: touch.handled = true
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && (touch.referencePosition distanceTo position) <= radius
						this.cursor = cursor
				
		if showTouchArea: drawCircle position, radius, fillColor:{"ff000080"}

	// Executes code when the user touches or clicks within a given polygon
	onTouchDownWithin: Vector2 position           // The center of the touch area
		               Vector2[] points           // The points that define the touch area
		               int userId = -1            // Only consider touches or clicks from this user  
		               string cursor = ""         // Change the mouse cursor image when hovering over this polygon
		               bool showTouchArea = false // Draw a red polygon to visualize that area to touch
		               bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		               void(Touch touch) code     // The code to execute for each touch or click
		Vector2[] poly
		for points: poly.add (position + .).transform(graphics.localMatrix)
			
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						code touch
						if markAsHandled: touch.handled = true
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
					and touch.referencePosition.isInsidePoygon(poly)
						log "down", touch.referencePosition
						code touch
						if markAsHandled: touch.handled = true
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawPolygon position, points, fillColor:{"ff0000b0"}

	// Executes code when the user touches or clicks within a given area
	onTouchUpWithin: Vector2 position           // The center of the touch area
		             Vector2 size               // The size of a rectangular touch area
		             int userId = -1            // Only consider touches or clicks from this user
		             bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		             bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		             void(Touch touch) code     // The code to execute for each touch or click
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
					code touch
					if markAsHandled: touch.handled = true
					Snapshot.autoSave
		else
			for internalUsers -> user
				for user.upTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						log "up", touch.referencePosition
						code touch
						if markAsHandled: touch.handled = true
						Snapshot.autoSave
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Executes code when the user touches or clicks within a given area
	onTouchUpWithin: Vector2 position           // The center of the touch area
		             float radius               // The radius of a round touch area
		             int userId = -1            // Only consider touches or clicks from this user  
		             string cursor = ""         // Change the mouse cursor image when hovering over this area
		             bool showTouchArea = false // Draw a red circle to visualize that area to touch
		             bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		             void(Touch touch) code     // The code to execute for each touch or click
		let referencePosition = position.transform(graphics.localMatrix)
		let referenceRadius = radius * graphics.localMatrix.scaleVector.x
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for user.upTouches -> touch
				if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
					log "up", touch.referencePosition
					code touch
					if markAsHandled: touch.handled = true
					Snapshot.autoSave
		else
			for internalUsers -> user
				for user.upTouches -> touch
					if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
						log "up", touch.referencePosition
						code touch
						if markAsHandled: touch.handled = true
						Snapshot.autoSave
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && (touch.referencePosition distanceTo position) <= radius
						this.cursor = cursor
				
		if showTouchArea: drawCircle position, radius, fillColor:{"ff000080"}

	onTouchOver: Vector2 position           // The center of the touch area
		         Vector2 size               // The size of a rectangular touch area
		         int userId = -1            // Only consider touches or clicks from this user  
		         string cursor = ""         // Change the mouse cursor image when hovering over this area
		         bool showTouchArea = false // Draw a red rectangle to visualize that area to touch
		         bool markAsHandled = true  // Mark the touch as handled so it won't trigger more touch events
		         void(Touch touch) code     // The code to execute for each touch or click
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
						code touch
		else
			for users -> user
				for user.touches -> touch
					if touch.referencePosition.isInsidePoygon(poly)
						log "over", touch.referencePosition
						code touch
			if cursor
				for localUser.movingTouches -> touch
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Executes code when the user touches or clicks
	onTouchDown: int userId = -1        // Only consider touches or clicks from this user
		         void(Touch touch) code // The code to execute for each touch or click
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
						log "down", touch.referencePosition
						code touch
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if !touch.handled and (user.enableTouch or touch.type != Touch)
						log "down", touch.referencePosition
						code touch

	// Executes code when the user touches, even if the touch is already handled
	onTouchDownAny: int userId = -1        // Only consider touches or clicks from this user
		            void(Touch touch) code // The code to execute for each touch or click
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = usersById[userId]
				for internalUsers[userId].downTouches -> touch
					if user.enableTouch or touch.type != Touch
						log "down", touch.referencePosition
						code touch
		else
			for users -> user
				for internalUsers[user.id].downTouches -> touch
					if user.enableTouch or touch.type != Touch
						log "down", touch.referencePosition
						code touch
			
	// Executes code when a touch or click moves
	onTouchMove: Touch touch            // Only execute the given code if this particular touch or click moves
		         void(Touch touch) code // The code to execute for each touch or click
		if !touch: return
		let touchId = touch.id, user = internalUsers[touch.userId]
		for user.movingTouches
			if .id == touchId
				log "move", .referencePosition
				code .
	
	// Executes code when a touch or click moves
	onTouchMove: int userId = -1        // Only consider touches or clicks from this user
		         void(Touch touch) code // The code to execute for each touch or click
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for user.movingTouches -> t
				if !t.handled
					log "move", t.referencePosition
					code t
		else
			for internalUsers -> user
				for user.movingTouches -> t
					if !t.handled
						log "move", t.referencePosition
						code t
					
	onTouchUp: Touch touch               // Only execute the given code if this particular touch or click ended
		       bool markAsHandled = true // Mark the touch as handled so it won't trigger more touch events
		       void(Touch touch) code    // The code to execute for each touch or click
		if !touch: return
		let touchId = touch.id, user = internalUsers[touch.userId]
		for user.upTouches
			if .id == touchId
				log "up", .referencePosition
				code .
				Snapshot.autoSave
				if markAsHandled: .handled = true
				
	// Executes code when a touch or click ends
	onTouchUp: int userId = -1
		       bool markAsHandled = true // Mark the touch as handled so it won't trigger more touch events
		       void(Touch touch) code    // The code to execute for each touch or click
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for user.upTouches -> t
				if !t.handled
					log "up", t.referencePosition
					code t
					Snapshot.autoSave
		else
			for internalUsers -> user
				for user.upTouches -> t
					if !t.handled
						log "up", t.referencePosition
						code t
						Snapshot.autoSave
						
	private log: string text, Vector2 pos
		Network.touchLog += " #{Network.frame}{isCertain ? " c" : ""} {text} {pos}"

	// Executes code when a touch or click ends
	onWheel: void(WheelEvent event) code // The code to execute for each touch or click
		for internalUsers -> user
			for user.wheelEvents
				code .
	
	// Executes code when a user moves the mouse wheel within a given rectangle
	onWheelWithin: Vector2 position            // The center of the rectangle
		           Vector2 size                // The size of the rectangle
		           int userId = -1             // Only consider wheel movments from this user
		           bool showTouchArea = false  // Draw a red rectangle to visualize that area to touch
		           bool markAsHandled = true   // Mark the touch as handled so it won't trigger more touch events
		           void(WheelEvent event) code // The code to execute
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
					code event
					if markAsHandled: event.markAsHandled
		else
			for internalUsers -> user
				for user.wheelEvents -> event
					if !event.handled && event.referencePosition.isInsidePoygon(poly)
						log "wheel", event.referencePosition
						code event
						if markAsHandled: event.markAsHandled
		if showTouchArea: drawRectangle position, size, Red
	
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
			_input.oninput = e => {
				Input_handleTextInput(7, _input.value)
			}
			document.body.appendChild(_input)
		}
		return _input
				
	js void startTextInput: string initalValue = null
		let input = Input_getOrCreateInputField()
		if(initalValue != null) { 
			input.value = initalValue
		}
		setTimeout(() => _input.focus(), 0)
		
	js void setTextInput: string value
		let input = Input_getOrCreateInputField()
		input.value = value
		Input_handleTextInput(7, value)
		
	js void updateCursor
		document.body.style.cursor = Input_cursor

	onTextComposition: void(string characters) code
		for internalUsers -> user
			for user.textCompositions -> text
				code text
				
	onTextInput: void(string textInput) code
		for internalUsers -> user
			for user.textInputs -> text
				code text
				
	onKeyDown: int key, int userId = -1, void(int key, int keyUserId) code
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for user.downKeys
				if . == key
					code key, userId
		else
			for internalUsers -> user
				for user.downKeys
					if . == key
						code key, user.id
				
	onKeyDown: int userId = -1, void(int key, int keyUserId) code
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for user.downKeys -> key
				code key, userId
		else
			for internalUsers -> user
				for user.downKeys -> key
					code key, user.id
				
	onKeyUp: int userId = -1, void(int key, int keyUserId) code
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for user.upKeys -> key
				code key, userId
		else
			for internalUsers -> user
				for user.upKeys -> key
					code key, user.id

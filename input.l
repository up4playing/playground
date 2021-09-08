// The internal state of a user that isn't serialized and shoudn't be accessed by the application
transient class InternalUser
	int id
	bool local
	
	bool collectInputs  // When we are done pinging, we add a join event and start collecting inputs
	int inputFrame      // We got all inputs from this player up to and including this frame
	int currentFrame    // The frame currently processed by this user, used to calculate "ahead"
	float aheadAverage
	
	visible Touch[] downTouches, movingTouches, upTouches
	visible WheelEvent[] wheelEvents
	visible int[] downKeys, upKeys
	visible string[] textInputs, textCompositions
	
	int[] lastTouchMoveIndex
	
	Buffer inputs         // The stream of inputs of this user
	int acknowledgedPos   // The remote user has received the input buffer up to this buffer position
	int uncertainReadPos  // The buffer position where we haven't received inputs from all users
	
	object videoElement = null
	
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
	Color color = null
	visible Touch[] touches
	string textInput
	float2 videoPosition = {}
	float videoWidth

	internal clearEvents
		for <- touches
			if t.phase == Up and t.button == None
				touches.remove t
	
enum InputType: None, TouchDown, TouchMove, TouchUp, Wheel, KeyDown, KeyUp, TextInput, Stick, Trigger, Grip, ButtonDown, ButtonUp, ControllerTransform, HeadTransform, DeviceRotation, Join, Leave, SetState
		
// Phase of a touch or a click
enum TouchPhase: Still, Down, Move, Up
		
enum MouseButton: None, Left, Middle, Right

// A touch or a click
class Touch
	int id
	int userId
	TouchPhase phase
	MouseButton button
	float2 referencePosition
	float2 referenceStartPosition
	float2 smoothPosition
	bool isDown
	float2 position
	float2 startPosition
	bool handled
	
	markAsHandled() handled = true
	
transient class WheelEvent
	NetworkUser user
	int delta
	float2 referencePosition
	float2 position
	bool handled
	
	markAsHandled() handled = true
	
transient class EventStreamUser
	int id
	bool local
	int frame
	object blob = null
	Buffer inputs = null
	
transient class EventStream
	string url
	string randomSeed
	EventStreamUser[] users
	
// A collection of methods to receive user input
unit Input
	transient internal InternalUser[] internalUsers
	transient visible bool isCertain
	
	NetworkUser[] users
	string cursor
	
	string textInput := users[Network.userId]?.textInput
	
	internal init
		initHandlers
	
	private js float2 logicalToPixelPosition: float2 pos
		let p = pos.getTransformed(graphics_totalMatrix)
		return new float2(p.x/Platform_pixelRatio, p.y/Platform_pixelRatio, null)

	private js void initHandlers
		window.onpointerdown = e => {
			if(e.button == 0 && Platform_mode == 0)
				Platform_record()
			let button = e.pointerType == "mouse" ? e.button+1 : 0 
			Input_handleTouchEvent(1, e.pageX, e.pageY, e.pointerId, button);
		}
		window.onpointermove = e => {
			let button = e.pointerType == "mouse" ? e.button+1 : 0 
			Input_handleTouchEvent(2, e.pageX, e.pageY, e.pointerId, button);
		}
		window.onpointerup = e => {
			let button = e.pointerType == "mouse" ? e.button+1 : 0 
			Input_handleTouchEvent(3, e.pageX, e.pageY, e.pointerId, button);
			
			// if(e.button == 2 && Platform_mode == 0) {
			// 	if(Platform_mode < 3/*Pointer*/) Platform_enterSlideMode(3/*Pointer*/)
			// 	else                             Platform_stop()
			// }
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
			// app_eventLog.push("onkeydown code:"+e.keyCode+" key:"+e.key+" code:"+e.code)
			let keyCode = e.keyCode
			if(window.require && e.key == "t" && e.ctrlKey && e.metaKey && e.shiftKey)
				require("electron").remote.getCurrentWindow().toggleDevTools()
			else
			if(e.ctrlKey && e.key == "s") {
				Network_saveEventStream();
				e.preventDefault();
			}
			else
			if(e.ctrlKey && e.key == "o") {
				Network_openEventStream();
				e.preventDefault();
			}
			else
			if(e.key >= "0" && e.key <= "9") {
				let index = e.key - "0"
				if(e.altKey)  Network_save(index); else
				if(e.ctrlKey) Network_restore(index); else
				              Network_userId = Math.min(index-1, Input_users.length-1);
				e.preventDefault();
			}
			else
			if(e.ctrlKey && e.key == "F1")
				// TEMP for testing
				Network_skipAnimationFrame = true;
			else
			if(e.ctrlKey && e.key == "F2")
				// TEMP for testing
				Network_skipSending = true;
			else
			if(e.key == "F9") {
				if(e.shiftKey) { Network_saveLogs(); }
				else           { Platform_showDebugInfo = !Platform_showDebugInfo; Network_debugString = "" }
				e.preventDefault();
			}
			else
			if(keyCode >= 49 && keyCode <= 52 && Network_simulateConnection)
				Network_userId = Math.min(keyCode-49, Input_users.length-1);
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
		let lastMoveIndex = internalUsers[Network.userId].lastTouchMoveIndex
		lastMoveIndex.add id
		lastMoveIndex.add index
	
	private getLastTouchMoveIndex: int id
		let lastMoveIndex = internalUsers[Network.userId].lastTouchMoveIndex
		let i = 0
		while i < lastMoveIndex.length
			if lastMoveIndex[i] == id: return lastMoveIndex[i+1]
			i += 2
		return 0
		
	private handleTextInput: InputType type, string text
		if Network.mode == None || Platform.mode != Record || Network.userId == -1: return
		let user = internalUsers[Network.userId], inputs = user.inputs
		if !user.collectInputs: return
		
		inputs.writeInt32 user.inputFrame
		inputs.writeUnsignedInt16 cast type
		inputs.writeString text
			
	private handleKeyEvent: InputType type, int keyCode
		if Network.mode == None || Platform.mode != Record || Network.userId == -1: return
		let user = internalUsers[Network.userId], inputs = user.inputs
		if !user.collectInputs: return
		
		inputs.writeInt32 user.inputFrame
		inputs.writeUnsignedInt16 cast type
		inputs.writeInt32 keyCode
		
	private handleTouchEvent: InputType type, float x, float y, int id, int button
		float2 pixelPos = {x*Platform.pixelRatio, y*Platform.pixelRatio}
		float2 referencePos = pixelPos.getRelativeTo(Platform.baseMatrix)
		Platform.handleSlide type, id, pixelPos, referencePos
		
		if Network.mode == None || Platform.mode != Record || Network.userId == -1: return
		let user = internalUsers[Network.userId], inputs = user.inputs
		if !user.collectInputs: return

		if type == TouchMove
			int index = getLastTouchMoveIndex id
			if index
				// We already moved the pointer this input frame, so just update the last move
				inputs.setInt16 index, Math.round(referencePos.x)
				inputs.setInt16 index+2, Math.round(referencePos.y)
				Network.writeLog += " #{user.inputFrame} override {id} at {index} to {Math.round(referencePos.x)} {Math.round(referencePos.y)}"
				return
			else
				setLastTouchMoveIndex id, inputs.writePos+6
				Network.writeLog += " save {id} at {inputs.writePos+6}"
			
		int composite = cast(type)                                      // type:   0 -  32 (5 bit)
		              + Math.shiftLeft(button.limit(min:0, max:3), 5)   // button: 0 -   4 (2 bit)
		              + Math.shiftLeft(Math.floor(Math.abs(id))%256, 7) // id:     0 - 256 (8 bit)
		inputs.writeInt32 user.inputFrame
		inputs.writeUnsignedInt16 composite
		inputs.writeInt16 Math.round(referencePos.x)
		inputs.writeInt16 Math.round(referencePos.y)
		Network.writeLog += " #{user.inputFrame} {composite} {Math.round(referencePos.x)} {Math.round(referencePos.y)} ({inputs.readPos}/{inputs.writePos})"
		
	private handleWheelEvent: float x, float y, float delta
		if Network.mode == None || Platform.mode != Record || Network.userId == -1: return
		let user = internalUsers[Network.userId], inputs = user.inputs
		if !user.collectInputs: return
		
		float2 referencePos = {x*Platform.pixelRatio, y*Platform.pixelRatio}.getRelativeTo(Platform.baseMatrix)
		inputs.writeInt32 user.inputFrame
		inputs.writeUnsignedInt16 cast InputType.Wheel
		inputs.writeInt16 Math.round(referencePos.x)
		inputs.writeInt16 Math.round(referencePos.y)
		inputs.writeInt16 Math.round(delta)
		Network.writeLog += " [{user.inputFrame}] wheel {Math.round(referencePos.x)} {Math.round(referencePos.y)} {Math.round(delta)} \{r:{inputs.readPos} w:{inputs.writePos}\}"
		
	handleSetState: Buffer buffer
		let user = internalUsers[Network.userId], inputs = user.inputs
		inputs.writeInt32 user.inputFrame
		inputs.writeUnsignedInt16 cast InputType.SetState
		inputs.writeBuffer buffer
		
	internal parseInputs(int frame, bool isCertain)
		this.isCertain = isCertain
		if isCertain: Network.parseLog += " c"
		for userIndex, internalUser -> internalUsers 
			if internalUser
				let inputs = internalUser.inputs, userId = internalUser.id
				let user = users[userId]
				Network.parseLog += " <{userId}>"
				
				while true
					int nextFrame = inputs.canRead ? inputs.peekInt32 : int.maxValue
					Network.parseLog += " ({inputs.readPos}/{inputs.writePos})"
					if inputs.canRead: Network.parseLog += " *{nextFrame}"
					if nextFrame > frame: break
					inputs.readPos += 4
					
					let value = inputs.readUnsignedInt16
					Network.parseLog += " "+value
					InputType type = cast value % 32
					
					if type >= TouchDown && type <= Wheel
						MouseButton button = cast Math.shiftRight(value, 5) % 4
						int id = Math.shiftRight(value, 7)
						float2 touchPos = {inputs.readInt16, inputs.readInt16}
						bool isSmoothPosition = !Network.smoothTouchPosition or isCertain or Network.userId == userId
						Network.parseLog += " "+id
						
						if type == TouchDown
							let touch = user.touches.find a.id == id
							if touch
								touch.phase = cast type
								touch.referencePosition = touchPos
								touch.referenceStartPosition = touchPos
								touch.handled = false
								touch.button = button
								touch.isDown = true
								if isSmoothPosition: touch.smoothPosition = touchPos
								Network.parseLog += " down {id} {touchPos} {button}"
							else
								touch = {id, userId, cast type, button, touchPos, touchPos, touchPos, isDown:true}
								user.touches.add touch
								Network.parseLog += " down(new) {id} {touchPos} {button}"
							internalUser.downTouches.add touch
						else
						if type == TouchMove
							let touch = user.touches.find a.id == id
							if touch
								touch.phase = cast type
								touch.referencePosition = touchPos
								touch.handled = false
								touch.button = button
								if isSmoothPosition: touch.smoothPosition = touchPos
								Network.parseLog += " move {id} {touchPos} {button}"
							else
								touch = {id, userId, cast type, button, touchPos, referenceStartPosition:float2.none, touchPos, isDown:false}
								user.touches.add touch
								Network.parseLog += " move(new) {id} {touchPos} {button}"
							internalUser.movingTouches.add touch
							cursor = "auto"
						else
						if type == TouchUp
							let touch = user.touches.find a.id == id
							if touch
								touch.phase = cast type
								touch.referencePosition = touchPos
								touch.handled = false
								touch.button = button
								touch.isDown = false
								if isSmoothPosition: touch.smoothPosition = touchPos
								Network.parseLog += " up {id} {touchPos} {button}"
							else
								touch = {id, userId, cast type, button, touchPos, referenceStartPosition:float2.none, touchPos, isDown:false}
								user.touches.add touch
								Network.parseLog += " up(new) {id} {touchPos} {button}"
							internalUser.upTouches.add touch
						else
						if type == Wheel
							let delta = inputs.readInt16
							internalUser.wheelEvents.add {user, delta, referencePosition:touchPos}
					else
					if type == TextInput
						let user = users[userId]
						let textInput = inputs.readString
						user.textInput = textInput
						internalUser.textInputs.add textInput
					else
					if type == KeyDown
						let keyCode = inputs.readInt32
						internalUser.downKeys.add keyCode
					else
					if type == KeyUp
						internalUser.upKeys.add inputs.readInt32
					else
					if type == Join
						Network.parseLog += " join {userId}"
						users[userId] = {id:userId}
					else
					if type == Leave
						Network.parseLog += " leave {userId}"
						users[userId] = null
					else
					if type == SetState
						Network.parseLog += " setState"
						Network.snapshotBuffer.reset
						inputs.readBuffer Network.snapshotBuffer
						Snapshot.deserialize Network.snapshotBuffer
				
	// Executes code when the user touches or clicks within a given area
	onTouchDownWithin: float2 position        // The center of the touch area
		               float2 size            // The size of a rectangular touch area
		               void(Touch touch) code // The code to execute for each touch or click
		               int userId = -1        // Only consider touches or clicks from this user  
		               string cursor = ""
		               bool showTouchArea = false
		               bool markAsHandled = true
		float2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for touch -> user.downTouches
				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					log "down", touch.position
					code touch
					if markAsHandled: touch.handled = true
		else
			for user -> internalUsers if user
				for touch -> user.downTouches
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						log "down", touch.position
						code touch
						if markAsHandled: touch.handled = true
			if cursor
				let user = internalUsers[Network.userId]
				for touch -> user.movingTouches
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Executes code when the user touches or clicks within a given area
	onTouchDownWithin: float2 position        // The center of the touch area
		               float2 size            // The size of a rectangular touch area
		               float angle
		               void(Touch touch) code // The code to execute for each touch or click
		               int userId = -1        // Only consider touches or clicks from this user  
		               string cursor = ""
		               bool showTouchArea = false
		               bool markAsHandled = true
		float2[] poly = [
			(position + float2( -size.x/2, -size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
			(position + float2( +size.x/2, -size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
			(position + float2( +size.x/2, +size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
			(position + float2( -size.x/2, +size.y/2 ).rotate(angle)).transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for touch -> user.downTouches
				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					log "down", touch.position
					code touch
					if markAsHandled: touch.handled = true
		else
			for user -> internalUsers if user
				for touch -> user.downTouches
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						log "down", touch.position
						code touch
						if markAsHandled: touch.handled = true
			if cursor
				let user = internalUsers[Network.userId]
				for touch -> user.movingTouches
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Executes code when the user touches or clicks within a given circle
	onTouchDownWithin: float2 position        // The center of the touch area
		               float radius           // The radius of a round touch area
		               void(Touch touch) code // The code to execute for each touch or click
		               int userId = -1        // Only consider touches or clicks from this user  
		               string cursor = ""
		               bool showTouchArea = false
		               bool markAsHandled = true
		let referencePosition = position.getTransformed(graphics.localMatrix)
		let referenceRadius = radius * graphics.localMatrix.scaleVector.x
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for touch -> user.downTouches
				if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					log "down", touch.position
					code touch
					if markAsHandled: touch.handled = true
		else
			for user -> internalUsers if user
				for touch -> user.downTouches
					if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						log "down", touch.position
						code touch
						if markAsHandled: touch.handled = true
			if cursor
				let user = internalUsers[Network.userId]
				for touch -> user.movingTouches
					if !touch.handled && (touch.referencePosition distanceTo position) <= radius
						this.cursor = cursor
				
		if showTouchArea: drawCircle position, radius, fillColor:{"ff000080"}

	// Executes code when the user touches or clicks within a given polygon
	onTouchDownWithin: float2 position        // The center of the touch area
		               float2[] points        // The points that define the touch area
		               void(Touch touch) code // The code to execute for each touch or click
		               int userId = -1        // Only consider touches or clicks from this user  
		               string cursor = ""
		               bool showTouchArea = false
		               bool markAsHandled = true
		float2[] poly
		for points: poly.add (position + p).transform(graphics.localMatrix)
			
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for touch -> user.downTouches
				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					log "down", touch.position
					code touch
					if markAsHandled: touch.handled = true
		else
			for user -> internalUsers if user
				for touch -> user.downTouches
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						log "down", touch.position
						code touch
						if markAsHandled: touch.handled = true
			if cursor
				let user = internalUsers[Network.userId]
				for touch -> user.movingTouches
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawPolygon position, points, fillColor:{"ff0000b0"}

	// Executes code when the user touches or clicks within a given area
	onTouchUpWithin: float2 position        // The center of the touch area
		             float2 size            // The size of a rectangular touch area
		             void(Touch touch) code // The code to execute for each touch or click
		             int userId = -1        // Only consider touches or clicks from this user
		             bool showTouchArea = false
		             bool markAsHandled = true
		float2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for touch -> user.upTouches
				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					log "up", touch.position
					code touch
					if markAsHandled: touch.handled = true
					Snapshot.autoSave
		else
			for user -> internalUsers if user
				for touch -> user.upTouches
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						log "up", touch.position
						code touch
						if markAsHandled: touch.handled = true
						Snapshot.autoSave
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Executes code when the user touches or clicks within a given area
	onTouchUpWithin: float2 position        // The center of the touch area
		             float radius           // The radius of a round touch area
		             void(Touch touch) code // The code to execute for each touch or click
		             int userId = -1        // Only consider touches or clicks from this user  
		             string cursor = ""
		             bool showTouchArea = false
		             bool markAsHandled = true
		let referencePosition = position.transform(graphics.localMatrix)
		let referenceRadius = radius * graphics.localMatrix.scaleVector.x
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for touch -> user.upTouches
				if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					log "up", touch.position
					code touch
					if markAsHandled: touch.handled = true
					Snapshot.autoSave
		else
			for user -> internalUsers if user
				for touch -> user.upTouches
					if !touch.handled && (touch.referencePosition distanceTo referencePosition) <= referenceRadius
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						log "up", touch.position
						code touch
						if markAsHandled: touch.handled = true
						Snapshot.autoSave
			if cursor
				let user = internalUsers[Network.userId]
				for touch -> user.movingTouches
					if !touch.handled && (touch.referencePosition distanceTo position) <= radius
						this.cursor = cursor
				
		if showTouchArea: drawCircle position, radius, fillColor:{"ff000080"}

	onTouchOver: float2 position        // The center of the touch area
		               float2 size            // The size of a rectangular touch area
		               void(Touch touch) code // The code to execute for each touch or click
		               int userId = -1        // Only consider touches or clicks from this user  
		               string cursor = ""
		               bool showTouchArea = false
		               bool markAsHandled = true
		float2[] poly = [
			{ position.x-size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y-size.y/2 }.transform(graphics.localMatrix),
			{ position.x+size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
			{ position.x-size.x/2, position.y+size.y/2 }.transform(graphics.localMatrix),
		]
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = users[userId]
			for touch -> user.touches
				if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					log "over", touch.position
					code touch
		else
			for user -> users
				for touch -> user.touches
					if touch.referencePosition.isInsidePoygon(poly)
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						log "over", touch.position
						code touch
			if cursor
				let user = internalUsers[Network.userId]
				for touch -> user.movingTouches
					if !touch.handled && touch.referencePosition.isInsidePoygon(poly)
						this.cursor = cursor
				
		if showTouchArea: drawRectangle position, size, fillColor:{"ff000080"}

	// Executes code when the user touches or clicks
	onTouchDown: void(Touch touch) code // The code to execute for each touch or click
		         int userId = -1        // Only consider touches or clicks from this user
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for touch -> user.downTouches
				if !touch.handled
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					log "down", touch.position
					code touch
		else
			for user -> internalUsers if user
				for touch -> user.downTouches
					if !touch.handled
						touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
						log "down", touch.position
						code touch

	// Executes code when the user touches, even if the touch is already handled
	onTouchDownAny: void(Touch touch) code // The code to execute for each touch or click
		            int userId = -1        // Only consider touches or clicks from this user
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for touch -> user.downTouches
				touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
				log "down", touch.position
				code touch
		else
			for user -> internalUsers if user
				for touch -> user.downTouches
					touch.position = touch.referencePosition.getRelativeTo(graphics.localMatrix)
					log "down", touch.position
					code touch
			
	// Executes code when a touch or click moves
	onTouchMove: Touch touch 
		         void(Touch touch) code // The code to execute when the given touch moves
		if !touch: return
		let touchId = touch.id, user = internalUsers[touch.userId]
		for t -> user.movingTouches
			if t.id == touchId && !t.handled
				t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
				t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
				log "move", t.position
				code t
	
	// Executes code when a touch or click moves
	onTouchMove: void(Touch touch) code // The code to execute when the given touch moves
		         int userId = -1
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for t -> user.movingTouches
				if !t.handled
					t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
					t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
					log "move", t.position
					code t
		else
			for user -> internalUsers if user
				for t -> user.movingTouches
					if !t.handled
						t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
						t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
						log "move", t.position
						code t
					
	onTouchUp: Touch touch
		       void(Touch touch) code // The code to execute for each touch or click
		       bool markAsHandled = true
		if !touch: return
		let touchId = touch.id, user = internalUsers[touch.userId]
		for t -> user.upTouches
			if t.id == touchId && !t.handled
				t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
				t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
				log "up", t.position
				code t
				Snapshot.autoSave
				if markAsHandled: t.handled = true
				
	// Executes code when a touch or click ends
	onTouchUp: void(Touch touch) code // The code to execute for each touch or click
		       bool markAsHandled = true
		       int userId = -1
		if (Network.mode == Connected || Network.simulateConnection) && userId != -1
			let user = internalUsers[userId]
			for t -> user.upTouches
				if !t.handled
					t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
					t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
					log "up", t.position
					code t
					Snapshot.autoSave
		else
			for user -> internalUsers if user
				for t -> user.upTouches
					if !t.handled
						t.position = t.referencePosition.getRelativeTo(graphics.localMatrix)
						t.startPosition = t.referenceStartPosition.getRelativeTo(graphics.localMatrix)
						log "up", t.position
						code t
						Snapshot.autoSave
						
	private log: string text, float2 pos
		Network.touchLog += " #{Network.frame}{isCertain ? " c" : ""} {text} {pos}"

	// Executes code when a touch or click ends
	onWheel: void(WheelEvent event) code // The code to execute for each touch or click
		for user -> internalUsers if user
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
			let user = internalUsers[userId]
			for event -> user.wheelEvents
				if !event.handled && event.referencePosition.isInsidePoygon(poly)
					event.position = event.referencePosition.getRelativeTo(graphics.localMatrix)
					log "wheel", event.position
					code event
					if markAsHandled: event.markAsHandled
		else
			for user -> internalUsers if user
				for event -> user.wheelEvents
					if !event.handled && event.referencePosition.isInsidePoygon(poly)
						event.position = event.referencePosition.getRelativeTo(graphics.localMatrix)
						log "wheel", event.position
						code event
						if markAsHandled: event.markAsHandled
		if fill: drawRectangle position, size, fill
	
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
		for user -> internalUsers if user
			for text -> user.textCompositions
				code text
				
	onTextInput: void(string textInput) code
		for user -> internalUsers if user
			for text -> user.textInputs
				code text
				
	onKeyDown: int key, void(int key) code
		for user -> internalUsers if user
			for k -> user.downKeys
				if k == key
					code key
				
	onKeyDown: void(int key) code
		for user -> internalUsers if user
			for key -> user.downKeys
				code key
				
	onKeyUp: void(int key) code
		for user -> internalUsers if user
			for key -> user.upKeys
				code key

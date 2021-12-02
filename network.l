enum NetworkMessageType: Tick, Ping, Pong, RequestState, State
enum ConnectionState: Disconnected, Connecting, Reconnecting, PingPong, Connected, Myself

transient class Connection
	int userId
	object peerConnection
	object dataChannel
	ConnectionState state
	bool offerByMe
	float fastestPingPongTime = float.maxValue
	
enum NetworkMode: None, Ping, Local, Connected, Reconnecting
transient class RoomInfo: int time, userId
	
transient unit Snapshot
	int autoSaveCount
	int lastSnapshotSize
	
	Buffer snapshots
	int[] snapshotStarts
	int snapshotEvery = 100
	
	private bool autoSaveAtEndOfStep
	
	inline js void serialize(Buffer buffer) serialize_internal(buffer)
	inline js void deserialize(Buffer buffer) deserialize_internal(buffer)
		
	js string toString: object value
		let buffer = new Buffer(null, 1024, 0, 0);
		setup_serialize();
		value.serialize_external(buffer);
		return btoa(String.fromCharCode(...new Uint8Array(buffer.buffer, 0, buffer.writePos)));	
		
	js void fromString: object value, string base64String
		let bytes = Uint8Array.from(atob(base64String), c => c.charCodeAt(0))
		let buffer = new Buffer(bytes.buffer,0,0,0);
		setup_deserialize();
		value.deserialize_external(buffer);
		
	js void fromBase64: object value, string base64String
		let bytes = Uint8Array.from(atob(base64String), c => c.charCodeAt(0))
		let buffer = new Buffer(bytes.buffer,0,0,0);
		setup_deserialize();
		value.deserialize_internal(buffer);
				
	Buffer save
		Buffer buffer
		serialize(buffer)
		return buffer
		
	restore: Buffer buffer
		deserialize(buffer)
		
	autoSave() autoSaveAtEndOfStep = true
	
	internal onEndOfStep
		if Input.isCertain
			if autoSaveAtEndOfStep and ++autoSaveCount > 5
				let snap = save
				IndexedDB.saveBuffer "snapshot", "{Network.gameId}-0", snap
				lastSnapshotSize = snap.writePos
				
			if Network.frame/snapshotEvery > snapshotStarts.length
				snapshotStarts.add snapshots.writePos
				serialize(snapshots)
			
			autoSaveAtEndOfStep = false
	
transient unit Network
	public int smoothStrength = 90
	public bool smoothTouchPosition = true
	public bool simulateConnection = true
	
	// Logs
	string logTable = "frame,id 0,lagFrom 0,lagTo 0,interval 0,id 1,lagFrom 1,lagTo 1,interval 1,id 2,lagFrom 2,lagTo 2,interval 2,messageSize,now,animTime,networkTime,tickTime,drawTime,iteration,restoreTime,replayFrames,replayTime,saveTime,pingPong,user0,user1,user2,received,uncertain,offset,ahead,avarage,percentile,certainFrame,buffer,checksums,events,send,receive,write,parse,touch\n"
	public string eventLog = ""; sentLog = "", receivedLog="", writeLog="", parseLog = "", touchLog = "", checksumLog = "", debugString = ""
	private float lastNetworkFrame, lastAnimationFrame, drawTime, tickTime, restoreTime, replayTime, saveTime
	private int replayFrames
	
	internal const targetFps = 30
	const targetFrameTime = 1000/targetFps
	
	NetworkMode mode
	
	int userId = -1       // The userId stays the same when a user reconnects
	visible string errorMessage
	public float startTime
	visible int frame               // Current frame, will increase by 1 at the end of every step (every targetFrameTime ms)
	private int frames              // Total number of frames we have inputs for
	public int receivedFrames      // We received all remote inputs up to this frame (lowest of all user frames)
	private int uncertainFrame = -1 // The first frame where we don't have inputs from all players
	public int certainFrame        // The last frame where we have inputs from all players
	private Buffer commonState      // A snapshot taken before the first uncertain frame
	internal int frameWithNewWatches = 0 // First frame with new watches, do not send watches for frames below this
	private bool startInLobby
	
	private int ahead
	private int[] aheads
	visible float aheadAverage
	// private int[] aheadsMax
	
	// TODO
	public  float[] checksums

	initDatabase
		IndexedDB.start "up4playing", "snapshot", 5

	startConnected
		if mode == Connected: return
		for connections
			if .state == PingPong
				let user = Input.internalUsers[.userId]
				.state = user.state = Connected
				
		let user = Input.internalUsers[userId]
		user.startInputFrame 0
		
		int joinFrame = Math.floor((currentTime - this.startTime)/targetFrameTime)+1
		user.inputs.writeInt32 joinFrame
		user.inputs.writeInt16 cast InputType.Join
		user.collectInputs = true
		writeLog += " #{joinFrame} Join"
		
		mode = Connected
		receivedFrames = -1
		certainFrame = -1
		frame = 0
		log "Connected", userId, frame, startTime, this.startTime
		saveState
		
	startLocal: userCount = 1
		userId = 0
		mode = Local
		startInLobby = false
		certainFrame = int.maxValue
		Input.internalUsers.clear
		Math.setRandomSeed Math.generateRandomSeed
		initDatabase
		reset
		resetStartTime
		animationFrame
		
	// Clears all inputs and resets the application to the first frame
	stop
		for Input.internalUsers: if .: .inputs.reset; .startInputFrame 0
		frames = 0
		frameWithNewWatches = 0
		startInLobby = false
		audio.pause
		goToFrame 0
		errorMessage = ""
		
	// Calls init functions, creates the local users, resets read positions and starts app
	// This is called on startup, after every code change and when going backwards in the timeline
	reset
		Platform.initApplication
		Input.users.clear
		Input.usersById.clear
		
		if !startInLobby
			// When the developer changed Platform.userCount, add or remove internal users accordingly
			for i = Input.internalUsers.length -> Platform.userCount
				Input.internalUsers.add {id:i, local:true, collectInputs:true}
			if Input.internalUsers.length > Platform.userCount
				Input.internalUsers.removeRange Platform.userCount, count: Input.internalUsers.length - Platform.userCount
			
			// We always recreating users, because developers might have added fields to NetworkUser or Touch
			// By the time we call startApp, all users need to exist
			for i, internalUser -> Input.internalUsers
				NetworkUser user = {id:.id, index:i}
				Input.usersById[.id] = user
				Input.users.add user
			
		// Reset read pos to replay inputs from the beginning
		Input.internalUsers.each.inputs.readPos = 0
			
		Math.randomValueIndex = 0
		frame = 0
		lobby.inLobby = startInLobby
		if !startInLobby: startApp
	
	// Steps forward when going to a frame in the future
	// or replays from the beginning when going to a frame in the past
	// This is called after every code change with replay = true 
	// to replay all inputs with the new code from the beginning,
	// and when stepping through the timeline with replay = false
	// to only replay from the beginning when going to a frame in the past
	goToFrame: int targetFrame, replay = false
		if replay: frameWithNewWatches = 0
		if targetFrame < frame or replay: reset
			
		while frame < targetFrame
			step fastFordward:true
		resetStartTime
		animationFrame

	// Smooth out animations by only executing code when we received inputs from everybody	
	smooth: int userId
		    void() code
		if Input.isCertain or this.userId == userId: code
	
	smooth: void() code
		if Input.isCertain: code
			
	// animationFrame --> step --> tick

	// animationFrame  Send tick message, replay state, and call step
	// step            Save state, parse inputs, step physics, process tick, and calculate checksum
	// tick            Clear screen, process application tick, and draw all graphics
		
	// Send tick message, replay state, call step, and logging
	// This is called by the requestAnimationFrame callback.
	// We ensure that step is called every targetFrameTime milliseconds.
	internal animationFrame
		let now = currentTime

		// ping
		ServerNetwork.ping
		if mode == None || mode == Ping
			graphics.startFrame
			lobby.tick
			PeerNetwork.updateVideoScreen
			graphics.finishFrame
			return
			
		// Ahead
		int aheadMax
		int aheadPercentile
		let localPlayer = Input.internalUsers[userId]
		if mode == Connected and Input.users.length > 1
			ahead = frame - receivedFrames
			aheads.add ahead, maxLength:100
			aheadAverage = aheads.average
			aheadMax = aheads.max .
			aheadPercentile = aheadMax + 2
			
			// aheadsMax.add aheadMax, maxLength:10
			// aheadPercentile = aheadsMax.average.round
			// aheadPercentile = smoothStrength ? Math.round(aheads.percentile(smoothStrength).limit(0, 50)*1.2) : 0
			// aheadPercentile = smoothStrength ? aheads.percentile(smoothStrength).limit(0, 50) : 0
			
			// statisticsGraph.add "aheadMax", aheadMax, Blue
			statisticsGraph.add "ahead", ahead, Blue
			statisticsGraph.add "average", aheadAverage, Red
			
			// let user = Input.internalUsers.find.local == false
			// statisticsGraph.add "lagTo", user.lagTo, Red
			// statisticsGraph.add "lagFrom", user.lagFrom, Yellow
			
		
		let targetFrame = Math.floor((now - startTime)/targetFrameTime)+1
		let frameMinusOffset = targetFrame - aheadPercentile
		certainFrame = mode == Connected ? Math.min(frameMinusOffset, receivedFrames) : int.maxValue

		// TEMP for testing: Simulate mouse movement
		Input.handleTouchEvent inputType:TouchMove, x:(targetFrame*10)%1000, y:50+userId*20, pointerType:"mouse", pointerId:0, button:0

		if mode == Local && targetFrame > frame + targetFps*2
			// After a long pause in local mode, we do not want to process all missed frames, so we adjust the start time
			let prevTargetFrame = targetFrame
			targetFrame = frame
			startTime = Math.round(now - targetFrame*targetFrameTime)
			log "Paused {prevTargetFrame-frame} frames, adjusting startTime. prevTargetTime:{prevTargetFrame} frame:{frame} targetFrame:{Math.floor((now - startTime)/targetFrameTime)}"
		
		if frame < targetFrame
			let startFrame = frame
			try
				// Send imputs
				// if mode == Connected: sendInputs inputFrame:targetFrame-1, aheadAverage
				if mode == Connected: ServerNetwork.sendInputs inputFrame:targetFrame-1
								
				// Replay all frames from the first uncertain frame until the current frame
				// when we received all inputs for frames that we were uncertain about before
				replayState
			
			catch 
				log error
				errorMessage = error.message
				Platform.sendErrorToEditor error
					
			// Ensure that step is called every targetFrameTime milliseconds
			while frame < targetFrame
				// Step
				step fastFordward:frame < targetFrame-1
				
				// Logs
				try
					logTable += "{frame-1}"
					let users = Input.internalUsers.where . and .state == Connected
					for 3
						let user = users[i]
							logTable += ",{user.id},{user.lagFrom},{user.lagTo},{ServerNetwork.sendInterval}"
						else
							logTable += ",,,,"
							
					logTable += ",{ServerNetwork.tickMessageSize},{now},{now - lastAnimationFrame},{now - lastNetworkFrame},{tickTime.format(fractionDigits:2)},{drawTime.format(fractionDigits:2)},{frame-startFrame}"
					logTable += ",{restoreTime.format(fractionDigits:2)},{replayFrames},{replayTime.format(fractionDigits:2)},{saveTime.format(fractionDigits:2)},{ServerNetwork.lastPingPongTime}"
					logTable += ","+(Input.internalUsers[0] ? Input.internalUsers[0].inputFrame : 0)
					logTable += ","+(Input.internalUsers[1] ? Input.internalUsers[1].inputFrame : 0)
					logTable += ","+(Input.internalUsers[2] ? Input.internalUsers[2].inputFrame : 0)
					logTable += ",{receivedFrames},{uncertainFrame},{frame - receivedFrames},{ahead},{aheadAverage.format(fractionDigits:1)}"
					logTable += ",{aheadPercentile},{certainFrame},{receivedFrames-frameMinusOffset}"
					logTable += ",\"{checksumLog.trim}\",\"{eventLog.trim}\",\"{sentLog.trim}\",\"{receivedLog.trim}\",\"{writeLog.trim}\",\"{parseLog.trim}\",\"{touchLog.trim}\"\n"
				catch
					print error
					errorMessage = error.message
					Platform.sendErrorToEditor error
					
				// Debug string
				if Platform.showDebugInfo
					debugString = "v{Platform.version} #{frame-1} ct:{PeerNetwork.connectionType} av:{aheadAverage.format(fractionDigits:1)} ap:{aheadPercentile}"
					for user -> Input.internalUsers
						if . and !.local
							debugString += " <{.id}> {.lagFrom}/{.lagTo} -> {ServerNetwork.sendInterval}"
					debugString += " maxLag:{ServerNetwork.lag}"
				else
					debugString = ""
					
				eventLog = ""; sentLog = ""; receivedLog = ""; writeLog = ""; parseLog = ""; touchLog = ""; checksumLog = ""
				ServerNetwork.lastPingPongTime = 0; ServerNetwork.tickMessageSize = 0
				
				lastNetworkFrame = now
				
			for Input.internalUsers: if . and .local: .startInputFrame targetFrame	
			
		lastAnimationFrame = now
		if Platform.mode == Play and frame >= frames: Platform.record()
		
	// Save state, parse inputs, step physics, process tick, and calculate checksum
	// This is called in animationFrame and during replays. 
	// All steps except the very last of an animation frame are fast forwared, which means that nothing is drawn.
	// The frame is increment at the end of this function. This means that while processing the frame,
	// frame will point to the current frame. After processing, frame will point to the next frame.
	private step: bool fastFordward = false // If a step is fast forwarted nothing is drawn
		try
			// Set time
			Time.now = Math.round(frame * targetFrameTime)
			Platform.fastForward = fastFordward
			
			// Log
			parseLog += " #{frame}"
			bool isCertain = frame <= certainFrame
			if fastFordward: parseLog += "f"
			if isCertain: parseLog += "c"
				
			// Save a snapshot when we are about to start the frame after the last certain frame where we got all inputs
			saveState
			
			// Parse inputs
			Input.parseInputs(frame, isCertain)
			
			// Physics
			Physics.step
			
			// Tick
			tick
			
			if mode != Local
				// Calculate checksum if we received all inputs for this frame
				// if isCertain
				// 	float myChecksum = Framework.checksum					
				// 	float theirChecksum = checksums[frame]
				// 	checksumLog += " <> #{frame} {myChecksum}"
				// 	if !theirChecksum
				// 		checksums[frame] = myChecksum
				// 	else
				// 	if !theirChecksum.isApproximately(myChecksum)
				// 		onWrongChecksum mine:myChecksum theirs:theirChecksum
						
				// Take snapshot
				Snapshot.onEndOfStep
			
			
		catch
			log error
			errorMessage = error.message
			Platform.sendErrorToEditor error
			
		// Cleanup
		for internalUser -> Input.internalUsers
			internalUser?.clearEvent
		for user -> Input.users
			user?.clearEvents
		
		// Send current frame to editor	
		if frames < frame+1: frames = frame+1
		if frameWithNewWatches < frame+1: frameWithNewWatches = frame+1
		if Platform.isDebug and !fastFordward and (Platform.mode == Record or Platform.mode == Play): Platform.sendFrame(frame, frames)
		
		frame++
		
	// Clear screen, process application tick, and draw all graphics
	// This is called in step.
	internal tick
		graphics.startFrame
		PeerNetwork.updateVideoScreen
		drawFingers
		
		try
			if lobby.inLobby
				lobby.tick
			else
				Framework.tick
				tickTime = Time.measure
					app.tick
		catch
			log error
			errorMessage = error.message
			Platform.sendErrorToEditor error
			
		Input.updateCursor
		if Platform.showDebugInfo
			statisticsGraph.draw
			drawText debugString, {0, 540}
			drawText "1500ms lag outbound, interval {ServerNetwork.sendIntervalMin} : {ServerNetwork.sendInvervalMax}", statisticsGraph.position+{statisticsGraph.size.x/2-10, -statisticsGraph.size.y/2-20}, align:Right, layer:1000000
		if ServerNetwork.sendInterval > 10: drawCircle {920, 496}, fillColor:Red
		drawTime = Time.measure
			graphics.finishFrame
		
	// Save a snapshot when we are about to start the frame after the last certain frame 
	// where we received inputs from all users. This is called at the beginning of a step
	// before we start processing the frame.
	private saveState
		if mode != Connected: return
		if frame == certainFrame+1
			for Input.internalUsers: if .: .uncertainReadPos = .inputs.readPos
			uncertainFrame = frame
			saveTime = Time.measure
				Snapshot.serialize commonState
			parseLog += " save u:{uncertainFrame} c:{Framework.checksum}"
	
	// Replay all frames from the first uncertain frame until the current frame
	// when we received all inputs for frames that we were uncertain about before.
	// This is called at the begining of animationFrame before we start stepping.
	private replayState
		if mode != Connected or Input.internalUsers.length == 1: return
		if uncertainFrame != -1 and certainFrame >= uncertainFrame
			// Restore state
			for Input.internalUsers: if .: .inputs.readPos = .uncertainReadPos
			restoreTime = Time.measure
				Snapshot.deserialize commonState
			parseLog +=  " restore u:{uncertainFrame} c:{Framework.checksum}"
	
			let targetFrame = frame
			frame = uncertainFrame
			
			// We set uncertainFrame to -1 because we currently have no uncertainty. If we process frames beyond 
			// the received frame during replay, we save a new state and set the uncertainFrame.
			// If not, uncertainFrame stays -1,  which means we are certain about every frame.
			uncertainFrame = -1
			
			// Replay from uncertainFrame to frame
			replayFrames = targetFrame - frame
			replayTime = Time.measure
				while frame < targetFrame
					step fastFordward:true
					
	log: logstring text
		eventLog += text + "\n"
		print text
		
	inline js int currentTime := Date.now()
	
	js void startApp
		lobby_inLobby = false
		Network_storeUserId()
		if(window.app_start) app_start()
		
	private resetStartTime
		startTime = Math.round(currentTime - frame*targetFrameTime - (targetFrameTime*.5))
		
	resetStartTimeIfNeeded
		if Platform.mode < Play: resetStartTime
		
	Buffer snapshotBuffer
		
	save: int slot
		snapshotBuffer.reset
		Snapshot.serialize snapshotBuffer
		IndexedDB.saveBuffer "snapshot", "{gameId}-{slot}", snapshotBuffer
			print "saved snapshot {gameId}-{slot} ({snapshotBuffer.writePos} bytes)"
		else
			print "save failed"
		
	restore: int slot
		IndexedDB.openBuffer "snapshot", "{gameId}-{slot}"
			Input.handleSetState buffer
			print "restored snapshot {gameId}-{slot} ({buffer.writePos} bytes)"
		else
			print "restore failed"
		
	saveEventStreamAndLogs
		if Input.isCertain
			saveEventStream
			Platform.schedule delay:1000
				saveLogs
			
	internal saveLogs
		let time = Time.current
		// Ensure that current eventLog is added to the table even if we haven't processed a single frame
		logTable += ",,,,,,,,,,,,,,,,,,,,,,,,\"{eventLog.trim}\""
		Platform.saveTextFile "{Platform.appName} {time.dayShortMonthNameYearString} {time.hourMinuteSecondString} v{Platform.version}.csv", logTable
		// Http.post "/saveLog/{gameId}/{roomId}/{userId}", logTable
		// 	log "save logs"
		// else
		// 	print "save logs failed {error}"
			
	saveEventStream
		Buffer buffer
		buffer.writeInt32 frame-1
		buffer.writeInt32 frames
		buffer.writeString Math.randomSeed
		buffer.writeBool startInLobby
		let userCount = Input.internalUsers.count . != null
		buffer.writeInt8 userCount
		for Input.internalUsers
			if .
				buffer.writeInt8 .id
				buffer.writeBool .local
				buffer.writeBuffer .inputs
		let time = Time.current
		Platform.saveBinaryFile "{Platform.appName} {time.dayShortMonthNameYearString} {time.hourMinuteSecondString} v{Platform.version}.state", buffer
		
	openEventStream
		Platform.pause
		Platform.openBinaryFile
			// Read event stream
			frame = buffer.readInt32
			frames = buffer.readInt32
			let randomSeed = buffer.readString
			startInLobby = buffer.readBool
			let userCount = buffer.readInt8
			Input.internalUsers.clear
			for userCount
				InternalUser user = {
					id: buffer.readInt8
					local: buffer.readBool
				}
				buffer.readBuffer user.inputs
				Input.internalUsers[user.id] = user
				
			// Replay
			for Input.internalUsers
				.collectInputs = true
				if Platform.isDebug: .local = true
				.startInputFrame frames
			userId = Input.internalUsers.findIndex.local
			certainFrame = int.maxValue
			Platform.sendFrame(frame, frames)
			Math.setRandomSeed randomSeed
			goToFrame targetFrame:frame, replay:true
		
	string roomString
	int roomId
	string gameId
	private Connection[] connections
	
	js void join: string gameId, string roomString, int userId
		init()
		Network_log("Network.join "+location.href)
		Network_startInLobby = true
		Network_gameId = gameId
		Network_roomString = roomString
		Network_userId = userId
		
		ServerNetwork_isLocalhost = location.href.indexOf("localhost") != -1
		// Platform_showDebugInfo = ServerNetwork_isLocalhost
		Platform_showDebugInfo = true
		
		// await PeerNetwork_setupLocalVideo(/*enableVideo*/true, /*enableAudio*/!ServerNetwork_isLocalhost)
		// await PeerNetwork_setupLocalVideo(/*enableVideo*/false, /*enableAudio*/false)
		await PeerNetwork_setupLocalVideo(/*enableVideo*/true, /*enableAudio*/false)
		ServerNetwork_setup()
		
	private storeUserId
		Platform.setLocalStorageObject "room"+roomId, RoomInfo(currentTime, userId)
				
	internal drawFingers
		for user -> Input.users
			if user
				let internalUser = Input.internalUsers[user.id]
					if (Input.showPointers and (!internalUser.local or Input.showLocalPointer)) or Platform.mode == Play or frame+1 < frames
						for user.touches
							if Framework.isVisibleFor .smoothPosition, this.userId
								drawImage finger, .smoothPosition+{11,32}, frame:.isDown ? 1 : 0, layer:int.maxValue
								if user.color
									if user.color == Black
										drawRectangle .smoothPosition+{16,80}, size:{26,10}, user.color, layer:int.maxValue, outlineColor:{"a0a0a0"}, outlineWidth:2
									else
										drawRectangle .smoothPosition+{16,78}, size:{26,10}, user.color, layer:int.maxValue
									

class StatisticsGraphSeries
	string name
	float[] values
	Color color
	float lastValue := values.length > 0 ? values[values.length-1] : 0
	
transient unit statisticsGraph
	const Vector2 position = {0, 440}
	const Vector2 size = {880, 180}
	
	private StatisticsGraphSeries[] series
	
	add: string name, float value, Color color = White
		var s = series.find.name == name
		if !s: series.add s = {name, color:color}
		s.values.add value, maxLength:size.x.round
		
	draw
		float maxValue
		for series:	for .values: if . > maxValue: maxValue = .
			
		Vector2 startPos = position + size/2
		Vector2 labelPos = position - size/2 - {0,20}
		for series
			drawRectangle labelPos, {32,32}, fillColor:.color, align:Left, layer:1000000
			drawText "{.name}: {.lastValue}", labelPos+{40, 0}, align:Left, layer:1000000
			labelPos.x += 200
			
			Vector2 prevPos
			int len = .values.length
			for len
				let value = .values[len-1-i]
				Vector2 pos = {startPos.x - i, startPos.y - value/maxValue*size.y}
				if i: drawLine prevPos, pos, color:.color, width:3, layer:1000000
				prevPos = pos
		drawRectangle position, size, fillColor:Black, outlineColor:White, outlineWidth:3, layer:1000000
		drawText cast maxValue, position+{size.x/2+8, -size.y/2}, align:Left
		drawText "0", position+{size.x/2+8, size.y/2}, align:Left
// States
// 
// fastForward: When replaying, all frames except the last are fast forward and are not drawn
// isCertain:
// isSmooth:
// isPremiere:
	
enum NetworkMode: None, Ping, Local, Connected
transient class RoomInfo: int time, userId
enum SendInputsMode: None, Peer, Server
	
transient unit Snapshot
	int autoSaveCount
	int lastSnapshotSize
	
	Buffer snapshots
	int[] snapshotStarts
	int snapshotEvery = 100
	
	private bool autoSaveAtEndOfStep
	
	inline js void serialize(Buffer buffer) serialize_internal(buffer)
	inline js void deserialize(Buffer buffer) deserialize_internal(buffer)
		
	js string toString: dynamic value
		let buffer = new Buffer(null, 1024, 0, 0);
		setup_serialize();
		value.serialize_external(buffer);
		return btoa(String.fromCharCode(...new Uint8Array(buffer.buffer, 0, buffer.writePos)));	
		
	js void fromString: dynamic value, string base64String
		let bytes = Uint8Array.from(atob(base64String), c => c.charCodeAt(0))
		let buffer = new Buffer(bytes.buffer,0,0,0);
		setup_deserialize();
		value.deserialize_external(buffer);
		
	js void fromBase64: dynamic value, string base64String
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
		// Disabled automatically saving snapshots because they haven't been used for while,
		// might use a lot of memory over time and IndexDB is one potential cause for Felix' startup problems
		// if Input.isCertain
		// 	if autoSaveAtEndOfStep and ++autoSaveCount > 5
		// 		let snap = save
		// 		IndexedDB.saveBuffer "snapshot", "{Network.gameId}-0", snap
		// 		lastSnapshotSize = snap.writePos
		// 	if Network.frame/snapshotEvery > snapshotStarts.length
		// 		snapshotStarts.add snapshots.writePos
		// 		serialize(snapshots)
		// 	autoSaveAtEndOfStep = false
	
transient skipInit unit Network
	int eventStreamVersion = 1
	int sendInterval = 1
	int smoothStrength = 90
	bool smoothTouchPosition = true
	bool simulateConnection = true
	bool simulateInputsForTesting = false
	bool simulateRollback = false
	bool showVideoForStaging = true
	bool muteInvisibleUsers = false
	int checksumInterval = 30
	
	SendInputsMode sendInputsMode = Peer
	internal const targetFps = 30
	const targetFrameTime = 1000/targetFps
	
	// TODO: Why is serverStartTime and startTime different in local game?
	
	NetworkMode mode                // Whether we are in local or connected mode
	visible string errorMessage     // The error message if we caught any exceptions in the main loop
	public float startTime          // The time the room was created, syncroniced between all clients
	// public float timeOffset
	public float serverStartTime
	visible int frame               // Current frame, will increase by 1 at the end of every step (every targetFrameTime ms)
	internal int frames             // Total number of frames we have inputs for
	public int receivedFrames       // We received all remote inputs up to this frame (lowest of all user frames)
	private int uncertainFrame = -1 // The first frame where we don't have inputs from all players
	public int certainFrame = -1    // The last frame where we have inputs from all players
	private Buffer commonState      // A snapshot taken before the first uncertain frame
	internal int frameWithNewWatches = 0 // First frame with new watches, do not send watches for frames below this
	internal bool startInLobby      // Connected sessions usually start in the lobby, local sessions start in the app
	private int joinFrame           // The frame the current user joined
	public float[] checksums
	bool alertShown
	bool isPremiere
	bool isSmooth
	
	private Buffer debugCommonState // Used in debug mode to validate that serialing twice yields the same result 

	initDatabase
		IndexedDB.start "up4playing", "snapshot", 5

	startConnected: int frame
		if mode == Connected: return
				
		let user = Input.localUser
		user.startInputFrame 0
		
		// joinFrame = Math.floor((now - this.startTime)/targetFrameTime)+1
		Input.handleJoin frame 
		user.collectInputs = true
		if Network.logging: writeLog += " #{joinFrame} Join"
		log "startConnected", joinFrame
		
		this.frame = frame
		mode = Connected
		receivedFrames = -1
		certainFrame = -1
		uncertainFrame = -1
		bufferFrames = 0
		saveState
		statistics.connectTime = Time.preciseTime
		log "Connected", user.id, frame, startTime, serverStartTime
		
	startLocal: userCount = 1
		mode = Local
		certainFrame = -1
		Input.internalUsers.clear
		Math.setRandomSeed Math.generateRandomSeed 
		// initDatabase
		stop
		
	// Clear all inputs and reset the application to the first frame
	stop
		for Input.internalUsers if .
			.inputs.reset
			.startInputFrame 0
		startTime = serverStartTime = currentTime
		frames = 0
		frameWithNewWatches = 0
		startInLobby = false
		errorMessage = ""
		audio.stop
		isPremiere = true
		startTime = serverStartTime = currentTime
		reset
		animationFrame
				
	// Keep inputs, call init functions, create the local users, reset read positions and start app
	// This is called on startup, after every code change and when going backwards in the timeline
	reset
		Input.users.clear
		Input.usersById.clear
		errorMessage = ""
		HTMLElement.clear
		Math.randomValueIndex = 0
		frame = 0
		certainFrame = int.maxValue
		uncertainFrame = -1
		Input.isCertain = true
		lobby.inLobby = startInLobby
		Time.now = serverStartTime
		audio.stop
		initAll
		
		if !startInLobby
			// When the developer changed Platform.userCount, add or remove internal users accordingly
			for Input.internalUsers.length to Platform.userCount
				Input.internalUsers.add {id:i, local:true, collectInputs:true}
			if Input.internalUsers.length > Platform.userCount
				Input.internalUsers.removeRange Platform.userCount, count: Input.internalUsers.length - Platform.userCount
			
			// We always recreating users, because developers might have added fields to NetworkUser or Touch
			// By the time we call startApp, all users need to exist
			for Input.internalUsers -> internalUser
				NetworkUser user = {id:.id, index:i}
				Input.usersById[.id] = user
				Input.users.add user
				
			// Set local user
			Input.localUser = Input.localUser?.id < Input.internalUsers.length ? Input.internalUsers[Input.localUser.id] : Input.internalUsers[0]
			
		// Reset read pos to replay inputs from the beginning
		for Input.internalUsers if .
			.inputs.readPos = 0
			
		if !startInLobby: startApp
		if simulateRollback: saveState
	
	// Steps forward when going to a frame in the future
	// or replays from the beginning when going to a frame in the past
	// This is called after every code change with replayFromStart = true 
	// to replay all inputs with the new code from the beginning,
	// and when stepping through the timeline with replayFromStart = false
	// to only replay from the beginning when going to a frame in the past
	goToFrame: int targetFrame, replayFromStart = false
		isPremiere = false
		if replayFromStart: frameWithNewWatches = 0
		if targetFrame < frame or replayFromStart: reset
			
		while frame < targetFrame
			step fastForward:true, draw:false
		adjustStartTime
		animationFrame
		isPremiere = true

	// Smooth out animations by only executing code when we received inputs from everybody	
	smooth: int userId
		    void() do
		if isSmooth or Input.localUser.id == userId: do
	
	smooth: void() do
		if isSmooth: do

	// animationFrame --> step --> tick

	// animationFrame  Send tick message, replay state, and call step
	// step            Save state, parse inputs, step physics, process tick, and calculate checksum
	// tick            Clear screen, process application tick, and draw all graphics
		
	// Send tick message, replay state, call step, and logging
	// This is called by the requestAnimationFrame callback.
	// We ensure that step is called every targetFrameTime milliseconds.
	internal animationFrame
		now = currentTime

		// Ping
		ServerNetwork.ping
		if mode == None || mode == Ping
			graphics.startFrame
			lobby.tick
			graphics.finishFrame
			return
		else
		if mode == Connected
			PeerNetwork.processSendStateQueue
			
		let targetFrame = Math.floor((now - startTime)/targetFrameTime)+1
		frameMinusBuffer = targetFrame - bufferFrames
		if mode == Connected: certainFrame = Math.min(frameMinusBuffer, receivedFrames); else
		if simulateRollback:  certainFrame = targetFrame - 5; else
			                  certainFrame = int.maxValue

		if mode == Local && targetFrame > frame + targetFps*2
			// After a long pause in local mode, we do not want to process all missed frames, so we adjust the start time
			let prevTargetFrame = targetFrame
			targetFrame = frame
			startTime = Math.round(now - targetFrame*targetFrameTime)
			log "Paused {prevTargetFrame-frame} frames, adjusting startTime. prevTargetTime:{prevTargetFrame} frame:{frame} targetFrame:{Math.floor((now - startTime)/targetFrameTime)}"
		
		if frame < targetFrame
			animationStartFrame = frame
			
			try
				sendInputs targetFrame-1
				// Replay all frames from the first uncertain frame until the current frame
				// when we received all inputs for frames that we were uncertain about before
				replayState
			
			catch 
				onError error
					
			// Ensure that step is called every targetFrameTime milliseconds
			while frame < targetFrame
				// Create artificial inputs to test the smoothness
				if simulateInputsForTesting and Platform.showDebugInfo and Input.localUser and Input.localUser.collectInputs
					Input.handleKeyEvent KeyDown, cast Key.F24, ""

				for Input.internalUsers -> user
					if user?.local: user.startInputFrame frame+1
				step fastForward:false, draw:frame == targetFrame-1
				collectStatistics
				lastNetworkFrame = now
				
		lastAnimationFrame = now
		if Platform.mode == Play and frame >= frames: Platform.record()
			
	// Statistics
	private int ahead               // How many frames are we ahead of frame we got inputs from all users for?
	private int[] aheads            // Rolling buffer of ahead values, used to calculate bufferFrames
	private int aheadMax            // The maximum ahead value
	private int[] aheadsMax         // Rolling buffer of aheadMax values
	visible int bufferFrames        // The average of all aheadMax values
	private int frameMinusBuffer    // We expect to receive all inputs by this frame (frame - bufferFrames)
	private int animationStartFrame // The frame at the beginning of animationFrame, used to calculate iteration
	private float now               // The time at the beginning of animationFrame
	
	// Logs
	string logTable = "frame,ahead,receivedFrames,frameMinusBuffer,certainFrame,sendInterval,id,frame,buffer,id,frame,buffer,id,frame,buffer,messageSize,now,animTime,networkTime,tickTime,drawTime,iteration,restoreTime,replayFrames,replayTime,saveTime,pingPong,checksums,events,controller,send,receive,write,parse,touch\n"
	public string eventLog = ""; sentLog = "", receivedLog="", writeLog="", parseLog = "", touchLog = "", checksumLog = ""
	private float lastNetworkFrame, lastAnimationFrame, drawTime, tickTime, restoreTime, replayTime, saveTime
	private int replayFrames
	int tickMessageSize
	bool logging = true
	
	collectStatistics
		if mode == Connected and Input.users.length > 1 and frame > joinFrame + 120
			ahead = frame - receivedFrames
			
			if sendInterval == 1
				aheads.add ahead, maxLength:400
				aheadMax = aheads.percentile(90)
				aheadsMax.add aheadMax maxLength:400
				int actualBufferFrames = Math.ceil(aheadsMax.average) max 90
				
				// We only update bufferFrames if the new value is smaller or at least 2 larger
				if actualBufferFrames < bufferFrames or actualBufferFrames > bufferFrames+1: bufferFrames = actualBufferFrames
			else
				aheads.add ahead, maxLength:200
				aheadMax = aheads.percentile(50)
				aheadsMax.add aheadMax maxLength:30
				bufferFrames = Math.round(aheadsMax.average * 2.0) max 60
			
			Input.localUser.bufferFrames = bufferFrames
			
			// Statistics graph
			for Input.users
				let internalUser = Input.internalUsers[.id]
				if not internalUser.local
					statistics.add .index, frame - internalUser.inputFrame, .color or graphics.defaultColors[.index]
			statistics.add "buffer", bufferFrames, Gray
			// statistics.add "interval", sendInterval, {"808080"}
			// statistics.add "ahead", ahead, Gray
			
		// Logs
		if logging
			try
				logTable += "{frame-1},{ahead},{receivedFrames},{frameMinusBuffer},{certainFrame},{sendInterval}"
				for 3
					let user = Input.internalUsers[i]
						logTable += ",{user.id},{user.inputFrame},{user.bufferFrames}"
					else
						logTable += ",,,"
					
				logTable += ",{tickMessageSize},{now},{now - lastAnimationFrame},{now - lastNetworkFrame},{tickTime.format(fractionDigits:2)},{drawTime.format(fractionDigits:2)},{frame-animationStartFrame}"
				logTable += ",{restoreTime.format(fractionDigits:2)},{replayFrames},{replayTime.format(fractionDigits:2)},{saveTime.format(fractionDigits:2)},{ServerNetwork.lastPingPongTime}"
				logTable += ",\"{checksumLog.trim}\",\"{eventLog.trim}\",\"{Input.users[0]?.controller?.leftStick}\",\"{sentLog.trim}\",\"{receivedLog.trim}\",\"{writeLog.trim}\",\"{parseLog.trim}\",\"{touchLog.trim}\"\n"
			catch
				onError error
			
			eventLog = ""; sentLog = ""; receivedLog = ""; writeLog = ""; parseLog = ""; touchLog = ""; checksumLog = ""
			ServerNetwork.lastPingPongTime = 0; tickMessageSize = 0

	private int lastSendFrame
	
	private sendInputs: int inputFrame
		if mode != Connected: return
			
		// We used to dynamically adjust the send interval
		// sendInterval = aheadsShort.length < 15 or (aheadsShort.min .) < 5 ? sendIntervalMin : sendInvervalMax

		// We used to dynamically adjust if we are using the peer or the server connection
		// if sendInputsMode != Server and Input.internalUsers.any.bufferFrames > 300
		// 	sendInputsMode = Server
		// 	ServerNetwork.sendSwitch Server
		
		if frame >= lastSendFrame + sendInterval
			if sendInputsMode == Peer:   PeerNetwork.sendInputs inputFrame
			if sendInputsMode == Server: ServerNetwork.sendInputs inputFrame
			lastSendFrame = frame
			
	switchUser: int userIndex
		let user = Input.users[userIndex]
		Input.localUser = Input.internalUsers.find.id == user.id
			
	switchSendInterval: int sendInterval
		this.sendInterval = sendInterval
		ServerNetwork.sendSwitch sendInputsMode, sendInterval
		
	switchSendInputMode: SendInputsMode sendInputsMode
		this.sendInputsMode = sendInputsMode
		ServerNetwork.sendSwitch sendInputsMode, sendInterval

	// Save state, parse inputs, step physics, process tick, and calculate checksum
	// This is called in animationFrame and during replays. 
	// All steps except the very last of an animation frame are fast forwared, which means that nothing is drawn.
	// The frame is increment at the end of this function. This means that while processing the frame,
	// frame will point to the current frame. After processing, frame will point to the next frame.
	private step: bool fastForward // If we are replaying after a rollack or a code change
		          bool draw        // We don't draw if we are stepping multiple frames in one animation frame
		try
			// Set time
			Time.now = serverStartTime + Math.round(frame * targetFrameTime)
			
			// Flags
			Platform.fastForward = fastForward
			bool isCertain = frame <= certainFrame
			isSmooth = mode == Local or frame <= frameMinusBuffer
			
			// Send current frame to editor	
			if Platform.isDebug and !fastForward and (Platform.mode == Record or Platform.mode == Play or Platform.isWaitingForInitialData): Platform.sendFrame(frame, Math.max(frame+1, frames))
			
			// Log
			if logging
				parseLog += " #{frame} (fmb{frameMinusBuffer})"
				if fastForward: parseLog += "f"
				if isCertain: parseLog += "c"
				if isSmooth: parseLog += "s"
				
			// Save a snapshot when we are about to start the frame after the last certain frame where we got all inputs
			saveState
			
			// Update game controllers
			Input.updateGameControllers
			
			// Post lost messages and remove users if nobody disagrees
			Input.handleLost
			
			// Parse inputs
			Input.parseInputs(frame, isCertain)
			
			// Physics
			Physics.step
			
			// Tick
			tick draw
			
			if HTMLElement.elements: HTMLElement.elements.each.tick
			
			if mode != Local and (frame % checksumInterval)==0 and isCertain
				// Calculate checksum if we received all inputs for this frame
				float myChecksum = Framework.checksum					
				float theirChecksum = checksums[frame]
				if logging: checksumLog += " <> #{frame} {myChecksum}"
				if !theirChecksum
					checksums[frame] = myChecksum
				else
				if !theirChecksum.isApproximately(myChecksum)
					onWrongChecksum mine:myChecksum theirs:theirChecksum
				PeerNetwork.sendChecksum frame, myChecksum
					
				// Take snapshot
				Snapshot.onEndOfStep
			
			
		catch
			onError error
			
		// Cleanup
		for Input.internalUsers if .
			.clearEvent
		Input.users.each.clearEvents
		
		// Advance frame
		frame++
		if frames < frame: frames = frame
		if frameWithNewWatches < frame: frameWithNewWatches = frame
		
	// Clear screen, process application tick, and draw all graphics
	// This is called in step.
	internal tick: bool draw
		graphics.startFrame
		if draw and not Platform.isWaitingForInitialData
			let isPlayback = Platform.mode == Play or frame+1 < frames
			if Input.showPointers or isPlayback
				Input.users.each drawPointer .id, showLocalPointer:isPlayback or Input.showLocalPointer
		audio.startFrame
		
		try
			if lobby.inLobby
				lobby.tick
			else
				Framework.tick
				tickTime = Time.measure
					appTick
		catch
			onError error
			
		if Platform.showDebugInfo
			graphics.resetMatrix
			statistics.draw
			networkVisualizer.tick
			
		if draw and not Platform.isWaitingForInitialData
			drawTime = Time.measure
				graphics.finishFrame
			if Platform.mode != Manipulator: Input.updateCursor
		audio.finishFrame
				
	js void appTick() if(window.app_tick) app_tick();
		
	// Save a snapshot when we are about to start the frame after the last certain frame 
	// where we received inputs from all users. This is called at the beginning of a step
	// before we start processing the frame.
	private saveState
		if mode != Connected and !simulateRollback: return
		if frame == certainFrame+1 or certainFrame == -1
			for Input.internalUsers if .
				.uncertainReadPos = .inputs.readPos
			uncertainFrame = frame
			saveTime = Time.measure
				Snapshot.serialize commonState
				
			if simulateRollback
				Snapshot.deserialize commonState
				Snapshot.serialize debugCommonState
				if(commonState != debugCommonState)
					onError {"Serializing state failed"}

			if logging: parseLog += " save f:{frame} c:{certainFrame} u:{uncertainFrame}"
		else
			if logging: parseLog += " no-save f:{frame} c:{certainFrame} u:{uncertainFrame}"
			
	
	// Replay all frames from the first uncertain frame until the current frame
	// when we received all inputs for frames that we were uncertain about before.
	// This is called at the begining of animationFrame before we start stepping.
	private replayState
		if (mode != Connected and !simulateRollback) or Input.internalUsers.length == 1: return
		if uncertainFrame != -1 and certainFrame >= uncertainFrame
			// Restore state
			for Input.internalUsers if .
				.inputs.readPos = .uncertainReadPos
			restoreTime = Time.measure
				Snapshot.deserialize commonState
			if logging: parseLog +=  " restore u:{uncertainFrame} c:{Framework.checksum}"
	
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
					step fastForward:true, draw:false
		else
			if logging: parseLog +=  " no-restore c:{certainFrame} u:{uncertainFrame}"
					
	js void log: logstring text
		let str = new Date().hourMinuteSecondString() + " " + text
		statistics_log += str + "\n"
		if(Network_logging) {
			Network_eventLog += str + "\n"
			console.log(str)
		}
		
	inline js int currentTime := Date.now()
	
	js void startApp
		lobby_inLobby = false
		if(window.app_start) app_start()
		
	private adjustStartTime
		startTime = Math.round(currentTime - frame*targetFrameTime - (targetFrameTime*.5))
		// timeOffset = Math.round(currentTime - frame*targetFrameTime - (targetFrameTime*.5)) - startTime
		
	adjustStartTimeIfNeeded
		if Platform.mode < Play: adjustStartTime
		
	Buffer snapshotBuffer
		
	save: int slot
		// Database disabled for now
		// snapshotBuffer.reset
		// Snapshot.serialize snapshotBuffer
		// IndexedDB.saveBuffer "snapshot", "{gameId}-{slot}", snapshotBuffer
		// 	print "saved snapshot {gameId}-{slot} ({snapshotBuffer.writePos} bytes)"
		// else
		// 	print "save failed"
		
	restore: int slot
		// Database disabled for now
		// IndexedDB.openBuffer "snapshot", "{gameId}-{slot}"
		// 	Input.handleSetState buffer
		// 	print "restored snapshot {gameId}-{slot} ({buffer.writePos} bytes)"
		// else
		// 	print "restore failed"
		
	saveEventStreamAndLogs
		if Input.isCertain
			saveEventStream
			Platform.delay 1s
				saveLogs
			
	internal saveLogs
		// Ensure that current eventLog is added to the table even if we haven't processed a single frame
		logTable += ",,,,,,,,,,,,,,,,,,,,,,,,\"{eventLog.trim}\""
		Platform.saveTextFile "{Platform.appName} {Date.now.invariantDayMonthYearHourMinuteSecondString} v{Platform.version}.csv", logTable
		// Http.post "/saveLog/{gameId}/{roomId}/{userId}", logTable
		// 	log "save logs"
		// else
		// 	print "save logs failed {error}"
			
	saveEventStream
		Buffer buffer
		buffer.writeInt eventStreamVersion
		buffer.writeInt frame-1
		buffer.writeInt frames
		buffer.writeString Math.randomSeed
		buffer.writeBool startInLobby
		buffer.writeBool Platform.isStaging
		let userCount = Input.internalUsers.count . != null
		buffer.writeInt8 userCount
		for Input.internalUsers if .
			buffer.writeInt .id
			buffer.writeBool .local
			buffer.writeBuffer .inputs
		let date = Date.now
		Platform.saveBinaryFile "{Platform.appName} {date.dayShortMonthNameYearString} {date.hourMinuteSecondString} v{Platform.version}.state", buffer
		
	openEventStream
		Platform.pause
		Platform.openBinaryFile
			// Read event stream
			int version = buffer.readInt
			int targetFrame = buffer.readInt
			frames = buffer.readInt
			let randomSeed = buffer.readString
			startInLobby = buffer.readBool
			Platform.isStaging = buffer.readBool
			let userCount = buffer.readInt8
			Input.internalUsers.clear
			for userCount
				InternalUser user = {
					id: buffer.readInt
					local: buffer.readBool
				}
				if user.local: Input.localUser = user
				buffer.readBuffer user.inputs
				Input.internalUsers[user.id] = user
				
			// Replay
			for Input.internalUsers if .
				.collectInputs = true
				if Platform.isDebug: .local = true
				.startInputFrame frames
			certainFrame = int.maxValue
			Math.setRandomSeed randomSeed
			
			Platform.sendClearTimeline
			goToFrame targetFrame, replayFromStart:true
			Platform.sendFrame(targetFrame, frames)
		
	string roomString
	int roomId
	string gameId
	
	join: string gameId, string roomString, int userId
		// Send statistics after 25 seconds
		Platform.setTimeout 25s: statistics.manuallyTriggerSend -1, clear:false
		
		isPremiere = true
		initAll
		log Platform.url
		log Date.realtime.dayMonthYearHourMinuteSecondString
		log Platform.userAgent
		startInLobby = true
		this.gameId = gameId
		this.roomString = roomString
		this.roomId = cast roomString
		Input.localUser = {userId, local:true, connectionId:0}
		//initDatabase
		setupVideoAndNetwork
		lobby.enableFullscreen = !Platform.isStaging
		
	private js void initAll
		init()
		// TODO: Is this needed?
		Platform_updateBaseMatrix();
		
	private js void setupVideoAndNetwork 
		await PeerNetwork_setupLocalMedia(/*enableVideo*/!Platform_isStaging || Network_showVideoForStaging, /*enableAudio*/!Platform_isStaging)
		ServerNetwork_setup()
		
	internal storeUserId
		Platform.setLocalStorageObject "room"+roomId, RoomInfo(currentTime, Input.localUser.id)
		
	onWrongChecksum: float mine, float theirs
		if logging: checksumLog += " MISMATCH mine:{mine} theirs:{theirs}"
		onError {"Out of sync"}
		
	onError: Error error
		errorMessage = error.stack
		if logging: eventLog += errorMessage + "\n" 
		statistics.log += errorMessage + "\n" 
		Platform.sendErrorToEditor error
		
		if !Platform.isDebug and !alertShown
			alert "Please send me the log file that will be created.\n\n{errorMessage}"
			saveLogs
			alertShown = true

class StatisticsGraphSeries
	int userIndex = -1
	string name = null
	float[] values
	float[] recentValues
	Color color
	
	float lastValue := values.length > 0 ? values[values.length-1] : 0
	
	add: float value
		recentValues.add value
		if recentValues.length >= statistics.framesPerValue
			values.add recentValues.max .
			recentValues.clear
				
skipInit transient unit statistics
	const Vector2 margin = {224,126}
	const Vector2 position = {-960, 540}
	const Vector2 size = {1920+margin.x, margin.y}
	const Vector2 labelPos = {970, 528}
	const Color backgroundColor = {"202020"}
	const framesPerValue = 10
	
	float[] serverPings
	private StatisticsGraphSeries[] series
	string log
	Time startTime, loadTime, connectTime
	
	clear
		series.each.values.clear
		serverPings.clear
		log = ""
	
	send: dynamic data = null, int game = 0, int round = 0, int step = 0, bool clear = true
		if not Input.isCertain or Platform.isDebug: return
		print "sending statistics", round
		let userName = localStorage.getStringDirectly("play-userId")
		let server = Platform.host.getUntil(".")
		StatisticsGraphSeries[] series
		string[] connections
		for Input.users
			let internalUser = Input.internalUsers[.id]
			connections.add internalUser.connectionType
			series.add this.series.find.userIndex == i
		http.post "{Platform.protocalAndHost}:3114/stats", body:{
			time: Date.now.isoString
			gameId: Network.gameId
			roomId: Network.roomId
			userId: Input.localUser.id
			userIndex: Input.localUser.index
			userName
			game
			round
			step
			staging: Platform.isStaging
			server
			minServerPing: serverPings.min .
			maxServerPing: serverPings.max .
			averageServerPing: serverPings.average
			ping:series.select {
				average:it?.values.average
				max:it?.values.max(.)
				peeks:it?.values.count . > 30
			}
			connections
			serverPings
			peerPings: series
			loadTime: loadTime - startTime
			connectTime: connectTime - startTime
			log
			data
		}
		if clear: this.clear
			
	internal manuallyTriggerSend: int value, bool clear
		let prevIsCertain = Input.isCertain
		Input.isCertain = true
		statistics.send round:value game:value clear
		Input.isCertain = prevIsCertain
			
	internal float maxValue
	
	
	add: string name, float value, Color color = White
		var s = series.find.name == name
		if !s
			series.add s = {name, color}
			series.orderBy.name
		s.color = color
		s.add value
		
	add: int userIndex, float value, Color color = White
		var s = series.find.userIndex == userIndex
		if !s
			series.add s = {userIndex, name:userIndex.toString, color}
			series.orderBy.name
		s.color = color
		s.add value
		
	internal draw
		maxValue = 0
		for series -> s
			int len = Math.min(.values.length, size.x.round)
			for len: 
				let value = s.values[-1-i]
				if value > maxValue: maxValue = value
			
		Vector2 startPos = position + size
		Vector2 labelPos = this.labelPos
		for series -> s, seriesIndex
			string text = cast .lastValue
			drawRectangle labelPos, {8,8}, fillColor:.color, align:Left, layer:1000000
			drawText text, labelPos+{11, -2}, align:Left, layer:1000000, size:12
			labelPos.x += graphics.getTextWidth(text, size:12) + 20
			
			int len = Math.min(.values.length, size.x.round)
			float prevY = 0
			for len
				let value = s.values[-1-i]
				Vector2 pos = {startPos.x - i, startPos.y - value/maxValue*size.y + seriesIndex*3}
				if i: drawRectangle pos, size:{4, prevY-pos.y+4}, fillColor:s.color, layer:1000000, valign:Top
				prevY = pos.y
				
		if Network.errorMessage: drawText Network.errorMessage, position, align:Left, layer:1000001, size:12, color:{"ffff00"}
		drawText "#{Network.frame} {maxValue}", {position.x+size.x-8, labelPos.y}, align:Right, layer:1000001, size:12
		drawRectangle position, size, fillColor:backgroundColor, layer:1000000, align:Left, valign:Top

unit networkVisualizer		
	private int[] posForUser = [0,-10000,-10000,-10000,-10000,-10000]
		
	internal tick
		for Input.users
			if posForUser[.index] == -10000: posForUser[.index] = posForUser[0]
				
		// Move circle with artificially created inputs to test the smoothness
		for Input.users -> user
			Network.smooth user.id
				Input.onKeyDown F24, userId:user.id
					if (posForUser[user.index] += 2) > 1080
						posForUser[user.index] -= 1080
			drawCircle {1110+user.index*20, -540+posForUser[user.index]}, size:20, fillColor:.color
		
		// Draw bar to visualizue up to which frame we got input from each player
		let bufferY = 510 - getHeightForFrame(Network.frame-Network.bufferFrames)
		drawLine {960,bufferY} to {1100,bufferY} width:5
		for Input.users -> user
			let internaluser = Input.internalUsers[.id]
				drawRectangle {984+user.index*32, 510} size:{24, getHeightForFrame(internaluser.inputFrame)}, valign:Bottom, fillColor:.color
	
	private getHeightForFrame: int frame
		return (100+frame-Network.frame)*10

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
	
	Buffer snapshots = {}
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
		Buffer buffer = {}
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
	public float serverStartTime
	visible int frame               // Current frame, will increase by 1 at the end of every step (every targetFrameTime ms)
	internal int frames             // Total number of frames we have inputs for
	internal int frameWithNewWatches = 0 // First frame with new watches, do not send watches for frames below this
	internal bool startInLobby      // Connected sessions usually start in the lobby, local sessions start in the app
	private int joinFrame           // The frame the current user joined
	bool isPremiere
	
	// Checksum
	public float[] checksums
	public int lastChecksumFrame
	
	initDatabase
		IndexedDB.start "up4playing", "snapshot", 5

	startConnected: int frame
		if mode == Connected: return
				
		let user = Input.localUser
		user.startInputFrame 0
		
		Input.handleJoin frame 
		user.collectInputs = true
		if Network.logging: writeLog += " #{joinFrame} Join"
		log "startConnected", joinFrame
		
		this.frame = frame
		mode = Connected
		snapshotFrame = -1
		nextSnapshotFrame = 0
		checkSaveState
		statistics.connectTime = Time.preciseTime
		log "Connected", user.id, frame, startTime, serverStartTime
		
	startLocal: userCount = 1
		mode = Local
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
		if simulateRollback: checkSaveState
	
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
		let user = Input.internalUsers[userId]
		if user and (user.local or frame <= user.smoothFrame): do

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
				checkRewindAndReplayState
			
			catch 
				onError error
					
			// Ensure that step is called every targetFrameTime milliseconds
			while frame < targetFrame
				// Create artificial inputs to test the smoothness
				if simulateInputsForTesting and Input.localUser and Input.localUser.collectInputs
					Input.handleKeyEvent KeyDown, cast Key.F24, ""

				for Input.internalUsers -> user
					if user?.local: user.startInputFrame frame+1
				step fastForward:false, draw:frame == targetFrame-1
				collectStatistics
				lastNetworkFrame = now
				
		lastAnimationFrame = now
		if Platform.mode == Play and frame >= frames: Platform.record()
			
	private int animationStartFrame // The frame at the beginning of animationFrame, used to calculate iteration
	private float now               // The time at the beginning of animationFrame
	
	// Logs
	string logTable = "frame,id,iframe,ahead,buffer,id,iframe,ahead,buffer,id,iframe,ahead,buffer,id,iframe,ahead,buffer,messageSize,now,animTime,networkTime,tickTime,drawTime,displayItems,iteration,restoreTime,replayFrames,replayTime,snapshotSize,saveTime,pingPong,checksums,events,replay,controller,send,receive,write,parse,touch\n"
	public string eventLog, replayLog, sentLog, receivedLog, writeLog, parseLog, touchLog, checksumLog
	private float lastNetworkFrame, lastAnimationFrame, drawTime, tickTime, restoreTime, replayTime, saveTime
	private int replayFrames
	internal int displayItems
	int tickMessageSize
	bool logging = true
	int replayFrom = -1
	
	collectStatistics
		if mode == Connected and Input.users.length > 1 and frame > joinFrame + 120
			for Input.users
				let internalUser = Input.internalUsers[.id]
				if not internalUser.local
					internalUser.collectStatistics frame
					statistics.add .index, frame - internalUser.inputFrame, .color, set:0
					statistics.add .index, frame - internalUser.smoothFrame, .color, set:1
			if replayFrom != -1: statistics.add "replay", frame - replayFrom, Gray
		else
		if mode == Local and simulateRollback
			Input.internalUsers.each.simulateRollback frame
			
		// Logs
		if logging
			try
				logTable += "{frame-1}"
				for 4
					let user = Input.internalUsers.find.index == i
						logTable += ",{user.id},{user.inputFrame},{frame-user.inputFrame},{user.bufferFrames}"
					else
						logTable += ",,,,"
					
				logTable += ",{tickMessageSize},{now},{now - lastAnimationFrame},{now - lastNetworkFrame},{tickTime.format(fractionDigits:2)},{drawTime.format(fractionDigits:2)},{displayItems},{frame-animationStartFrame}"
				logTable += ",{restoreTime.format(fractionDigits:2)},{replayFrames},{replayTime.format(fractionDigits:2)},{snapshot.writePos},{saveTime.format(fractionDigits:2)},{ServerNetwork.lastPingPongTime}"
				logTable += ",\"{checksumLog.trim}\",\"{eventLog.trim}\",\"{replayLog.trim}\",\"{Input.users[0]?.controller?.leftStick}\",\"{sentLog.trim}\",\"{receivedLog.trim}\",\"{writeLog.trim}\",\"{parseLog.trim}\",\"{touchLog.trim}\"\n"
			catch
				onError error
			
			eventLog = ""; replayLog = ""; sentLog = ""; receivedLog = ""; writeLog = ""; parseLog = ""; touchLog = ""; checksumLog = ""
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
			int certainFrame = Input.internalUsers.min Math.min(.inputFrame, .smoothFrame) where .active
			bool isCertain = frame <= certainFrame
			
			// Send current frame to editor	
			if Platform.isDebug and !fastForward and (Platform.mode == Record or Platform.mode == Play or Platform.waitingForInitialData): Platform.sendFrame(frame, Math.max(frame+1, frames))
			
			// Save a snapshot when we are about to start the frame after the last certain frame where we got all inputs
			checkSaveState
			
			// Log
			if logging
				replayLog += " #{frame} c:{certainFrame}"
				parseLog += " #{frame}"
				if fastForward: parseLog += "f"; replayLog += "f"
				if isCertain:   parseLog += "c"; replayLog += "c"
				
			// Update game controllers
			Input.updateGameControllers
			
			// Post lost messages and remove users if nobody disagrees
			Input.handleLost
			
			// Parse inputs
			Input.parseInputs(frame)
			
			// Physics
			Physics.step
			
			// Tick
			tick draw
			
			if HTMLElement.elements: HTMLElement.elements.each.tick
			
			if mode != Local and isCertain
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
		if draw and not Platform.waitingForInitialData
			let isPlayback = Platform.mode == Play or frame+1 < frames
			if Input.showPointers or isPlayback
				Input.users.each drawPointer .id, showLocalPointer:isPlayback or Input.showLocalPointer
		audio.startFrame
		
		if Platform.showDebugInfo
			if draw: statistics.tick
			networkVisualizer.tick
			
		try
			if lobby.inLobby
				lobby.tick
			else
				Framework.tick
				tickTime = Time.measure
					appTick
		catch
			onError error
			
		if draw and not Platform.waitingForInitialData
			drawTime = Time.measure
				graphics.finishFrame
			if Platform.mode != Manipulator: Input.updateCursor
		audio.finishFrame
				
	js void appTick() if(window.app_tick) app_tick();
		
	private Buffer snapshot = {}
	private Buffer secondSnapshotForTesting = {}
	private int snapshotFrame = -1
	private int nextSnapshotFrame = -1
	
	// This is called at the begining of animationFrame before we start stepping.
	private checkRewindAndReplayState
		if (mode != Connected and !simulateRollback) or Input.internalUsers.length == 1: return
			
		if mode == Local and simulateRollback: nextSnapshotFrame = frame - 5
		else                nextSnapshotFrame = (Input.internalUsers.min Math.min(.smoothFrame, .inputFrame) where .active and not .local)+1
		replayLog += "(next:{nextSnapshotFrame})"
		if snapshotFrame != -1: rewindAndReplayState snapshot, snapshotFrame

	private rewindAndReplayState: Buffer snapshot, int snapshotFrame
		// Rewind
		replayLog += " rewind to {snapshotFrame}("
		restoreTime = Time.measure
			snapshot.rewind
			Snapshot.deserialize snapshot
			
			let userCount = snapshot.readInt
			for userCount
				let user = Input.internalUsers[.]
				user.inputs.readPos = snapshot.readInt
		replayLog += ")"
		
		// Replay
		let targetFrame = frame
		frame = replayFrom = snapshotFrame
		replayFrames = targetFrame - frame
		this.snapshotFrame = -1
		
		replayLog += "\{"
		replayTime = Time.measure
			while frame < targetFrame
				step fastForward:true, draw:false			
		replayLog += "\} "
			
	// This is called at the beginning of each step
	private checkSaveState
		if mode != Connected and !simulateRollback: return
			
		if snapshotFrame == -1 and frame >= nextSnapshotFrame
			replayLog += " save{frame}("
			snapshotFrame = frame
			saveState snapshot
			replayLog += ")"

	private saveState: Buffer snapshot
		snapshot.reset
		saveTime = Time.measure
			Snapshot.serialize snapshot
				
		// To check if serialization works consistently, deserialize, serialize a second snapshot and compare it with the first
		if simulateRollback
			Snapshot.deserialize snapshot
			Snapshot.serialize secondSnapshotForTesting
			if(snapshot != secondSnapshotForTesting)
				onError {"Inconsistent serialization"}
												
		// Checksum
		if Input.users.length >= 2 and frame > 200
			float myChecksum = Framework.checksum + snapshot.writePos
			float theirChecksum = checksums[frame]
			if logging: checksumLog += " <{Input.localUser.id}*> #{frame} {myChecksum}"
			if !theirChecksum                             checksums[frame] = myChecksum; else
			if !theirChecksum.isApproximately(myChecksum) onWrongChecksum mine:myChecksum theirs:theirChecksum
			lastChecksumFrame = frame
			
			// Temporary logging
			eventLog += "objects:{Framework.objects.length} fx:{fx.effects.length} items:{app.items.length} Platform.size:{Platform.size} "
			eventLog += Framework.debugString + app.debugString
			
		snapshot.writeInt Input.internalUsers.length
		for Input.internalUsers
			snapshot.writeInt .inputs.readPos
		replayLog += "sn.writepos:{snapshot.writePos} "
				
	js void log: logstring text
		let str = new Date().hourMinuteSecondString() + " " + text
		statistics_log += str + "\n"
		if(Network_logging) {
			Network_eventLog += str + "\n"
			console.log(str)
		}
		
	inline js int currentTime := Date.now()
	// inline js int currentTime := Math.round(performance.now())
	
	js void startApp
		lobby_inLobby = false
		if(window.app_start) app_start()
		
	private adjustStartTime
		startTime = Math.round(currentTime - frame*targetFrameTime - (targetFrameTime*.5))
		// timeOffset = Math.round(currentTime - frame*targetFrameTime - (targetFrameTime*.5)) - startTime
		
	adjustStartTimeIfNeeded
		if Platform.mode < Play: adjustStartTime
		
	Buffer snapshotBuffer = {}
		
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
		Buffer buffer = {}
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
		
		// if !Platform.isDebug and !alertShown
		// 	alert "Please send me the log file that will be created.\n\n{errorMessage}"
		// 	saveLogs
		// 	alertShown = true

class StatisticsGraphSeries
	int userIndex = -1
	int set
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
			
class StatisticsInfo
	float value
	int index
	int frame
				
skipInit transient unit statistics
	const Vector2 margin = {224,126}
	const Vector2 position = {-960, 540}
	const Vector2 size = {1920+margin.x, margin.y}
	const Vector2 labelPos = {970, 528}
	const Color backgroundColor = {"202020"}
	const framesPerValue = 15
	
	float[] serverPings
	private StatisticsGraphSeries[] series
	string log
	Time startTime, loadTime, connectTime
	internal float maxValue
	int currentSet
	int sets = 1
	
	private StatisticsInfo[] infos
	private string[] infoNames
	
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
			
	add: string name, float value, Color color = White, int set = 0
		var s = series.find.name == name and .set == set
		if !s
			series.add s = {name, color, set}
			series.orderBy.name
			sets assignIfGreater set+1
		s.color = color
		s.add value
		
	add: int userIndex, float value, Color color = White, int set = 0
		var s = series.find.userIndex == userIndex and .set == set
		if !s
			series.add s = {userIndex, name:userIndex.toString, color, set}
			series.orderBy.name
			sets assignIfGreater set+1
		s.color = color
		s.add value
		
	addInfo: string name, float value
		int index = infoNames.indexOf name
		if index == -1: index = infoNames.length; infoNames.add name
		infos.add {value, index, frame:Network.frame}
		
	internal tick
		Input.onTouchDownWithin position, size, align:Left, valign:Top
			currentSet incrementAndWrap sets
	
		maxValue = 12
		for series -> s
			if .set != currentSet: continue
			int len = Math.min(.values.length, 50)
			for len: 
				let value = s.values[-1-i]
				if value > maxValue: maxValue = value
			
		Vector2 startPos = position + size
		Vector2 labelPos = this.labelPos
		const height = size.y - 20
		for series -> s, seriesIndex
			if .set != currentSet: continue
			string text = cast .lastValue
			drawRectangle labelPos, {8,8}, fillColor:.color, align:Left
			drawText text, labelPos+{11, -2}, align:Left, size:12
			labelPos.x += graphics.getTextWidth(text, size:12) + 20
			
			int len = Math.min(.values.length, size.x.round)
			float prevY = 0
			for len
				let value = s.values[-1-i]
				Vector2 pos = {startPos.x - i, startPos.y - (value/maxValue).max(1)*height + seriesIndex*3}
				if i: drawRectangle pos, size:{4, prevY-pos.y+4}, fillColor:s.color, valign:Top
				prevY = pos.y
				
		// Draw infos
		for infos <-
			let x = (Network.frame - .frame)/framesPerValue
			if x > size.x: break
			drawText cast .value, {position.x + size.x - x, position.y + 10*.index}, size:8, valign:Top
				
		if Network.errorMessage: drawText Network.errorMessage, position, align:Left, size:12, color:{"ffff00"}
		drawText "#{Network.frame} {maxValue}", {position.x+size.x-8, labelPos.y}, align:Right, size:12
		drawRectangle position, size, fillColor:backgroundColor, align:Left, valign:Top

unit networkVisualizer		
	private int[] posForUser = [0,-10000,-10000,-10000,-10000,-10000]
		
	internal tick
		if Network.simulateInputsForTesting
			for Input.users
				if posForUser[.index] == -10000: posForUser[.index] = posForUser[0]
					
			// Move circle with artificially created inputs to test the smoothness
			for Input.users -> user
				Network.smooth user.id
					if user.id == 1: Network.replayLog += "C"
					// Network.log "[{Network.frame}] <{user.id}> networkVisualizer", Network.isSmooth
					Input.onKeyDown F24, userId:user.id
						if user.id == 1: Network.replayLog += "D"
						if (posForUser[user.index] += 2) > 1080
							posForUser[user.index] -= 1080
						// Network.log "[{Network.frame}] <{user.id}> networkVisualizer Input.onKeyDown", posForUser[user.index]
				
			for Input.users -> user
				drawCircle {1110+user.index*20, -540+posForUser[user.index]}, size:20, fillColor:.color
		
		// // AheadMin
		// let minY = 510 - getHeightForFrame(Network.frame-Network.aheadMin+1)
		// drawLine {960,minY} to {1100,minY} width:3
		// drawText cast Network.aheadMin, {1110, minY}, size:20, align:Left
		
		// Draw bar to visualizue up to which frame we got input from each player
		for Input.users -> user
			let internaluser = Input.internalUsers[.id]
				// BufferFrames
				let bufferY = 510 - getHeightForFrame(Network.frame-internaluser.bufferFrames+1)
				drawLine {960,bufferY} to {1100,bufferY} width:3, color:.color
				drawText cast internaluser.bufferFrames, {1110, bufferY}, size:20, color:.color, align:Left
		
				drawRectangle {984+user.index*32, 510} size:{24, getHeightForFrame(internaluser.inputFrame)}, valign:Bottom, fillColor:.color
		
		// Replay from
		if Network.replayFrom != -1
			let bufferY = 510 - getHeightForFrame(Network.replayFrom)
			drawLine {960,bufferY} to {1100,bufferY} width:3, color:White
			drawText cast(Network.frame - Network.replayFrom), {1110, bufferY}, size:20, color:White, align:Left
	
	private getHeightForFrame: int frame
		return (50+frame-Network.frame)*20

enum NetworkMode: None, Ping, Local, Connected
transient class RoomInfo: int time, userId
enum SendInputsMode: None, Peer, Server
	
transient skipInit unit core
	int eventStreamVersion = 1
	int sendInterval = 1
	int smoothStrength = 90
	bool smoothTouchPosition = true
	bool simulateConnection = true
	bool simulateInputsForTesting = false
	bool simulateRollback = false
	bool drawPointsForTesting = false
	Time sendStatisticsEvery = 3 minutes
	bool showVideoForStaging = true
	bool muteInvisibleUsers = false
	
	SendInputsMode sendInputsMode = Peer
	internal const targetFps = 30
	const targetFrameTime = 1000/targetFps
	
	NetworkMode mode                // Whether we are in local or connected mode
	visible string errorMessage     // The error message if we caught any exceptions in the main loop
	public float startTime          // The time the room was created, syncroniced between all clients
	public float serverStartTime
	visible int frame               // Current frame, will increase by 1 at the end of every step (every targetFrameTime ms)
	internal int frames             // Total number of frames we have inputs for
	internal int frameWithNewWatches = 0 // First frame with new watches, do not send watches for frames below this
	internal bool startInLobby      // Connected sessions usually start in the lobby, local sessions start in the app
	private int joinFrame           // The frame the local user joined
	bool isPremiere
	
	// Checksum
	public float[] checksums
	public int lastChecksumFrame
	
	initDatabase
		IndexedDB.start "up4playing", "snapshot", 5

	startConnected: int frame
		if mode == Connected: return
				
		let user = input.localUser
		user.startInputFrame 0
		
		input.handleJoin frame 
		user.collectInputs = true
		if core.logging: writeLog += " #{joinFrame} Join"
		log "startConnected", joinFrame
		
		this.frame = frame
		mode = Connected
		snapshotFrame = -1
		nextSnapshotFrame = 0
		checkSaveState
		statistics.connectTime = Time.preciseTime
		log "Connected", user.id, frame, startTime, serverStartTime
		
	startLocal
		mode = Local
		input.internalUsers.clear
		math.setRandomSeed math.generateRandomSeed 
		// initDatabase
		stop
		
	// Clear all inputs and reset the application to the first frame
	stop
		for input.internalUsers if .
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
		
	// Start recording (from the beginning or the middle of an existing event stream)
	// We remove all future inputs
	// This is called when the user clicks first clicks inside the app
	record
		frames = frameWithNewWatches = frame
		for input.internalUsers if .
			.inputs.writePos = .inputs.readPos
			.startInputFrame frame
		if Platform.isDebug: Platform.sendFrame frame, frames
		
	// Keep inputs, call init functions, create the local players, reset read positions and start app
	// This is called on startup, after every code change and when going backwards in the timeline
	reset
		players.clear
		input.playersById.clear
		errorMessage = ""
		HTMLElement.clear
		math.randomValueIndex = 0
		frame = 0
		input.isCertain = true
		lobby.inLobby = startInLobby
		Time.now = serverStartTime
		snapshotFrame = -1
		checksums.clear
		lastChecksumFrame = -1
		audio.stop
		initAll
		
		if !startInLobby
			// When the developer changed Platform.userCount, add or remove internal users accordingly
			for input.internalUsers.length to Platform.userCount
				input.internalUsers.add {id:i, local:true, collectInputs:true}
			if input.internalUsers.length > Platform.userCount
				input.internalUsers.removeRange Platform.userCount..input.internalUsers.length
			
			// We always recreating players, because developers might have added fields to Player or Touch
			// By the time we call startApp, all players need to exist
			for input.internalUsers -> internalUser
				Player user = {id:.id, index:i}
				input.playersById[.id] = user
				players.add user
				
			// Set local user
			let localUserId = input.localUser?.id < input.internalUsers.length ? input.localUser.id : 0
			input.localUser = input.internalUsers[localUserId]
			input.localPlayer = input.playersById[localUserId]
			input.updatePlayers
			
		// Reset read pos to replay inputs from the beginning
		for input.internalUsers if .
			.inputs.readPos = 0
			
		if !startInLobby: startApp
		if simulateRollback: checkSaveState
		
	// Keep event stream running, recreate players, call init function and start app
	// Called manually with the global "restart" function	
	restart
		initAll
		Player[] newPlayers
		for input.players
			Player user = {id:.id, index:i}
			input.playersById[.id] = user
			newPlayers.add user
		input.players = newPlayers
		let localUserId = input.localUser?.id < input.internalUsers.length ? input.localUser.id : 0
		input.localUser = input.internalUsers[localUserId]
		input.localPlayer = input.playersById[localUserId]
		input.updatePlayers
		startApp
	
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
	smooth: Player player
		    void() do
		let user = input.internalUsers[player.id]
		if user and (user.local or frame <= user.smoothFrame): do
			
	Time lastPingTime

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
			
		let targetFrame = math.floor((now - startTime)/targetFrameTime)+1
		
		if mode == Local && targetFrame > frame + targetFps*2
			// After a long pause in local mode, we do not want to process all missed frames, so we adjust the start time
			let prevTargetFrame = targetFrame
			targetFrame = frame
			startTime = math.round(now - targetFrame*targetFrameTime)
			log "Paused {prevTargetFrame-frame} frames, adjusting startTime. prevTargetTime:{prevTargetFrame} frame:{frame} targetFrame:{math.floor((now - startTime)/targetFrameTime)}"
		
		if frame < targetFrame
			// Create artificial inputs to test the smoothness
			if simulateInputsForTesting and input.localUser and input.localUser.collectInputs
				for frame to targetFrame
					input.handleKeyEvent KeyDown, cast Key.F24, ""
				
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
				for input.internalUsers -> user
					if user?.local: user.startInputFrame frame+1
				step fastForward:false, draw:frame == targetFrame-1
				collectStatistics
				lastNetworkFrame = now
				
		lastAnimationFrame = now
		if Platform.mode == Play and frame >= frames: Platform.record()
			
		// Ping
		if currentTime - lastPingTime > 1000
			lastPingTime = currentTime
			PeerNetwork.ping
			
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
		if mode == Connected and players.length > 1 and frame > joinFrame + 120
			for players
				let internalUser = input.internalUsers[.id]
				if not internalUser.local
					internalUser.collectStatistics frame
					statistics.add .index, frame - internalUser.inputFrame, .color, set:0
					statistics.add .index, frame - internalUser.smoothFrame, .color, set:1
			if replayFrom != -1: statistics.add "replay", frame - replayFrom, Gray
		else
		if mode == Local and simulateRollback
			input.internalUsers.each.simulateRollback frame
			
		// Logs
		if logging
			try
				logTable += "{frame-1}"
				for 4
					let user = input.internalUsers.find.index == i
						logTable += ",{user.id},{user.inputFrame},{frame-user.inputFrame},{user.bufferFrames}"
					else
						logTable += ",,,,"
					
				logTable += ",{tickMessageSize},{now},{now - lastAnimationFrame},{now - lastNetworkFrame},{tickTime.format(fractionDigits:2)},{drawTime.format(fractionDigits:2)},{displayItems},{frame-animationStartFrame}"
				logTable += ",{restoreTime.format(fractionDigits:2)},{replayFrames},{replayTime.format(fractionDigits:2)},{snapshot.writePos},{saveTime.format(fractionDigits:2)},{ServerNetwork.lastPingPongTime}"
				logTable += ",\"{checksumLog.trim}\",\"{eventLog.trim}\",\"{replayLog.trim}\",\"{players[0]?.controller?.leftStick}\",\"{sentLog.trim}\",\"{receivedLog.trim}\",\"{writeLog.trim}\",\"{parseLog.trim}\",\"{touchLog.trim}\"\n"
			catch
				onError error
			
			eventLog = ""; replayLog = ""; sentLog = ""; receivedLog = ""; writeLog = ""; parseLog = ""; touchLog = ""; checksumLog = ""
			ServerNetwork.lastPingPongTime = 0; tickMessageSize = 0

	private int lastSendFrame
	
	private sendInputs: int inputFrame
		if mode != Connected: return
		
		if frame >= lastSendFrame + sendInterval
			if sendInputsMode == Peer:   PeerNetwork.sendInputs inputFrame
			if sendInputsMode == Server: ServerNetwork.sendInputs inputFrame
			lastSendFrame = frame
			
	switchUser: int userIndex
		let prevPlayer = input.localPlayer
		if 0 <= userIndex < input.players.length
			input.localPlayer = players[userIndex]
			input.localUser = input.internalUsers.find.id == input.localPlayer.id
			for prevPlayer.touches
				input.handleUpdateTouchAfterSwitchingUser .id, .referencePosition
			
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
			Time.now = serverStartTime + math.round(frame * targetFrameTime)
			
			// Flags
			Platform.fastForward = fastForward
			int certainFrame = input.internalUsers.min math.min(.inputFrame, .smoothFrame) where .active
			bool isCertain = frame <= certainFrame
			
			// Send current frame to editor	
			if Platform.isDebug and !fastForward and (Platform.mode == Record or Platform.mode == Play or Platform.waitingForInitialData): Platform.sendFrame(frame, math.max(frame+1, frames))
			
			// Save a snapshot when we are about to start the frame after the last certain frame where we got all inputs
			checkSaveState
			
			// Log
			if logging
				replayLog += " #{frame} c:{certainFrame}"
				parseLog += " #{frame}"
				if fastForward: parseLog += "f"; replayLog += "f"
				if isCertain:   parseLog += "c"; replayLog += "c"
				
			// Update game controllers
			input.updateGameControllers
			
			// Post lost messages and remove players if nobody disagrees
			input.handleLost
			
			// Parse inputs
			input.parseInputs(frame)
			
			// Physics
			Physics.step
			
			// Tick
			tick draw
			
			if HTMLElement.elements: HTMLElement.elements.each.tick
			
		catch
			onError error
			
		// Cleanup
		for input.internalUsers if .
			.clearEvent
		players.each.clearEvents
		
		// Advance frame
		frame++
		if frames < frame: frames = frame
		if frameWithNewWatches < frame: frameWithNewWatches = frame
		
	// Clear screen, process application tick, and draw all graphics
	// This is called in step.
	internal tick: bool draw
		graphics.startFrame
		if draw and not Platform.waitingForInitialData
			if input.showPointers or Platform.mode == Play
				players.each drawPointer ., Platform.isDebug ? Local : input.showPointersMode
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
			if Platform.mode != Manipulator: input.updateCursor
		audio.finishFrame
				
	js void appTick() if(window.app_tick) app_tick();
	js string appDebugString() (window.app_debugString || "")
		
	private Buffer snapshot = {}
	private Buffer secondSnapshotForTesting = {}
	private int snapshotFrame = -1
	private int nextSnapshotFrame = -1
	
	// This is called at the begining of animationFrame before we start stepping.
	private checkRewindAndReplayState
		if (mode != Connected and !simulateRollback) or input.internalUsers.length == 1: return
			
		if mode == Local and simulateRollback: nextSnapshotFrame = frame - 5
		else                                   nextSnapshotFrame = (input.internalUsers.min math.min(.smoothFrame, .inputFrame) where .active and not .local)+1
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
				let user = input.internalUsers[.]
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
		if players.length >= 2 and frame > 200
			float myChecksum = snapshot.checksum
			float theirChecksum = checksums[frame]
			if logging: checksumLog += " <{input.localUser.id}*> #{frame} {myChecksum} writePos:{snapshot.writePos}"
			if !theirChecksum                             checksums[frame] = myChecksum; else
			if !theirChecksum.isApproximately(myChecksum) onWrongChecksum frame, mine:myChecksum theirs:theirChecksum
			lastChecksumFrame = frame
			
		snapshot.writeInt input.internalUsers.length
		for input.internalUsers
			snapshot.writeInt .inputs.readPos
		replayLog += "sn.writepos:{snapshot.writePos} "
				
	js void log: logstring text
		let str = new Date().hourMinuteSecondString() + " " + text
		statistics_systemLogs.push(str)
		if(core_logging) {
			core_eventLog += str + "\n"
			console.log(str)
		}
		
	inline js int currentTime := Date.now()
	
	js void startApp
		lobby_inLobby = false
		if(window.app_start) app_start()
		
	private adjustStartTime
		startTime = math.round(currentTime - frame*targetFrameTime - (targetFrameTime*.5))
		
	adjustStartTimeIfNeeded
		if Platform.mode < Play: adjustStartTime
			
	Buffer snapshotBuffer = {}
		
	saveEventStreamAndLogs
		if input.isCertain
			saveEventStream
			Platform.delay 1 seconds
				saveLogs
			
	internal saveLogs
		// Ensure that current eventLog is added to the table even if we haven't processed a single frame
		logTable += ",,,,,,,,,,,,,,,,,,,,,,,,\"{eventLog.trim}\""
		file.saveText "{input.localUser.id} {Platform.appName} {Date.now.invariantDayMonthYearHourMinuteSecondString} v{Platform.version}.csv", logTable
			
	saveEventStream
		Buffer buffer = {}
		buffer.writeInt eventStreamVersion
		buffer.writeInt frame-1
		buffer.writeInt frames
		buffer.writeString math.randomSeed
		buffer.writeBool startInLobby
		buffer.writeBool Platform.isStaging
		let userCount = input.internalUsers.count . != null
		buffer.writeInt8 userCount
		for input.internalUsers if .
			buffer.writeInt .id
			buffer.writeBool .local
			buffer.writeBuffer .inputs
		let date = Date.now
		file.saveBinary "{Platform.appName} {date.dayShortMonthNameYearString} {date.hourMinuteSecondString} v{Platform.version}.state", buffer
		
	openEventStream
		Platform.pause
		file.openBinary
			// Read event stream
			int version = buffer.readInt
			int targetFrame = buffer.readInt
			frames = buffer.readInt
			let randomSeed = buffer.readString
			startInLobby = buffer.readBool
			Platform.isStaging = buffer.readBool
			let userCount = buffer.readInt8
			input.internalUsers.clear
			for userCount
				InternalUser user = {
					id: buffer.readInt
					local: buffer.readBool
				}
				if user.local: input.localUser = user
				buffer.readBuffer user.inputs
				input.internalUsers[user.id] = user
				
			// Replay
			for input.internalUsers if .
				.collectInputs = true
				if Platform.isDebug: .local = true
				.startInputFrame frames
			math.setRandomSeed randomSeed
			
			Platform.sendClearTimeline
			goToFrame targetFrame, replayFromStart:true
			Platform.sendFrame(targetFrame, frames)
		
	string roomString
	int roomId
	string gameId
	
	join: string gameId, string roomString, int userId
		// Send statistics
		Platform.setTimeout 30 seconds
			statistics.startSession
			if sendStatisticsEvery: Platform.setInterval sendStatisticsEvery: statistics.saveStatistics
		
		isPremiere = true
		initAll
		log Platform.url
		log Date.realtime.dayMonthYearHourMinuteSecondString
		log Platform.userAgent
		startInLobby = true
		this.gameId = gameId
		this.roomString = roomString
		this.roomId = cast roomString
		input.localUser = {userId, local:true, connectionId:0}
		//initDatabase
		setupVideoAndNetwork
		lobby.enableFullscreen = !Platform.isStaging
		
	private js void initAll
		init()
		graphics_updateBaseMatrix();
		
	private js void setupVideoAndNetwork 
		await PeerNetwork_setupLocalMedia(/*enableVideo*/!Platform_isStaging || core_showVideoForStaging, /*enableAudio*/!Platform_isStaging)
		ServerNetwork_setup()
		
	internal storeUserId
		Platform.setLocalStorageObject "room"+roomId, RoomInfo(currentTime, input.localUser.id)
		
	onWrongChecksum: int frame, float mine, float theirs
		string message = "Out of sync. frame:{frame} mine:{mine} theirs:{theirs}"
		if logging: checksumLog += message
		onError {message}
		
	onError: Error error
		errorMessage = error.stack
		if logging: eventLog += errorMessage + "\n" 
		statistics.systemLogs.add errorMessage
		Platform.sendErrorToEditor error
		
transient unit Snapshot
	int autoSaveCount
	int lastSnapshotSize
	
	Buffer snapshots = {}
	int[] snapshotStarts
	int snapshotEvery = 100
	
	private bool autoSaveAtEndOfStep
	
	inline js string serialize(Buffer buffer) serialize_internal(buffer)
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
		Buffer buffer = {}
		serialize(buffer)
		return buffer
		
	restore: Buffer buffer
		deserialize(buffer)
		
	autoSave() autoSaveAtEndOfStep = true
	
	internal onEndOfStep
		if input.isCertain
			if autoSaveAtEndOfStep and ++autoSaveCount > 5
				let snap = save
				IndexedDB.saveBuffer "snapshot", "{core.gameId}-0", snap
				lastSnapshotSize = snap.writePos
			if core.frame/snapshotEvery > snapshotStarts.length
				snapshotStarts.add snapshots.writePos
				serialize(snapshots)
			autoSaveAtEndOfStep = false
	
global transient unit System
	// Reset all variables to their initial value and restart the app
	global inline restart() core.restart

class StatisticsGraphSeries
	int userIndex = -1
	int set
	string name = null
	float[] values
	float[] recentValues
	Color color
	int successfullySent
	
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
	const framesPerValue = 15
	
	float[] serverPings
	int successfullySentServerPings
	
	private StatisticsGraphSeries[] series
	
	string[] systemLogs
	private dynamic[] gameLogs
	int successfullySentGameLogs
	int successfullySentSystemLogs
	
	Time startTime, loadTime, connectTime
	internal float maxValue
	int currentSet
	int sets = 1
	int id
	
	private StatisticsInfo[] infos
	private string[] infoNames
	private bool currentlySendingStatistics
	
	// Log game events (like scores, playtimes, etc)
	log: any value
		value.frame = Time.frame
		this.gameLogs.add value
	
	startSession
		let user = localStorage.getObjectDirectly("user")
		let server = Platform.host.getUntil(".")
		let userId = input.localUser.id
		id = core.roomId*100 + userId
		int sendingSystemLogsUntil = systemLogs.length
		currentlySendingStatistics = true

		http.postDirectly "{Platform.protocolAndHost}:3114/startSession", body:{
			id
			gameId: core.gameId
			roomId: core.roomId
			userId
			userIndex: input.localUser.index
			userEmail: user.email
			staging: Platform.isStaging
			server
			loadTime: loadTime - startTime
			connectTime: connectTime - startTime
			systemLogs: systemLogs[successfullySentSystemLogs..]
		}
			successfullySentSystemLogs = sendingSystemLogsUntil
			currentlySendingStatistics = false
	
	saveStatistics
		if currentlySendingStatistics: return
		currentlySendingStatistics = true
		
		// Compile server and peer pings to send
		string[] connections
		float[][] peerPingsToSend = [[],[],[],[],[],[],[],[]]
		int[] sendingPeerLogsUntil = [0,0,0,0,0,0,0,0]
		for players -> p
			let internalUser = input.internalUsers[.id]
			connections.add internalUser.connectionType
			
			let inputFrameSeries = this.series.find.userIndex == p.index and .set == 0
				peerPingsToSend[i*2] = inputFrameSeries.values[inputFrameSeries.successfullySent..]
				sendingPeerLogsUntil[i*2] = inputFrameSeries.values.length
				
			let bufferFrameSeries = this.series.find.userIndex == p.index and .set == 1
				peerPingsToSend[i*2 + 1] = bufferFrameSeries.values[bufferFrameSeries.successfullySent..]
				sendingPeerLogsUntil[i*2 + 1] = bufferFrameSeries.values.length
		
		int sendingServerPingsUntil = serverPings.length
		int sendingSystemLogsUntil = systemLogs.length
		int sendingGameLogsUntil = gameLogs.length
			
		// Send statistics to server
		http.postDirectly "{Platform.protocolAndHost}:3114/saveStatistics", body:{
			id
			connections
			peerPings: peerPingsToSend
			serverPings: serverPings[successfullySentServerPings..]
			systemLogs: systemLogs[successfullySentSystemLogs..]
			gameLogs: gameLogs[successfullySentGameLogs..]
		}
			for players -> p
				let inputFrameSeries = this.series.find.userIndex == p.index and .set == 0
					inputFrameSeries.successfullySent = sendingPeerLogsUntil[i*2]
				let bufferFrameSeries = this.series.find.userIndex == p.index and .set == 1
					bufferFrameSeries.successfullySent = sendingPeerLogsUntil[i*2 + 1]
			successfullySentServerPings = sendingServerPingsUntil
			successfullySentSystemLogs = sendingSystemLogsUntil
			successfullySentGameLogs = sendingGameLogsUntil
			currentlySendingStatistics = false
						
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
		infos.add {value, index, frame:core.frame}
		
	internal tick
		input.onTouchDownWithin position, size, align:Left, valign:Top
			currentSet incrementAndWrap sets
	
		maxValue = 12
		for series -> s
			if .set != currentSet: continue
			int len = math.min(.values.length, 50)
			for len: 
				let value = s.values[-1-i]
				if value > maxValue: maxValue = value
					
		draw

unit networkVisualizer		
	visible int[] posForPlayer = [0,-10000,-10000,-10000,-10000,-10000]
		
	internal tick
		if core.simulateInputsForTesting
			for players
				if posForPlayer[.index] == -10000: posForPlayer[.index] = posForPlayer[0]
					
			// Move circle with artificially created inputs to test the smoothness
			for players -> player
				core.smooth player
					if player.id == 1: core.replayLog += "C"
					// core.log "[{core.frame}] <{player.id}> networkVisualizer", core.isSmooth
					input.onKeyDown by:player
						if player.id == 1: core.replayLog += "D"
						if (posForPlayer[player.index] += 2) > 1080
							posForPlayer[player.index] -= 1080
						// core.log "[{core.frame}] <{player.id}> pos:", posForPlayer[player.index]
				
		draw
				
	private getHeightForFrame: int frame
		return (50+frame-core.frame)*20

global skipInit unit math
	init
		initDefaultRandomGenerator
		
	js void initDefaultRandomGenerator
		math_randomGenerator = Math.random
		
	js string generateRandomSeed:
		let crypto = !window.crypto && typeof(require) != "undefined" ? require("crypto") : window.crypto
		if(crypto) {
			let out = new Uint8Array(256);
			crypto.getRandomValues(out);
			return out.toString();
		}
		
	transient internal string randomSeed
	internal int randomValueIndex
	transient internal float[] randomValues
	
	internal recreateRandomValues
		let targetRandomValueIndex = randomValueIndex
		setRandomSeed randomSeed
		for targetRandomValueIndex: randomFloat
	
	js void setRandomSeed: string seed
		math_randomSeed = seed
		math_randomValues.length = 0
		math_randomValueIndex = 0
		
		// Seeding the random number generator in Javascript
		// https://stackoverflow.com/a/47593316
		function xmur3(str) {
		    for(var i = 0, h = 1779033703 ^ str.length; i < str.length; i++) {
		        h = Math.imul(h ^ str.charCodeAt(i), 3432918353);
		        h = h << 13 | h >>> 19;
		    } return function() {
		        h = Math.imul(h ^ (h >>> 16), 2246822507);
		        h = Math.imul(h ^ (h >>> 13), 3266489909);
		        return (h ^= h >>> 16) >>> 0;
		    }
		}
		
		function sfc32(a, b, c, d) {
		    return function() {
		      a >>>= 0; b >>>= 0; c >>>= 0; d >>>= 0; 
		      var t = (a + b) | 0;
		      a = b ^ b >>> 9;
		      b = c + (c << 3) | 0;
		      c = (c << 21 | c >>> 11);
		      d = d + 1 | 0;
		      t = t + d | 0;
		      c = c + t | 0;
		      return (t >>> 0) / 4294967296;
		    }
		}
		
		function mulberry32(a) {
		    return function() {
		      var t = a += 0x6D2B79F5;
		      t = Math.imul(t ^ t >>> 15, t | 1);
		      t ^= t + Math.imul(t ^ t >>> 7, t | 61);
		      return ((t ^ t >>> 14) >>> 0) / 4294967296;
		    }
		}
		
		var seed = xmur3(seed);
		var rand = sfc32(seed(), seed(), seed(), seed());
		var rand = mulberry32(seed());
		
		math_randomGenerator = function() {
			let value
			if(math_randomValueIndex < math_randomValues.length) {
				value = math_randomValues[math_randomValueIndex]
				math_randomValueIndex++
			} else {
				value = rand()
				math_randomValues[math_randomValueIndex++] = value;
			}
			return value
		}

	// Generates a random integer
	global js int randomInteger: int from // The inclusive lower bound of the random integer
		                         int to // The exclusive upper bound of the random integer
		return from + Math.floor(math_randomGenerator() * (to-from))
	
	global js int randomInteger: int to = 2147483647 // The exclusive upper bound of the random integer
		return Math.floor(math_randomGenerator() * to)
	
	// Generates a random float
	global js int randomFloat: float from
		                       float to
		return from + math_randomGenerator() * (to-from)
	
	global js int randomFloat: float to = 1.0
		return math_randomGenerator() * to
	

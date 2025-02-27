enum NetworkMode: None, Ping, Local, Connected
internal transient immutable RoomInfo: int time, userId
enum SendInputsMode: None, Peer, Server
	
internal transient skipInit unit core
	int eventStreamVersion = 2
	int sendInterval = 1
	bool enabledMilestones = true
	int milestoneInterval = 1800
	int smoothStrength = 90
	bool smoothTouchPosition = true
	bool everybodyCanClickForEverybody = false
	bool simulateConnection = true
	bool simulateInputsForTesting = false
	bool simulateRollback = false
	bool drawPointsForTesting = false
	Time sendStatisticsEvery = 2 minutes
	bool muteInvisibleUsers = false
	bool testLobby = false                // Start in the lobby for testing
	
	bool enableVideoForStaging = true
	bool enableAudioForStaging = false
		
	SendInputsMode sendInputsMode = Peer
	internal const targetFps = 30
	const frameTime = 1000/targetFps
	
	NetworkMode mode                // Whether we are in local or connected mode
	visible string errorMessage     // The error message if we caught any exceptions in the main loop
	public float startTime          // The time the room was created, syncroniced between all clients
	public float serverStartTime    // Used to calculate the same Time.now from core.frame for all users in core.step
	visible int frame               // Current frame, will increase by 1 at the end of every step (every targetFrameTime ms)
	internal int frames             // Total number of frames we have inputs for
	internal int frameWithNewWatches// First frame with new watches, do not send watches for frames below this
	int watchIndex
	internal bool startInLobby      // Connected sessions usually start in the lobby, local sessions start in the app
	private int joinFrame           // The frame the local user joined
	bool isPremiere
	UserAccount account
	
	// Checksum
	public float[] checksums
	public int lastChecksumFrame
	
	IndexedDBStore inputStore = {"input", indices:[{"roomId"}]}
	IndexedDBStore roomStore  = {"room"}
	
	startConnected: int frame
		if mode == Connected: return
			
		account = Platform.getLocalStorageObject("user") or {}
		if not account._id
			account._id = generateObjectId
			Platform.setLocalStorageObject("user", account)
				
		log "startConnected", joinFrame, this.frame, this.frames
		if this.frames == 0
			log "handleJoin", frame
			input.localUser.startInputFrame 0
			input.handleJoin frame, account
		
		mode = Connected
		input.localUser.collectInputs = true
		snapshotFrame = -1
		nextSnapshotFrame = 0
		checkSaveState
		log "Start", input.localUser.id, frame, startTime, serverStartTime
		
	js string generateObjectId
		const timestamp = Math.floor(new Date().getTime() / 1000).toString(16);
		const machineIdentifier = Math.floor(Math.random() * 0xFFFFFF).toString(16).padStart(6, '0');
		const processIdentifier = Math.floor(Math.random() * 0xFFFF).toString(16).padStart(4, '0');
		const counter = Math.floor(Math.random() * 0xFFFFFF).toString(16).padStart(6, '0');
		return (timestamp + machineIdentifier + processIdentifier + counter).toLowerCase();
		
	startLocal
		mode = Local
		input.internalUsers.clear
		math.setRandomSeed math.generateRandomSeed 
		stop
		
	// Clear all inputs and reset the application to the first frame
	stop
		for input.internalUsers if .
			.inputs.reset
			.startInputFrame 0
		startTime = serverStartTime = currentTime
		frames = 0
		frameWithNewWatches = 0
		watchIndex = 0
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
		input.host = null
		input.playersToRemove.clear
		errorMessage = ""
		HTMLElement.clear
		math.randomValueIndex = 0
		frame = 0
		watchIndex = 0
		input.isCertain = true
		lobby.inLobby = startInLobby
		Time.now = serverStartTime
		snapshotFrame = -1
		checksums.clear
		lastChecksumFrame = -1
		audio.stop
		initAll
		
		if !startInLobby or testLobby
			// When the developer changed Platform.userCount, add or remove internal users accordingly
			for Platform.userCount
				if not input.internalUsers[.]
					input.internalUsers[.] = {id:i, local:true, collectInputs:true}
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
			account = {}
			
		// Reset read pos to replay inputs from the beginning
		for input.internalUsers if .
			.inputs.readPos = 0
			
		if !startInLobby and not testLobby: startApp
		if simulateRollback: checkSaveState
		
	// Keep event stream running, recreate players, call init function and start app
	// Called manually with the global "restart" function	
	restart
		if not input.isCertain: return
		let hostPlayerId = input.host ? input.host.id : -1
		Framework.clear includingLockedObjects:true
		Platform.fastForward = false
		let prevLanguage = Loca.language
		initAll
		Loca.setLanguage prevLanguage
		Player[] newPlayers
		for input.players
			Player user = .cloneBaseData
			input.playersById[.id] = user
			newPlayers.add user
		input.players = newPlayers
		let localUserId = input.localUser?.id < input.internalUsers.length ? input.localUser.id : 0
		input.localUser = input.internalUsers[localUserId]
		input.localPlayer = input.playersById[localUserId]
		input.host = hostPlayerId != -1 ? input.playersById[hostPlayerId] : null
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
		if replayFromStart
			frameWithNewWatches = 0
			reset
		else
		if targetFrame < frame
			let milestoneIndex = enabledMilestones ? math.floor(targetFrame/milestoneInterval) - 1 : -1
			if 0 <= milestoneIndex < milestones.length
				let milestone = milestones[milestoneIndex]
				frame = (milestoneIndex+1) * milestoneInterval
				rewind milestone
			else
				reset
			
		replay frame to targetFrame
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
	// We ensure that step is called every frameTime milliseconds.
	internal animationFrame
		now = currentTime
		if lastAnimationFrame: frameTimes.add now - lastAnimationFrame

		ServerNetwork.tick
		PeerNetwork.tick
		statistics.tick
		if mode == None or mode == Ping: return
			
		let targetFrame = math.floor((now - startTime)/frameTime)+1
		if verbose: core.log "----- #{frame} -> #{targetFrame} -----"
		
		if mode == Local && targetFrame > frame + targetFps*2
			// After a long pause in local mode, we do not want to process all missed frames, so we adjust the start time
			let prevTargetFrame = targetFrame
			targetFrame = frame
			startTime = math.round(now - targetFrame*frameTime)
			log "Paused {prevTargetFrame-frame} frames, adjusting startTime. prevTargetTime:{prevTargetFrame} frame:{frame} targetFrame:{math.floor((now - startTime)/frameTime)}"
		
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
					
			// Ensure that step is called every frameTime milliseconds
			while frame < targetFrame
				if Platform.mode == Record
					for input.internalUsers -> user
						if user?.local: user.startInputFrame frame+1
				step fastForward:false, draw:frame == targetFrame-1
				collectStatistics
				
				lastNetworkFrame = now
				
			// Store local inputs
			if IndexedDB.isReady
				core.storeInputsToDB input.localUser
				core.storeRoomToDB
				
		lastAnimationFrame = now
		if Platform.mode == Play and frame >= frames: Platform.record()
			
		// Ping
		if currentTime - lastPingTime > 1000
			lastPingTime = currentTime
			PeerNetwork.ping
			
	private int animationStartFrame // The frame at the beginning of animationFrame, used to calculate iteration
	private float now               // The time at the beginning of animationFrame
	
	private Time prevLogTime
	
	// Logs
	js void log: logstring text
		if(Time.now > core.prevLog + 3000) core.logs += "\n"
		core.prevLog = Time.now
		
		let str = new Date().hourMinuteSecondMillisecondString() + " " + text
		statistics.systemLogs.push(str)
		console.log(str)
		core.logs += str + "\n"
		
		// !!! Temporary for debugging windows that are crashed or don't respond
		// if(Platform.isStaging) {
		// 	try {
		// 		localStorage.setItem(`logs-${core.roomId}-${input.localUser ? input.localUser.id : "?"}`, core.logs)
		// 	} catch(e) {
		// 		console.error(e)
		// 	}
		// }
			
	internal string logs
	private float lastNetworkFrame, lastAnimationFrame, drawTime, tickTime, restoreTime, replayTime, saveTime
	internal int displayItems
	int tickMessageSize
	bool verbose = false
	int replayFrom = -1
	
	RollingList drawTimes, tickTimes, frameTimes = {length:150}
	
	collectStatistics
		// Players
		if mode == Connected and players.length > 1 and frame > joinFrame + 120
			for players
				let internalUser = input.internalUsers[.id]
				if not internalUser.local
					internalUser.collectStatistics frame
					statistics.add "input", userIndex:.index, value:frame - internalUser.inputFrame, .color, set:0
					statistics.add "smooth", userIndex:.index, value:frame - internalUser.smoothFrame, .color, set:1
					statistics.add "delta", userIndex:.index, value:internalUser.certainFrame - internalUser.prevCertainFrame, .color, set:2

			if replayFrom != -1: statistics.add "replay", value:frame - replayFrom, color:Gray
		else
		if mode == Local and simulateRollback
			input.internalUsers.each.simulateRollback frame
			
		// Memory
		statistics.add "memory", value:Platform.usedMemory, color:Yellow set:4
		statistics.add "snapshotSize", value:snapshot.writePos, color:Red set:5
		statistics.add "inputs", value:input.localUser?.inputs.writePos, color:Blue set:6
		
		// Times
		statistics.add "drawTime", value:drawTime, color:Blue set:7
		statistics.add "tickTime", value:tickTime, color:Red set:7
		statistics.add "restoreTime", value:restoreTime, color:Green set:7
		statistics.add "replayTime", value:replayTime, color:Yellow set:7
		statistics.add "saveTime", value:saveTime, color:White set:7
		
	connectionStates
		string result
		for input.internalUsers
			if not .local
				if result: result += ", "
				result += .connectionState
		return result

	private int lastSendFrame
	
	private sendInputs: int inputFrame
		if mode != Connected: return
		
		if frame >= lastSendFrame + sendInterval
			if sendInputsMode == Peer:   PeerNetwork.sendInputs inputFrame
			if sendInputsMode == Server: ServerNetwork.sendInputs inputFrame
			lastSendFrame = frame
	
	internal switchToPlayer: Player player
		if not player: return
		let prevPlayer = input.localPlayer
		input.localPlayer = player
		input.localUser = input.internalUsers.find . and .id == player.id
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
	internal step: bool fastForward // If we are replaying after a rollback or a code change
		           bool draw        // We don't draw if we are stepping multiple frames in one animation frame
		try
			if verbose: core.log "#{frame}{fastForward ? " fastForward":""}{draw ? " draw":""}"
				
			// Set time
			Time.now = serverStartTime + math.round(frame * frameTime)
			
			// Flags
			Platform.fastForward = fastForward
			int certainFrame = input.internalUsers.min math.min(.inputFrame, .smoothFrame) where . != null
			input.isCertain = frame <= certainFrame
			
			// Send current frame to editor	
			// if Platform.isDebug and !fastForward and (Platform.mode == Record or Platform.mode == Play or Platform.waitingForInitialData): Platform.sendFrame(frame, math.max(frame+1, frames))
			if Platform.isDebug and !fastForward: Platform.sendFrame(frame, math.max(frame+1, frames))
			
			// Save a snapshot when we are about to start the frame after the last certain frame where we got all inputs
			checkSaveState
			
			// Update game controllers
			input.updateGameControllers
			
			// Parse inputs
			input.parseInputs(frame)
			
			// Physics
			Physics.step
			
			// Tick
			tick draw
			
			if HTMLElement.elements: HTMLElement.elements.each.tick
			input.removePlayersIfNecessary
			
		catch
			onError error
			
		// Cleanup
		for input.internalUsers if .
			.clearEvent
		players.each.postprocessEvents
		
		// Advance frame
		frame++
		if frames < frame: frames = frame
		if frame > frameWithNewWatches: frameWithNewWatches = frame
			
	// Clear screen, process application tick, and draw all graphics
	// This is called in step.
	internal tick: bool draw
		Platform.isDrawing = draw
		graphics.startFrame
		if draw and not Platform.waitingForInitialData
			if input.showPointers or Platform.mode == Play
				players.each drawPointer ., Platform.mode == Play ? input.showPointersDuringPlaybackMode : input.showPointersMode
		audio.startFrame
		
		if Platform.showDebugInfo
			if draw: statistics.tickGraph
			networkVisualizer.tick
			
		try
			Framework.tick
			tickTimes.add tickTime = Time.measure
				if lobby.inLobby:      lobby.tick; else
				if awardScreen.active: awardScreen.tick; else
				                       appTick
		catch
			onError error
			
		if draw and not Platform.waitingForInitialData
			drawTimes.add drawTime = Time.measure
				graphics.finishFrame
			if Platform.mode != Manipulator: input.updateCursor
		audio.finishFrame
				
	js void appTick() if(app.tick) app.tick();
	js string appDebugString() (app.debugString || "")
		
	private Buffer snapshot = {}
	private Buffer secondSnapshotForTesting = {}
	private int snapshotFrame = -1
	private int nextSnapshotFrame = -1
	
	private Buffer[] milestones
	
	// This is called at the begining of animationFrame before we start stepping.
	private checkRewindAndReplayState
		if (mode != Connected and !simulateRollback) or input.internalUsers.length == 1: return
			
		if mode == Local and simulateRollback: nextSnapshotFrame = frame - 5
		else                                   nextSnapshotFrame = (input.internalUsers.min math.min(.smoothFrame, .inputFrame) where . and not .local)+1
		
		if snapshotFrame != -1
			if verbose
				core.log "rewindAndReplayState", snapshotFrame, frame, nextSnapshotFrame
				for input.internalUsers
					core.log "\t<{.id}>", .smoothFrame, .inputFrame, .local
			
			let prevSnapshotFrame = snapshotFrame
			snapshotFrame = -1
			rewind snapshot
			replay prevSnapshotFrame to frame

	private rewind: Buffer snapshot
		restoreTime = Time.measure
			snapshot.rewind
			Snapshot.deserialize snapshot
			
			let userCount = snapshot.readInt
			for userCount
				let user = input.internalUsers[.]
				user.inputs.readPos = snapshot.readInt
		
	private replay: int from, int to
		replayTime = Time.measure
			frame = replayFrom = from
			while frame < to
				step fastForward:true, draw:false			
			
	// This is called at the beginning of each step
	private checkSaveState
		if enabledMilestones and input.isCertain and frame > 0 and frame % milestoneInterval == 0
			Buffer buffer = {}
			saveState buffer
			int milestoneIndex = math.floor(frame / milestoneInterval) - 1
			milestones[milestoneIndex] = buffer
			watch "Milestone {milestoneIndex}"
			
		if (mode == Connected or simulateRollback) and snapshotFrame == -1 and frame >= nextSnapshotFrame
			snapshotFrame = frame
			saveState snapshot
			
	string[] serializeLogs
			
	private saveState: Buffer snapshot
		snapshot.reset
		saveTime = Time.measure
			Snapshot.serialize snapshot
			if Platform.logSerialize
				serializeLogs[frame % 100] = Snapshot.serializeLog
				
		// To check if serialization works consistently, deserialize, serialize a second snapshot and compare it with the first
		if simulateRollback
			Snapshot.deserialize snapshot
			Snapshot.serialize secondSnapshotForTesting
			if(snapshot != secondSnapshotForTesting)
				onError {"Inconsistent serialization"}
												
		snapshot.writeInt input.internalUsers.length
		for input.internalUsers
			snapshot.writeInt .inputs.readPos
				
		// Checksum
		if players.length >= 2 and input.isCertain
			float myChecksum = snapshot.checksum
			float theirChecksum = checksums[frame]
			if verbose: core.log "<{input.localUser.id}*> #{frame} {myChecksum} writePos:{snapshot.writePos}"
			if !theirChecksum                             checksums[frame] = myChecksum; else
			if !theirChecksum.isApproximately(myChecksum) onWrongChecksum frame, mine:myChecksum theirs:theirChecksum
			lastChecksumFrame = frame
				
	inline js int currentTime := Date.now()
	
	js void startApp
		lobby.inLobby = false
		if(app.start) app.start()
		
	private adjustStartTime
		startTime = math.round(currentTime - frame*frameTime - (frameTime*.5))
		
	adjustStartTimeIfNeeded
		if Platform.mode < Play: adjustStartTime
			
	Buffer snapshotBuffer = {}
	Buffer eventStreamSnapshotBuffer = {}
		
	saveEventStreamAndLogs
		if input.isCertain
			saveEventStream
			Platform.delay 1 seconds
				saveLogs
			
	internal saveLogs
		// Ensure that current eventLog is added to the table even if we haven't processed a single frame
		file.saveText "{input.localUser.id} {Platform.appName} {Date.now.invariantDayMonthYearHourMinuteSecondString} v{Platform.buildVersion}.csv", logs
			
	saveEventStream
		Buffer buffer = {}
		buffer.writeInt eventStreamVersion
		
		eventStreamSnapshotBuffer.reset
		Snapshot.serialize eventStreamSnapshotBuffer
		buffer.writeBuffer eventStreamSnapshotBuffer
		
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
			
		buffer.writeInt milestones.length
		for milestones
			buffer.writeBuffer .
			
		let date = Date.now
		file.saveBinary "{Platform.appName} {date.dayShortMonthNameYearString} {date.hourMinuteSecondString} v{Platform.buildVersion}.state", buffer
		
	const chunkSize = 256
	
	storeRoomToDB
		roomStore.put {
			id: roomId
			frame
			frames
			eventStreamVersion
			math.randomSeed
			startInLobby
			Platform.isStaging
			localUserId: input.localUser.id
		}
	
	storeInputsToDB: InternalUser user
		let inputs = user.inputs
		if inputs.writePos > user.storedInputsUpTo
			// let chunkStart = math.floor(inputs.writePos / chunkSize) * chunkSize
			let start = inputs.writePos - (inputs.writePos % chunkSize)
			let id = "{roomId}-{user.id}-{start}"
			print "[{frame}] <{user.id}> Storing inputs {id} ({start} to {inputs.writePos})"
			inputStore.put {id, roomId, userId:user.id, start, inputs:inputs.subArrayBuffer(start to inputs.writePos)}
				print "[{frame}] <{user.id}> Storing inputs successful"
			else
				print "[{frame}] <{user.id}> Storing inputs failed"
			user.storedInputsUpTo = inputs.writePos
			
	openFromDB
		await IndexedDB.start Platform.isStaging ? "up4playing-{localUserId}" : "up4playing", version:2
		
		let room = await roomStore.get roomId
		int targetFrame = room.frame - 1
		frames = room.frames
		let randomSeed = room.randomSeed
		startInLobby = room.startInLobby
		Platform.isStaging = room.isStaging
		localUserId = room.localUserId
		
		print "#database opening from db {object.toJson room}"
		let result = await inputStore.getAllFromIndex "roomId", roomId
		result.orderBy.start
		for result
			int userId = .userId
			int start = .start
			any inputs = .inputs
			let user = input.internalUsers[.userId] ?= {id:.userId, local:.userId == localUserId, collectInputs:true}
			if user.local
				input.localUser = user
			user.inputs.insertArrayBuffer .inputs
			print "#database", userId, start, inputs.toString()
		print "#database", input.localUser.inputs.toString
			
		// Replay
		for input.internalUsers if .
			.startInputFrame frames
		math.setRandomSeed randomSeed
		replay 0 to targetFrame
	
	openState
		file.openBinary
			int version = buffer.readInt
			Buffer finalSnapshot = {}
			buffer.readBuffer finalSnapshot
			input.handleSetState finalSnapshot
						
	openEventStream
		Platform.pause
		file.openBinary
			// Read event stream
			int version = buffer.readInt
			
			if version >= 2
				Buffer finalSnapshot = {}
				buffer.readBuffer finalSnapshot
			
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
			
			if version >= 2
				milestones.clear
				let milestoneCount = buffer.readInt
				for milestoneCount
					Buffer milestone = {}
					buffer.readBuffer milestone
					milestones.add milestone
				
			// Replay
			for input.internalUsers if .
				.collectInputs = true
				if Platform.isDebug: .local = true
				.startInputFrame frames
			math.setRandomSeed randomSeed
			
			if Platform.isDebug: Platform.sendClearTimeline
			frame = int.maxValue
			goToFrame targetFrame
			if Platform.isDebug: Platform.sendFrame(targetFrame, frames)
		
	string roomString
	int roomId
	string gameId
	int localUserId
	
	join: string gameId, string roomString, int userId
		statistics.scheduleSendIn 30 seconds
		isPremiere = true
		initAll
		log "{Platform.url}"
		log "{Date.realtime.dayMonthYearHourMinuteSecondString} v{Platform.buildVersion}"
		log "{Platform.userAgent}"
		startInLobby = true
		this.gameId = gameId
		this.roomString = roomString
		this.roomId = cast roomString
		this.localUserId = userId
		this.frame = 0
		this.frames = 0
		try
			await openFromDB
		catch 
			input.localUser = {this.localUserId, local:true, connected:true, connectionId:0}
		await PeerNetwork.setupLocalMedia 
			enableVideo:not Platform.isStaging || core.enableVideoForStaging
			enableAudio:not Platform.isStaging || core.enableAudioForStaging
		ServerNetwork.setup
		lobby.enableFullscreen = !Platform.isStaging
		
	private js void initAll
		init()
		graphics.updateBaseMatrix();
		
	internal storeUserId
		Platform.setLocalStorageObject "room"+roomId, RoomInfo(currentTime, input.localUser.id)
		
	string snapshotLogWithWrongChecksum
		
	onWrongChecksum: int frame, float mine, float theirs
		string message = " Out of sync. frame:{frame} mine:{mine} theirs:{theirs}"
		string serializeLog = serializeLogs[frame % 100]
		core.log message
		if not snapshotLogWithWrongChecksum
			snapshotLogWithWrongChecksum = "frame:{frame} mine:{mine} theirs:{theirs}\n{serializeLog}"
			core.log "\n{serializeLog}"
			// file.saveText "{input.localUser.id}-snapshot{frame}.json", serializeLog
		onError {message}
		
	onError: Error error
		errorMessage = error.stack
		log "{errorMessage}"
		Platform.sendErrorToEditor error
		
internal transient unit Snapshot
	int autoSaveCount
	int lastSnapshotSize
	
	Buffer snapshots = {}
	int[] snapshotStarts
	int snapshotEvery = 100
	
	private bool autoSaveAtEndOfStep
	
	inline js string serialize(Buffer buffer) serialize_internal(buffer)
	inline js void deserialize(Buffer buffer) deserialize_internal(buffer)
	inline js string serializeLog() _serializeLog
		
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
	
	
global transient unit System
	// Reset all variables to their initial value and restart the app
	global inline restart() core.restart
		
	global inline refresh()
		
	// Prints a message to the console
	global js void print: logstring text // The text, variables or expressions to print
		                  SourceCodeLocation location
		// (location ? log(text, location.start, location.file) : log(text))
		core.log(text);
		if(Platform.isDebug) {
			var stringValue = typeof text === "string" ? text : JSON.stringify(text);
			if(stringValue) _sendToEditor({type:"log", value:stringValue, location:location ? location.start : 0, file:location ? location.file: ""});
		}

internal class StatisticsGraph
	int userIndex = -1
	int set
	string label = null
	float[] values
	Color color
	
	float[] recentValues
	float[] valuesToSend
	int sendingUntil
	int successfullySentUntil
	
	float lastValue := values.length > 0 ? values[values.length-1] : 0
	
	add: float value
		recentValues.add value
		if recentValues.length >= statistics.framesPerValue
			values.add recentValues.max .
			recentValues.clear

	addDirectly: float value
		values.add value
			
internal immutable StatisticsInfo
	float value
	int index
	int frame
				
skipInit transient unit statistics
	const Vector2 margin = {224,126}
	const Vector2 position = {-960, 540}
	const Vector2 size = {1920+margin.x, margin.y}
	const framesPerValue = 15
	
	float[] serverPings
	int successfullySentServerPings
	
	private StatisticsGraph[] graphs
	
	string[] systemLogs
	private dynamic[] gameLogs
	int successfullySentGameLogs
	int successfullySentSystemLogs
	
	Time startTime, loadTime, cameraTime, connectTime
	internal float maxValue
	int currentSet
	int sets = 1
	int id
	
	private StatisticsInfo[] infos
	private string[] infoNames
	private bool currentlySendingStatistics
	
	bool sessionStarted
	Time nextSendTime = Time.maxValue
	
	scheduleSendIn: Time delay
		nextSendTime = math.min(nextSendTime, Time.realTime + delay)
	
	tick
		if Time.realTime > nextSendTime
			if not sessionStarted: startSession
			else                   saveStatistics
			nextSendTime = Time.realTime + core.sendStatisticsEvery
	
	// Log game events (like scores, playtimes, etc)
	log: any value
		value.frame = Time.frame
		this.gameLogs.add value
	
	private startSession
		core.log "#statistics Start Session"
		if currentlySendingStatistics: return
		currentlySendingStatistics = true
		
		let user = storage.getObjectDirectly("user")
		let server = Platform.hostname.getUntil(".")
		let userId = input.localUser.id
		id = core.roomId*100 + userId
		int sendingSystemLogsUntil = systemLogs.length

		http.postDirectly "{Platform.protocolAndHost}:3114/startSession", body:{
			id
			gameId: core.gameId
			roomId: core.roomId
			userId
			userIndex: input.localUser.index
			userEmail: user.email
			version: Platform.buildVersion
			staging: Platform.isStaging
			server
			times: [ loadTime, connectTime, cameraTime ]
			systemLogs: systemLogs[successfullySentSystemLogs..]
		}
			successfullySentSystemLogs = sendingSystemLogsUntil
			currentlySendingStatistics = false
			sessionStarted = true
		else
			currentlySendingStatistics = false
	
	private saveStatistics
		core.log "#statistics Send Statistics"
		if currentlySendingStatistics: return
		currentlySendingStatistics = true
		
		// Compile server and peer pings to send
		string[] connections
		for players -> p
			let internalUser = input.internalUsers[.id]
			connections.add internalUser.connectionType
			
		for graphs
			.valuesToSend = .values[.successfullySentUntil..]
			.sendingUntil = .values.length

		int sendingServerPingsUntil = serverPings.length
		int sendingSystemLogsUntil = systemLogs.length
		int sendingGameLogsUntil = gameLogs.length
			
		// Send statistics to server
		http.postDirectly "{Platform.protocolAndHost}:3114/saveStatistics", body:{
			id
			connections
			graphLabels: graphs.select.label
			graphs: graphs.select.valuesToSend
			serverPings: serverPings[successfullySentServerPings..]
			systemLogs: systemLogs[successfullySentSystemLogs..]
			gameLogs: gameLogs[successfullySentGameLogs..]
		}
			graphs.each.successfullySentUntil = .sendingUntil
			successfullySentServerPings = sendingServerPingsUntil
			successfullySentSystemLogs = sendingSystemLogsUntil
			successfullySentGameLogs = sendingGameLogsUntil
			currentlySendingStatistics = false
		else
			currentlySendingStatistics = false
						
	add: string label, int userIndex = -1, float value, Color color = White, int set = 0, isPerFrame = true
		if userIndex != -1: label += " #{userIndex}"
		var s = graphs.find.label == label
		if !s
			graphs.add s = {label, userIndex, color, set}
			sets assignIfGreater set+1
		s.color = color
		if isPerFrame: s.add value
		else           s.addDirectly value

	addInfo: string name, float value
		int index = infoNames.indexOf name
		if index == -1: index = infoNames.length; infoNames.add name
		infos.add {value, index, frame:core.frame}
		
	internal tickGraph
		input.onTouchDown position, size, align:Left, valign:Top
			currentSet incrementAndWrap sets
	
		maxValue = 12
		for graphs -> s
			if .set != currentSet: continue
			int len = math.min(.values.length, 50)
			for len: 
				let value = s.values[s.values.length-1-i]
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
					input.onKeyDown by:player
						if (posForPlayer[player.index] += 2) > 1080
							posForPlayer[player.index] -= 1080
				
		draw
				
	private getHeightForFrame: int frame
		return (50+frame-core.frame)*20

global skipInit unit math
	init
		initDefaultRandomGenerator
		
	js void initDefaultRandomGenerator
		math.randomGenerator = Math.random
		
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
		math.randomSeed = seed
		math.randomValues.length = 0
		math.randomValueIndex = 0
		
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
		
		math.randomGenerator = function() {
			let value
			if(math.randomValueIndex < math.randomValues.length) {
				value = math.randomValues[math.randomValueIndex]
				math.randomValueIndex++
			} else {
				value = rand()
				math.randomValues[math.randomValueIndex++] = value;
			}
			return value
		}

	// Generates a random integer
	global js int randomInteger: int from // The inclusive lower bound of the random integer
		                         int to // The exclusive upper bound of the random integer
		return from + Math.floor(math.randomGenerator() * (to-from))
	
	global js int randomInteger: int to = 2147483647 // The exclusive upper bound of the random integer
		return Math.floor(math.randomGenerator() * to)
	
	// Generates a random float
	global js int randomFloat: float from
		                       float to
		return from + math.randomGenerator() * (to-from)
	
	global js int randomFloat: float to = 1.0
		return math.randomGenerator() * to
	

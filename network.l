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
	
	// Logs
	string logTable = "frame,id 0,lagFrom 0,lagTo 0,interval 0,id 1,lagFrom 1,lagTo 1,interval 1,id 2,lagFrom 2,lagTo 2,interval 2,messageSize,now,animTime,networkTime,tickTime,drawTime,iteration,restoreTime,replayFrames,replayTime,saveTime,pingPong,user0,user1,user2,received,uncertain,offset,ahead,avarage,percentile,certainFrame,buffer,checksums,events,send,receive,write,parse,touch\n"
	public string eventLog = ""; sentLog = "", receivedLog="", writeLog="", parseLog = "", touchLog = "", checksumLog = "", debugString = ""
	private float lastNetworkFrame, lastAnimationFrame, drawTime, tickTime, restoreTime, replayTime, saveTime
	private int replayFrames
	private string connectionType
	private float lastPingPongTime
	private InternalUser master
	
	internal const targetFps = 30
	private const bufferFrames = 1
	const targetFrameTime = 1000/targetFps
	
	NetworkMode mode
	public bool simulateConnection = true
	
	int userId = -1       // The userId stays the same when a user reconnects
	visible int connectionId = -1 // The connectionId increments with every connection, lowest connectionId means oldest user
	
	visible string error
	visible string errorMessage
	
	private object localVideoStream
	public object localVideoElement
	private Vector2 localVideoPos
	private float localVideoWidth = 440
	
	public float startTime
	
	visible int frame               // Current frame, will increase by 1 at the end of every step (every targetFrameTime ms)
	private int frames              // Total number of frames we have inputs for
	public int receivedFrames      // We received all remote inputs up to this frame (lowest of all user frames)
	private int uncertainFrame = -1 // The first frame where we don't have inputs from all players
	public int certainFrame        // The last frame where we have inputs from all players
	private Buffer commonState      // A snapshot taken before the first uncertain frame
	
	internal int frameWithNewWatches = 0 // First frame with new watches, do not send watches for frames below this
		
	public  float[] checksums
	private bool alertShown
	private int nextReconnect
	bool isLocalhost
	private bool startInLobby
	private int ahead
	private int[] aheads
	private Buffer sendBuffer
	private int tickMessageSize

	init
		Platform.showDebugInfo = isLocalhost = Platform.url.contains("localhost")
		
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
		error = ""
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
			if mode == Reconnecting: reconnect
			else                     lobby.tick
			updateVideoScreen
			graphics.finishFrame
			return
			
		if mode == Reconnecting
			reconnect
			return
			
		// Ahead
		float aheadAverage
		int aheadPercentile
		let localPlayer = Input.internalUsers[userId]
		if mode == Connected and Input.users.length > 1
			ahead = frame - receivedFrames
			aheads.add ahead, maxLength:100
			aheadAverage = aheads.average
			aheadPercentile = smoothStrength ? aheads.percentile(smoothStrength).limit(0, 50) : 0
		
		let targetFrame = Math.floor((now - startTime)/targetFrameTime)+1
		let frameMinusOffset = targetFrame - aheadPercentile
		certainFrame = mode == Connected ? Math.min(frameMinusOffset, receivedFrames) : int.maxValue

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
							logTable += ",{user.id},{user.lagFrom},{user.lagTo},{user.sendInterval}"
						else
							logTable += ",,,,"
							
					logTable += ",{tickMessageSize},{now},{now - lastAnimationFrame},{now - lastNetworkFrame},{tickTime.format(fractionDigits:2)},{drawTime.format(fractionDigits:2)},{frame-startFrame}"
					logTable += ",{restoreTime.format(fractionDigits:2)},{replayFrames},{replayTime.format(fractionDigits:2)},{saveTime.format(fractionDigits:2)},{lastPingPongTime}"
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
					debugString = "v{Platform.version} #{frame-1} ct:{connectionType} av:{aheadAverage.format(fractionDigits:1)}"
					for user -> Input.internalUsers
						if . and !.local
							debugString += " <{.id}> {.lagFrom}/{.lagTo} -> {.sendInterval}"
					
				eventLog = ""; sentLog = ""; receivedLog = ""; writeLog = ""; parseLog = ""; touchLog = ""; checksumLog = ""
				lastPingPongTime = 0; tickMessageSize = 0
				
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
				if isCertain
					float myChecksum = Framework.checksum					
					float theirChecksum = checksums[frame]
					checksumLog += " <> #{frame} {myChecksum}"
					if !theirChecksum
						checksums[frame] = myChecksum
					else
					if !theirChecksum.isApproximately(myChecksum)
						onWrongChecksum mine:myChecksum theirs:theirChecksum
						
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
		updateVideoScreen
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
		drawText debugString, {0, 528}
		if Input.internalUsers.any . and .sendInterval > 1: drawCircle {920, 496}, fillColor:Red
		drawTime = Time.measure
			graphics.finishFrame
		
	// Send inputs to other user. This is called in animationFrame.
	private sendInputs: int inputFrame, float aheadAverage
		let localPlayer = Input.internalUsers[userId]
		let inputs = localPlayer.inputs
		for c -> connections
			if c.state == Connected
				let receiver = Input.internalUsers[c.userId]
				receiver.sendInterval = receiver.lagFrom < 15 and receiver.lagTo < 15 ? 1 : 60
				
				if (inputFrame % receiver.sendInterval) == 0
					sendBuffer.reset
					sendBuffer.writeInt8 cast NetworkMessageType.Tick
					sendBuffer.writeInt32 inputFrame        // You got all inputs up to and including this frame
					sendBuffer.writeInt32 receiver.lagFrom  // TEMP for testing
					sendBuffer.writeBuffer inputs, receiver.inputsSentPos, inputs.writePos - receiver.inputsSentPos
					send c, sendBuffer
					
					sentLog += " #{inputFrame} to:{c.userId} lag:{receiver.lagFrom} {receiver.inputsSentPos}->{inputs.writePos} {inputs.toRangeString(receiver.inputsSentPos, inputs.writePos)}"
					receiver.inputsSentPos = inputs.writePos
					tickMessageSize = sendBuffer.writePos

	private onTickMessage: Connection c, Buffer buffer
		let sender = Input.internalUsers[c.userId]
		if c.state != Connected: c.state = sender.state = Connected
		let prevWritePos = sender.inputs.writePos
		
		sender.inputFrame = buffer.readInt32
		sender.lagTo = buffer.readInt32
		buffer.readBuffer sender.inputs, prevWritePos
		
		receivedFrames = getReceivedInputFrames
		sender.lagFrom = frame - sender.inputFrame
		
		receivedLog += " [{currentTime}] <{c.userId}> #{sender.inputFrame} lag:{sender.lagTo} {prevWritePos}->{sender.inputs.writePos} {sender.inputs.toRangeString(prevWritePos, sender.inputs.writePos)}"
		
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
		
	// Calculate the frame we received all remote inputs for.
	// The lowest of all user frames. Called in onTickMessage.
	private getReceivedInputFrames
		int minFrames = -1
		for user -> Input.internalUsers
			if user && user.state == Connected && !user.local && (minFrames == -1 || user.inputFrame < minFrames)
				minFrames = user.inputFrame
		return minFrames
	
	private onWrongChecksum: float mine, float theirs
		errorMessage = "Checksum mismatch"
		checksumLog += " MISMATCH mine:{mine} theirs:{theirs}"
		
		if !alertShown
			alert "Clients out of sync. Please send me the log file that will be created."
			saveLogs
			alertShown = true
			
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
		
	private float nextPingTime
	private int pongCount
	
	private onConnectedToPeer: Connection connection
		                       bool isNewUser // Did this user just join the already exiting users (and make the offer)
		
		let user = Input.internalUsers[connection.userId]
		// if mode == Reconnecting && user && user.acknowledgedPos > 0
		// 	mode = Connected
		// 	connection.state = user.state = Connected
		// 	log "Both users were already connected before", connection.userId, userId, mode, connection.state
		// else
		if isNewUser
			// New users will send out ping messages to sync the startTime (and this way also the current frame)
			mode = Ping
			nextPingTime = currentTime + 100
			pongCount = 0
			connection.state = user.state = PingPong
			log "New user, starting to ping", connection.userId, userId, mode, connection.state
		else
			// Existing users will wait for the new user to finish pinging
			// to prevent sending the large initial message several times
			if mode == Reconnecting: mode = Connected
			connection.state = user.state = PingPong
			log "Answering user, waiting for ping", connection.userId, userId, mode, connection.state
		
		log connection.userId, isNewUser, mode, connection.state
		
	private onDisconnectFromPeer: Connection connection
		log "onDisconnectFromPeer userId:"+connection.userId
		closeConnection connection
		let connectedUser = Input.internalUsers[connection.userId]
		connection.state = connectedUser.state = Disconnected
		
		// Write "lost" event to tell everybody that we lost the connection to this user
		let user = Input.internalUsers[userId]
		int frame = Math.floor((currentTime - this.startTime)/targetFrameTime)
		user.inputs.writeInt32 frame
		user.inputs.writeInt16 cast InputType.Lost
		user.inputs.writeInt16 connection.userId

	private js void closeConnection: Connection connection
		Network_removeVideoElement(connection.userId)
		
		if(connection.dataChannel) {
			Network_log("closeConnection: dataChannel")
			connection.dataChannel.close();
			connection.dataChannel = null;
		}
		if(connection.peerConnection) {
			Network_log("closeConnection: peerConnection")
			connection.peerConnection.close();
			connection.peerConnection = null;
		}
		
	private reconnect
		// if currentTime >= nextReconnect
		// 	if(socket)
		// 		log "Existing socket -> resending offers"
		// 		resendOffers
		// 	else
		// 		log "No existing socket -> reconnecting to server"
		// 		join gameId, roomId, userId
		// 	nextReconnect = currentTime + 6000
	
	string roomString
	int roomId
	string gameId
	private Connection[] connections
	
	js void join: string gameId, string roomString, int userId
		init()
		Network_startInLobby = true
		Network_gameId = gameId
		Network_roomString = roomString
		Network_userId = userId
		Network_log("Network.join "+location.href)
		await Network_setupLocalVideo()
		ServerNetwork_setup();
		
	private storeUserId
		Platform.setLocalStorageObject "room"+roomId, RoomInfo(currentTime, userId)
				
	private resendOffers
		Partner[] partners
		for c -> connections
			if c: log "Connection "+c.userId+" state:"+c.state+" offerByMe:"+c.offerByMe
			else  log "Connection null"
			if c && (c.state == Disconnected || c.state == Reconnecting) && c.offerByMe
				partners.add {c.userId, Input.internalUsers[c.userId]?.connectionId}
		log "Resending offers", userId, partners
		createOffers partners	
	
	private onSignal: SignalMessage message
		log "on signal: "+message.signal.type+" "+message.senderId+" -> "+message.signal.receiverId
		if message.signal.type == "offer":  onReceivedOffer message.senderId, message.signal; else
		if message.signal.type == "answer": onReceivedAnswer message.senderId, message.signal
	
	private js object setupPeerConnection: Connection c
		let peerConnection = new RTCPeerConnection({
			// Set the ice transport policy to "relay" to test a turn server
			// iceTransportPolicy: "relay",
			// iceTransportPolicy: "all",
			iceServers: [
			{
				urls: [
					'stun:stun1.l.google.com:19302',
					'stun:stun2.l.google.com:19302',
				],
			},{
				urls: 'turn:81.169.197.127',
				username: 'app',
				credential: 'cyancircle'
			}
			],
			// iceCandidatePoolSize: 10,
		})
		
		// Event handlers
		peerConnection.onconnectionstatechange = e => {
			Network_log("onconnectionstatechange " + peerConnection.connectionState)
			if(peerConnection.connectionState == "disconnected")
				Network_onDisconnectFromPeer(c)
		}
		
		peerConnection.onicecandidate = async event => {
			if (event.candidate)
				Network_sendToServer(new IceMessage(Network_userId, c.userId, event.candidate))
			else
				Network_log('Got final candidate!');
		}
		return peerConnection
	
	private Connection createConnection: int partnerId, int connectionId, bool offerByMe
		let user = Input.internalUsers[partnerId] || (Input.internalUsers[partnerId] = {id:partnerId, local:false})
		let existingConnection = connections.find.userId == partnerId
			log "removing existing connections", partnerId
			closeConnection existingConnection
			connections.removeAllWhere.userId == partnerId
		
		let connection = Connection(partnerId)
		connections.add connection
		connection.state = user.state = Connecting
		connection.peerConnection = setupPeerConnection(connection)
		connection.offerByMe = offerByMe
		user.connectionId = connectionId
		log partnerId, connectionId, offerByMe, connection.state, connection.dataChannel
		return connection
		
	private js void createOffers: Partner[] partners
		let offers = [];
		
		for(let partner of partners) {
			try {
				// Tell the other users whether we are are reconnecting and already have inputs from them
				// or whether they need to send their past inputs to us
				let partnerId = partner.userId
				let existingUser = Input_internalUsers[partnerId]
				
				// Peer connection
				let connection = Network_createConnection(partnerId, partner.connectionId, /*offerByMe*/true)
				let peerConnection = connection.peerConnection
				Network_log("createOffers: Created peer connection for partner "+partnerId)
				
				// Create reliable data channel
				// These options would create an unreliable one: {ordered:false, maxRetransmits:0}
				let dataChannel = peerConnection.createDataChannel("channel")
				dataChannel.binaryType = "arraybuffer"
				connection.dataChannel = dataChannel
				dataChannel.onopen = e => {
					Network_log("createOffer: connection opened!")
					Network_logConnectionType(peerConnection);
					Network_onConnectedToPeer(connection, /*isNewUser*/true);
				}
				dataChannel.onerror = e => Network_log("DataChannel error: ", e)
				dataChannel.onclose = e => Network_log("DataChannel close: ", e)
				dataChannel.onclosing = e => {
					Network_log("DataChannel closing: ", e)
					Network_onDisconnectFromPeer(connection)
				}
				dataChannel.onmessage = e => {
					Network_onPeerMessage(connection, new Buffer(e.data, 0, 0, 0))
				}
				
				// Video
				Network_setupRemoteVideo(partnerId, peerConnection)
				
				// Offer
				let offer = await peerConnection.createOffer();
				await peerConnection.setLocalDescription(offer);
				offers.push({receiverId:partnerId, type: "offer", sdp: peerConnection.localDescription.sdp, connectionId:Network_connectionId })
				Network_log("createOffers: Created and sent offer, waiting for answer. partnerId:"+partnerId);
			}
			catch(e) {
				console.error(e);
				Network_log(e.stack);
			}
		}
		if(offers.length) Network_sendToServer(new OffersMessage(Network_userId, offers));
		
	private js void onReceivedOffer: int partnerId, Signal offer
		try {
			// Peer connection
			let connection = Network_createConnection(partnerId, offer.connectionId, /*offerByMe*/false)
			let peerConnection = connection.peerConnection
			
			// Data channel
			peerConnection.addEventListener('datachannel', e => {
				Network_log("onReceivedOffer: received datachannel")
				let dataChannel = e.channel
				dataChannel.binaryType = "arraybuffer"
				connection.dataChannel = dataChannel
				dataChannel.onopen = e => {
					Network_log("onReceivedOffer: connection opened!")
					Network_logConnectionType(peerConnection);
					Network_onConnectedToPeer(connection, /*isNewUser*/false);
				}
				dataChannel.onerror = e => Network_log("DataChannel error: ", e)
				dataChannel.onclose = e => Network_log("DataChannel close: ", e)
				dataChannel.onclosing = e => {
					Network_log("DataChannel closing: ", e)
					Network_onDisconnectFromPeer(connection)
				}
				dataChannel.onmessage = e => {
					Network_onPeerMessage(connection, new Buffer(e.data, 0, 0, 0))
				}
			})
			Network_log("onReceivedOffer: data channel listeners")
						
			// Video
			Network_setupRemoteVideo(partnerId, peerConnection)
				
			// Answer
			await peerConnection.setRemoteDescription(new RTCSessionDescription(offer));
			let answer = await peerConnection.createAnswer();
			await peerConnection.setLocalDescription(answer);
			Network_sendToServer(new SignalMessage(Network_userId, {receiverId:partnerId, type: "answer", sdp: peerConnection.localDescription.sdp, connectionId:Network_connectionId }))
			Network_log("onReceivedOffer: Created and sent answer for "+partnerId+", received connectionId:"+offer.connectionId+" my connectionId:"+Network_connectionId+", waiting for connection")
		}
		catch(e) {
			console.error(e)
			Network_log(e.stack);
		}
	private js void onReceivedAnswer: int partnerId, Signal answer
		let connection = Network_connections.find(a => a.userId == partnerId)
		await connection.peerConnection.setRemoteDescription(new RTCSessionDescription(answer));
		Network_log("onReceivedAnswer: Received answer, set remote description")
		
	private js void onIce: IceMessage message
		let partnerId = message.senderId
		let connection = Network_connections.find(a => a.userId == partnerId)
		if(connection) {
			try {
				await connection.peerConnection.addIceCandidate(new RTCIceCandidate(message.iceCandidate));
			} catch(e) {
				Network_log("onIce failed " + e.message)
				Network_log(e.stack);
			}
		}
		
	private onPeerMessage: Connection c, Buffer buffer
		NetworkMessageType type = cast buffer.readInt8
		if type == Tick:         onTickMessage c, buffer; else
		if type == Ping:         onPingMessage c, buffer; else
		if type == Pong:         onPongMessage c, buffer; else
		if type == RequestState: onRequestState c, buffer; else
		if type == State:        onState c, buffer;
			
	private ping
		if (mode == Ping or mode == Connected) and currentTime >= nextPingTime
			master = Input.internalUsers.withMin.connectionId where . and (.state == Connected or .state == PingPong or .local)
			if master and (master.state == Connected or master.state == PingPong)
				let c = connections.find.userId == master.id
				sendPingMessage c, currentTime
				nextPingTime = currentTime + 2000
		
	private void sendPingMessage: Connection c, float pingTime
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Ping
		sendBuffer.writeFloat64 pingTime
		sendBuffer.writeInt32 certainFrame                    // The last certain frame with inputs from everybody
		sendBuffer.writeFloat64 checksums[certainFrame] || 0  // The checksum of the last certain frame
		
		send c, sendBuffer
			
	private onPingMessage: Connection c, Buffer buffer
		if c.state != Disconnected
			let pingTime = buffer.readFloat64
			
			// Checksum
			let checksumFor = buffer.readInt32
			let checksum = buffer.readFloat64
			checksumLog += " <{c.userId}> #{checksumFor} {checksum}"
			if checksum
				let myChecksum = checksums[checksumFor]
				if !myChecksum
					checksums[checksumFor] = checksum
				else
				if !myChecksum.isApproximately(checksum)
					onWrongChecksum mine:myChecksum theirs:checksum
			
			sendPongMessage c, currentTime-startTime, pingTime
		
	private void sendPongMessage: Connection c, float timeSinceStart, float pingTime
		log c.userId, c.state, timeSinceStart, pingTime, startTime
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Pong
		sendBuffer.writeFloat64 timeSinceStart		
		sendBuffer.writeFloat64 pingTime
		send c, sendBuffer

	private onPongMessage: Connection c, Buffer buffer
		float now = currentTime
		float timeSinceStart = buffer.readFloat64
		float pingTime = buffer.readFloat64
		float pingPongTime = now - pingTime
		if pingPongTime < c.fastestPingPongTime
			// Use the fastest ping-pong-time we have ever seen to calculate the start time
			c.fastestPingPongTime = pingPongTime
			startTime = Math.round(now - pingPongTime/2 - timeSinceStart)
			log "New fastest pingPongTime", c.userId, pongCount, pingPongTime, startTime
		else
			log c.userId, pongCount, pingPongTime, c.fastestPingPongTime, startTime
			
		pongCount++
		lastPingPongTime = pingPongTime
		
		// Finish pinging after the 20th pong
		if mode == Ping and pongCount >= 20 and c.fastestPingPongTime < 1000
			// Request the state from the user who has been here the longest (has the lowest connectionId)
			log "Ping-Pong complete", pongCount, c.fastestPingPongTime
			master = Input.internalUsers.withMin.connectionId where . and (.state == Connected or .state == PingPong or .local)
			let connection = connections.find.userId == master.id
				sendRequestState connection

		nextPingTime = now + (c.state == PingPong ? 100 : 3000)
		
	private sendRequestState: Connection to
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.RequestState
		send to, sendBuffer
		log "requesting state from {to.userId}"	
		
	private onRequestState: Connection c, Buffer buffer
		snapshotBuffer.reset
		Snapshot.serialize snapshotBuffer
		sendState c, snapshotBuffer
		
	private sendState: Connection to, Buffer buffer
		let localPlayer = Input.internalUsers[userId]
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.State
		sendBuffer.writeInt32 frame-1
		let userCount = Input.internalUsers.count . != null
		sendBuffer.writeInt32 userCount
		for Input.internalUsers
			if .
				sendBuffer.writeInt32 .id
				sendBuffer.writeInt32 .inputs.readPos
		sendBuffer.writeBuffer buffer
		send to, sendBuffer	
		log "sending state to {to.userId} frame:{frame-1} readPos:{localPlayer.inputs.readPos} size:{buffer.writePos}"	
		
	private onState: Connection c, Buffer buffer
		snapshotBuffer.reset
		let frame = buffer.readInt32
		let userCount = buffer.readInt32
		for userCount
			let id = buffer.readInt32
			let readPos = buffer.readInt32
			let user = Input.internalUsers[id]
				user.inputFrame = frame
				user.inputs.readPos = user.inputs.writePos = readPos
				log user.id, user.inputFrame, user.inputs.readPos
		buffer.readBuffer snapshotBuffer
		Snapshot.deserialize Network.snapshotBuffer
		Math.recreateRandomValues
		// int startFrame = Math.floor((currentTime - this.startTime)/targetFrameTime)+1
		// startConnected startFrame
		startConnected
		log "received state",c.userId, frame, snapshotBuffer.writePos, userCount
			
	private js void send: Connection connection, Buffer buffer
		connection.dataChannel.send(buffer.buffer)

	private js void setupLocalVideo: int userId
		if(Network_isLocalhost) return
		try {
			Network_localVideoStream = await navigator.mediaDevices.getUserMedia({video: true, audio: true});
			Network_localVideoElement = Network_createVideoElement(Network_localVideoStream, /*local*/true);
			Network_log("setupLocalVideo: success")
		} catch(error) {
			Network_log(error.message)
			if(error.name == "NotAllowedError") {
				Network_error = "To play with friends over a video call, you need to allow access to your webcam."
			} else {
				Network_error = "Can't access webcam. Please make sure it's not used by another application."
			}
			Network_errorMessage = error.message
			throw error
		}
			
	private js void setupRemoteVideo: int partnerId, object peerConnection
		if(Network_isLocalhost) return 
		for(let track of Network_localVideoStream.getTracks())
			peerConnection.addTrack(track, Network_localVideoStream);
		
		// TEMP logging
		Network_log("creating video for user "+partnerId)
		var remoteStream = new MediaStream();
		let internalUser = Input_internalUsers[partnerId];
		internalUser.videoElement = Network_createVideoElement(remoteStream, /*local*/false)
		
		peerConnection.addEventListener('track', event => {
			Network_log('Got remote track:', event.streams[0]);
			event.streams[0].getTracks().forEach(track => {
				Network_log('Add a track to the remoteStream:', track);
				remoteStream.addTrack(track);
			});
		});

	private js object createVideoElement: object stream, bool local
		let el = document.createElement('video')
		el.style = "position:absolute; top:0px; left:0px; z-index:10000; visibility:hidden; "+(local ? "transform: scaleX(-1)" : "")
		el.autoplay = true
		el.playsinline = true
		el.controls = false
		el.muted = local
		document.body.appendChild(el)
		el.srcObject = stream
		return el
		
	js void removeVideoElement: int userId
		let internalUser = Input_internalUsers[userId];
		if(internalUser?.videoElement) internalUser.videoElement.remove()
			
	setUserVideoAndColor: int userId = 0, Vector2 pos = {}, float width = 440, Color color = null
		let user = Input.usersById[userId]
			user.videoPosition = pos
			user.videoWidth = width
			user.color = color
			
	internal setLocalVideo: Vector2 pos={}, float width = 440
		// Set position and size of local video before we connected
		localVideoPos = pos
		localVideoWidth = width
		
	internal js void updateVideoScreen
		if(Network_mode == 2/*Local*/ || Network_isLocalhost) {
			for(let user of Input_users) {
				if(user && user.videoWidth) {
					graphics_drawImage(Image_VideoScreen, user.videoPosition, 0, user.videoWidth/440, -1, 1000000, 1.0)
				}
			}
		} else if(Input_users.length > 0) {
			// Set position and size of videos
			for(let user of Input_users) {
				if(user) {
					let internetUser = Input_internalUsers[user.id];
					let el = internetUser?.videoElement
					if(el) {
						let pixelPos = Input_logicalToPixelPosition(user.videoPosition)
						let pixelSizeX = user.videoWidth*graphics_totalMatrix.m0/Platform_pixelRatio
						let pixelSizeY = (user.videoWidth*3/4)*graphics_totalMatrix.m3/Platform_pixelRatio
						el.style.left = (pixelPos.x-pixelSizeX/2)+"px"
						el.style.top = (pixelPos.y-pixelSizeY/2)+"px"
						el.style.width = pixelSizeX+"px"
						el.style.height = pixelSizeY+"px"
						el.style.visibility = "visible"
					}
				}
			}
		} else if(Network_localVideoElement) {
			// Set position and size of local video before we connected
			let pixelPos = Input_logicalToPixelPosition(Network_localVideoPos)
			let pixelSizeX = Network_localVideoWidth*graphics_totalMatrix.m0/Platform_pixelRatio
			let pixelSizeY = (Network_localVideoWidth*3/4)*graphics_totalMatrix.m3/Platform_pixelRatio
			Network_localVideoElement.style.left = (pixelPos.x-pixelSizeX/2)+"px"
			Network_localVideoElement.style.top = (pixelPos.y-pixelSizeY/2)+"px"
			Network_localVideoElement.style.width = pixelSizeX+"px"
			Network_localVideoElement.style.height = pixelSizeY+"px"
			Network_localVideoElement.style.visibility = "visible"
		}
		
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
									
	private js void logConnectionType(object peerConnection)
		setTimeout(async () => {
			let stats = await peerConnection.getStats()
			let candidatePairs = [...stats.values()].filter(s => s.type == "candidate-pair" && s.state == "succeeded")
			let candidatePair = candidatePairs.find(a => a.selected) || candidatePairs[0]
			if(candidatePair) {
				let candidate = stats.get(candidatePair.localCandidateId);
				let ip = candidate.ip || candidate.address
				Network_connectionType = candidate.candidateType
				Network_log("Connection: " + Network_connectionType+" "+ip+" "+candidate)
			} else {
				window.stats = [...stats.values()]
				Network_log("Can't access stats", window.stats)
			}
		}, 5000)

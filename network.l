enum NetworkMessageType: Tick, Ping, Pong, OwnInputsAfterReconnect
enum ConnectionState: Disconnected, Reconnecting, WaitingForFirstTickMessage, Connected

transient class Connection
	int userId
	object peerConnection = null
	object dataChannel = null
	ConnectionState state
	bool offerByMe
	
enum NetworkMode: None, Ping, Local, Connected, Reconnecting
transient class HTMLVideoElement: int id
transient class RoomInfo: int time, userId
		
transient class VideoScreenInfo
	object videoElement = null
	float2 pos
	float width
	
transient unit Snapshot
	inline js void serialize(Buffer buffer) serialize(buffer)
	inline js void deserialize(Buffer buffer) deserialize(buffer)
		
	Buffer save
		Buffer buffer
		serialize(buffer)
		return buffer
		
	void restore: Buffer buffer
		deserialize(buffer)
	
transient class Buffer
	int readPos, writePos
	private object buffer = null
	private object dataView = null
	
	Buffer: object buffer = null
		    int size = 1024
		setup(size)
		
	private js void setup: int size = 1024
		if(!this.buffer) this.buffer = new ArrayBuffer(size)
		else             this.writePos = this.buffer.byteLength
		this.dataView = new DataView(this.buffer)
		
	canRead := readPos < writePos
	// setWritePos(int writePos) this.writePos = writePos
	// setReadPos(int readPos) this.readPos = readPos
	
	reset
		this.writePos = 0
		this.readPos = 0   
		
	js void expandBuffer: int size
		let prevLength = this.buffer.byteLength
		this.buffer = new ArrayBuffer(Math.max(prevLength * 2, size))
		let prevDataView = this.dataView
		let newDataView = new DataView(this.buffer)
		for(let i=0; i<prevLength; i+=2)
			newDataView.setInt16(i, prevDataView.getInt16(i))
		this.dataView = newDataView
		
	inline js void setInt16: int index, int value
		this.dataView.setInt16(index, value)
	
	js void writeInt8: int value
		if(this.writePos+1 > this.buffer.byteLength) this.expandBuffer((this.writePos+1)*2)
		this.dataView.setInt8(this.writePos, value)
		this.writePos += 1
	
	js void writeInt16: int value
		if(this.writePos+2 > this.buffer.byteLength) this.expandBuffer((this.writePos+2)*2)
		this.dataView.setInt16(this.writePos, value)
		this.writePos += 2
	
	js void writeInt32: int value
		if(this.writePos+4 > this.buffer.byteLength) this.expandBuffer((this.writePos+4)*2)
		this.dataView.setInt32(this.writePos, value)
		this.writePos += 4
	
	js void writeFloat64: float value
		if(this.writePos+8 > this.buffer.byteLength) this.expandBuffer((this.writePos+8)*2)
		this.dataView.setFloat64(this.writePos, value)
		this.writePos += 8
		
	js void writeBool: bool value
		if(this.writePos+1 > this.buffer.byteLength) this.expandBuffer((this.writePos+1)*2)
		this.dataView.setInt8(this.writePos, value ? 1 : 0)
		this.writePos += 1
		
	js void writeString: string value
		let len = value.length
		let size = 4+len*4
		if(this.writePos+size > this.buffer.byteLength) this.expandBuffer((this.writePos+size)*2)
		this.dataView.setInt32(this.writePos, len)
		this.writePos += 4
		for(let i=0; i<len; ++i) {
			this.dataView.setInt32(this.writePos, value.charCodeAt(i))
			this.writePos += 4
		}
	
	js void writeBuffer: Buffer source
		                 int start
		                 int length
		let readPos = start
		let writePos = this.writePos
		
		// Expand if neccessary
		if(writePos+length+4 > this.buffer.byteLength) this.expandBuffer((writePos+length+4)*2)
			
		// Write length
		this.dataView.setInt32(writePos, length)
		writePos += 4
		
		// Write bytes
		let readPosEnd = start + length
		while(readPos < readPosEnd)
			this.dataView.setUint8(writePos++, source.dataView.getUint8(readPos++))
			
		this.writePos = writePos
		
	inline js int peekInt8  := this.dataView.getInt8(this.readPos)
	inline js int peekInt16 := this.dataView.getInt16(this.readPos)
	inline js int peekInt32 := this.dataView.getInt32(this.readPos)
	
	js int readInt8
		return this.dataView.getInt8(this.readPos++)
		
	js int readInt16
		let value = this.dataView.getInt16(this.readPos)
		this.readPos += 2
		return value
		
	js int readInt32
		let value = this.dataView.getInt32(this.readPos)
		this.readPos += 4
		return value

	js float readFloat64
		let value = this.dataView.getFloat64(this.readPos)
		this.readPos += 8
		return value
		
	js bool readBool
		return this.dataView.getInt8(this.readPos++) != 0
		
	js string readString
		let value = ""
		let len = this.dataView.getInt32(this.readPos)
		this.readPos += 4
		for(let i=0; i<len; ++i) {
			value += String.fromCharCode(this.dataView.getInt32(this.readPos))
			this.readPos += 4
		}
		return value

	js int readBuffer: Buffer writeBuffer
		               int writeStart
		let readPos = this.readPos
		let writePos = writeStart
		
		// Read length
		let length = this.dataView.getInt32(readPos)
		readPos += 4
		
		// Expand writeBuffer if neccessary
		if(writeStart+length > writeBuffer.buffer.byteLength) writeBuffer.expandBuffer((writeStart+length)*2)
			
		// Read bytes
		let readPosEnd = readPos + length
		while(readPos < readPosEnd)
			writeBuffer.dataView.setUint8(writePos++, this.dataView.getUint8(readPos++))
			
		this.readPos = readPos
		return length
		
	js string toString
		let result = "readPos:" + this.readPos + " writePos:" + this.writePos
		for(let i=0; i<this.writePos; i ++)
			result += " " + this.dataView.getUint8(i)
		return result
		
	js string toRangeString: int start, int end
		let result = ""
		for(let i=start; i<end; i++)
			result += " " + this.dataView.getUint8(i)
		return result
		
transient unit Network
	// Logs
	string logTable = "frame,animTime,networkTime,tickTime,drawTime,iteration,restoreTime,replayFrames,replayTime,saveTime,user0,user1,user2,received,uncertain,ahead,avarage,checksums,events,send,receive,write,parse,touch\n"
	public string eventLog = ""; sentLog = "", receivedLog="", writeLog="", parseLog = "", touchLog = "", checksumLog = ""
	private float lastNetworkFrame, lastAnimationFrame, drawTime, tickTime, restoreTime, replayTime, saveTime
	private int replayFrames
	
	internal const targetFps = 30
	private const pingCount = 6
	private const bufferFrames = 2
	private const targetFrameTime = 1000/targetFps
	
	visible NetworkMode mode
	visible int userId = -1
	public bool simulateConnection = true
	
	private VideoScreenInfo[] videoScreens
	private object localVideo = null
	
	private float startTime
	private int startInputFrame
	
	visible int frame               // Will increase by 1 at the end of every step (so every targetFrameTime milliseconds)
	private int receivedFrames      // We received all remote inputs up to this frame (lowest of all user frames)
	private int uncertainFrame = -1 // The first frame that doesn't have inputs from all players
	private Buffer commonState      // A snapshot taken before the first uncertain frame
		
	private float[] checksums
	private bool alertShown
	private int nextReconnect
	private string randomSeed
	private bool isLocalhost
	private int[] aheads
		
	init
		isLocalhost = Platform.url.contains("localhost")

	private startConnected: float startTime = 0
		if mode == Connected: return
		if startTime
			this.startTime = startTime
		else
			resetStartTime
		let user = Input.internalUsers[userId]
		user.startInputFrame 0
		
		int joinFrame = Math.floor(currentTime - this.startTime)/targetFrameTime
		InputType type = Join
		user.inputs.writeInt32 joinFrame
		user.inputs.writeInt16 cast type
		user.collectInputs = true
		
		mode = Connected
		receivedFrames = -1
		log "Connected", userId, frame, startTime, this.startTime, receivedFrames
		saveState
		
	startLocal: userCount = 1
		userId = 0
		mode = Local
		Input.internalUsers.clear
		randomSeed = Math.generateRandomSeed
		Math.setRandomSeed randomSeed
		for userCount: Input.internalUsers.add {id:i, local:true}
		startTime = currentTime
		startApp
		animationFrame
			
	// AnimationFrame --> Step --> Tick

	// AnimationFrame  Send tick message, replay state, and call step
	// Step            Save state, parse inputs, process tick, and calculate checksum
	// Tick            Step physics, prepare graphics, process application tick, and draw all graphics
		
	// Send tick message, replay state, call step, and logging
	// This is called by the requestAnimationFrame callback.
	// We ensure that step is called every targetFrameTime milliseconds.
	internal animationFrame
		if mode == None || mode == Ping
			graphics.startFrame
			if mode == Ping: ping
			if mode == Reconnecting: reconnect
			else                     lobby.tick
			updateVideoScreen
			graphics.finishFrame
			return
			
		if mode == Reconnecting
			reconnect
			return
			
		let now = currentTime
		let localPlayer = Input.internalUsers[userId]
		let aheadAverage = aheads.average.limit(min:0).round
		let targetFrame = Math.floor((now - startTime)/targetFrameTime)+1
		let nextInputFrame = targetFrame + aheadAverage + bufferFrames
		
		if mode == Local && targetFrame > frame + targetFps*2
			// After a long pause in local mode, we do not want to process all missed frames, so we adjust the start time
			let prevTargetFrame = targetFrame
			targetFrame = frame
			startTime = now - targetFrame*targetFrameTime
			log "Paused {prevTargetFrame-frame} frames, adjusting startTime. prevTargetTime:{prevTargetFrame} frame:{frame} targetFrame:{Math.floor((now - startTime)/targetFrameTime)}"
		
		if frame < targetFrame
			let startFrame = frame
			
			// Send each user the inputs that they haven't acknowleged yet
			if mode == Connected
				for c -> connections
					if c.state == Connected
						let receiver = Input.internalUsers[c.userId]
						sendTickMessage
							to: c
							inputFrame: nextInputFrame            // You got all inputs up to and including this frame
							currentFrame: targetFrame-1           // The currently processed frame, used to calculate "ahead" 
							
							checksumFor: uncertainFrame-1         // The last certain frame with inputs from everybody
							checksum: checksums[uncertainFrame-1] // The checksum of the last certain frame
							
							acknowledgePos: receiver.inputs.writePos  // We ackledge that we received up to this input buffer pos
							
							buffer: localPlayer.inputs                // Send inputs that they haven't acknowleged yet
							start: receiver.acknowledgedPos
							end: localPlayer.inputs.writePos
							
			// Replay all frames from the first uncertain frame until the current frame
			// when we received all inputs for frames that we were uncertain about before
			replayState
					
			// Ensure that step is called every targetFrameTime milliseconds
			while frame < targetFrame
				// Step
				step fastFordward:frame < targetFrame-1
				
				// Logs
				logTable += "{frame-1},{now - lastAnimationFrame},{now - lastNetworkFrame},{tickTime},{drawTime},{frame-startFrame}"
				logTable += ",{restoreTime},{replayFrames},{replayTime},{saveTime}"
				logTable += ","+(Input.internalUsers[0] ? Input.internalUsers[0].inputFrame : 0)
				logTable += ","+(Input.internalUsers[1] ? Input.internalUsers[1].inputFrame : 0)
				logTable += ","+(Input.internalUsers[2] ? Input.internalUsers[2].inputFrame : 0)
				logTable += ",{receivedFrames},{uncertainFrame},{frame - receivedFrames},{aheadAverage}"
				logTable += ",\"{checksumLog.trim}\",\"{eventLog.trim}\",\"{sentLog.trim}\",\"{receivedLog.trim}\",\"{writeLog.trim}\",\"{parseLog.trim}\",\"{touchLog.trim}\"\n"
				eventLog = ""; sentLog = ""; receivedLog = ""; writeLog = ""; parseLog = ""; touchLog = ""; checksumLog = ""
				Platform.setTitle cast aheadAverage
				lastNetworkFrame = now
				
		localPlayer.startInputFrame nextInputFrame
		lastAnimationFrame = now
		
	// Save state, parse inputs, process tick, and calculate checksum
	// This is called in animationFrame and during replays. 
	// All steps except the very last of an animation frame are fast forwared, which means that nothing is drawn.
	// The frame is increment at the end of this function. This means that while processing the frame,
	// frame will point to the current frame. After processing, frame will point to the next frame.
	private step: bool fastFordward = false // If a step is fast forwarted nothing is drawn
		// Set time
		Time.now = frame * targetFrameTime
		Platform.fastForward = fastFordward
		
		// Log
		parseLog += " #{frame}"
		bool isCertain = receivedFrames >= frame
		if fastFordward: parseLog += "f"
		if isCertain: parseLog += "c"
			
		// Save a snapshot when we are about to start the frame after the last certain frame where we got all inputs
		saveState
		
		// Parse inputs
		Input.parseInputs(frame, isCertain)
		
		// Tick
		tick
		
		// Calculate checksum if we received all inputs for this frame
		if isCertain
			let myChecksum = 0
			for Framework.objects
				myChecksum += o.position.x + o.position.y + o.frame + cast o.side
				if o.type == Board
					Board board = cast o
					let m = board.matrix
					myChecksum += m.m0 + m.m1 + m.m2 + m.m3 + m.m4 + m.m5
					
			let theirChecksum = checksums[frame]
			checksumLog += " <mine> #{frame} {myChecksum}"
			if !theirChecksum
				checksums[frame] = myChecksum
			else
			if theirChecksum != myChecksum
				onWrongChecksum
				checksumLog += " MISMATCH saved theirs:{theirChecksum}"
		
		// Cleanup
		for user -> Input.internalUsers if user
			user.clearEvent
			
		frame++
		
	// Step physics, prepare graphics, process application tick, and draw all graphics
	// This is called in step.
	internal tick
		Physics.step
		graphics.startFrame
		updateVideoScreen
		drawFingers
		if lobby.inLobby
			lobby.tick
		else
			Framework.tick
			tickTime = Time.measure
				app.tick
			Input.updateCursor
		drawTime = Time.measure
			graphics.finishFrame
			
	// Save a snapshot when we are about to start the frame after the last certain frame 
	// where we received inputs from all users. This is called at the beginning of a step
	// before we start processing the frame.
	private saveState
		if mode != Connected: return
		if frame == receivedFrames+1
			for Input.internalUsers: uncertainReadPos = inputs.readPos
			parseLog += " [saveState] r0:{Input.internalUsers[0]?.inputs.readPos} r1:{Input.internalUsers[1]?.inputs.readPos} u0:{Input.internalUsers[0]?.uncertainReadPos} u1:{Input.internalUsers[1]?.uncertainReadPos}"
			uncertainFrame = frame
			saveTime = Time.measure
				Snapshot.serialize commonState
			log "Save angle:{Framework.objects.length ? Framework.objects[0].angle : 0}", lobby.inLobby, frame, Input.internalUsers[0]?.uncertainReadPos, Input.internalUsers[1]?.uncertainReadPos
	
	// Replay all frames from the first uncertain frame until the current frame
	// when we received all inputs for frames that we were uncertain about before.
	// This is called at the begining of animationFrame before we start stepping.
	private replayState
		if mode != Connected or Input.internalUsers.length == 1: return
		if uncertainFrame != -1 and receivedFrames >= uncertainFrame
			// Restore state
			for Input.internalUsers: inputs.readPos = uncertainReadPos
			restoreTime = Time.measure
				Snapshot.deserialize commonState
			log "Replay angle:{Framework.objects.length ? Framework.objects[0].angle : 0}", lobby.inLobby, frame, Input.internalUsers[0].inputs.readPos, Input.internalUsers[1].inputs.readPos, receivedFrames, uncertainFrame, frame
				
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
			if user && !user.local && (minFrames == -1 || user.inputFrame < minFrames)
				minFrames = user.inputFrame
		return minFrames
	
	private getReceivedCurrentFrames
		int minFrames = -1
		for user -> Input.internalUsers
			if user && !user.local && (minFrames == -1 || user.currentFrame < minFrames)
				minFrames = user.currentFrame
		return minFrames
	
	private onWrongChecksum
		log "%%% OUT OF SYNC %%%"
		Platform.setTitle "%%% OUT OF SYNC %%%"
		
		// if !alertShown
		// 	alert "Clients out of sync. Please click 'Save Logs' and send me the log file that will be created."
		// 	alertShown = true
			
	log: logstring text
		string str = text
		eventLog += str + "\n"
		
	inline js int currentTime := Date.now()
	
	js void startApp
		lobby_inLobby = false
		if(window.app_start) app_start()
		
	resetStartTime
		startTime = currentTime - frame*targetFrameTime// - (targetFrameTime-0.001)
		
	eventStreamSize
		string result
		for user -> Input.internalUsers
			if user
				if result: result += ", "
				result += user.inputs.writePos.formatWithSpaces
		return result
		
	object db = null
	
	js void openEventStream: void(EventStream eventStream) then, void() else
		var request = indexedDB.open("up4playing", 1)
		request.onupgradeneeded = e => {
			db = e.target.result;
			db.createObjectStore("eventstreams",{ keyPath: "url" });
		}
		request.onsuccess = e => {
			db = e.target.result;
			let trans = db.transaction("eventstreams", "readonly")
			let req = trans.objectStore("eventstreams").get(location.href)
			req.onsuccess = async e => {
				let eventStream = req.result
				if(eventStream) {
					for(let user of eventStream.internalUsers) {
						let arrayBuffer = await user.blob.arrayBuffer()
						user.inputs = new Buffer(arrayBuffer, 0, 0, 0)
					}
					then(eventStream)
				} @else {
					else()
				}
			}
			req.onerror = e => {
				else()
			}
		}
		
	save
		if Platform.fastForward: return
		saveLogs
		saveEventStream
		
	saveLogs
		Platform.createTextFile "log.csv", logTable
		Http.post "/saveLog/{gameId}/{roomId}/{userId}", logTable
			log "save logs"
		else
			print "save logs failed {error}"
		
	js void saveEventStream
		let trans = db.transaction("eventstreams", "readwrite")
		trans.onerror = e => {
			alert("error saveEventStream"+e)
		}
		let id = location.href
		let log = ""
		let users = []
		for(let i=0; i<Input_users.length; i++) {
			let user = Input_users[i]
			let dataView = new DataView(user.inputs.buffer, 0, user.inputs.writePos)
			users.push({
				id: user.id,
				local: user.local,
				frame: user.frame,
				blob: new Blob([dataView]),
				inputs: null
			})
			if(log) log += ", "
			log += user.id + ": " + user.inputs.writePos + " bytes"
		}
		let eventStream = {
			url: location.href,
			randomSeed: Network_randomSeed,
			users
		}
		trans.objectStore("eventstreams").put(eventStream).onsuccess = e => {
			alert("Saved game. "+log)
		}
		
	private float nextPingTime
	private float estimatedStartTimeTotal
	private int pongCount
	
	private onConnectedToPeer: Connection connection
		                       bool isNewUser // Did this user just join the already exiting users (and make the offer)
		
		let user = Input.internalUsers[connection.userId]
		if mode == Reconnecting && user && user.acknowledgedPos > 0
			mode = Connected
			connection.state = Connected
			log "Both users were already connected before", connection.userId, userId, mode, connection.state
		else
		if mode == None
			// New users will send out ping messages to sync the startTime (and this way also the current frame)
			mode = Ping
			nextPingTime = currentTime + 300
			estimatedStartTimeTotal = 0
			pongCount = 0
			connection.state = Connected
			log "New user, starting to ping", connection.userId, userId, mode, connection.state
		else
			// Existing users will wait for the new user to finish pinging
			// to prevent sending the large initial message several times
			if mode == Reconnecting: mode = Connected
			connection.state = WaitingForFirstTickMessage
			log "Answering user, waiting for ping", connection.userId, userId, mode, connection.state
		
		log connection.userId, isNewUser, mode, connection.state
		
	private onDisconnectFromPeer: Connection connection
		log "onDisconnectFromPeer userId:"+connection.userId
		closeConnection connection
		connection.state = Disconnected
		mode = Reconnecting
		nextReconnect = currentTime + 1000
		removeVideoElement connection.userId
		graphics.reset
		drawText "Connection lost. Trying to reconnect...", {0,-Platform.size.y/2+32}
		drawRectangle {0,-Platform.size.y/2+32}, {Platform.size.x, 64}, fillColor:{"900000"}
		graphics.finishFrame

	private js void closeConnection: Connection connection
		if(connection.peerConnection) {
			Network_log("closeConnection: peerConnection")
			connection.peerConnection.close();
			connection.peerConnection = null;
		}
		if(connection.dataChannel) {
			Network_log("closeConnection: dataChannel")
			connection.dataChannel.close();
			connection.dataChannel = null;
		}
		
	private reconnect
		if currentTime >= nextReconnect
			log "Trying to reconnect"
			join gameId, roomId
			nextReconnect = currentTime + 5000
	
	private ping
		if currentTime >= nextPingTime
			for c -> connections
				if c.state != Disconnected
					sendPingMessage c, currentTime
			nextPingTime = currentTime + 300
		
	private object socket = null
	private string roomId, gameId
	private Connection[] connections
	
	js void join: string gameId, string roomId
		Network_gameId = gameId
		Network_roomId = roomId
		Network_log("Network.join "+location.href)
		if(Network_isLocalhost) Network_socket = new WebSocket("ws://localhost:3111");
		else                    Network_socket = new WebSocket("wss://"+location.host+":3111");
		Network_socket.onopen = function() {
			log("Websocket open");
			Network_onConnectedToServer();
		}
		Network_socket.onmessage = function(event) {
			let message = JSON.parse(event.data);
			Network_onMessageFromServer(message);
		}
		Network_socket.onclose = function() {
			log("Websocket closed")
		}
		Network_socket.onerror = ex => {
			log(ex)
		}
		
	private onConnectedToServer
		// Disabled rejoining with the same id to support testing in two browser tabs
		// Is this still needed if we have an eventStream?
		// if userId == -1
		// 	RoomInfo roomInfo = cast Platform.getLocalStorageObject "room"+roomId
		// 	userId = roomInfo && roomInfo.time > currentTime - 3600000*24 ? roomInfo.userId : -1
		// 	log "Reconnect to session", roomInfo, userId
		
		openEventStream
			Math.setRandomSeed eventStream.randomSeed
			for eventStream.users
				Input.internalUsers.add {id:u.id, local:u.local, inputFrame:u.frame, inputs:u.inputs}
			userId = Input.internalUsers.find(local).id
			// receivedFrames = getReceivedFrames
			frame = receivedFrames
			// resetStartTime
			while frame < receivedFrames - 1
				step fastFordward:true
			step
			log "Opening saved eventstream", roomId, frame, eventStreamSize
			sendToServer JoinMessage roomId, userId, version:Platform.version
		else
			frame = 0
			log "onConnectedToServer {roomId} connect as user {userId}"
			sendToServer JoinMessage roomId, userId, version:Platform.version
		
	private onMessageFromServer: ServerMessage message
		if message.type == JoinResponseMessage: onJoinResponse cast message; else
		if message.type == SignalMessage: onSignal cast message; else
		if message.type == IceMessage: onIce cast message;
		
	private js void sendToServer: ServerMessage message
		try {
			let messageString = JSON.stringify(message)
			Network_socket.send(messageString)
		} catch(e) {
			Network_log(e)
		}
	
	private onJoinResponse: JoinResponseMessage message
		log "onJoinResponse", message.roomId, message.userId
		if mode == Reconnecting
			log "onJoinResponse: Reconnecting to "+roomId+" with user "+userId
			int[] partnerIds
			for c -> connections
				if c: log "Connection "+c.userId+" state:"+c.state+" offerByMe:"+c.offerByMe
				else  log "Connection null"
				if c && (c.state == Disconnected || c.state == Reconnecting) && c.offerByMe
					partnerIds.add c.userId
			createOffers partnerIds
		else
			log Time.dateAndTimeString + " local version:" + Platform.version + " user agent:"+Platform.userAgent+" "
			if message.roomId != roomId
				log "Received room id {message.roomId}"
				Platform.pushState null, "{gameId} {message.roomId}", "/{gameId}/{message.roomId}"
			
			roomId = message.roomId
			userId = message.userId
			Input.internalUsers[message.userId] = {id:userId, local:true}
			Platform.setLocalStorageObject "room"+roomId, RoomInfo(currentTime, userId)
			
			if message.version != Platform.version
				alert "You are using an old version of this application. Please refresh your browser."
			Math.setRandomSeed message.seed
			
			createOffers message.partnerIds
			
			// The first user will enter the "connected" state right away, all later uers will first 
			// ping the existing users to sync the startTime and calculate the frame from it
			if userId == 0: startConnected
	
	private onSignal: SignalMessage message
		log "on signal: "+message.signal.type+" "+message.senderId+" -> "+message.signal.receiverId
		if message.signal.type == "offer":  onReceivedOffer message.senderId, message.signal; else
		if message.signal.type == "answer": onReceivedAnswer message.senderId, message.signal
	
	private js object setupPeerConnection: Connection c
		let peerConnection = new RTCPeerConnection({
			// Set the ice transport policy to "replay" to test a turn server
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
			Network_log("onconnectionstatechange", peerConnection.connectionState)
			if(peerConnection.connectionState == "disconnected")
				Network_onDisconnectFromPeer(c)
		}
		peerConnection.oniceconnectionstatechange = e => Network_log("oniceconnectionstatechange", peerConnection.iceConnectionState)
		peerConnection.onicegatheringstatechange = e => Network_log("onicegatheringstatechange", peerConnection.iceGatheringState)
		peerConnection.onsignalingstatechange  = e => Network_log("onsignalingstatechange", peerConnection.signalingState)
		peerConnection.onnegotiationneeded = () => Network_log("onnegotiationneeded")
		Network_log("createOfferFor: setup event handlers")
		
		peerConnection.onicecandidate = async event => {
			if (event.candidate)
				Network_sendToServer(new IceMessage(Network_userId, c.userId, event.candidate))
			else
				Network_log('Got final candidate!');
		}
		return peerConnection
	
	private Connection createConnection: int partnerId, bool offerByMe, int acknowledgePos
		let connection = connections.find(a.userId == partnerId)
		if connection
			connection.state = Reconnecting
			connection.dataChannel = null
			removeVideoElement partnerId
		else
			connections.add connection = Connection(partnerId)
		connection.peerConnection = setupPeerConnection(connection)
		connection.offerByMe = offerByMe
		let user = Input.internalUsers[partnerId] || (Input.internalUsers[partnerId] = {id:partnerId, local:false})
		user.acknowledgedPos = acknowledgePos
		log partnerId, offerByMe, acknowledgePos, connection.state, connection.dataChannel
		return connection
		
	private js void createOffers: int[] partnerIds
		if(!Network_localVideo) await Network_setupLocalVideo(Network_userId);
		let offers = [];
		
		for(let partnerId of partnerIds) {
			if(partnerId < Network_userId) {
				try {
					// Tell the other users whether we are are reconnecting and already have inputs from them
					// or whether they need to send their past inputs to us
					let existingUser = Input_users[partnerId]
					let acknowledgePos = existingUser ? existingUser.inputs.writePos : 0
					
					// Peer connection
					let connection = Network_createConnection(partnerId, /*offerByMe*/true, acknowledgePos)
					let peerConnection = connection.peerConnection
					Network_log("createOffers: Created peer connection for partner "+partnerId)
					
					// Data channel
					let dataChannel = peerConnection.createDataChannel("channel", {ordered: false, maxRetransmits: 0})
					dataChannel.binaryType = "arraybuffer"
					connection.dataChannel = dataChannel
					dataChannel.onopen = e => {
						log("createOffer: connection opened!")
						Network_logConnectionType(peerConnection);
						Network_onConnectedToPeer(connection, /*isNewUser*/true);
					}
					dataChannel.onclose = e => Network_log("onclose", e)
					dataChannel.onclosing = e => {
						Network_log("onclosing -> disconnect", e)
						Network_onDisconnectFromPeer(connection)
					}
					dataChannel.onerror = e => Network_log("onerror", e)
					dataChannel.onmessage = e => {
						Network_onPeerMessage(connection, new Buffer(e.data, 0, 0, 0))
					}
					
					// Video
					Network_setupRemoteVideo(partnerId, peerConnection)
					
					// Offer
					let offer = await peerConnection.createOffer();
					await peerConnection.setLocalDescription(offer);
					offers.push({receiverId:partnerId, type: "offer", sdp: peerConnection.localDescription.sdp, acknowledgePos})
					Network_log("createOffers: Created and sent offer, waiting for answer. receiverId:"+partnerId+" acknowledgePos:"+acknowledgePos);
				}
				catch(e) {
					console.error(e)
				}
			}
		}
		if(offers.length) Network_sendToServer(new OffersMessage(Network_userId, offers));
		
	private js void onReceivedOffer: int partnerId, Signal offer
		try {
			// Peer connection
			let connection = Network_createConnection(partnerId, /*offerByMe*/true, offer.acknowledgePos)
			let peerConnection = connection.peerConnection
			
			// Data channel
			peerConnection.addEventListener('datachannel', e => {
				Network_log("onReceivedOffer: received datachannel")
				let dataChannel = e.channel
				dataChannel.binaryType = "arraybuffer"
				connection.dataChannel = dataChannel
				dataChannel.onopen = e => {
					log("onReceivedOffer: connection opened!")
					Network_logConnectionType(peerConnection);
					Network_onConnectedToPeer(connection, /*isNewUser*/false);
				}
				dataChannel.onmessage = e => {
					Network_onPeerMessage(connection, new Buffer(e.data, 0, 0, 0))
				}
				dataChannel.onclose = e => Network_log("onclose", e)
				dataChannel.onclosing = e => {
					Network_log("onclosing -> disconnect", e)
					Network_onDisconnectFromPeer(connection)
				}
				dataChannel.onerror = e => Network_log("onerror", e)
			})
			Network_log("onReceivedOffer: data channel listeners")
						
			// Video
			Network_setupRemoteVideo(partnerId, peerConnection)
				
			// Answer
			await peerConnection.setRemoteDescription(new RTCSessionDescription(offer));
			let answer = await peerConnection.createAnswer();
			await peerConnection.setLocalDescription(answer);
			Network_sendToServer(new SignalMessage(Network_userId, {receiverId:partnerId, type: "answer", sdp: peerConnection.localDescription.sdp}))
			Network_log("onReceivedOffer: Created and sent answer for "+partnerId+" acknowledgePos:"+offer.acknowledgePos+", waiting for connection")
		}
		catch(e) {
			console.error(e)
			// Network_statusString = "Error while joining room: "+e
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
				log("onIce " + message.iceCandidate)
				await connection.peerConnection.addIceCandidate(new RTCIceCandidate(message.iceCandidate));
			} catch(e) {
				log("onIce failed " + e.message)
			}
		}
		
	Buffer sendBuffer
	
	// Delay for debugging
	private js void onPeerMessage: Connection c, Buffer buffer
		setTimeout(() => Network_onPeerMessageActual(c, buffer), 500)
		
	private onPeerMessageActual: Connection c, Buffer buffer
	// private onPeerMessage: Connection c, Buffer buffer
		NetworkMessageType type = cast buffer.readInt16
		if type == Tick: onTickMessage c, buffer; else
		if type == Ping: onPingMessage c, buffer; else
		if type == Pong: onPongMessage c, buffer; else
		if type == OwnInputsAfterReconnect: onOwnInputsAfterReconnect c, buffer;
			
	private void sendTickMessage: Connection to
		                          int inputFrame
		                          int currentFrame
		                          int acknowledgePos
		                          int checksumFor
		                          float checksum
		                          Buffer buffer
		                          int start
		                          int end
		sendBuffer.reset
		NetworkMessageType type = Tick
		sendBuffer.writeInt16 cast type
		sendBuffer.writeInt32 inputFrame
		sendBuffer.writeInt32 currentFrame
		sendBuffer.writeInt32 acknowledgePos
		sendBuffer.writeInt32 checksumFor
		sendBuffer.writeFloat64 checksum || 0
		sendBuffer.writeInt32 start
		sendBuffer.writeBuffer buffer, start, end - start
		send to, sendBuffer
		
		sentLog += " #{frame} ack:{acknowledgePos} csFor:{checksumFor} cs:{checksum} {buffer.toRangeString(start, end)}"
		
	
	private onTickMessage: Connection c, Buffer buffer
		let sender = Input.internalUsers[c.userId]
		if c.state != Connected: c.state = Connected

		sender.inputFrame = buffer.readInt32 
		sender.currentFrame = buffer.readInt32 
		sender.acknowledgedPos = buffer.readInt32
		
		// Checksum
		let checksumFor = buffer.readInt32
		let checksum = buffer.readFloat64
		let myChecksum = checksums[checksumFor] 
		checksumLog += " <{c.userId}> #{checksumFor} {checksum}"
		if !myChecksum
			checksums[checksumFor] = checksum
		else
		if myChecksum != checksum
			onWrongChecksum
			checksumLog += " MISMATCH mine:{myChecksum}"
		
		let writeStart = buffer.readInt32
		let length = buffer.readBuffer sender.inputs, writeStart
		sender.inputs.writePos = writeStart + length
		receivedFrames = getReceivedInputFrames
		
		// Calculate "ahead"
		let receivedCurrentFrames = getReceivedCurrentFrames
		let ahead = frame - receivedCurrentFrames
		if ahead >= 0 and ahead < 60: aheads.add ahead, maxLength:900

		receivedLog += " <{c.userId}> #{sender.inputFrame} a:{sender.acknowledgedPos} l:{length} w:{sender.inputs.writePos}"
				
	private void sendOwnInputsAfterReconnectMessage: Connection c
		                                int frame
		                                Buffer buffer
		sendBuffer.reset
		NetworkMessageType type = OwnInputsAfterReconnect
		sendBuffer.writeInt16 cast type
		sendBuffer.writeInt32 frame
		sendBuffer.writeBuffer buffer, start:0, length:buffer.writePos
		send c, sendBuffer
		log "Sending own inputs to {c.userId}", frame, buffer, sendBuffer
		
	private onOwnInputsAfterReconnect: Connection c, Buffer buffer
		// Platform.debugger
		let localUser = Input.internalUsers[userId]
		log userId, localUser.id
		localUser.inputFrame = buffer.readInt32
		let length = buffer.readBuffer localUser.inputs, writeStart:0
		localUser.inputs.writePos = length
		log "Receiving own inputs from {c.userId}", localUser.inputFrame, localUser.inputs.writePos, buffer, localUser.inputs
		
	private void sendPingMessage: Connection c, float pingTime
		sendBuffer.reset
		NetworkMessageType type = Ping
		sendBuffer.writeInt16 cast type
		sendBuffer.writeFloat64 pingTime
		send c, sendBuffer
			
	private onPingMessage: Connection c, Buffer buffer
		log c.state
		if c.state != Disconnected
			let pingTime = buffer.readFloat64
			sendPongMessage c, currentTime-startTime, pingTime
		
	private void sendPongMessage: Connection c, float timeSinceStart, float pingTime
		sendBuffer.reset
		NetworkMessageType type = Pong
		sendBuffer.writeInt16 cast type
		sendBuffer.writeFloat64 timeSinceStart		
		sendBuffer.writeFloat64 pingTime
		send c, sendBuffer

	private onPongMessage: Connection c, Buffer buffer
		float now = currentTime
		float timeSinceStart = buffer.readFloat64
		float pingTime = buffer.readFloat64
		float pingPongTime = now - pingTime
		float estimatedStartTime = now - pingPongTime/2 - timeSinceStart
		if pongCount >= 2: estimatedStartTimeTotal += estimatedStartTime
		log pongCount, pingPongTime, estimatedStartTime
		if ++pongCount >= pingCount
			startConnected startTime: estimatedStartTimeTotal / (pongCount - 2)
			
	private js void send: Connection connection, Buffer buffer
		connection.dataChannel.send(buffer.buffer)

	private js void setupLocalVideo: int userId
		if(Network_isLocalhost) return 
		Network_localVideo = await navigator.mediaDevices.getUserMedia({video: true, audio: true});
		Network_createVideoElement(userId, Network_localVideo, /*local*/true)
			
	private js void setupRemoteVideo: int partnerId, object peerConnection
		if(Network_isLocalhost) return 
		for(let track of Network_localVideo.getTracks())
			peerConnection.addTrack(track, Network_localVideo);
		
		var remoteStream = new MediaStream();
		Network_createVideoElement(partnerId, remoteStream, /*local*/false)
		peerConnection.addEventListener('track', event => {
			Network_log('Got remote track:', event.streams[0]);
			event.streams[0].getTracks().forEach(track => {
				Network_log('Add a track to the remoteStream:', track);
				remoteStream.addTrack(track);
			});
		});

	private js void createVideoElement: int userId, object stream, bool local
		let el = document.createElement('video');
		el.style = "position:absolute; top:0px; left:0px; z-index:10000; visibility:hidden; "+(local ? "transform: scaleX(-1)" : "")
		el.autoplay = true
		el.playsinline = true
		el.controls = false
		el.muted = local
		document.body.appendChild(el)
		el.srcObject = stream;
		let vs = Network_videoScreens[userId] || (Network_videoScreens[userId] = new VideoScreenInfo(null, new float2(0,0,null), 0))
		vs.videoElement = el
		
	private js void removeVideoElement: int userId
		let vs = Network_videoScreens[userId]
		if(vs && vs.videoElement) vs.videoElement.remove()
			
	setUserVideoAndColor: int userId = 0, float2 pos = {}, float width = 440, Color color = null
		let vs = videoScreens[userId] || (videoScreens[userId] = VideoScreenInfo)
		vs.pos = pos
		vs.width = width
		let user = Input.users[userId]
		if color and user: user.color = color
		
	internal js void updateVideoScreen
		if(Network_mode == 2/*Local*/ || Network_isLocalhost) {
			for(let vs of Network_videoScreens) {
				graphics_drawImage(Image_VideoScreen, vs.pos, 0, vs.width/440, -1)
			}
		}
		else {
			for(let vs of Network_videoScreens) {
				if(vs.videoElement && vs.width) {
					let el = vs.videoElement
					let pixelPos = Input_logicalToPixelPosition(vs.pos)
					let pixelSizeX = vs.width*graphics_totalMatrix.m0/Platform_pixelRatio
					let pixelSizeY = (vs.width*3/4)*graphics_totalMatrix.m3/Platform_pixelRatio
					el.style.left = (pixelPos.x-pixelSizeX/2)+"px"
					el.style.top = (pixelPos.y-pixelSizeY/2)+"px"
					el.style.width = pixelSizeX+"px"
					el.style.height = pixelSizeY+"px"
					el.style.visibility = "visible"
				}
			}
		}
		
	internal drawFingers
		for user -> Input.users
			if user
				let internalUser = Input.internalUsers[user.id]
				if (!internalUser.local or Platform.showLocalPointer) and Framework.isVisibleFor user.touchPos, this.userId
					drawImage finger, user.touchPos+{11,34}, frame:user.id
					if user.color: drawRectangle user.touchPos+{16,76}, size:{26,8}, user.color
				
	private js void logConnectionType(object peerConnection)
		setTimeout(async () => {
			let stats = await peerConnection.getStats()
			let candidatePairs = [...stats.values()].filter(s => s.type == "candidate-pair" && s.state == "succeeded")
			let candidatePair = candidatePairs.find(a => a.selected) || candidatePairs[0]
			if(candidatePair) {
				let candidate = stats.get(candidatePair.localCandidateId);
				let type = candidate.candidateType
				let ip = candidate.ip || candidate.address
				Network_log(">>> Connection", type, ip, candidate)
				if(Network_userId == 0) Platform_setTitle(candidate.candidateType+" "+ip) 
			} else {
				window.stats = [...stats.values()]
				Network_log("Can't access stats", window.stats)
			}
		}, 5000)

enum NetworkMessageType: Tick, Ping, Pong, OwnInputsAfterReconnect
enum ConnectionState: Disconnected, Reconnecting, WaitingForFirstTickMessage, Connected

class Connection
	int userId
	object peerConnection = null
	object dataChannel = null
	ConnectionState state
	bool offerByMe
	
enum NetworkMode: None, Ping, Local, Connected, Reconnecting
class HTMLVideoElement: int id
class RoomInfo: int time, userId
		
class VideoScreenInfo
	object videoElement = null
	float2 pos
	float width
	
unit Serializer
	void serialize: Buffer buffer
	void deserialize: Buffer buffer
	
class Buffer
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
	
	inline js void writeInt16: int value
		if(this.writePos+2 > this.buffer.byteLength) this.expandBuffer((this.writePos+2)*2)
		this.dataView.setInt16(this.writePos, value)
		this.writePos += 2
	
	inline js void writeInt32: int value
		if(this.writePos+4 > this.buffer.byteLength) this.expandBuffer((this.writePos+4)*2)
		this.dataView.setInt32(this.writePos, value)
		this.writePos += 4
	
	inline js void writeFloat64: float value
		if(this.writePos+8 > this.buffer.byteLength) this.expandBuffer((this.writePos+8)*2)
		this.dataView.setFloat64(this.writePos, value)
		this.writePos += 8
		
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
	
	js int readInt16
		let value = this.dataView.getInt16(this.readPos)
		this.readPos += 2
		return value
		
	js int readInt32
		let value = this.dataView.getInt32(this.readPos)
		this.readPos += 4
		return value

	js int peekInt32
		return this.dataView.getInt32(this.readPos)

	js float readFloat64
		let value = this.dataView.getFloat64(this.readPos)
		this.readPos += 8
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
		
unit Network
	// Logs
	string logTable = "tickTime,networkTime,networkFrame,user0,user1,user2,received,common,logic,ahead,checksums,events,send,receive,write,parse,touch\n"
	public string eventLog = ""; sentLog = "", receivedLog="", writeLog="", parseLog = "", touchLog = ""
	private float lastNetworkFrame, lastTick
	
	internal targetFps = 30
	private inputFrameEvery = 1, maxAhead = 10, pingCount = 6
	private targetFrameTime = 1000/targetFps
	
	visible NetworkMode mode
	visible bool inLobby = true
	visible int userId = -1
	public bool simulateConnection = true
	
	private VideoScreenInfo[] videoScreens
	private object localVideo = null
	
	private float startTime
	private int startInputFrame
	
	internal int inputFrame
	internal int logicFrame
	private int networkFrame
	
	private float[] checksums
	private bool alertShown
	private int nextReconnect
	private string randomSeed
	
	// init() initHandlers
	
	// js void initHandlers
	// 	log("initHandlers")
	// 	window.onbeforeunload = e => { Network_saveEventStream(); alert("onbeforeunload") }
	// 	window.onunload = e => { alert("onunload") }
	
	log: logstring text
		string str = text
		eventLog += str + "\n"
		print str

	private startConnected: float startTime = 0
		// for Input.users: log "User {id}", id, frames, inputs
		if mode == Connected: return
		if startTime
			this.startTime = startTime
			networkFrame = Math.floor((Time.now - this.startTime)/targetFrameTime)
		else
			resetStartTime
		// startInputFrame = inputFrame = Math.floor(networkFrame / inputFrameEvery) + 1
		inputFrame = networkFrame+1
		Input.users[userId].startInputFrame inputFrame
		// for Input.users: log "User {id}", id, frames, inputs
		int receivedFrames = getReceivedFrames
		log "Connected", userId, logicFrame, networkFrame, startTime, this.startTime, inputFrame, receivedFrames
		// for Input.users: log "User {id}", id, inputs
		// while logicFrame < receivedFrames - 1
		// 	step fastFordward:true
		// log "Replay done", logicFrame
		// for Input.users: log "User {id}", id, inputs.readPos, inputs.writePos
		mode = Connected
		
	startLocal: userCount = 1
		userId = 0
		mode = Local
		Input.users.clear
		// openEventStream
		// 	log "opening session from event stream"
		// 	Math.setRandomSeed eventStream.randomSeed
		// 	for eventStream.users
		// 		Input.users.add {id:u.id, local:u.local, frames:u.frames, inputs:u.inputs}
		// 	int receivedFrames = getReceivedFrames * inputFrameEvery
		// 	networkFrame = receivedFrames
		// 	resetStartTime
		// 	startApp
		// 	while logicFrame < receivedFrames - 1
		// 		step fastFordward:true
		// 	step
		// 	// tick
		// else
		// log "starting new session"
		randomSeed = Math.generateRandomSeed
		Math.setRandomSeed randomSeed
		for userCount: Input.users.add {id:i, local:true}
		startTime = Time.now
		startApp
		tick
			
	js void startApp
		Network_inLobby = false
		if(window.app_start) app_start()
		
	resetStartTime
		startTime = Time.now - networkFrame*targetFrameTime// - (targetFrameTime-0.001)
		
	eventStreamSize
		string result
		for Input.users
			if u
				if result: result += ", "
				result += u.inputs.writePos.formatWithSpaces
		return result
		
	Buffer commonState
	int commonFrame
		
	internal tick
		let now = Platform.now
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
			
		let targetFrame = Math.floor((now - startTime)/targetFrameTime)
		if mode == Local && targetFrame > networkFrame + targetFps*2
			// After a long pause in local mode, we do not want to process all missed frames, so we adjust the start time
			let prevTargetFrame = targetFrame
			targetFrame = networkFrame
			startTime = now - targetFrame*targetFrameTime - (targetFrameTime-0.001)
			log "Paused {prevTargetFrame-networkFrame} frames, adjusting startTime. prevTargetTime:{prevTargetFrame} networkFrame:{networkFrame} targetFrame:{Math.floor((now - startTime)/targetFrameTime)}"
			
		while networkFrame <= targetFrame
			networkFrame++
			let localPlayer = Input.users[userId]
			// bool isInputFrame = (networkFrame % inputFrameEvery) == 0
			// bool isInputFrame = true
			// inputFrame = Math.floor(networkFrame / inputFrameEvery) + 1
			int startLogicFrame = logicFrame
			
			// if isInputFrame
			inputFrame = networkFrame + 1
			localPlayer.startInputFrame networkFrame
			
			if mode == Connected
				for c -> connections
					if c.state == Connected
						let receiver = Input.users[c.userId]
						sendTickMessage
							c
							frames: networkFrame
							acknowledgePos: receiver.inputs.writePos
							checksumFor: logicFrame-1
							checksum: checksums[logicFrame-1] || 0
							buffer:localPlayer.inputs
							start:receiver.acknowledgedPos
							end:localPlayer.inputs.writePos
							
						// int startFrame = Math.max(startInputFrame, p.acknowledgedFrames)
						// sentLog += " <"+c.userId+">"
						// for f = startFrame -> localPlayer.frames
						// 	message.inputs.add localPlayer.inputs[f]
						// 	sentLog += " ["+f+"]"
						// 	for input -> localPlayer.inputs[f]: sentLog += " "+input
						// send c, message
			
			// for Input.users: log id, frames
			int receivedFrames = getReceivedFrames
			if logicFrame < receivedFrames - maxAhead
				log " >>> catching up", logicFrame, receivedFrames
				while logicFrame < receivedFrames - 1
					step fastFordward:true
					
			// if logicFrame < receivedFrames
			//	step
			
			step fastFordward:networkFrame <= targetFrame
			
			// Logs	
			// string logTable = "Δtick,Δnetwork,networkFrame,user0,user1,user2,received,common,logic,Δreceived,checksums,events,send,receive,write,parse,touch\n"
			logTable += ""+(now - lastTick)+","+(now - lastNetworkFrame)+","+networkFrame
			logTable += ","+(Input.users[0] ? Input.users[0].frames : 0)
			logTable += ","+(Input.users[1] ? Input.users[1].frames : 0)
			logTable += ","+(Input.users[2] ? Input.users[2].frames : 0)
			logTable += ",{receivedFrames},{commonFrame},{logicFrame},{receivedFrames-logicFrame},"
			for i = startLogicFrame -> logicFrame
				logTable += "("+i+") "+checksums[i]
			logTable += ",\"{eventLog.trim}\",\"{sentLog.trim}\",\"{receivedLog.trim}\",\"{writeLog.trim}\",\"{parseLog.trim}\",\"{touchLog.trim}\"\n"
			eventLog = ""; sentLog = ""; receivedLog = ""; writeLog = ""; parseLog = ""; touchLog = ""

			lastNetworkFrame = now
		lastTick = now
		
	// inputFrame:     networkFrame + 1
	// networkFrame:   will increase by 1 at the beginning of every {targetFrameTime} milliseconds
	// user.frames:    for the localPlayer, user.frames will be the networkFrame
	// receivedFrames: the lowest value of all user.frames
	// commonFrame:    the last logic frame that has inputs from all players
	// logicFrame:     the same as networkFrame, but adjusted during replay
	saveCommonState
		int receivedFrames = getReceivedFrames
		// if logicFrame <= receivedFrames
		// 	commonFrame = logicFrame
		// else
		if logicFrame == receivedFrames+1
			for Input.users: commonReadPos = inputs.readPos
			commonFrame = logicFrame-1
			Serializer.serialize commonState
			// log "Save state", logicFrame, app.xPos[0], app.xPos[1], app.speed[0], app.speed[1]
			log "Save state", logicFrame
	
	replayCommonState
		int receivedFrames = getReceivedFrames
		if commonFrame and receivedFrames > commonFrame
			log "Replay state", receivedFrames, commonFrame, logicFrame, commonState
			let currentLogicFrame = logicFrame
			logicFrame = commonFrame
			for Input.users: inputs.readPos = commonReadPos
			Serializer.deserialize commonState
			commonFrame = 0
			// log "Restore state", app.xPos[0], app.xPos[1], app.speed[0], app.speed[1]
			while logicFrame < currentLogicFrame
				step fastFordward:true
		
	private getReceivedFrames
		if mode == Local: return Input.users[userId].frames
		int minFrames = -1
		for user -> Input.users
			if user && (minFrames == -1 || user.frames < minFrames)
				minFrames = user.frames
		return minFrames
		
	private step: bool fastFordward = false
		logicFrame++
		Platform.fastForward = fastFordward
		parseLog += " #{logicFrame}"
		if fastFordward
			parseLog += "f"
			log "Replay", logicFrame
			
		saveCommonState
		
		// Parse inputs
		bool isInputFrame = logicFrame % inputFrameEvery == 0
		if isInputFrame: Input.parseInputs(logicFrame)
		
		// Tick
		tickFrame
		
		// Checksum
		let myChecksum = 0
		for Framework.objects:
			myChecksum += position.x + position.y + frame + cast side
			if type == Board
				Board board = cast o
				let m = board.matrix
				myChecksum += m.m0 + m.m1 + m.m2 + m.m3 + m.m4 + m.m5
				
		let theirChecksum = checksums[logicFrame]
		if !theirChecksum
			checksums[logicFrame] = myChecksum
		else
			if theirChecksum != myChecksum: onWrongChecksum
			eventLog += " ["+logicFrame+"] mine:"+myChecksum+" theirs:"+theirChecksum
		
		// Cleanup
		if isInputFrame
			for user -> Input.users if user
				user.clearEvent
				
	internal tickFrame
		Physics.step
		graphics.startFrame
		updateVideoScreen
		drawFingers
		if Network.inLobby
			lobby.tick
		else
			Timeline.tick
			app.tick
			Framework.tick
			Input.updateCursor
		graphics.finishFrame
			
	private onWrongChecksum
		eventLog += "%%% OUT OF SYNC %%%"
		if !alertShown
			alert "Clients out of sync. Please click 'Save Logs' and send me the log file that will be created."
			alertShown = true
			
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
					for(let user of eventStream.users) {
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
		Http.post "https://up4playing.com:3112/saveLog/{roomId}/{userId}", logTable
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
				frames: user.frames,
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
		
		// for Input.users: log "User {id}", id, frames, inputs
			
		// if mode == Reconnecting
		// 	// mode = Connected
		// 	// let user = Input.users[connection.userId]
		// 	// connection.state = user && user.acknowledgedPos > 0 ? Connected : WaitingForFirstTickMessage
			
		// 	// connection.state = WaitingForFirstTickMessage
		// 	// showLocalVideo
		// 	// Platform.debugger
			
			
		// 	bool isHost
		// 	for i -> Input.users.length
		// 		if i == userId: isHost = true; break
		// 		let c = connections.find userId == i
		// 		if c && c != connection && c.state == Connected: isHost = false; break
		// 	log "Reconnected", isHost
		// 	if isHost
		// 		let user = Input.users[connection.userId]
		// 		sendOwnInputsAfterReconnectMessage connection, user.frames, user.inputs
				
		// 	// return
			
		let user = Input.users[connection.userId]
		if mode == Reconnecting && user && user.acknowledgedPos > 0
			mode = Connected
			connection.state = Connected
			log "Both users were already connected before", connection.userId, userId, mode, connection.state
		else
		if mode == None
			mode = Ping
			nextPingTime = Time.now + 300
			estimatedStartTimeTotal = 0
			pongCount = 0
			connection.state = Connected
			log "New user, starting to ping", connection.userId, userId, mode, connection.state
		else
			if mode == Reconnecting: mode = Connected
			connection.state = WaitingForFirstTickMessage
			log "Answering user, waiting for ping", connection.userId, userId, mode, connection.state
		
		// The first user will enter the "connected" state right away, all later uers will first 
		// ping the existing users to sync the startTime and calculate the networkFrame from it
		// if mode == None
		// 	mode = Ping
		// 	nextPingTime = Time.now + 300
			
		// New users will start sending tick messages as soon as they are done with pinging,
		// existing users will wait for the new user to finish pinging
		// to prevent sending the large initial message several times
		// connection.state = isNewUser ? Connected : WaitingForFirstTickMessage
		
		log connection.userId, isNewUser, mode, connection.state
		// for Input.users: log "User {id}", id, frames, inputs
		
	private onDisconnectFromPeer: Connection connection
		log "onDisconnectFromPeer userId:"+connection.userId
		closeConnection connection
		connection.state = Disconnected
		mode = Reconnecting
		nextReconnect = Time.now + 1000
		removeVideoElement connection.userId
		graphics.reset
		drawText "Connection lost. Trying to reconnect...", {0,-Platform.size.y/2+32}
		drawRectangle {0,-Platform.size.y/2+32}, {Platform.size.x, 64}, fillColor:{"900000"}
		graphics.finishFrame

	
	private js void closeConnection: Connection connection
		if(connection.peerConnection) {
			console.log("closeConnection: peerConnection")
			connection.peerConnection.close();
			connection.peerConnection = null;
		}
		if(connection.dataChannel) {
			console.log("closeConnection: dataChannel")
			connection.dataChannel.close();
			connection.dataChannel = null;
		}
		
	private reconnect
		if Time.now >= nextReconnect
			log "Trying to reconnect"
			join roomId
			nextReconnect = Time.now + 5000
	
	private ping
		if Time.now >= nextPingTime
			for c -> connections
				if c.state != Disconnected
					sendPingMessage c, Time.now
			nextPingTime = Time.now + 300
		
	private object socket = null
	private string roomId = ""
	private Connection[] connections
	
	js void join: string roomId
		Network_roomId = roomId
		console.log(location.href)
		log("init websocket "+roomId)
		Network_socket = new WebSocket("wss://up4playing.com:3111");
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
		// 	userId = roomInfo && roomInfo.time > Time.now - 3600000*24 ? roomInfo.userId : -1
		// 	log "Reconnect to session", roomInfo, userId
		
		openEventStream
			Math.setRandomSeed eventStream.randomSeed
			for eventStream.users
				Input.users.add {id:u.id, local:u.local, frames:u.frames, inputs:u.inputs}
			userId = Input.users.find(local).id
			int receivedFrames = getReceivedFrames
			networkFrame = receivedFrames
			// resetStartTime
			while logicFrame < receivedFrames - 1
				step fastFordward:true
			step
			log "Opening saved eventstream", roomId, logicFrame, networkFrame, eventStreamSize
			sendToServer JoinMessage roomId, userId, version:Platform.version
		else
			networkFrame = 0
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
			console.log(e)
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
			eventLog += Time.dateAndTimeString + " local version:" + Platform.version + " user agent:"+Platform.userAgent+" "
			if message.roomId != roomId
				log "Received room id {message.roomId}"
				let gameId = Platform.url.split("/")[3]
				Platform.pushState null, "{gameId} {message.roomId}", "https://up4playing.com/{gameId}/{message.roomId}"
			
			roomId = message.roomId
			userId = message.userId
			Input.users[message.userId] = {id:userId, local:true}
			Platform.setLocalStorageObject "room"+roomId, RoomInfo(Time.now, userId)
			
			if message.version != Platform.version
				alert "You are using an old version of this application. Please refresh your browser."
			Math.setRandomSeed message.seed
			
			createOffers message.partnerIds
			
			// The first user will enter the "connected" state right away, all later uers will first 
			// ping the existing users to sync the startTime and calculate the networkFrame from it
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
			console.log("onconnectionstatechange", peerConnection.connectionState)
			if(peerConnection.connectionState == "disconnected")
				Network_onDisconnectFromPeer(c)
		}
		peerConnection.oniceconnectionstatechange = e => console.log("oniceconnectionstatechange", peerConnection.iceConnectionState)
		peerConnection.onicegatheringstatechange = e => console.log("onicegatheringstatechange", peerConnection.iceGatheringState)
		peerConnection.onsignalingstatechange  = e => console.log("onsignalingstatechange", peerConnection.signalingState)
		peerConnection.onnegotiationneeded = () => console.log("onnegotiationneeded")
		console.log("createOfferFor: setup event handlers")
		
		peerConnection.onicecandidate = async event => {
			if (event.candidate)
				Network_sendToServer(new IceMessage(Network_userId, c.userId, event.candidate))
			else
				console.log('Got final candidate!');
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
		let user = Input.users[partnerId] || (Input.users[partnerId] = {id:partnerId, local:false})
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
					console.log("createOffers: Created peer connection for partner "+partnerId)
					
					// Data channel
					let dataChannel = peerConnection.createDataChannel("channel", {ordered: false, maxRetransmits: 0})
					dataChannel.binaryType = "arraybuffer"
					connection.dataChannel = dataChannel
					dataChannel.onopen = e => {
						log("createOffer: connection opened!")
						Network_logConnectionType(peerConnection);
						Network_onConnectedToPeer(connection, /*isNewUser*/true);
					}
					dataChannel.onclose = e => console.log("onclose", e)
					dataChannel.onclosing = e => {
						console.log("onclosing -> disconnect", e)
						Network_onDisconnectFromPeer(connection)
					}
					dataChannel.onerror = e => console.log("onerror", e)
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
				console.log("onReceivedOffer: received datachannel")
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
				dataChannel.onclose = e => console.log("onclose", e)
				dataChannel.onclosing = e => {
					console.log("onclosing -> disconnect", e)
					Network_onDisconnectFromPeer(connection)
				}
				dataChannel.onerror = e => console.log("onerror", e)
			})
			console.log("onReceivedOffer: data channel listeners")
						
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
		console.log("onReceivedAnswer: Received answer, set remote description")
		
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
	
	private onPeerMessage: Connection c, Buffer buffer
		NetworkMessageType type = cast buffer.readInt16
		if type == Tick: onTickMessage c, buffer; else
		if type == Ping: onPingMessage c, buffer; else
		if type == Pong: onPongMessage c, buffer; else
		if type == OwnInputsAfterReconnect: onOwnInputsAfterReconnect c, buffer;
			
	private void sendTickMessage: Connection c
		                          int frames
		                          int acknowledgePos
		                          int checksumFor
		                          float checksum
		                          Buffer buffer
		                          int start
		                          int end
		sendBuffer.reset
		NetworkMessageType type = Tick
		sendBuffer.writeInt16 cast type
		sendBuffer.writeInt32 frames
		sendBuffer.writeInt32 acknowledgePos
		sendBuffer.writeInt32 checksumFor
		sendBuffer.writeFloat64 checksum
		sendBuffer.writeInt32 start
		sendBuffer.writeBuffer buffer, start, end - start
		send c, sendBuffer
		
	private onTickMessage: Connection c, Buffer buffer
		let sender = Input.users[c.userId]
		if c.state != Connected: c.state = Connected

		sender.frames = buffer.readInt32
		sender.acknowledgedPos = buffer.readInt32
		
		// Checksum
		let checksumFor = buffer.readInt32
		let checksum = buffer.readFloat64
		let myChecksum = checksums[checksumFor] 
		if !myChecksum
			checksums[checksumFor] = checksum
		else
			if myChecksum != checksum: onWrongChecksum
			eventLog += " ["+checksumFor+"] mine:"+myChecksum+" theirs:"+checksum
		
		let writeStart = buffer.readInt32
		let length = buffer.readBuffer sender.inputs, writeStart
		sender.inputs.writePos = writeStart + length
		
		// log sender.frames, writeStart, length, sender.acknowledgedPos
		receivedLog += " <{c.userId}> f:{sender.frames} a:{sender.acknowledgedPos} l:{length}"
		
		replayCommonState
		
		// if length: for Input.users: log "User {id}", id, inputs
			
		// let startFrame = message.frames - message.inputs.length
		// for i, item -> message.inputs
		// 	// sender.inputs[startFrame + i] = item
		// 	receivedLog += " ["+(startFrame + i)+"]"
		// 	for input -> item: receivedLog += " "+input
				
	private void sendOwnInputsAfterReconnectMessage: Connection c
		                                int frames
		                                Buffer buffer
		// Platform.debugger
		sendBuffer.reset
		NetworkMessageType type = OwnInputsAfterReconnect
		sendBuffer.writeInt16 cast type
		sendBuffer.writeInt32 frames
		sendBuffer.writeBuffer buffer, start:0, length:buffer.writePos
		send c, sendBuffer
		log "Sending own inputs to {c.userId}", frames, buffer, sendBuffer
		
	private onOwnInputsAfterReconnect: Connection c, Buffer buffer
		// Platform.debugger
		let localUser = Input.users[userId]
		log userId, localUser.id
		localUser.frames = buffer.readInt32
		let length = buffer.readBuffer localUser.inputs, writeStart:0
		localUser.inputs.writePos = length
		log "Receiving own inputs from {c.userId}", localUser.frames, localUser.inputs.writePos, buffer, localUser.inputs
		// for Input.users: log "User {id}", id, frames, inputs
		
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
			sendPongMessage c, Time.now-startTime, pingTime
		
	private void sendPongMessage: Connection c, float timeSinceStart, float pingTime
		sendBuffer.reset
		NetworkMessageType type = Pong
		sendBuffer.writeInt16 cast type
		sendBuffer.writeFloat64 timeSinceStart		
		sendBuffer.writeFloat64 pingTime
		send c, sendBuffer

	private onPongMessage: Connection c, Buffer buffer
		float now = Time.now
		float timeSinceStart = buffer.readFloat64
		float pingTime = buffer.readFloat64
		float pingPongTime = now - pingTime
		float estimatedStartTime = now - pingPongTime/2 - timeSinceStart
		// eventLog += "user:"+c.userId+" count:"+pongCount+" pingPongTime: "+pingPongTime+" estimatedStartTime:"+estimatedStartTime
		if pongCount >= 2: estimatedStartTimeTotal += estimatedStartTime
		log pongCount, pingPongTime, estimatedStartTime
		if ++pongCount >= pingCount
			startConnected startTime: estimatedStartTimeTotal / (pongCount - 2)
			
	private js void send: Connection connection, Buffer buffer
		// if(Math.random() < .5) setTimeout(() => connection.dataChannel.send(buffer.buffer), Math.random()*250)
		connection.dataChannel.send(buffer.buffer)
		
	private js void setupLocalVideo: int userId
		let audio = location.href.indexOf("/p/") == -1
		Network_localVideo = await navigator.mediaDevices.getUserMedia({video: true, audio});
		Network_createVideoElement(userId, Network_localVideo, /*local*/true)
			
	private js void setupRemoteVideo: int partnerId, object peerConnection
		for(let track of Network_localVideo.getTracks())
			peerConnection.addTrack(track, Network_localVideo);
		
		var remoteStream = new MediaStream();
		Network_createVideoElement(partnerId, remoteStream, /*local*/false)
		peerConnection.addEventListener('track', event => {
			console.log('Got remote track:', event.streams[0]);
			event.streams[0].getTracks().forEach(track => {
				console.log('Add a track to the remoteStream:', track);
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
		if color: Input.users[userId].color = color
		
	internal js void updateVideoScreen
		if(Network_mode == 2/*Local*/) {
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
			if (!user.local or Platform.showLocalPointer) and Framework.isVisibleFor user.touchPos, this.userId
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
				console.log(">>> Connection", type, ip, candidate)
				if(Network_userId == 0) Platform_setTitle(candidate.candidateType+" "+ip) 
			} else {
				window.stats = [...stats.values()]
				console.log("Can't access stats", window.stats)
			}
		}, 5000)

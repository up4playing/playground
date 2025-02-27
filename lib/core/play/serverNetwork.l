enum NetworkMessageType: Join, JoinResponse, Ping, Pong, Signal, Ice, Tick, Switch, Reload, RequestState, State, Checksum

internal transient skipInit unit ServerNetwork
	private object socket
	private Buffer sendBuffer = {}
	int nextConnectionId = 1
	bool connected
	Time startToConnectTime = Time.maxValue
	int retries
	
	tick
		let now = Time.realTime
		// Reconnect to server: Try to connect again if we aren't connected 5 seconds after starting to connect
		// We use a central place to reconnect and no intervals, timeouts or reloads to make it easier to reason about
		if not connected and now > startToConnectTime + 5000
			core.log "#server WebSocket not connected after {now - startToConnectTime} ms -> Reconnecting"
			setup
			retries++
			
		// Ping
		if (core.mode == Ping or core.mode == Connected) and now >= nextPingTime
			sendBuffer.reset
			sendBuffer.writeInt8 cast NetworkMessageType.Ping
			sendBuffer.writeFloat64 now
			send sendBuffer
			nextPingTime = now + (core.mode == Ping ? 200 : pongCount < 20 ? 1000 : 30000)
		
	js void setup
		ServerNetwork.startToConnectTime = Date.now()
		ServerNetwork.connected = false
		
		if(ServerNetwork.socket) {
			core.log("#server Closing Previous Websocket");
			ServerNetwork.socket.onopen = null
			ServerNetwork.socket.onclose = null
			ServerNetwork.socket.onmessage = null
			ServerNetwork.socket.onerror = null
			ServerNetwork.socket.close()
		}
		
		core.log("#server Creating Websocket");
		if(location.href.indexOf("localhost") != -1) ServerNetwork.socket = new WebSocket("ws://localhost:3112");
		else                                         ServerNetwork.socket = new WebSocket("wss://"+location.host+":3112");
		ServerNetwork.socket.binaryType = "arraybuffer";
		
		ServerNetwork.socket.onopen = () => {
			core.log("#server Websocket Open");
			ServerNetwork.connected = true;
			if(!ServerNetwork.firstConnectionTime)
				ServerNetwork.firstConnectionTime = Date.now() - ServerNetwork.startToConnectTime;
			ServerNetwork.onConnectedToServer();
		}
		ServerNetwork.socket.onclose = ev => {
			core.log("#server Websocket Closed "+ev.code+" "+ev.reason);
			ServerNetwork.connected = false;
		}
		ServerNetwork.socket.onerror = ev => {
			core.log("#server Websocket Error "+ev);
		}
		ServerNetwork.socket.onmessage = ev => {
			ServerNetwork.onMessageFromServer(new Buffer(ev.data, 0, 0, 0));
		}
	
	private getOrCreateUser: int id
		return input.internalUsers[id] || (input.internalUsers[id] = {id, local:false})
		
	// Called when we first connec to the server or when we reconnect
	private onConnectedToServer
		core.log "#server Connected to Server", input.localUser.id, core.roomId
		sendJoinMessage core.roomString, input.localUser.id, version:Platform.buildVersion
		
	js int bufferedAmount
		return ServerNetwork.socket.bufferedAmount 
		
	private js int send: Buffer buffer
		try {
			let data = buffer.toByteArray()
			ServerNetwork.socket.send(data)
			return data.byteLength
		} catch(e) { 
			core.log(e)
			return 0
		}
		
	private onMessageFromServer: Buffer buffer
		NetworkMessageType type = cast buffer.readInt8
		if type == JoinResponse: onJoinResponse buffer; else
		if type == Pong:         onPong buffer; else
		if type == Signal:       onSignal buffer; else
		if type == Ice:          onIce buffer; else
		if type == Tick:         onTick buffer; else
		if type == Switch:       onSwitch buffer; else
		if type == Reload:       onReload buffer;
		
	private void sendJoinMessage: string roomId, int userId, int version
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Join
		sendBuffer.writeString roomId
		sendBuffer.writeInt16 userId
		sendBuffer.writeInt16 version
		send sendBuffer
		
		
	bool alreadyJoinedBefore
		
	private onJoinResponse: Buffer buffer
		if alreadyJoinedBefore: return
		alreadyJoinedBefore = true
		
		try
			// Use float64 or string for roomId in future to support 20240603121500
			int roomId = cast buffer.readFloat64
			// let roomId = buffer.readInt32
			let userId = buffer.readInt32
			let version = buffer.readInt32
			let seed = buffer.readString
			let serverStartTime = buffer.readFloat64
			let userCount = buffer.readInt16
			for userCount
				let id = buffer.readInt32
				InternalUser user
				if id == userId: user = input.internalUsers[id] ?= input.localUser
				else             user = input.internalUsers[id] ?= {offerByMe:true, connectionId:nextConnectionId++}
				user.id = id
				
				// We don't send inputs from server any more
				// buffer.readBuffer user.inputs
				
				core.log "#onJoinResponse", id, user.local, user.inputs
				
			// TEMP
			// for input.internalUsers
			// 	core.log "#onJoinResponse <{.id}>", .local, .inputs
	
			if roomId != core.roomId
				core.log "#server Received room id {roomId}"
				Platform.pushState "/{core.gameId}/{roomId}"
				core.roomId = roomId
				
			if version != Platform.buildVersion
				alert "You are using an old version of this application. Please refresh your browser."
				
			inputsSentPos = input.localUser.inputs.writePos
			input.localUser.id = userId
			math.setRandomSeed seed
			PeerNetwork.retries = 0
			PeerNetwork.dataChannelId = 0
			core.serverStartTime = serverStartTime
			core.mode = Ping
			core.storeUserId
			core.log "#server Joining room {roomId} as user {userId}"
	
			// The first person in the room triggers sending an notification with the link to everybody
			// if userCount <= 1 and !Platform.isStaging: http.getStringDirectly "{Platform.protocolAndHost}:3114/sendGamedayNotification/{core.gameId}/{core.roomId}/hasStarted"
			
			// Create an offer for each user already in the room
			for input.internalUsers
				if . and not .local
					PeerNetwork.initiate .
		catch 
			core.onError error
		
	float nextPingTime, fastestPingPongTime = int.maxValue
	int pongCount

	float[] calculatedStartTimes
	float referenceStartTime
	float[] pingPongTimes
			
	private onPong: Buffer buffer
		float now = core.currentTime
		float timeSinceStart = buffer.readFloat64
		float pingTime = buffer.readFloat64
		float pingPongTime = now - pingTime
		float calculatedStartTime = now - pingPongTime/2 - timeSinceStart
		
		int deltaFromAverage = math.round(calculatedStartTime - core.startTime)
		// int deltaFromReference = math.round(calculatedStartTime - referenceStartTime)
		statistics.serverPings.add pingPongTime
		// core.log "<<< Pong ({pongCount})", pingPongTime, calculatedStartTime
		// core.log "average", core.startTime, deltaFromAverage 
		// core.log "reference", referenceStartTime, deltaFromReference 
		
		// Ignore pings that took more than twice as long as the average
		pongCount++
		pingPongTimes.add pingPongTime maxLength:30
		let pingPongTimesAverage = pingPongTimes.average
		if pingPongTime > 400 or (pingPongTimes.length >= 15 and pingPongTime > pingPongTimesAverage * 2)
			core.log "#server ignoring ping-pong", pingPongTimes.length, pingPongTimesAverage
			return
			
		statistics.addInfo "from average", deltaFromAverage
		// statistics.addInfo "from reference", deltaFromReference
		
		// Ajust start time (currently disabled)
		// calculatedStartTimes.add calculatedStartTime maxLength:20
		// core.startTime = calculatedStartTimes.average
			
		// Use the fastest ping-pong-time we have ever seen to calculate the reference start time
		if pingPongTime < fastestPingPongTime
			fastestPingPongTime = pingPongTime
			referenceStartTime = calculatedStartTime
			
			// For testing
			core.startTime = referenceStartTime
			
			core.log "#server New fastest pingPongTime", pongCount, now, pingPongTime, timeSinceStart, core.startTime, referenceStartTime
			
		if pongCount >= 5
			core.startConnected frame:math.floor((now - core.startTime)/core.frameTime)+1
			
	sendSignal:	int receiverId, string type, string sdp
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Signal
		sendBuffer.writeInt32 receiverId
		sendBuffer.writeInt32 input.localUser.id
		sendBuffer.writeString type
		sendBuffer.writeString sdp
		send sendBuffer
		
	private onSignal: Buffer buffer
		let receiverId = buffer.readInt32
		let senderId = buffer.readInt32
		let type = buffer.readString
		let sdp = buffer.readString
		
		let sender = getOrCreateUser senderId
		if type == "offer"
			// When we receive an offer, a new user is connecting or an old user is reconnecting
			// -> Assign a new connection id
			sender.connectionId = nextConnectionId++
			PeerNetwork.onReceivedOffer sender, sdp
		else
		if type == "answer"
			PeerNetwork.onReceivedAnswer sender, sdp
			
	sendIce: int receiverId, string candidate
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Ice
		sendBuffer.writeInt32 receiverId
		sendBuffer.writeInt32 input.localUser.id
		sendBuffer.writeString candidate
		send sendBuffer
		
	private onIce: Buffer buffer
		let receiverId = buffer.readInt32
		let senderId = buffer.readInt32
		let candidate = buffer.readString
		
		let sender = getOrCreateUser senderId
		PeerNetwork.onIce sender, candidate
		
	int inputsSentPos
		
	sendInputs: int inputFrame
		let inputs = input.localUser.inputs
		
		let length = inputs.writePos - inputsSentPos
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Tick
		sendBuffer.writeInt32 input.localUser.id
		sendBuffer.writeInt32 inputFrame // You got all inputs up to and including this frame
		sendBuffer.writeBuffer inputs, inputsSentPos, length
		sendBuffer.writeInt core.lastChecksumFrame                           // The last certain frame with inputs from everybody
		sendBuffer.writeFloat64 core.checksums[core.lastChecksumFrame] || 0  // The checksum of the last certain frame
		send sendBuffer
		
		inputsSentPos = inputs.writePos
		core.tickMessageSize = sendBuffer.writePos	
						
	private onTick: Buffer buffer
		let senderId = buffer.readInt32
		let sender = getOrCreateUser senderId
		let prevWritePos = sender.inputs.writePos
		
		sender.inputFrame = buffer.readInt32
		buffer.readBuffer sender.inputs, prevWritePos

	sendSwitch: SendInputsMode mode, int sendInterval
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Switch
		sendBuffer.writeInt32 cast mode
		sendBuffer.writeInt32 sendInterval
		send sendBuffer

	onSwitch: Buffer buffer
		SendInputsMode mode = cast buffer.readInt32
		core.sendInterval = buffer.readInt32
		
		if mode != core.sendInputsMode
			core.sendInputsMode = mode
	
	sendReload: bool newRoom, bool newUserId, bool keepMaster
		string url = "/{core.gameId}/{newRoom ? core.roomId+(core.roomId < 0 ? -1 : 1) : core.roomId}"
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Reload
		sendBuffer.writeBool keepMaster
		sendBuffer.writeBool newUserId
		sendBuffer.writeString url
		send sendBuffer

	onReload: Buffer buffer
		let keepMaster = buffer.readBool
		let newUserId = buffer.readBool
		let url = buffer.readString
		if !newUserId: url += "u{input.localUser.id}"
		Platform.setLocation url

enum NetworkMessageType: Join, JoinResponse, Ping, Pong, Signal, Ice, Tick, Switch, Reload, RequestState, State, Checksum

transient unit ServerNetwork
	private object socket
	private Buffer sendBuffer = {}
	int nextConnectionId = 1
	
	js void setup
		let startTime = Date.now()
		let socket
		if(location.href.indexOf("localhost") != -1) socket = new WebSocket("ws://localhost:3112");
		else                                         socket = new WebSocket("wss://"+location.host+":3112");
		socket.binaryType = "arraybuffer";
		socket.onopen = function() {
			core_log("Websocket open");
			ServerNetwork_socket = socket
			ServerNetwork_onConnectedToServer();
		}
		socket.onmessage = function(event) {
			ServerNetwork_onMessageFromServer(new Buffer(event.data, 0, 0, 0));
		}
		socket.onclose = function(ev) {
			core_log("Websocket closed "+ev.code+" "+ev.reason)
			ServerNetwork_socket = null
			if(Date.now() - startTime < 30000) {
				location.href = "/{core_gameId}/{core_roomId}"
			}
		}
		socket.onerror = error => {
			core_error = "Can't connect to server."
			core_errorMessage = error.message
			core_log(error.message)
		}
		
	// We set the internal user to active when we receive the first signal (offer or answer)
	// to ensure we hold on to the current snapshot, so we can later rewind to a frame before the new user joined.
	// This ensured that the user joins on the same frame on all clients
	private getOrCreateUser: int id
		return input.internalUsers[id] || (input.internalUsers[id] = {id, local:false, active:true})
		
	private onConnectedToServer
		if input.localUser.id == -1 and !Platform.isStaging
			// We were in this room before -> connect with the same userId we had before
			RoomInfo roomInfo = cast Platform.getLocalStorageObject "room"+core.roomId
			input.localUser.id = roomInfo && roomInfo.time > core.currentTime - 3600000*6 ? roomInfo.userId : -1
			core.log roomInfo, input.localUser.id
		
		core.log "onConnectedToServer as {input.localUser.id} {core.roomId}"
		sendJoinMessage core.roomString, input.localUser.id, version:Platform.buildVersion
		
	js int bufferedAmount
		return ServerNetwork_socket.bufferedAmount 
		
	private js int send: Buffer buffer
		try {
			let data = buffer.toByteArray()
			ServerNetwork_socket.send(data)
			return data.byteLength
		} catch(e) { 
			core_log(e)
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
		
	private onJoinResponse: Buffer buffer
		let roomId = buffer.readInt32
		let userId = buffer.readInt32
		let version = buffer.readInt32
		let seed = buffer.readString
		let serverStartTime = buffer.readFloat64
		let userCount = buffer.readInt16
		for userCount
			let id = buffer.readInt32
			InternalUser user
			if id == userId: user = input.localUser
			else             user = {offerByMe:true, connectionId:nextConnectionId++}
			user.id = id
			input.internalUsers[id] = user
			buffer.readBuffer user.inputs

		if roomId != core.roomId
			core.log "Received room id {roomId}"
			Platform.pushState "/{core.gameId}/{roomId}"
			core.roomId = roomId
			
		if version != Platform.buildVersion
			alert "You are using an old version of this application. Please refresh your browser."
			
		inputsSentPos = input.localUser.inputs.writePos
		input.localUser.id = userId
		math.setRandomSeed seed
		core.serverStartTime = serverStartTime
		core.mode = Ping
		for input.internalUsers
			if . and !.local: PeerNetwork.createOffer .
		core.storeUserId
		
		if userCount <= 1
			core.log "We are the only user so far -> Make primary user"
			PeerNetwork.makePrimaryUser
		else
			PeerNetwork.makePrimiaryUserIfStateIsNotReceived

		core.log "Joining room {roomId} as user {userId}"
		
		// The first person in the room triggers sending an notification with the link to everybody
		if userCount <= 1 and !Platform.isStaging: http.getDirectly "{Platform.protocolAndHost}:3114/sendGamedayNotification/{core.gameId}/{core.roomId}/hasStarted"

		
	float nextPingTime, fastestPingPongTime = int.maxValue, lastPingPongTime
	int pongCount
	
	ping
		let now = core.currentTime
		if (core.mode == Ping or core.mode == Connected) and now >= nextPingTime
			sendBuffer.reset
			sendBuffer.writeInt8 cast NetworkMessageType.Ping
			sendBuffer.writeFloat64 now
			send sendBuffer
			nextPingTime = now + (core.mode == Ping ? 200 : pongCount < 20 ? 1000 : 5000)
			
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
		lastPingPongTime = pingPongTime
		pingPongTimes.add pingPongTime maxLength:30
		let pingPongTimesAverage = pingPongTimes.average
		if pingPongTime > 400 or (pingPongTimes.length >= 15 and pingPongTime > pingPongTimesAverage * 2)
			core.log "ignoring ping-pong", pingPongTimes.length, pingPongTimesAverage
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
			
			core.log "New fastest pingPongTime", pongCount, now, pingPongTime, timeSinceStart, core.startTime, referenceStartTime
			
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
		
		if core.logging: core.sentLog += " #{inputFrame} {inputsSentPos}->{inputs.writePos} {inputs.toRangeString(inputsSentPos, inputs.writePos)}"
		
		inputsSentPos = inputs.writePos
		core.tickMessageSize = sendBuffer.writePos	
						
	private onTick: Buffer buffer
		let senderId = buffer.readInt32
		let sender = getOrCreateUser senderId
		let prevWritePos = sender.inputs.writePos
		
		sender.inputFrame = buffer.readInt32
		buffer.readBuffer sender.inputs, prevWritePos

		if core.logging: core.receivedLog += " [{core.currentTime}] <{senderId}> #{sender.inputFrame} {prevWritePos}->{sender.inputs.writePos} {sender.inputs.toRangeString(prevWritePos, sender.inputs.writePos)}"
	
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
			
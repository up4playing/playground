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
			Network_log("Websocket open");
			ServerNetwork_socket = socket
			ServerNetwork_onConnectedToServer();
		}
		socket.onmessage = function(event) {
			ServerNetwork_onMessageFromServer(new Buffer(event.data, 0, 0, 0));
		}
		socket.onclose = function(ev) {
			Network_log("Websocket closed "+ev.code+" "+ev.reason)
			ServerNetwork_socket = null
			if(Date.now() - startTime < 30000) {
				location.href = "/{Network_gameId}/{Network_roomId}"
			}
		}
		socket.onerror = error => {
			Network_error = "Can't connect to server."
			Network_errorMessage = error.message
			Network_log(error.message)
		}
		
	// We set the internal user to active when we receive the first signal (offer or answer)
	// to ensure we hold on to the current snapshot, so we can later rewind to a frame before the new user joined.
	// This ensured that the user joins on the same frame on all clients
	private getOrCreateUser: int id
		return Input.internalUsers[id] || (Input.internalUsers[id] = {id, local:false, active:true})
		
	private onConnectedToServer
		if Input.localUser.id == -1 and !Platform.isStaging
			// We were in this room before -> connect with the same userId we had before
			RoomInfo roomInfo = cast Platform.getLocalStorageObject "room"+Network.roomId
			Input.localUser.id = roomInfo && roomInfo.time > Network.currentTime - 3600000*6 ? roomInfo.userId : -1
			Network.log roomInfo, Input.localUser.id
		
		Network.log "onConnectedToServer as {Input.localUser.id} {Network.roomId}"
		sendJoinMessage Network.roomString, Input.localUser.id, version:Platform.version
		
	js int bufferedAmount
		return ServerNetwork_socket.bufferedAmount 
		
	private js int send: Buffer buffer
		try {
			let data = buffer.toByteArray()
			ServerNetwork_socket.send(data)
			return data.byteLength
		} catch(e) { 
			Network_log(e)
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
			if id == userId: user = Input.localUser
			else             user = {offerByMe:true, connectionId:nextConnectionId++}
			user.id = id
			Input.internalUsers[id] = user
			buffer.readBuffer user.inputs

		if roomId != Network.roomId
			Network.log "Received room id {roomId}"
			Platform.pushState "/{Network.gameId}/{roomId}"
			Network.roomId = roomId
			
		if version != Platform.version
			alert "You are using an old version of this application. Please refresh your browser."
			
		inputsSentPos = Input.localUser.inputs.writePos
		Input.localUser.id = userId
		Math.setRandomSeed seed
		Network.serverStartTime = serverStartTime
		Network.mode = Ping
		for Input.internalUsers
			if . and !.local: PeerNetwork.createOffer .
		Network.storeUserId
		
		if userCount <= 1
			Network.log "We are the only user so far -> Make primary user"
			PeerNetwork.makePrimaryUser
		else
			PeerNetwork.makePrimiaryUserIfStateIsNotReceived

		Network.log "Joining room {roomId} as user {userId}"
		
		// The first person in the room triggers sending an notification with the link to everybody
		if userCount <= 1 and !Platform.isStaging: http.getInternal "{Platform.protocolAndHost}:3114/sendGamedayNotification/{Network.gameId}/{Network.roomId}/hasStarted"

		
	float nextPingTime, fastestPingPongTime = int.maxValue, lastPingPongTime
	int pongCount
	
	ping
		let now = Network.currentTime
		if (Network.mode == Ping or Network.mode == Connected) and now >= nextPingTime
			sendBuffer.reset
			sendBuffer.writeInt8 cast NetworkMessageType.Ping
			sendBuffer.writeFloat64 now
			send sendBuffer
			nextPingTime = now + (Network.mode == Ping ? 200 : pongCount < 20 ? 1000 : 6000)
			
	float[] calculatedStartTimes
	float referenceStartTime
	float[] pingPongTimes
			
	private onPong: Buffer buffer
		float now = Network.currentTime
		float timeSinceStart = buffer.readFloat64
		float pingTime = buffer.readFloat64
		float pingPongTime = now - pingTime
		float calculatedStartTime = now - pingPongTime/2 - timeSinceStart
		
		int deltaFromAverage = Math.round(calculatedStartTime - Network.startTime)
		int deltaFromReference = Math.round(calculatedStartTime - referenceStartTime)
		statistics.serverPings.add pingPongTime
		// Network.log "<<< Pong ({pongCount})", pingPongTime, calculatedStartTime
		// Network.log "average", Network.startTime, deltaFromAverage 
		// Network.log "reference", referenceStartTime, deltaFromReference 
		
		// Ignore pings that took more than twice as long as the average
		pongCount++
		lastPingPongTime = pingPongTime
		pingPongTimes.add pingPongTime maxLength:30
		let pingPongTimesAverage = pingPongTimes.average
		if pingPongTime > 400 or (pingPongTimes.length >= 15 and pingPongTime > pingPongTimesAverage * 2)
			Network.log "ignoring ping-pong", pingPongTimes.length, pingPongTimesAverage
			return
			
		statistics.addInfo "from average", deltaFromAverage
		statistics.addInfo "from reference", deltaFromReference
		
		calculatedStartTimes.add calculatedStartTime maxLength:20
		Network.startTime = calculatedStartTimes.average
			
		// Use the fastest ping-pong-time we have ever seen to calculate the reference start time
		if pingPongTime < fastestPingPongTime
			fastestPingPongTime = pingPongTime
			referenceStartTime = calculatedStartTime
			Network.log "New fastest pingPongTime", pongCount, now, pingPongTime, timeSinceStart, Network.startTime, referenceStartTime
			
	sendSignal:	int receiverId, string type, string sdp
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Signal
		sendBuffer.writeInt32 receiverId
		sendBuffer.writeInt32 Input.localUser.id
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
		sendBuffer.writeInt32 Input.localUser.id
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
		let inputs = Input.localUser.inputs
		
		let length = inputs.writePos - inputsSentPos
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Tick
		sendBuffer.writeInt32 Input.localUser.id
		sendBuffer.writeInt32 inputFrame // You got all inputs up to and including this frame
		sendBuffer.writeBuffer inputs, inputsSentPos, length
		sendBuffer.writeInt Network.lastChecksumFrame                              // The last certain frame with inputs from everybody
		sendBuffer.writeFloat64 Network.checksums[Network.lastChecksumFrame] || 0  // The checksum of the last certain frame
		send sendBuffer
		
		if Network.logging: Network.sentLog += " #{inputFrame} {inputsSentPos}->{inputs.writePos} {inputs.toRangeString(inputsSentPos, inputs.writePos)}"
		
		inputsSentPos = inputs.writePos
		Network.tickMessageSize = sendBuffer.writePos	
						
	private onTick: Buffer buffer
		let senderId = buffer.readInt32
		let sender = getOrCreateUser senderId
		let prevWritePos = sender.inputs.writePos
		
		sender.inputFrame = buffer.readInt32
		buffer.readBuffer sender.inputs, prevWritePos

		if Network.logging: Network.receivedLog += " [{Network.currentTime}] <{senderId}> #{sender.inputFrame} {prevWritePos}->{sender.inputs.writePos} {sender.inputs.toRangeString(prevWritePos, sender.inputs.writePos)}"
	
	sendSwitch: SendInputsMode mode, int sendInterval
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Switch
		sendBuffer.writeInt32 cast mode
		sendBuffer.writeInt32 sendInterval
		send sendBuffer

	onSwitch: Buffer buffer
		SendInputsMode mode = cast buffer.readInt32
		Network.sendInterval = buffer.readInt32
		
		if mode != Network.sendInputsMode
			Network.sendInputsMode = mode
	
	sendReload: bool newRoom, bool newUserId, bool keepMaster
		string url = "/{Network.gameId}/{newRoom ? Network.roomId+(Network.roomId < 0 ? -1 : 1) : Network.roomId}"
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
		if !newUserId: url += "u{Input.localUser.id}"
		Platform.setLocation url
			
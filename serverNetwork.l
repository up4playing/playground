enum NetworkMessageType: Join, JoinResponse, Ping, Pong, Signal, Ice, Tick, Switch, Reload, Checksum

transient unit ServerNetwork
	private object socket
	private Buffer sendBuffer
	bool isLocalhost
	
	js void setup
		let socket
		if(ServerNetwork_isLocalhost) socket = new WebSocket("ws://localhost:3112");
		else                          socket = new WebSocket("wss://"+location.host+":3112");
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
		}
		socket.onerror = error => {
			Network_error = "Can't connect to server."
			Network_errorMessage = error.message
			Network_log(error.message)
		}
		
	private getOrCreateUser: int id
		return Input.internalUsers[id] || (Input.internalUsers[id] = {id, local:false})
		
	private onConnectedToServer
		if Input.localUser.id == -1 and !isLocalhost
			// We were in this room before -> connect with the same userId we had before
			RoomInfo roomInfo = cast Platform.getLocalStorageObject "room"+Network.roomId
			Input.localUser.id = roomInfo && roomInfo.time > Network.currentTime - 3600000*24 ? roomInfo.userId : -1
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
		print roomId, userId, version
		
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
		let userCount = buffer.readInt16
		for userCount
			let id = buffer.readInt32
			InternalUser user
			if id == userId: user = Input.localUser
			else             user = {offerByMe:true}
			user.id = id
			Input.internalUsers[id] = user
			buffer.readBuffer user.inputs

		if roomId != Network.roomId
			Network.log "Received room id {roomId}"
			Platform.pushState null, "{Network.gameId} {roomId}", "/{Network.gameId}/{roomId}"
			Network.roomId = roomId
			
		if version != Platform.version
			alert "You are using an old version of this application. Please refresh your browser."
		
		inputsSentPos = Input.localUser.inputs.writePos
		Input.localUser.id = userId
		Math.setRandomSeed seed
		Network.mode = Ping
		Network.storeUserId
		for Input.internalUsers
			if !.local: PeerNetwork.createOffer .
				
		Network.log "Joining room {roomId} as user {userId}", seed
		
	float nextPingTime, fastestPingPongTime = int.maxValue, lastPingPongTime
	int pongCount
	
	ping
		let now = Network.currentTime
		if (Network.mode == Ping or Network.mode == Connected) and now >= nextPingTime
			sendBuffer.reset
			sendBuffer.writeInt8 cast NetworkMessageType.Ping
			sendBuffer.writeFloat64 now
			sendBuffer.writeInt32 Network.certainFrame                    // The last certain frame with inputs from everybody
			sendBuffer.writeFloat64 Network.checksums[Network.certainFrame] || 0  // The checksum of the last certain frame
			send sendBuffer
			nextPingTime = now + 5000
			
	private onPong: Buffer buffer
		float now = Network.currentTime
		float timeSinceStart = buffer.readFloat64
		float pingTime = buffer.readFloat64
		float pingPongTime = now - pingTime
		if pingPongTime < fastestPingPongTime
			// Use the fastest ping-pong-time we have ever seen to calculate the start time
			fastestPingPongTime = pingPongTime
			Network.startTime = Math.round(now - pingPongTime/2 - timeSinceStart)
			Network.log "New fastest pingPongTime", pongCount, now, pingPongTime, timeSinceStart, Network.startTime
			
		pongCount++
		lastPingPongTime = pingPongTime
		
		// Finish pinging after the 20th pong
		if Network.mode == Ping and pongCount >= 10 and fastestPingPongTime < 1000
			// Request the state from the user who has been here the longest (has the lowest connectionId)
			Network.log "Ping-Pong complete", pongCount, fastestPingPongTime
			Network.startConnected

		nextPingTime = now + (Network.mode == Ping ? 100 : 10000)
		
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
		if type == "offer":  PeerNetwork.onReceivedOffer sender, sdp; else
		if type == "answer": PeerNetwork.onReceivedAnswer sender, sdp
			
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
		sendBuffer.writeInt32 Network.bufferFrames
		sendBuffer.writeBuffer inputs, inputsSentPos, length
		send sendBuffer
		
		Network.sentLog += " #{inputFrame} {inputsSentPos}->{inputs.writePos} {inputs.toRangeString(inputsSentPos, inputs.writePos)}"
		
		inputsSentPos = inputs.writePos
		Network.tickMessageSize = sendBuffer.writePos	
						
	private onTick: Buffer buffer
		let senderId = buffer.readInt32
		let sender = getOrCreateUser senderId
		let prevWritePos = sender.inputs.writePos
		
		sender.inputFrame = buffer.readInt32
		sender.bufferFrames = buffer.readInt32
		buffer.readBuffer sender.inputs, prevWritePos
		
		Network.receivedFrames = Input.internalUsers.min.inputFrame where . and !.local
		Network.receivedLog += " [{Network.currentTime}] <{senderId}> #{sender.inputFrame} ama:{sender.bufferFrames} {prevWritePos}->{sender.inputs.writePos} {sender.inputs.toRangeString(prevWritePos, sender.inputs.writePos)}"
	
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
	
	sendReload: bool newRoom, bool newUserId
		string url = "/{Network.gameId}/{newRoom ? Network.roomId+1 : Network.roomId}"
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Reload
		sendBuffer.writeString url
		sendBuffer.writeBool newUserId
		send sendBuffer

	onReload: Buffer buffer
		let url = buffer.readString
		let newUserId = buffer.readBool
		if !newUserId: url += "-{Input.localUser.id}"
		Platform.setLocation url
			
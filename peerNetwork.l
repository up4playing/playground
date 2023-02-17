transient class Signal
	int receiverId
	string type
	string sdp

transient class IceMessage
	int receiverId
	object iceCandidate
	
enum VideoShape: Rectangle, Square, Circle
enum RelayMode: Never, Auto, Always
		
class MediaDeviceInfo
	string deviceId
	string groupId
	string kind
	string label

class MediaDevices
	MediaDeviceInfo[] audioInput
	MediaDeviceInfo[] audioOutput
	MediaDeviceInfo[] videoInput
	
transient unit PeerNetwork
	RelayMode relayMode = Auto
	
	internal enableVideo = true
	internal enableAudio = true
	
	visible string error
	
	private js object setupPeerConnection: InternalUser user, bool offerByMe
		let options = {
			// We use the ice transport policy "relay" to test our turn server
			iceTransportPolicy: PeerNetwork_relayMode == 2 ? "relay" : "all",
			iceServers: [],
			// iceCandidatePoolSize: 10,
		}
		if(PeerNetwork_relayMode > 0) {
			// Alwyzon
			options.iceServers.push({
				urls: 'turn:94.177.8.204:39917',
				username: 'play-user-x8env28gx41odbxzwjyut2oq871987syq8ovyuqp-alwyzon',
				credential: 'qoy91n981vlplabb1873jdcgsouz2qm87qmmakqpc-alwyzon'
			});
			// Amazon Lightsail
			// options.iceServers.push({
			// 	urls: 'turn:81.169.197.127',
			// 	username: 'play-user-x8env28gx41odbxzwjyut2hx82jyzdk7qm6d-ok',
			// 	credential: '9y4vm5vxj3uyqvc8wkyzrm26ygebxutkd52bymr8zsmy6qa8-ok'
			// });
		}
		options.iceServers.push({
			urls: [
				'stun:stun1.l.google.com:19302',
				'stun:stun2.l.google.com:19302',
			],
		});
		let peerConnection = new RTCPeerConnection(options);
		let connectionId = user.connectionId
		Network_log("setupPeerConnection userId:"+user.id+" connectionId:"+connectionId+" relayMode:"+PeerNetwork_relayMode)
		
		// Event handlers
		peerConnection.oniceconnectionstatechange = e => {
			Network_log("oniceconnectionstatechange " + peerConnection.iceConnectionState)
			if(peerConnection.iceConnectionState == "disconnected") {
				// Send logfiles to server
				setTimeout(() => statistics_manuallyTriggerSend(-5, /*clear*/false), 7000);
			}
		}
		peerConnection.onicecandidate = async event => {
			if (event.candidate)
				ServerNetwork_sendIce(user.id, JSON.stringify(event.candidate))
			else
				Network_log("Final ice candidate");
		}
		user.peerConnection = peerConnection
		user.offerByMe = offerByMe
		return peerConnection
	
	js void stopRecreatingDataChannel: InternalUser user
		if(user.recreateDataChannelInterval) {
			Network_log("stopRecreatingDataChannel for user:"+user.id+" connectionId:"+user.connectionId)
			clearInterval(user.recreateDataChannelInterval)
			user.recreateDataChannelInterval = null
		}
	
	js void setupDataChannel: InternalUser user
		// Create reliable data channel
		// These options would create an unreliable one: {ordered:false, maxRetransmits:0}
		Network_log("setupDataChannel: Creating data channel for user "+user.id)
		let dataChannel = user.peerConnection.createDataChannel("channel")
		dataChannel.binaryType = "arraybuffer"
		dataChannel.onopen = e => {
			user.dataChannel = dataChannel
			Network_log("setupDataChannel: Open data channel for "+user.id)
			PeerNetwork_stopRecreatingDataChannel(user)
			PeerNetwork_logConnectionType(user)
			if(!PeerNetwork_requestedState) {
				PeerNetwork_requestState(user)
				PeerNetwork_requestedState = true
			}
		}
		dataChannel.onclosing = e => Network_log("Data channel "+user.id+" closing")
		dataChannel.onclose = e => {
			Network_log("setupDataChannel: Close data channel for "+user.id+" recreateInterval:"+user.recreateDataChannelInterval)
			user.dataChannel = null
			if(!user.recreateDataChannelInterval) {
				Network_log("setupDataChannel: Start recreating interval for "+user.id)
				user.recreateDataChannelInterval = setInterval(() => PeerNetwork_setupDataChannel(user), 2000)
			}
			// Send logfiles to server
			setTimeout(() => statistics_manuallyTriggerSend(-4, /*clear*/false), 7000);
		}
		dataChannel.onerror = e => Network_log("DataChannel "+user.id+"error "+e)
		dataChannel.onmessage = e => PeerNetwork_onMessage(user, new Buffer(e.data, 0, 0, 0))
	
	js void createOffer: InternalUser user
		try {
			PeerNetwork_setupPeerConnection(user, /*offerByMe*/true)
			PeerNetwork_setupRemoteMedia(user)
			PeerNetwork_stopRecreatingDataChannel(user)
			PeerNetwork_setupDataChannel(user)
			
			// Offer
			let peerConnection = user.peerConnection
			let offer = await peerConnection.createOffer();
			await peerConnection.setLocalDescription(offer);
			ServerNetwork_sendSignal(user.id, "offer", peerConnection.localDescription.sdp)
			user.receivedAnswer = false
			Network_log("Sent offer to "+user.id+", waiting for answer.");
		}
		catch(e) {
			console.error(e);
			Network_log(e.stack);
		}
		
	js void setBitrate: InternalUser user, float scaleResolutionDownBy = 1, float maxBitrate
		let senderList = user.peerConnection.getSenders();
		for(let sender of senderList) {
			const params = sender.getParameters();
			console.log(params);
			if (!params.encodings) {
				params.encodings = [{ }];
			}
			params.encodings[0].scaleResolutionDownBy = scaleResolutionDownBy;
			params.encodings[0].maxBitrate = maxBitrate;
			// params.encodings[0].adaptivePtime = true;
			await sender.setParameters(params);
		}
		
	js void onReceivedOffer: InternalUser user, string sdp
		try {
			PeerNetwork_setupPeerConnection(user, /*offerByMe*/false)
			PeerNetwork_setupRemoteMedia(user)
			
			// When a user reconnects, we receive a new offer and a new data channel,
			// so we need to stop trying to recreate the old data channel to avoid two open data channels
			PeerNetwork_stopRecreatingDataChannel(user)
			
			// Data channel
			user.peerConnection.addEventListener('datachannel', e => {
				Network_log("Data Channel received")
				let dataChannel = e.channel
				dataChannel.binaryType = "arraybuffer"
				user.dataChannel = dataChannel
				dataChannel.onopen = e => {
					Network_log("Data channel opened")
					user.dataChannel = dataChannel
					PeerNetwork_logConnectionType(user)
				}
				dataChannel.onclosing = e => {
					Network_log("Data channel closing")
					user.dataChannel = null
				}
				dataChannel.onclose = e => Network_log("DataChannel close "+e)
				dataChannel.onerror = e => Network_log("DataChannel error "+e)
				dataChannel.onmessage = e => PeerNetwork_onMessage(user, new Buffer(e.data, 0, 0, 0))
			})
			Network_log("onReceivedOffer: data channel listeners")
						
			// Answer
			let peerConnection = user.peerConnection
			await peerConnection.setRemoteDescription(new RTCSessionDescription({type: "offer", sdp}));
			let answer = await peerConnection.createAnswer();
			await peerConnection.setLocalDescription(answer);
			ServerNetwork_sendSignal(user.id, "answer", peerConnection.localDescription.sdp)
			Network_log("Received offer from "+user.id+", sent answer, waiting for connection.");
		}
		catch(e) {
			console.error(e)
			Network_log(e.stack);
		}
		
	Buffer sendBuffer
	
	sendInputs: int inputFrame
		for Input.internalUsers -> user
			if user?.dataChannel
				let inputs = Input.localUser.inputs
				let length = inputs.writePos - user.inputsSentPos
				sendBuffer.reset
				sendBuffer.writeInt8 cast NetworkMessageType.Tick
				sendBuffer.writeInt inputFrame // You got all inputs up to and including this frame
				sendBuffer.writeInt Network.bufferFrames
				sendBuffer.writeInt user.inputsSentPos
				sendBuffer.writeBuffer inputs, user.inputsSentPos, length
				Network.tickMessageSize = send ., sendBuffer
				
				if Network.logging: Network.sentLog += " <{user.id}> #{inputFrame} {user.inputsSentPos}->{inputs.writePos} {inputs.toRangeString(user.inputsSentPos, inputs.writePos)} ({Network.tickMessageSize} bytes)"
				user.inputsSentPos = inputs.writePos
			
	private js int send: InternalUser user, Buffer buffer
		try {
			let data = buffer.toByteArray()
			user.dataChannel.send(data)
			return data.byteLength
		} catch(e) {
			console.error(e)
			Network_log(e.stack)
			return 0
		}
		
	// private js void onMessage: InternalUser user, Buffer buffer
	// 	setTimeout(() => PeerNetwork_onMessageDo(user, buffer), 1000)
		
	private getMinReceivedFrames
		let minReceivedFrames = int.maxValue
		for Input.users
			let internalUser = Input.internalUsers[.id]
				if internalUser.inputFrame < minReceivedFrames
					minReceivedFrames = internalUser.inputFrame
		return minReceivedFrames
								
	private onMessage: InternalUser user, Buffer buffer
		NetworkMessageType type = cast buffer.readInt8
		if type == Tick:         onTick user, buffer; else
		if type == Checksum:     onChecksum user, buffer; else
		if type == RequestState: onRequestState user, buffer; else
		if type == State:        onState user, buffer
			
	private onTick: InternalUser sender, Buffer buffer
		let inputFrame = buffer.readInt
		if inputFrame >= sender.inputFrame
			sender.inputFrame = inputFrame
			
			sender.bufferFrames = buffer.readInt
			let prevWritePos = buffer.readInt
			buffer.readBuffer sender.inputs, prevWritePos
			
			Network.receivedFrames = getMinReceivedFrames
			if Network.logging: Network.receivedLog += " [{Network.currentTime}] <{sender.id}> #{inputFrame} buffer:{sender.bufferFrames} {prevWritePos}->{sender.inputs.writePos} {sender.inputs.toRangeString(prevWritePos, sender.inputs.writePos)}"
		else
			if Network.logging: Network.receivedLog += " [{Network.currentTime}] <{sender.id}> (ignoring #{inputFrame})"
		
	js void onReceivedAnswer: InternalUser user, string sdp
		await user.peerConnection.setRemoteDescription(new RTCSessionDescription({type: "answer", sdp}));
		user.receivedAnswer = true
		Network_log("Received answer from "+user.id+".");
		
	js void onIce: InternalUser user, string candidate
		try {
			await user.peerConnection.addIceCandidate(new RTCIceCandidate(JSON.parse(candidate)));
		} catch(e) {
			Network_log("onIce failed " + e.message)
			Network_log(e.stack);
		}
		
	private js void logConnectionType: InternalUser user
		// setTimeout(async () => {
		let stats = await user.peerConnection.getStats()
		let candidatePairs = [...stats.values()].filter(s => s.type == "candidate-pair" && s.state == "succeeded")
		let candidatePair = candidatePairs.find(a => a.selected) || candidatePairs[0]
		if(candidatePair) {
			let candidate = stats.get(candidatePair.localCandidateId);
			let ip = candidate.ip || candidate.address
			user.connectionType = candidate.candidateType + " " + ip
			Network_log("####################connection to "+user.id+": "+user.connectionType)
		} else {
			Network_log("####################connection: no candidate pair for "+user.id)
			window.stats = [...stats.values()]
			console.log(window.stats)
			try  { Network_log(JSON.stringify(window.stats)) }
			catch{ }
		}
		// }, 5000)
		
	// --------------------------------------------- Checksum ---------------------------------------------
	
	sendChecksum: int checksumFor, float checksum
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Checksum
		sendBuffer.writeInt checksumFor
		sendBuffer.writeFloat64 checksum
		
		for Input.internalUsers -> user
			if user?.dataChannel		
				send ., sendBuffer

	onChecksum: InternalUser user, Buffer buffer
		int checksumFor = buffer.readInt
		float checksum = buffer.readFloat64
		if Network.logging: Network.checksumLog += " <{user.id}> #{checksumFor} {checksum}"
		
		let myChecksum = Network.checksums[checksumFor]
		if !myChecksum
			Network.checksums[checksumFor] = checksum
		else
		if !myChecksum.isApproximately(checksum)
			Network.onWrongChecksum mine:myChecksum theirs:checksum
				
	// --------------------------------------------- Media Setup ---------------------------------------------
	
	MediaDevices devices = {}
	string videoInputId, audioInputId, audioOutputId	
	
	private js void setupLocalMedia: bool enableVideo, bool enableAudio
		Network_log("setupLocalMedia: start")
		PeerNetwork_enableVideo = enableVideo
		PeerNetwork_enableAudio = enableAudio
		if(!enableVideo && !enableAudio) return
			
		try {
			// Create local media stream
			Input_localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
				video: {width: 500, height: 375},
				audio: enableAudio
			});
			Network_log("setupLocalMedia: getUserMedia done")
			
			// Enummerate local devices
			let devices = await navigator.mediaDevices.enumerateDevices();
			Network_log("setupLocalMedia: enumerateDevices done")
			
			for(let device of devices) {
				switch(device.kind) {
					case "videoinput":  PeerNetwork_devices.videoInput.push(device); break;
					case "audioinput":  PeerNetwork_devices.audioInput.push(device); break;
					case "audiooutput": PeerNetwork_devices.audioOutput.push(device); break;
				}
			}
			PeerNetwork_videoInputId = Input_localUser.mediaStream.getVideoTracks()[0]?.getSettings().deviceId || PeerNetwork_devices.videoInput[0]?.deviceId
			PeerNetwork_audioInputId = Input_localUser.mediaStream.getAudioTracks()[0]?.getSettings().deviceId || PeerNetwork_devices.audioInput[0]?.deviceId
			PeerNetwork_audioOutputId = PeerNetwork_devices.audioInput[0]?.deviceId
			Network_log("setupLocalMedia: success")
			
		} catch(error) {
			Network_log(error.message)
			if(error.name == "NotAllowedError") {
				PeerNetwork_error = "To play with friends over a video call, you need to allow access to your webcam."
			} else {
				PeerNetwork_error = "Can't access webcam. Please make sure it's not used by another application."
			}
			Network_errorMessage = error.message
			throw error
		}
	
	js void setVideoInput: string videoInputId
		if(PeerNetwork_videoInputId == videoInputId) return;
		PeerNetwork_videoInputId = videoInputId;
		
		// Create local media stream
		Input_localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
			audio: {deviceId: PeerNetwork_audioInputId},
			video: {deviceId: PeerNetwork_videoInputId},
		});
		
		// Update video elements and tracks
		for(let el of Input_localUser.videoElements) {
			el.srcObject = Input_localUser.mediaStream;
		}
		const [videoTrack] = Input_localUser.mediaStream.getVideoTracks();
		for(let user of Input_internalUsers) {
			if(user?.peerConnection) {
				const sender = user.peerConnection.getSenders().find((s) => s.track.kind === videoTrack.kind);
				sender.replaceTrack(videoTrack);
			}
		}
			
	js void setAudioInput: string audioInputId
		if(PeerNetwork_audioInputId == audioInputId) return;
		PeerNetwork_audioInputId = audioInputId;
		
		// Create local media stream
		Input_localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
			audio: {deviceId: PeerNetwork_audioInputId},
			video: {deviceId: PeerNetwork_videoInputId},
		});
		
		// Update tracks
		const [audioTrack] = Input_localUser.mediaStream.getAudioTracks();
		for(let user of Input_internalUsers) {
			if(user?.peerConnection) {
				const sender = user.peerConnection.getSenders().find((s) => s.track.kind === audioTrack.kind);
				log('Found sender:', sender);
				sender.replaceTrack(audioTrack);
			}
		}
			
	js void setAudioOutput: string audioOutputId
		PeerNetwork_audioOutputId = audioOutputId;
		
		// Update audio elements
		for(let user of Input_internalUsers) {
			if(user?.audioElement && user.audioElement.setSinkId) {
				user.audioElement.setSinkId(PeerNetwork_audioOutputId);
			}
		}
		audio_reload();
		
	private js void setupRemoteMedia: InternalUser user
		// Remove old video elements
		for(let videoElement of user.videoElements)
			videoElement.remove()
		user.videoElements.length = 0
		
		if(!PeerNetwork_enableVideo && !PeerNetwork_enableAudio) return
			
		// Add local tracks to peer connection
		for(let track of Input_localUser.mediaStream.getTracks())
			user.peerConnection.addTrack(track, Input_localUser.mediaStream);
		
		// Create media stream for remote player
		user.mediaStream = new MediaStream();
		
		// Create audio element so we always hear the remote user, event if no video is shown
		let audioElement = user.audioElement = document.createElement('audio')
		audioElement.srcObject = user.mediaStream
		if(audioElement.setSinkId) audioElement.setSinkId(PeerNetwork_audioOutputId);
		document.body.appendChild(audioElement);
		
		// Add incoming tracks to media stream for remote player
		user.peerConnection.addEventListener('track', event => {
			event.streams[0].getTracks().forEach(track => {
				user.mediaStream.addTrack(track);
			});
		});

	// --------------------------------------------- Media elements ---------------------------------------------
	
	js object createVideoElement: object stream, bool local
		let el = document.createElement('video')
		el.style = "border-radius: 500px; object-fit: cover; position:absolute; top:0px; left:0px; z-index:10000; visibility:hidden; "+(local ? "transform: scaleX(-1)" : "")
		el.autoplay = true
		el.playsinline = true
		el.controls = false
		el.muted = true
		el.srcObject = stream
		document.body.appendChild(el)
		return el
		
	js void removeVideoElement: object videoElement
		videoElement.remove()
						
	js void updateVideoElement: object videoElement, float x, float y, float sizeX, float sizeY, float radius
		videoElement.style.left = (x-sizeX/2)+"px"
		videoElement.style.top = (y-sizeY/2)+"px"
		videoElement.style.width = sizeX+"px"
		videoElement.style.height = sizeY+"px"
		videoElement.style.visibility = "visible"
		videoElement.style.borderRadius = radius+"px"
		
	js void setAudioMuted: object audioElement, bool muted
		if(audioElement) audioElement.muted = muted
		
	// --------------------------------------------- Send state ---------------------------------------------
		
	Buffer snapshotBuffer
	int[] sendStateQueue
	bool requestedState
	int stateTimeout
	
	makePrimiaryUserIfStateIsNotReceived
		requestedState = false
		stateTimeout = Platform.setTimeout 25s
			if Input.internalUsers.any.receivedAnswer
				Network.log "No state after 25s, but we received answers -> Alert the user to make sure WebRTC connections aren't blocked."
				alert "Could not connect. Please make sure WebRTC connections aren't block by your router, firewall or a browser extension. If you have a VPN browser extension installed, please check your settings and make sure WebRTC connections aren't blocked."
			else
				Network.log "No state after 25s -> Make primary user"
				makePrimaryUser
	
	makePrimaryUser
		let frame = Math.floor((Network.currentTime - Network.startTime)/Network.targetFrameTime)+3
		Network.startConnected frame
	
	private requestState: InternalUser from
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.RequestState
		send from, sendBuffer
		
	private onRequestState: InternalUser sender, Buffer buffer
		Network.log "Received state request from {sender.id}"
		sendStateQueue.add sender.id
		if Network.mode == Connected: processSendStateQueue
	
	processSendStateQueue
		if sendStateQueue.length > 0
			snapshotBuffer.reset
			Snapshot.serialize snapshotBuffer
			for sendStateQueue <-
				let user = Input.internalUsers[.]
				if user?.dataChannel
					sendState user, snapshotBuffer
					sendStateQueue.removeAt i
		
	private sendState: InternalUser to, Buffer buffer
		Network.log "Sending state to {to.id}"
		let localPlayer = Input.localUser
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.State
		sendBuffer.writeInt32 Network.frame-1
		let userCount = Input.internalUsers.count . != null
		sendBuffer.writeInt32 userCount
		for Input.internalUsers if .
			sendBuffer.writeInt32 .id
			sendBuffer.writeInt32 .inputs.readPos
		to.inputsSentPos = localPlayer.inputs.readPos
		sendBuffer.writeBuffer buffer
		send to, sendBuffer
		
	private onState: InternalUser c, Buffer buffer
		Platform.clearTimeout stateTimeout
		if Network.mode == Connected:
			Network.log "Ignoring received state from {c.id} because we are already connected"
			return
			
		Network.log "Received state from {c.id}"
		let frame = buffer.readInt32
		let userCount = buffer.readInt32
		for userCount
			let id = buffer.readInt32
			let readPos = buffer.readInt32
			let user = Input.internalUsers[id]
				user.inputFrame = frame
				user.inputs.readPos = user.inputs.writePos = readPos
				
		for Input.internalUsers if .
			.inputsSentPos = Input.localUser.inputs.writePos
			
		snapshotBuffer.reset
		buffer.readBuffer snapshotBuffer
		Snapshot.deserialize snapshotBuffer
		Math.recreateRandomValues
		Network.startConnected frame+1
		
					
	// private float nextPingTime
	// private int pongCount
	
	// private onConnectedToPeer: Connection connection
	// 	                       bool isNewUser // Did this user just join the already exiting users (and make the offer)
		
	// 	let user = Input.internalUsers[connection.userId]
	// 	// if mode == Reconnecting && user && user.acknowledgedPos > 0
	// 	// 	mode = Connected
	// 	// 	connection.state = user.state = Connected
	// 	// 	log "Both users were already connected before", connection.userId, userId, mode, connection.state
	// 	// else
	// 	if isNewUser
	// 		// New users will send out ping messages to sync the startTime (and this way also the current frame)
	// 		mode = Ping
	// 		nextPingTime = currentTime + 100
	// 		pongCount = 0
	// 		connection.state = user.state = PingPong
	// 		log "New user, starting to ping", connection.userId, userId, mode, connection.state
	// 	else
	// 		// Existing users will wait for the new user to finish pinging
	// 		// to prevent sending the large initial message several times
	// 		if mode == Reconnecting: mode = Connected
	// 		connection.state = user.state = PingPong
	// 		log "Answering user, waiting for ping", connection.userId, userId, mode, connection.state
		
	// 	log connection.userId, isNewUser, mode, connection.state

	// // Calculate the frame we received all remote inputs for.
	// // The lowest of all user frames. Called in onTickMessage.
	// private getReceivedInputFrames
	// 	int minFrames = -1
	// 	for user -> Input.internalUsers
	// 		if user && user.state == Connected && !user.local && (minFrames == -1 || user.inputFrame < minFrames)
	// 			minFrames = user.inputFrame
	// 	return minFrames
		
	// // Send inputs to other user. This is called in animationFrame.
	// private sendInputs: int inputFrame, float aheadAverage
	// 	let localPlayer = Input.internalUsers[userId]
	// 	let inputs = localPlayer.inputs
	// 	for c -> connections
	// 		if c.state == Connected
	// 			let receiver = Input.internalUsers[c.userId]
	// 			receiver.sendInterval = receiver.lagFrom < 15 and receiver.lagTo < 15 ? 1 : 60
				
	// 			if (inputFrame % receiver.sendInterval) == 0
	// 				sendBuffer.reset
	// 				sendBuffer.writeInt8 cast NetworkMessageType.Tick
	// 				sendBuffer.writeInt32 inputFrame        // You got all inputs up to and including this frame
	// 				sendBuffer.writeInt32 receiver.lagFrom  // TEMP for testing
	// 				sendBuffer.writeBuffer inputs, receiver.inputsSentPos, inputs.writePos - receiver.inputsSentPos
	// 				send c, sendBuffer
					
	// 				sentLog += " #{inputFrame} to:{c.userId} lag:{receiver.lagFrom} {receiver.inputsSentPos}->{inputs.writePos} {inputs.toRangeString(receiver.inputsSentPos, inputs.writePos)}"
	// 				receiver.inputsSentPos = inputs.writePos
	// 				tickMessageSize = sendBuffer.writePos

	// private onTickMessage: Connection c, Buffer buffer
	// 	let sender = Input.internalUsers[c.userId]
	// 	if c.state != Connected: c.state = sender.state = Connected
	// 	let prevWritePos = sender.inputs.writePos
		
	// 	sender.inputFrame = buffer.readInt32
	// 	sender.lagTo = buffer.readInt32
	// 	buffer.readBuffer sender.inputs, prevWritePos
		
	// 	receivedFrames = getReceivedInputFrames
	// 	sender.lagFrom = frame - sender.inputFrame
		
	// 	receivedLog += " [{currentTime}] <{c.userId}> #{sender.inputFrame} lag:{sender.lagTo} {prevWritePos}->{sender.inputs.writePos} {sender.inputs.toRangeString(prevWritePos, sender.inputs.writePos)}"

	// private onSignal: SignalMessage message
	// 	log "on signal: "+message.signal.type+" "+message.senderId+" -> "+message.signal.receiverId
	// 	if message.signal.type == "offer":  onReceivedOffer message.senderId, message.signal; else
	// 	if message.signal.type == "answer": onReceivedAnswer message.senderId, message.signal
			
	// private ping
	// 	if (mode == Ping or mode == Connected) and currentTime >= nextPingTime
	// 		master = Input.internalUsers.withMin.connectionId where . and (.state == Connected or .state == PingPong or .local)
	// 		if master and (master.state == Connected or master.state == PingPong)
	// 			let c = connections.find.userId == master.id
	// 			sendPingMessage c, currentTime
	// 			nextPingTime = currentTime + 2000
		
	// private void sendPingMessage: Connection c, float pingTime
	// 	sendBuffer.reset
	// 	sendBuffer.writeInt8 cast NetworkMessageType.Ping
	// 	sendBuffer.writeFloat64 pingTime
	// 	sendBuffer.writeInt32 certainFrame                    // The last certain frame with inputs from everybody
	// 	sendBuffer.writeFloat64 checksums[certainFrame] || 0  // The checksum of the last certain frame
		
	// 	send c, sendBuffer
			
	// private onPingMessage: Connection c, Buffer buffer
	// 	if c.state != Disconnected
	// 		let pingTime = buffer.readFloat64
			
	// 		// Checksum
	// 		let checksumFor = buffer.readInt32
	// 		let checksum = buffer.readFloat64
	// 		checksumLog += " <{c.userId}> #{checksumFor} {checksum}"
	// 		if checksum
	// 			let myChecksum = checksums[checksumFor]
	// 			if !myChecksum
	// 				checksums[checksumFor] = checksum
	// 			else
	// 			if !myChecksum.isApproximately(checksum)
	// 				onWrongChecksum mine:myChecksum theirs:checksum
			
	// 		sendPongMessage c, currentTime-startTime, pingTime
		
	// private void sendPongMessage: Connection c, float timeSinceStart, float pingTime
	// 	log c.userId, c.state, timeSinceStart, pingTime, startTime
	// 	sendBuffer.reset
	// 	sendBuffer.writeInt8 cast NetworkMessageType.Pong
	// 	sendBuffer.writeFloat64 timeSinceStart		
	// 	sendBuffer.writeFloat64 pingTime
	// 	send c, sendBuffer

	// private onPongMessage: Connection c, Buffer buffer
	// 	float now = currentTime
	// 	float timeSinceStart = buffer.readFloat64
	// 	float pingTime = buffer.readFloat64
	// 	float pingPongTime = now - pingTime
	// 	if pingPongTime < c.fastestPingPongTime
	// 		// Use the fastest ping-pong-time we have ever seen to calculate the start time
	// 		c.fastestPingPongTime = pingPongTime
	// 		startTime = Math.round(now - pingPongTime/2 - timeSinceStart)
	// 		log "New fastest pingPongTime", c.userId, pongCount, pingPongTime, startTime
	// 	else
	// 		log c.userId, pongCount, pingPongTime, c.fastestPingPongTime, startTime
			
	// 	pongCount++
	// 	lastPingPongTime = pingPongTime
		
	// 	// Finish pinging after the 20th pong
	// 	if mode == Ping and pongCount >= 20 and c.fastestPingPongTime < 1000
	// 		// Request the state from the user who has been here the longest (has the lowest connectionId)
	// 		log "Ping-Pong complete", pongCount, c.fastestPingPongTime
	// 		master = Input.internalUsers.withMin.connectionId where . and (.state == Connected or .state == PingPong or .local)
	// 		let connection = connections.find.userId == master.id
	// 			sendRequestState connection

	// 	nextPingTime = now + (c.state == PingPong ? 100 : 3000)
		
	// private sendRequestState: Connection to
	// 	sendBuffer.reset
	// 	sendBuffer.writeInt8 cast NetworkMessageType.RequestState
	// 	send to, sendBuffer
	// 	log "requesting state from {to.userId}"	
		
	// private onRequestState: Connection c, Buffer buffer
	// 	snapshotBuffer.reset
	// 	Snapshot.serialize snapshotBuffer
	// 	sendState c, snapshotBuffer
		
	// private sendState: Connection to, Buffer buffer
	// 	let localPlayer = Input.internalUsers[userId]
	// 	sendBuffer.reset
	// 	sendBuffer.writeInt8 cast NetworkMessageType.State
	// 	sendBuffer.writeInt32 frame-1
	// 	let userCount = Input.internalUsers.count . != null
	// 	sendBuffer.writeInt32 userCount
	// 	for Input.internalUsers
	// 		if .
	// 			sendBuffer.writeInt32 .id
	// 			sendBuffer.writeInt32 .inputs.readPos
	// 	sendBuffer.writeBuffer buffer
	// 	send to, sendBuffer	
	// 	log "sending state to {to.userId} frame:{frame-1} readPos:{localPlayer.inputs.readPos} size:{buffer.writePos}"	
		
	// private onState: Connection c, Buffer buffer
	// 	snapshotBuffer.reset
	// 	let frame = buffer.readInt32
	// 	let userCount = buffer.readInt32
	// 	for userCount
	// 		let id = buffer.readInt32
	// 		let readPos = buffer.readInt32
	// 		let user = Input.internalUsers[id]
	// 			user.inputFrame = frame
	// 			user.inputs.readPos = user.inputs.writePos = readPos
	// 			log user.id, user.inputFrame, user.inputs.readPos
	// 	buffer.readBuffer snapshotBuffer
	// 	Snapshot.deserialize Network.snapshotBuffer
	// 	Math.recreateRandomValues
	// 	// int startFrame = Math.floor((currentTime - this.startTime)/targetFrameTime)+1
	// 	// startConnected startFrame
	// 	startConnected
	// 	log "received state",c.userId, frame, snapshotBuffer.writePos, userCount
			
	// private js void send: Connection connection, Buffer buffer
	// 	connection.dataChannel.send(buffer.buffer)

	// private js void closeConnection: Connection connection
	// 	Network_removeVideoElement(connection.userId)
		
	// 	if(connection.dataChannel) {
	// 		Network_log("closeConnection: dataChannel")
	// 		connection.dataChannel.close();
	// 		connection.dataChannel = null;
	// 	}
	// 	if(connection.peerConnection) {
	// 		Network_log("closeConnection: peerConnection")
	// 		connection.peerConnection.close();
	// 		connection.peerConnection = null;
	// 	}
		
	// private reconnect
	// 	if currentTime >= nextReconnect
	// 		if(socket)
	// 			log "Existing socket -> resending offers"
	// 			resendOffers
	// 		else
	// 			log "No existing socket -> reconnecting to server"
	// 			join gameId, roomId, userId
	// 		nextReconnect = currentTime + 6000
	
	// private resendOffers
	// 	Partner[] partners
	// 	for c -> connections
	// 		if c: log "Connection "+c.userId+" state:"+c.state+" offerByMe:"+c.offerByMe
	// 		else  log "Connection null"
	// 		if c && (c.state == Disconnected || c.state == Reconnecting) && c.offerByMe
	// 			partners.add {c.userId, Input.internalUsers[c.userId]?.connectionId}
	// 	log "Resending offers", userId, partners
	// 	createOffers partners		

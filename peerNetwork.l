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
			// --- Alphahosting ---
			options.iceServers.push({
				urls: 'turn:89.22.121.145:39571',
				username: 'play-user-x8env28gx41odbxzwjyut2oq871987syq8ovyuqp-alphahosting',
				credential: 'qoy91n981vlplabb1873jdcgsouz2qm87qmmakqpc-alphahosting'
			});			
			// --- Alwyzon ---
			// options.iceServers.push({
			// 	urls: 'turn:94.177.8.204:39571',
			// 	username: 'play-user-x8env28gx41odbxzwjyut2oq871987syq8ovyuqp-alwyzon',
			// 	credential: 'qoy91n981vlplabb1873jdcgsouz2qm87qmmakqpc-alwyzon'
			// });
			// --- Strato-v30 ---
			// options.iceServers.push({
			// 	urls: 'turn:85.214.133.53:39571',
			// 	username: 'play-user-9q2gy75kmlp4qn7tb86pogsmtyp7qqo0n5-strato-v30',
			// 	credential: '8q76nby32odjamuzbexi6eb2f1k9gc3my99o-strato-v30'
			// });
			// --- Strato ---
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
		core_log("<"+user.id+"> setupPeerConnection connectionId:"+connectionId+" relayMode:"+PeerCore_relayMode)
		
		// Event handlers
		peerConnection.oniceconnectionstatechange = e => {
			core_log("<"+user.id+"> oniceconnectionstatechange " + peerConnection.iceConnectionState)
			if(peerConnection.iceConnectionState == "disconnected") {
				// Send logfiles to server
				setTimeout(() => statistics_manuallyTriggerSend(-5, /*clear*/false), 7000);
			}
		}
		peerConnection.onicecandidate = async event => {
			if (event.candidate)
				ServerNetwork_sendIce(user.id, JSON.stringify(event.candidate))
			else
				core_log("<"+user.id+"> Final ice candidate");
		}
		user.peerConnection = peerConnection
		user.offerByMe = offerByMe
		return peerConnection
	
	js void stopRecreatingDataChannel: InternalUser user
		if(user.recreateDataChannelInterval) {
			core_log("<"+user.id+"> stopRecreatingDataChannel connectionId:"+user.connectionId)
			clearInterval(user.recreateDataChannelInterval)
			user.recreateDataChannelInterval = null
		}
	
	js void setupDataChannel: InternalUser user
		// Create reliable data channel
		// These options would create an unreliable one: {ordered:false, maxRetransmits:0}
		core_log("<"+user.id+"> setupDataChannel: Creating data channel")
		let dataChannel = user.peerConnection.createDataChannel("channel")
		dataChannel.binaryType = "arraybuffer"
		dataChannel.onopen = e => {
			user.dataChannel = dataChannel
			core_log("<"+user.id+"> setupDataChannel: Open data channel")
			PeerNetwork_stopRecreatingDataChannel(user)
			PeerNetwork_logConnectionType(user)
			if(!PeerNetwork_requestedState) {
				PeerNetwork_requestState(user)
				PeerNetwork_requestedState = true
			}
		}
		dataChannel.onclosing = e => core_log("<"+user.id+"> Data channel closing")
		dataChannel.onclose = e => {
			core_log("<"+user.id+"> setupDataChannel: Close data channel, recreateInterval:"+user.recreateDataChannelInterval)
			user.dataChannel = null
			if(!user.recreateDataChannelInterval) {
				core_log("<"+user.id+"> setupDataChannel: Start recreating interval")
				user.recreateDataChannelInterval = setInterval(() => PeerNetwork_setupDataChannel(user), 2000)
			}
			// Send logfiles to server
			setTimeout(() => statistics_manuallyTriggerSend(-4, /*clear*/false), 7000);
		}
		dataChannel.onerror = e => core_log("<"+user.id+"> DataChannel "+user.id+"error "+e)
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
			core_log("<"+user.id+"> Sent offer to "+user.id+", waiting for answer.");
		}
		catch(e) {
			console.error(e);
			core_log(e.stack);
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
			core_log("<"+user.id+"> Received offer, senting answer");
			PeerNetwork_setupPeerConnection(user, /*offerByMe*/false)
			PeerNetwork_setupRemoteMedia(user)
			
			// When a user reconnects, we receive a new offer and a new data channel,
			// so we need to stop trying to recreate the old data channel to avoid two open data channels
			PeerNetwork_stopRecreatingDataChannel(user)
			
			// Data channel
			user.peerConnection.addEventListener('datachannel', e => {
				core_log("<"+user.id+"> Data channel received")
				let dataChannel = e.channel
				dataChannel.binaryType = "arraybuffer"
				user.dataChannel = dataChannel
				dataChannel.onopen = e => {
					core_log("<"+user.id+"> Data channel opened")
					user.dataChannel = dataChannel
					PeerNetwork_logConnectionType(user)
				}
				dataChannel.onclosing = e => {
					core_log("<"+user.id+"> Data channel closing")
					user.dataChannel = null
				}
				dataChannel.onclose = e => core_log("<"+user.id+"> Data channel close "+e)
				dataChannel.onerror = e => core_log("<"+user.id+"> Data channel error "+e)
				dataChannel.onmessage = e => PeerNetwork_onMessage(user, new Buffer(e.data, 0, 0, 0))
			})
						
			// Answer
			let peerConnection = user.peerConnection
			await peerConnection.setRemoteDescription(new RTCSessionDescription({type: "offer", sdp}));
			let answer = await peerConnection.createAnswer();
			await peerConnection.setLocalDescription(answer);
			ServerNetwork_sendSignal(user.id, "answer", peerConnection.localDescription.sdp)
		}
		catch(e) {
			console.error(e)
			core_log(e.stack);
		}
		
	Buffer sendBuffer = {}
	
	sendInputs: int inputFrame
		for input.internalUsers -> user
			if user?.dataChannel
				let inputs = input.localUser.inputs
				let length = inputs.writePos - user.inputsSentPos
				sendBuffer.reset
				sendBuffer.writeInt8 cast NetworkMessageType.Tick
				sendBuffer.writeInt inputFrame // You got all inputs up to and including this frame
				sendBuffer.writeInt user.inputsSentPos
				sendBuffer.writeBuffer inputs, user.inputsSentPos, length
				sendBuffer.writeInt core.lastChecksumFrame                           // The last certain frame with inputs from everybody
				sendBuffer.writeFloat64 core.checksums[core.lastChecksumFrame] || 0  // The checksum of the last certain frame
				
				core.tickMessageSize = send ., sendBuffer
				user.inputsSentPos = inputs.writePos
				if core.logging: core.sentLog += " <{user.id}> #{inputFrame} {user.inputsSentPos}->{inputs.writePos} {inputs.toRangeString(user.inputsSentPos, inputs.writePos)} ({core.tickMessageSize} bytes)"
			
	private js int send: InternalUser user, Buffer buffer
		try {
			let data = buffer.toByteArray()
			user.dataChannel.send(data)
			return data.byteLength
		} catch(e) {
			console.error(e)
			core_log(e.stack)
			return 0
		}
		
	// private js void onMessage: InternalUser user, Buffer buffer
	// 	setTimeout(() => PeerNetwork_onMessageDo(user, buffer), 1000)
								
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
			let prevWritePos = buffer.readInt
			buffer.readBuffer sender.inputs, prevWritePos
			
			// Checksum
			int checksumFor = buffer.readInt
			float checksum = buffer.readFloat64
			if core.logging: core.checksumLog += " <{sender.id}> #{checksumFor} {checksum}"
			
			let myChecksum = core.checksums[checksumFor]
			if !myChecksum                           core.checksums[checksumFor] = checksum; else
			if !myChecksum.isApproximately(checksum) core.onWrongChecksum mine:myChecksum theirs:checksum
			
			if core.logging: core.receivedLog += " [{core.currentTime}] <{sender.id}> #{inputFrame} {prevWritePos}->{sender.inputs.writePos} {sender.inputs.toRangeString(prevWritePos, sender.inputs.writePos)}"
		else
			if core.logging: core.receivedLog += " [{core.currentTime}] <{sender.id}> (ignoring #{inputFrame})"
		
	js void onReceivedAnswer: InternalUser user, string sdp
		await user.peerConnection.setRemoteDescription(new RTCSessionDescription({type: "answer", sdp}));
		user.receivedAnswer = true
		core_log("<"+user.id+"> Received answer from "+user.id+".");
		
	js void onIce: InternalUser user, string candidate
		try {
			await user.peerConnection.addIceCandidate(new RTCIceCandidate(JSON.parse(candidate)));
		} catch(e) {
			core_log("<"+user.id+"> onIce failed " + e.message)
			core_log(e.stack);
		}
		
	private js void logConnectionType: InternalUser user
		setTimeout(async () => {
			let stats = await user.peerConnection.getStats()
			let candidatePairs = [...stats.values()].filter(s => s.type == "candidate-pair" && s.state == "succeeded")
			let candidatePair = candidatePairs.find(a => a.selected) || candidatePairs[0]
			if(candidatePair) {
				let candidate = stats.get(candidatePair.localCandidateId);
				let ip = candidate.ip || candidate.address
				user.connectionType = candidate.candidateType + " " + ip
				core_log("<"+user.id+"> ####################connection to "+user.id+": "+user.connectionType)
			} else {
				core_log("<"+user.id+"> ####################connection: no candidate pair for "+user.id)
				window.stats = [...stats.values()]
				console.log(window.stats)
				try  { core_log(JSON.stringify(window.stats)) }
				catch{ }
			}
		}, 10000)
		
	// --------------------------------------------- Checksum ---------------------------------------------
	
	sendChecksum: int checksumFor, float checksum
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Checksum
		sendBuffer.writeInt checksumFor
		sendBuffer.writeFloat64 checksum
		
		for input.internalUsers -> user
			if user?.dataChannel		
				send ., sendBuffer

	onChecksum: InternalUser user, Buffer buffer
		int checksumFor = buffer.readInt
		float checksum = buffer.readFloat64
		if core.logging: core.checksumLog += " <{user.id}> #{checksumFor} {checksum}"
		
		let myChecksum = core.checksums[checksumFor]
		if !myChecksum
			core.checksums[checksumFor] = checksum
		else
		if !myChecksum.isApproximately(checksum)
			core.onWrongChecksum mine:myChecksum theirs:checksum
				
	// --------------------------------------------- Media Setup ---------------------------------------------
	
	MediaDevices devices = {}
	string videoInputId, audioInputId, audioOutputId	
	
	private js void setupLocalMedia: bool enableVideo, bool enableAudio
		core_log("setupLocalMedia: start")
		PeerNetwork_enableVideo = enableVideo
		PeerNetwork_enableAudio = enableAudio
		if(!enableVideo && !enableAudio) return
			
		try {
			// Create local media stream
			input_localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
				video: {width: 500, height: 375},
				audio: enableAudio
			});
			core_log("setupLocalMedia: getUserMedia done")
			
			// Enummerate local devices
			let devices = await navigator.mediaDevices.enumerateDevices();
			core_log("setupLocalMedia: enumerateDevices done")
			
			for(let device of devices) {
				switch(device.kind) {
					case "videoinput":  PeerNetwork_devices.videoInput.push(device); break;
					case "audioinput":  PeerNetwork_devices.audioInput.push(device); break;
					case "audiooutput": PeerNetwork_devices.audioOutput.push(device); break;
				}
			}
			PeerNetwork_videoInputId = input_localUser.mediaStream.getVideoTracks()[0]?.getSettings().deviceId || PeerNetwork_devices.videoInput[0]?.deviceId
			PeerNetwork_audioInputId = input_localUser.mediaStream.getAudioTracks()[0]?.getSettings().deviceId || PeerNetwork_devices.audioInput[0]?.deviceId
			PeerNetwork_audioOutputId = PeerNetwork_devices.audioInput[0]?.deviceId
			core_log("setupLocalMedia: success")
			
		} catch(error) {
			core_log(error.message)
			if(error.name == "NotAllowedError") {
				PeerNetwork_error = "To play with friends over a video call, you need to allow access to your webcam."
			} else {
				PeerNetwork_error = "Can't access webcam. Please make sure it's not used by another application."
			}
			core_errorMessage = error.message
			throw error
		}
	
	js void setVideoInput: string videoInputId
		if(PeerNetwork_videoInputId == videoInputId) return;
		PeerNetwork_videoInputId = videoInputId;
		
		// Create local media stream
		input_localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
			audio: {deviceId: PeerNetwork_audioInputId},
			video: {deviceId: PeerNetwork_videoInputId},
		});
		
		// Update video elements and tracks
		for(let el of input_localUser.videoElements) {
			el.srcObject = input_localUser.mediaStream;
		}
		const [videoTrack] = input_localUser.mediaStream.getVideoTracks();
		for(let user of input_internalUsers) {
			if(user?.peerConnection) {
				const sender = user.peerConnection.getSenders().find((s) => s.track.kind === videoTrack.kind);
				sender.replaceTrack(videoTrack);
			}
		}
			
	js void setAudioInput: string audioInputId
		if(PeerNetwork_audioInputId == audioInputId) return;
		PeerNetwork_audioInputId = audioInputId;
		
		// Create local media stream
		input_localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
			audio: {deviceId: PeerNetwork_audioInputId},
			video: {deviceId: PeerNetwork_videoInputId},
		});
		
		// Update tracks
		const [audioTrack] = input_localUser.mediaStream.getAudioTracks();
		for(let user of input_internalUsers) {
			if(user?.peerConnection) {
				const sender = user.peerConnection.getSenders().find((s) => s.track.kind === audioTrack.kind);
				log('Found sender:', sender);
				sender.replaceTrack(audioTrack);
			}
		}
			
	js void setAudioOutput: string audioOutputId
		PeerNetwork_audioOutputId = audioOutputId;
		
		// Update audio elements
		for(let user of input_internalUsers) {
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
		for(let track of input_localUser.mediaStream.getTracks())
			user.peerConnection.addTrack(track, input_localUser.mediaStream);
		
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
		
	Buffer snapshotBuffer = {}
	int[] sendStateQueue
	bool requestedState
	int stateTimeout
	
	makePrimiaryUserIfStateIsNotReceived
		requestedState = false
		stateTimeout = Platform.setTimeout 25 seconds
			if input.internalUsers.any.receivedAnswer
				core.log "No state after 25s, but we received answers -> Alert the user to make sure WebRTC connections aren't blocked."
				alert "Could not connect. Please make sure WebRTC connections aren't block by your router, firewall or a browser extension. If you have a VPN browser extension installed, please check your settings and make sure WebRTC connections aren't blocked."
			else
				core.log "No state after 25s -> Make primary user"
				makePrimaryUser
	
	makePrimaryUser
		let frame = math.floor((core.currentTime - core.startTime)/core.targetFrameTime)+3
		core.startConnected frame
	
	private requestState: InternalUser from
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.RequestState
		send from, sendBuffer
		
	private onRequestState: InternalUser sender, Buffer buffer
		core.log "Received state request from {sender.id}"
		sendStateQueue.add sender.id
		if core.mode == Connected: processSendStateQueue
	
	processSendStateQueue
		if sendStateQueue.length > 0
			snapshotBuffer.reset
			Snapshot.serialize snapshotBuffer
			for sendStateQueue <-
				let user = input.internalUsers[.]
				if user?.dataChannel
					sendState user, snapshotBuffer
					sendStateQueue.removeAt i
		
	private sendState: InternalUser to, Buffer buffer
		core.log "Sending state to {to.id}"
		let localUser = input.localUser
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.State
		sendBuffer.writeInt32 core.frame-1
		let userCount = input.internalUsers.count . != null
		sendBuffer.writeInt32 userCount
		for input.internalUsers if .
			sendBuffer.writeInt32 .id
			sendBuffer.writeInt32 .inputs.readPos
			sendBuffer.writeBool .active
		to.inputsSentPos = localUser.inputs.readPos
		sendBuffer.writeBuffer buffer
		send to, sendBuffer
		
	private onState: InternalUser c, Buffer buffer
		Platform.clearTimeout stateTimeout
		if core.mode == Connected:
			core.log "Ignoring received state from {c.id} because we are already connected"
			return
			
		core.log "Received state from {c.id}"
		let frame = buffer.readInt32
		let userCount = buffer.readInt32
		for userCount
			let id = buffer.readInt32
			let readPos = buffer.readInt32
			let active = buffer.readBool
			let user = input.internalUsers[id]
				user.inputFrame = frame
				user.inputs.readPos = user.inputs.writePos = readPos
				user.active = active
				
		for input.internalUsers if .
			.inputsSentPos = input.localUser.inputs.writePos
			
		snapshotBuffer.reset
		buffer.readBuffer snapshotBuffer
		Snapshot.deserialize snapshotBuffer
		math.recreateRandomValues
		core.startConnected frame+1
		
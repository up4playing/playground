// Platform.start
// core.join

// ServerNetwork
//     setup
//     onConnectedToServer
//     sendJoinMessage
//     onJoinResponse     ->  PeerNetwork.initiate for each user already in the room
//     ping
//     onPong
//     startConnected 
	
// PeerNetwork (for each user already in the room)
//     initiate
//     setupPeerConnection
//     setupRemoteMedia
//     setupDataChannel
//     onNegotiationNeeded
//     createOffer
//     onAnwserReceived
//     onConnectionStateChange

internal transient immutable Signal
	int receiverId
	string type
	string sdp

internal transient immutable IceMessage
	int receiverId
	object iceCandidate
	
enum VideoShape: Rectangle, Square, Circle
enum RelayMode: Never, Auto, Always
		
internal immutable MediaDeviceInfo
	string deviceId
	string groupId
	string kind
	string label

internal immutable MediaDevices
	MediaDeviceInfo[] audioInput
	MediaDeviceInfo[] audioOutput
	MediaDeviceInfo[] videoInput
	
internal transient skipInit unit PeerNetwork
	RelayMode relayMode = Auto
	
	internal enableVideo = true
	internal enableAudio = true
	
	visible string error
	int retries
	int dataChannelId
	
	initiate: InternalUser user
		setupPeerConnection user, offerByMe:true
		setupRemoteMedia user
		
	tick
		let now = Time.realTime
		
		for input.internalUsers as user
			if . and not .local
				// Reconnect to peer: Try to connect again if
				// - we aren't connected 5 seconds after starting to connect
				// - we are connect, but haven't received a message for 10 seconds
				// We use a central place to reconnect and no intervals, timeouts or reloads to make it easier to reason about
				// if (not .connected and now > .startToConnectTime + 5000)
				// or (    .connected and now > .lastIncomingMessageTime + 10000)
				// if (not .connected and now > .lastIncomingMessageTime +  8000)
				// or (    .connected and now > .lastIncomingMessageTime + 12000)
				if now > .lastIncomingMessageTime + 10000
				
				// !!! EVALUATE Wait longer for the 2nd retry
				// if .connectionState != "connected" and (now > .startToConnectTime + 10000
				// or (retries == 0 and now > .startToConnectTime + 5000))
				
				// !!! EVALUATE Reconned immediately when failed
				// or .connectionState == "failed"
					
					core.log "[{Time.frame}] <{.id}> #problem -------------------------------- State is {.connectionState} after {now-.startToConnectTime} ms, {.connectionTries} retries, last incomming message {now - .lastIncomingMessageTime} ms ago, offerByMe:{.offerByMe} --------------------------------"
					.startToConnectTime = user.lastIncomingMessageTime = Time.realTime
					statistics.scheduleSendIn 3 seconds
					
					if user.offerByMe
						retries++
						if ++user.connectionTries < 3
							core.log "#peer Restarting ICE (offer by me)"
							user.peerConnection.restartIce()
						else
							core.log "#peer Recreate peer connection (offer by me)"
							initiate user
					
					// !!! EVALUATE Recreate peer channel after a few failed tries
					// if .connectionTries < 2
					// 	core.log "#peer The state is {.connectionState} after {now-.startToConnectTime} ms and {.connectionTries} tries -> Restart ICE"
					// 	setupDataChannel .
					// 	.peerConnection.restartIce()
					// else
					// 	core.log "#peer The state is {.connectionState} after {now-.startToConnectTime} ms and {.connectionTries} tries -> Recreate Peer Connection"
					// 	setupPeerConnection . offerByMe:true
					// 	setupDataChannel .
				
				// !!! Evaluate: Recreate data channel if all are closed
				// if .connectionState == "connected" and .dataChannels.length == 0 and now > .startDataChannelTime + 5000
				// 	core.log "#peer No data channels after {now-.startDataChannelTime} ms -> Recreate data channel"
				// 	setupDataChannel .
				
				// if .connectionState == "connected" and now > .lastIncomingMessageTime + 10000
				// 	core.log "#peer No data channels after {now-.startDataChannelTime} ms -> Recreate data channel"
				// 	setupDataChannel .
				
	
	private js object setupPeerConnection: InternalUser user, bool offerByMe
		if(user.peerConnection) {
			try {
				core.log(`#peer <${user.id}> Close Previous Peer Connection`)
				user.peerConnection.onnegotiationneeded = null;
				user.peerConnection.onsignalingstatechange = null;
				user.peerConnection.onconnectionstatechange = null;
				user.peerConnection.onicecandidate = null;
				user.peerConnection.icecandidateerror = null;
				user.peerConnection.oniceconnectionstatechange = null;
				user.peerConnection.onicegatheringstatechange = null;
				user.peerConnection.close();
			} catch {}
		}
		try {
			user.startToConnectTime = user.lastIncomingMessageTime = Date.now();
			user.offerByMe = offerByMe;
			
			let options = {
				// We use the ice transport policy "relay" to test our turn server
				iceTransportPolicy: PeerNetwork.relayMode == 2 ? "relay" : "all",
				iceServers: [],
				// iceCandidatePoolSize: 10,
			}
			if(PeerNetwork.relayMode > 0) {
				// OVH turn server
				options.iceServers.push({
					urls: 'turn:193.70.81.132:39571',
					username: 'play-user-x8env28gx41odbxzwjyut2oq871987syq8ovyuqp128djbsjue',
					credential: 'qoy91n981vlplabb1873jdcgsouz2qm87qmmakqpc2t8hbeyjsyaqkuz'
				});	
				
				// Alphahosting turn server
				// options.iceServers.push({
				// 	urls: 'turn:89.22.121.145:39571',
				// 	username: 'play-user-x8env28gx41odbxzwjyut2oq871987syq8ovyuqp128djbsjue',
				// 	credential: 'qoy91n981vlplabb1873jdcgsouz2qm87qmmakqpc2t8hbeyjsyaqkuz'
				// });	
			}
			options.iceServers.push({
				urls: [
					// OVH stun server
					// "stun:193.70.81.132:39571",
					
					// Google stun server
					"stun:stun1.l.google.com:19302",
					"stun:stun2.l.google.com:19302",
				],
			});
			core.log(`#peer <${user.id}> Setup Peer Connection offerByMe: ${offerByMe}`);
			let peerConnection = user.peerConnection = new RTCPeerConnection(options);
			
			// Negotiation
			peerConnection.onnegotiationneeded = e => {
				core.log(`#peer <${user.id}> Negotiation Needed`);
				if(offerByMe) PeerNetwork.createOffer(user);
			}
			
			// Signaling, Connection
			// peerConnection.onsignalingstatechange = e => {
			// 	core.log(`#peer <${user.id}> Signaling State Change: ${peerConnection.signalingState}`);
			// }
			peerConnection.onconnectionstatechange = e => {
				core.log(`#peer <${user.id}> Connection State Change: ${peerConnection.connectionState}`);
				user.connectionState = peerConnection.connectionState;
				user.connected = peerConnection.connectionState == "connected";
				if(user.connected) PeerNetwork.onConnected(user);
				if(peerConnection.connectionState == "disconnected")
					setTimeout(() => statistics.saveStatistics(), 7000);
					
				// !!! EVALUATE Retry right away when connection failed
				// if(peerConnection.connectionState == "failed" && offerByMe) {
				// 	core.log(`#peer <${user.id}> Connection Failed -> Restart ICE`);
				// 	// if(user.dataChannel) user.dataChannel.close();
				// 	user.startToConnectTime = Date.now();
				// 	PeerNetwork.setupDataChannel(user);
				// 	peerConnection.restartIce();
				// }
			}
			
			// ICE: Candidate, Error, Connection, Gathering
			let candidateCount = 0
			peerConnection.onicecandidate = async event => {
				if (event.candidate) {
					core.log(`#peer <${user.id}> Gathered Local Ice Candidate ${++candidateCount} -> Send to peer`);
					ServerNetwork.sendIce(user.id, JSON.stringify(event.candidate));
				} else {
					core.log(`#peer <${user.id}> Gathered Local Ice Candidates Complete`);
				}
			}
			peerConnection.icecandidateerror = e => {
				core.log(`#peer <${user.id}> IDE Candidate Error: ${e.errorText}`);
			}
			// peerConnection.oniceconnectionstatechange = e => {
			// 	core.log(`#peer <${user.id}> ICE Connection State Change: ${peerConnection.iceConnectionState}`);
			// }
			// peerConnection.onicegatheringstatechange = e => {
			// 	core.log(`#peer <${user.id}> ICE Gathering State Change: ${peerConnection.iceGatheringState}`);
			// }
			
			// !!! EVALUATE Create offer right away, because sometimes "negotiationneeded" isn't fired
			// if(offerByMe) PeerNetwork.createOffer(user);
			
			return peerConnection;
		} 
		catch(e) {
			core.log("#peer <"+user.id+"> setupPeerConnection failed " + e.message)
			console.error(e);
			core.log(e.stack);
			return null;
		}

	private js void setupDataChannel: InternalUser user
		try {
			user.startDataChannelTime = Date.now();
			// !!! EVAL
			// if(user.dataChannels.length > 0) {
			// 	core.log("#peer <"+user.id+"> Data Channel We still have open data channels, don't create a new one");
			// 	return
			// }
			
			core.log("#peer <"+user.id+"> Data Channel Creating");
			
			// !!! EVALUATE: List of data channels
			// if(user.dataChannel) {
			// 	core.log("#peer <"+user.id+"> Closing previous Data Channel");
			// 	user.dataChannel.onopen = null;
			// 	user.dataChannel.onclosing = null;
			// 	user.dataChannel.onclose = null;
			// 	user.dataChannel.onerror = null;
			// 	user.dataChannel.onmessage = null;
			// 	user.dataChannel.close();
			// 	user.dataChannel = null;
			// 	core.log("#peer <"+user.id+"> Closed previous Data Channel");
			// }
			// user.dataChannel = null
			
			// Close all previous data channels
			for(let dataChannel of user.dataChannels) {
				try   { 
					dataChannel.close();
					core.log("#peer <"+user.id+"> Data Channel Closing previous channel (id:"+dataChannel._id+")");
				} catch {}
			}
			user.dataChannels.length = 0;
			
			// Create reliable data channel
			// let dataChannel = user.peerConnection.createDataChannel("channel"); // reliable
			let dataChannel = user.peerConnection.createDataChannel("channel", {ordered:false, maxRetransmits:0}); // unreliable
			dataChannel.binaryType = "arraybuffer";
			dataChannel._id = PeerNetwork.dataChannelId++;
			
			// Open
			dataChannel.onopen = e => {
				user.dataChannels.splice(0,0,dataChannel);
				core.log("#peer <"+user.id+"> Data Channel Open (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
			}
			
			// Close, Error
			dataChannel.onclosing = e => {
				user.dataChannels.remove();
				core.log("#peer <"+user.id+"> Data Channel Closing (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
			}
			dataChannel.onclose = e => {
				user.dataChannels.remove();
				core.log("#peer <"+user.id+"> Data Channel Close (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
			}
			dataChannel.onerror = e => {
				core.log("#peer <"+user.id+"> Data Channel Error " + ev.error.message+" (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
			}
			
			// Message
			dataChannel.onmessage = e => {
				// core.log("#data <"+user.id+"> received " + e.data.byteLength + " bytes on channel "+ dataChannel._id);
				PeerNetwork.onMessage(user, new Buffer(e.data, 0, 0, 0));
			}
		} 
		catch(e) {
			core.log("#peer <"+user.id+"> setupDataChannel failed " + e.message)
			console.error(e);
			core.log(e.stack);
		}
		
	onConnected: InternalUser user
		user.startDataChannelTime = user.lastIncomingMessageTime = Time.realTime
		logConnectionType user
		
		if user.offerByMe
			setupDataChannel user
		
		if not statistics.connectTime
			int connectedCount = input.internalUsers.count.offerByMe and .connected
			int offerCount = input.internalUsers.count.offerByMe
			core.log "#peer Connected on try {user.connectionTries}, {connectedCount} of {offerCount} my offers are connected"
			
			if input.internalUsers.none.offerByMe and not .connected
				statistics.connectTime = Time.preciseTime - statistics.startTime
				core.log "#peer All my offers are connected after {statistics.connectTime} ms and {retries} retries"
			
	disconnect: InternalUser user
		user.dataChannels.each.close()
		if user.peerConnection != null: user.peerConnection.close
		input.internalUsers[user.id] = null
		
	js void setBitrate: InternalUser user, float scaleResolutionDownBy = 1, float maxBitrate
		try {
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
		}
		catch(e) {
			core.log("#peer <"+user.id+"> setBitrate failed " + e.message)
			console.error(e);
			core.log(e.stack);
		}
				
	private js void createOffer: InternalUser user
		try {
			core.log("#peer <"+user.id+"> Sending offer to "+user.id+", waiting for answer. Try:"+user.connectionTries);
			let peerConnection = user.peerConnection
			let offer = await peerConnection.createOffer();
			await peerConnection.setLocalDescription(offer);
			ServerNetwork.sendSignal(user.id, "offer", peerConnection.localDescription.sdp)
			user.receivedAnswer = false

			// !!! EVALUATE Reconnect using timeout
			// setTimeout(() => {
			// 	let state = peerConnection.connectionState 
			// 	core.log(`#peer <${user.id}> Checking connection state after ${retryIfNotConnectedAfter}: ${state}`);
			// 	if(state != "connected") {
			// 		peerConnection.restartIce();
			// 		PeerNetwork.retries++
			// 	}
			// }, retryIfNotConnectedAfter);
		}
		catch(e) {
			core.log("#peer <"+user.id+"> createOffer failed " + e.message)
			console.error(e);
			core.log(e.stack);
		}
		
	js void onReceivedOffer: InternalUser user, string sdp
		try {
			core.log("#peer <"+user.id+"> Received offer -> Send answer");
			PeerNetwork.setupPeerConnection(user, /*offerByMe*/false);
			PeerNetwork.setupRemoteMedia(user);

			// Data channel
			user.peerConnection.ondatachannel = e => {
				core.log("#peer <"+user.id+"> Data Channel Received");
				let dataChannel = e.channel;
				dataChannel.binaryType = "arraybuffer";
				dataChannel._id = PeerNetwork.dataChannelId++;
				
				// Open
				dataChannel.onopen = e => {
					PeerNetwork.logConnectionType(user);
					user.dataChannels.splice(0,0,dataChannel);
					core.log("#peer <"+user.id+"> Data Channel Open (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
				}
				
				// Close, Error
				dataChannel.onclosing = e => {
					user.dataChannels.remove(dataChannel);
					core.log("#peer <"+user.id+"> Data Channel Closing (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
				}
				dataChannel.onclose = e => {
					user.dataChannels.remove(dataChannel);
					core.log("#peer <"+user.id+"> Data Channel Close (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
				}
				dataChannel.onerror = e => {
					core.log("#peer <"+user.id+"> Data Channel Error "+e.error.message+" (id:"+dataChannel._id+", length: "+user.dataChannels.length+")");
				}
				
				// Message
				dataChannel.onmessage = e => {
					// core.log("#data <"+user.id+"> received " + e.data.byteLength + " bytes on channel "+ dataChannel._id);
					PeerNetwork.onMessage(user, new Buffer(e.data, 0, 0, 0));
				}
			}
						
			// Answer
			let peerConnection = user.peerConnection;
			await peerConnection.setRemoteDescription(new RTCSessionDescription({type: "offer", sdp}));
			let answer = await peerConnection.createAnswer();
			await peerConnection.setLocalDescription(answer);
			ServerNetwork.sendSignal(user.id, "answer", peerConnection.localDescription.sdp);
		}
		catch(e) {
			core.log("#peer <"+user.id+"> onReceivedOffer failed " + e.message)
			console.error(e)
			core.log(e.stack);
		}
		
	Buffer sendBuffer = {}
	
	private js int send: InternalUser user, Buffer buffer
		if(user.dataChannels.length == 0) {
			core.log("#data <"+user.id+"> Trying to send without dataChannels")
		}
		try {
			let data = buffer.toByteArray()
			let channel = user.dataChannels[0]
			channel.send(data)
			// core.log("#data <"+user.id+"> send " + data.byteLength + " bytes on channel "+ channel._id)
			return data.byteLength
		} 
		catch(e) {
			core.log("#peer <"+user.id+"> send failed " + e.message)
			console.error(e)
			core.log(e.stack)
			return 0
		}
	
	private onMessage: InternalUser user, Buffer buffer
		user.lastIncomingMessageTime = Time.realTime
		NetworkMessageType type = cast buffer.readInt8
		if type == Tick:         onTick user, buffer; else
		if type == Ping:         onPing user, buffer; else
		if type == Pong:         onPong user, buffer;
			
	sendInputs: int inputFrame
		let inputs = input.localUser.inputs
		for input.internalUsers -> receiver if receiver
			let length = inputs.writePos - receiver.receivedMyInputsUpToPos
			
			if not receiver.local and receiver.dataChannels
				sendBuffer.reset
				sendBuffer.writeInt8 cast NetworkMessageType.Tick
				sendBuffer.writeInt inputFrame                       // I send inputs up to and including this frame
				sendBuffer.writeInt receiver.receivedMyInputsUpToPos // I send inputs starting from the last pos you received
				sendBuffer.writeInt receiver.inputs.writePos         // I received your inputs up to this pos
				sendBuffer.writeBuffer inputs, receiver.receivedMyInputsUpToPos, length
				sendBuffer.writeInt core.lastChecksumFrame                           // The last certain frame with inputs from everybody
				sendBuffer.writeFloat64 core.checksums[core.lastChecksumFrame] || 0  // The checksum of the last certain frame
				
				core.tickMessageSize = send ., sendBuffer
				
				if core.verbose
					if receiver.receivedMyInputsUpToPos > inputs.writePos
						core.log "[{inputFrame}] <{receiver.id}> #send -->> {receiver.receivedMyInputsUpToPos}->{inputs.writePos} id:{receiver.dataChannels[0]._id}"
					else
						core.log "[{inputFrame}] <{receiver.id}> #send -->>"
				
				core.log "[{inputFrame}] <{receiver.id}> #send -->> The other <{receiver.id}> received up to {receiver.receivedMyInputsUpToPos} and I'm <{input.localUser.id}> sending {length} bytes, from {receiver.receivedMyInputsUpToPos} to {inputs.writePos}"
		
	private onTick: InternalUser sender, Buffer buffer
		let inputFrame = buffer.readInt                     // The sender sent inputs up to and including this frame
		
		if inputFrame >= sender.inputFrame
			let prevInputFrame = sender.inputFrame         
			let incomingInputsWritePos = buffer.readInt     // The sender sent inputs starting from the last pos I received
			sender.receivedMyInputsUpToPos = buffer.readInt // The sender received my inputs up to this pos
			
			sender.inputFrame = inputFrame
			let length = buffer.readBuffer sender.inputs, incomingInputsWritePos
			
			core.log "[{inputFrame}] <{sender.id}> #receive <<-- I <{input.localUser.id}> received {length} bytes, up to {sender.inputs.writePos} from {sender.id}"
			
			if core.verbose
				if sender.inputs.writePos > incomingInputsWritePos
					core.log "[{inputFrame}] <{sender.id}> #receive <<-- writePos: {incomingInputsWritePos}->{sender.inputs.writePos}"
				else
					core.log "[{inputFrame}] <{sender.id}> #receive <<--"
			
			// Checksum
			int checksumFor = buffer.readInt
			float checksum = buffer.readFloat64
			if core.verbose: core.log "<{sender.id}> #{checksumFor} {checksum}"
			
			let myChecksum = core.checksums[checksumFor]
			if !myChecksum                           core.checksums[checksumFor] = checksum; else
			if !myChecksum.isApproximately(checksum) core.onWrongChecksum checksumFor, mine:myChecksum theirs:checksum
				
			// Store incoming inputs
			if length: core.storeInputsToDB sender
		
	js void onReceivedAnswer: InternalUser user, string sdp
		core.log("#peer <"+user.id+"> Received Answer");
		try {
			await user.peerConnection.setRemoteDescription(new RTCSessionDescription({type: "answer", sdp}));
			user.receivedAnswer = true
		}
		catch(e) {
			core.log("#peer <"+user.id+"> onReceivedAnswer failed " + e.message)
			core.log(e.stack);
		}	
			
	js void onIce: InternalUser user, string candidate
		core.log("#peer <"+user.id+"> Received Ice Candidate");
		try {
			await user.peerConnection.addIceCandidate(new RTCIceCandidate(JSON.parse(candidate)));
		}
		catch(e) {
			core.log("#peer <"+user.id+"> onIce failed " + e.message)
			core.log(e.stack);
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
				core.log("#connection <"+user.id+"> connection "+user.connectionType)
			} else {
				core.log("#connection <"+user.id+"> connection: no candidate pair for "+user.id)
				window.stats = [...stats.values()]
				console.log(window.stats)
				try  { core.log(JSON.stringify(window.stats)) }
				catch{ }
			}
		}, 10000)
		
	// --------------------------------------------- Ping/Pong ---------------------------------------------
	
	ping
		for input.internalUsers -> user
			if user and user.dataChannels
				sendBuffer.reset
				sendBuffer.writeInt8 cast NetworkMessageType.Ping
				sendBuffer.writeFloat64 core.currentTime
				send ., sendBuffer
				
	private onPing: InternalUser user, Buffer buffer
		float pingTime = buffer.readFloat64
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Pong
		sendBuffer.writeFloat64 pingTime
		send user, sendBuffer
		
	private onPong: InternalUser user, Buffer buffer
		float now = core.currentTime
		float pingTime = buffer.readFloat64
		float pingPongTime = now - pingTime
		let player = input.players.find.id == user.id
			statistics.add "pingPongTime" userIndex:player.index, color:player.color, value:pingPongTime, set:3, isPerFrame:false
				
	// --------------------------------------------- Checksum ---------------------------------------------
	
	sendChecksum: int checksumFor, float checksum
		sendBuffer.reset
		sendBuffer.writeInt8 cast NetworkMessageType.Checksum
		sendBuffer.writeInt checksumFor
		sendBuffer.writeFloat64 checksum
		
		for input.internalUsers -> user
			if user and user.dataChannels
				send ., sendBuffer

	onChecksum: InternalUser user, Buffer buffer
		int checksumFor = buffer.readInt
		float checksum = buffer.readFloat64
		if core.verbose: core.log "<{user.id}> #{checksumFor} {checksum}"
		
		let myChecksum = core.checksums[checksumFor]
		if !myChecksum
			core.checksums[checksumFor] = checksum
		else
		if !myChecksum.isApproximately(checksum)
			core.onWrongChecksum checksumFor, mine:myChecksum theirs:checksum
				
	// --------------------------------------------- Media Setup ---------------------------------------------
	
	MediaDevices devices = {}
	string videoInputId, audioInputId, audioOutputId	
	
	js async void setupLocalMedia: bool enableVideo, bool enableAudio
		core.log("setupLocalMedia: start")
		PeerNetwork.enableVideo = enableVideo
		PeerNetwork.enableAudio = enableAudio
		if(!enableVideo && !enableAudio) return
			
		try {
			// Create local media stream
			input.localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
				video: {width: 500, height: 375},
				audio: enableAudio
			});
			core.log("setupLocalMedia: getUserMedia done")
			
			// Enummerate local devices
			let devices = await navigator.mediaDevices.enumerateDevices();
			core.log("setupLocalMedia: enumerateDevices done")
			
			for(let device of devices) {
				switch(device.kind) {
					case "videoinput":  PeerNetwork.devices.videoInput.push(device); break;
					case "audioinput":  PeerNetwork.devices.audioInput.push(device); break;
					case "audiooutput": PeerNetwork.devices.audioOutput.push(device); break;
				}
			}
			PeerNetwork.videoInputId = input.localUser.mediaStream.getVideoTracks()[0]?.getSettings().deviceId || PeerNetwork.devices.videoInput[0]?.deviceId
			PeerNetwork.audioInputId = input.localUser.mediaStream.getAudioTracks()[0]?.getSettings().deviceId || PeerNetwork.devices.audioInput[0]?.deviceId
			PeerNetwork.audioOutputId = PeerNetwork.devices.audioOutput[0]?.deviceId
			statistics.cameraTime = performance.now() - statistics.startTime
			core.log("#camera Setup Local Camera and Microphone after "+statistics.cameraTime+" ms")
			
		} catch(error) {
			core.log(error.message)
			if(error.name == "NotAllowedError") {
				PeerNetwork.error = "To play with friends over a video call, you need to allow access to your webcam."
			} else {
				PeerNetwork.error = "Can't access webcam. Please make sure it's not used by another application."
			}
			core.errorMessage = error.message
			throw error
		}
	
	js void setVideoInput: string videoInputId
		                   Player player
		if(Platform.fastForward || input.localUser.id != player.id ||  PeerNetwork.videoInputId == videoInputId || !videoInputId) return;
		PeerNetwork.videoInputId = videoInputId;
		
		// Create local media stream
		input.localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
			audio: {deviceId: PeerNetwork.audioInputId},
			video: {deviceId: PeerNetwork.videoInputId},
		});
		
		// Update video elements and tracks
		for(let el of input.localUser.videoElements) {
			el.srcObject = input.localUser.mediaStream;
		}
		const [videoTrack] = input.localUser.mediaStream.getVideoTracks();
		for(let user of input.internalUsers) {
			if(user?.peerConnection) {
				const sender = user.peerConnection.getSenders().find((s) => s.track.kind === videoTrack.kind);
				sender.replaceTrack(videoTrack);
			}
		}
			
	js void setAudioInput: string audioInputId
		                   Player player
		if(Platform.fastForward || input.localUser.id != player.id || PeerNetwork.audioInputId == audioInputId || !audioInputId) return;
		PeerNetwork.audioInputId = audioInputId;
		
		// Create local media stream
		input.localUser.mediaStream = await navigator.mediaDevices.getUserMedia({
			audio: {deviceId: PeerNetwork.audioInputId},
			video: {deviceId: PeerNetwork.videoInputId},
		});
		
		// Update tracks
		const [audioTrack] = input.localUser.mediaStream.getAudioTracks();
		for(let user of input.internalUsers) {
			if(user?.peerConnection) {
				const sender = user.peerConnection.getSenders().find((s) => s.track.kind === audioTrack.kind);
				sender.replaceTrack(audioTrack);
			}
		}
			
	js void setAudioOutput: string audioOutputId
		                    Player player
		if(Platform.fastForward || input.localUser.id != player.id || PeerNetwork.audioOutputId == audioOutputId || !audioOutputId) return;
		PeerNetwork.audioOutputId = audioOutputId;
		
		// Update audio elements
		for(let user of input.internalUsers) {
			if(user) {
				if(user.audioElement && user.audioElement.setSinkId) {
					user.audioElement.setSinkId(PeerNetwork.audioOutputId);
				}
				for(let videoElement of user.videoElements) {
					if(videoElement.setSinkId) {
						videoElement.setSinkId(PeerNetwork.audioOutputId);
					}
				}
			}
		}
		audio.reload();
		
	private js void setupRemoteMedia: InternalUser user
		// Remove old video elements
		for(let videoElement of user.videoElements)
			videoElement.remove()
		user.videoElements.length = 0
		
		if(!PeerNetwork.enableVideo && !PeerNetwork.enableAudio) return
			
		// Add local tracks to peer connection
		for(let track of input.localUser.mediaStream.getTracks())
			user.peerConnection.addTrack(track, input.localUser.mediaStream);
		
		// Create media stream for remote player
		user.mediaStream = new MediaStream();
		
		// Add incoming tracks to media stream for remote player
		user.peerConnection.ontrack = event => {
			core.log("#peer <"+user.id+"> Add track");
			event.streams[0].getTracks().forEach(track => {
				user.mediaStream.addTrack(track);
			});
		}
		user.peerConnection.onremovetrack = event => {
			core.log("#peer <"+user.id+"> Remove track");
		}

	// --------------------------------------------- Media elements ---------------------------------------------
	
	js object createVideoElement: object stream, bool local
		let el = document.createElement("video")
		el.style = "border-radius: 500px; object-fit: cover; position:absolute; top:0px; left:0px; z-index:10000; visibility:hidden; pointer-events: none; user-select: none; "+(local ? "transform: scaleX(-1)" : "")
		el.autoplay = true
		el.playsinline = true
		el.controls = false
		el.muted = local
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

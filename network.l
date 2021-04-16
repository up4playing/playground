class Message
	int senderId
	
Message TickMessage
	int frames
	int acknowledgeFrames
	int[][] inputs
	int checksumFor
	float checksum
	
Message PingMessage
	float pingTime
	
Message PongMessage
	float timeSinceStart
	float pingTime

enum ConnectionState: Disconnected, WaitingForFirstTickMessage, Connected

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
	Vector2 pos
	float width

unit Network
	// Logs
	string log = "tickTime,networkTime,networkFrame,inputFrame,user0,user1,user2,logic,received,ahead,logicFrames,events,send,receive,parse,touch\n"
	public string eventLog = ""; sentLog = "", receivedLog="", parseLog = "", touchLog = ""
	private float lastNetworkFrame, lastTick
	
	internal targetFps = 30
	private inputFrameEvery = 2, maxAhead = 10, pingCount = 10
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
	
	private startConnected: float startTime = 0
		if mode == Connected: return
		let now = Platform.now
		this.startTime = startTime || now
		networkFrame = Math.floor((now - this.startTime)/targetFrameTime)
		startInputFrame = inputFrame = Math.floor(networkFrame / inputFrameEvery) + 1
		Input.users[userId].startInputFrame startInputFrame
		print "Start connected. startTime:"+this.startTime+" networkFrame:"+networkFrame+" startInputFrame:"+startInputFrame
		eventLog += "Start connected"
		mode = Connected
		
	startLocal: userCount = 1
		userId = 0
		Math.setRandomSeed Math.generateRandomSeed
		Input.users.clear
		for userCount: Input.users.add {id:i, local:true}
		startTime = Platform.now
		mode = Local
		startApp
		
	js void startApp
		Network_inLobby = false
		if(window.app_start) app_start()
		
	resetStartTime
		startTime = Platform.now
		
	internal tick
		let now = Platform.now
		if mode == None || mode == Ping || mode == Reconnecting
			graphics.matrix = Platform.baseMatrix
			graphics.appMatrix.clear
			graphics.clearScreen
			if mode == Ping: ping
			if mode == Reconnecting: reconnect
			else                     lobby.tick
			updateVideoScreen
			return
			
		let targetFrame = Math.floor((now - startTime)/targetFrameTime)
		if mode == Local && targetFrame > networkFrame + targetFps*2
			// After a long pause in local mode, we do not want to process all missed frames, so we adjust the start time
			let prevTargetFrame = targetFrame
			targetFrame = networkFrame
			startTime = now - targetFrame*targetFrameTime - (targetFrameTime-0.001)
			print "Paused {prevTargetFrame-networkFrame} frames, adjusting startTime. prevTargetTime:{prevTargetFrame} networkFrame:{networkFrame} targetFrame:{Math.floor((now - startTime)/targetFrameTime)}"
			
		while networkFrame <= targetFrame
			let localPlayer = Input.users[userId]
			bool isInputFrame = (networkFrame % inputFrameEvery) == 0
			inputFrame = Math.floor(networkFrame / inputFrameEvery) + 1
			int startLogicFrame = logicFrame
			
			if isInputFrame
				localPlayer.startInputFrame inputFrame
				
				if mode == Connected
					for c -> connections
						if c.state == Connected
							let p = Input.users[c.userId]
							TickMessage message = {
								senderId:this.userId
								frames:localPlayer.frames
								acknowledgeFrames:p.frames
								checksumFor: logicFrame-1
								checksum: checksums[logicFrame-1]
							}
							int startFrame = cast Math.max(startInputFrame, p.acknowledgedFrames)
							sentLog += " <"+c.userId+">"
							for f = startFrame -> localPlayer.frames
								message.inputs.add localPlayer.inputs[f]
								sentLog += " ["+f+"]"
								for input -> localPlayer.inputs[f]: sentLog += " "+input
							send c, message
			
			int receivedFrames = getReceivedFrames * inputFrameEvery
			if logicFrame < receivedFrames - maxAhead
				eventLog += " >>> catching up logicFrame:"+logicFrame+" receivedFrames:"+receivedFrames
				print " >>> catching up logicFrame:"+logicFrame+" receivedFrames:"+receivedFrames
				while logicFrame < receivedFrames - 1
					step fastFordward:true
				print " <<< catching up done"
					
			if logicFrame < receivedFrames
				step
			
			// Logs	
			log += ""+(now - lastTick)+","+(now - lastNetworkFrame)+","+networkFrame+","+inputFrame
			log += ","+(Input.users[0] ? Input.users[0].frames : 0)
			log += ","+(Input.users[1] ? Input.users[1].frames : 0)
			log += ","+(Input.users[2] ? Input.users[2].frames : 0)
			log += ","+logicFrame+","+receivedFrames+","+(receivedFrames-logicFrame)+","
			for i = startLogicFrame -> logicFrame
				log += "("+i+") "+checksums[i]
			log += ","+eventLog+","+sentLog+","+receivedLog+","+parseLog+","+touchLog+"\n"
			eventLog = ""; sentLog = ""; receivedLog = ""; parseLog = ""; touchLog = ""

			networkFrame++
			lastNetworkFrame = now
		lastTick = now
		
	private getReceivedFrames
		if mode == Local: return Input.users[userId].frames
		int minFrames = 0
		for user -> Input.users
			if user && user.frames && (!minFrames || user.frames < minFrames)
				minFrames = user.frames
		return minFrames
		
	private step: bool fastFordward = false
		Platform.fastForward = fastFordward
		
		// Parse inputs
		bool isInputFrame = logicFrame % inputFrameEvery == 0
		if isInputFrame: Input.parseInputs(Math.floor(logicFrame / inputFrameEvery))
		
		// Tick
		framework.tick
		drawFingers
		updateVideoScreen
		graphics.drawSafeArea
		Input.updateCursor
		
		// Checksum
		let myChecksum = 0
		for framework.objects:
			myChecksum += position.x + position.y + frame + cast side
			if type == Board
				Board board = cast o
				float[] m = board.matrix.matrix
				myChecksum += m[0] + m[1] + m[2] + m[3] + m[4] + m[5]
				
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
				
		logicFrame++
		
	private onWrongChecksum
		eventLog += "%%% OUT OF SYNC %%%"
		if !alertShown
			alert "Clients out of sync. Please click 'Save Logs' and send me the log file that will be created."
			alertShown = true
			
	private onPeerMessage: Connection c, Message message
		if message.type == TickMessage: onTickMessage c, cast message
		if message.type == PingMessage: onPing c, cast message
		if message.type == PongMessage: onPong c, cast message

	private onTickMessage: Connection c, TickMessage message
		let sender = Input.users[message.senderId]
		if c.state != Connected: c.state = Connected

		receivedLog += " <"+message.senderId+"> "+message.acknowledgeFrames
		sender.frames = message.frames
		sender.acknowledgedFrames = message.acknowledgeFrames
		let startFrame = message.frames - message.inputs.length
		for i, item -> message.inputs
			sender.inputs[startFrame + i] = item
			receivedLog += " ["+(startFrame + i)+"]"
			for input -> item: receivedLog += " "+input
				
		// Checksum
		let myChecksum = checksums[message.checksumFor] 
		if !myChecksum
			checksums[message.checksumFor] = message.checksum
		else
			if myChecksum != message.checksum: onWrongChecksum
			eventLog += " ["+message.checksumFor+"] mine:"+myChecksum+" theirs:"+message.checksum
			
	private float nextPingTime
	private float estimatedStartTimeTotal
	private int pongCount
	
	private onConnectedToPeer: Connection connection
		                       bool isNewUser // Did this user just join the already exiting users (and make the offer)
		
		if mode == Reconnecting
			print "onConnectedToPeer: successfully reconnected"
			mode = Connected
			connection.state = Connected
			showLocalVideo
			return
		
		// The first user will enter the "connected" state right away, all later uers will first 
		// ping the existing users to sync the startTime and calculate the networkFrame from it
		if mode == None
			mode = Ping
			nextPingTime = Platform.now + 300
			
		// New users will start sending tick messages as soon as they are done with pinging,
		// existing users will wait for the new user to finish pinging
		// to prevent sending the large initial message several times
		connection.state = isNewUser ? Connected : WaitingForFirstTickMessage
		
		print "onConnectedToPeer userId:"+userId+" mode:"+mode
		
	private onDisconnectFromPeer: Connection connection
		print "onDisconnectFromPeer userId:"+connection.userId
		closeConnection connection
		connection.state = Disconnected
		mode = Reconnecting
		nextReconnect = Platform.now + 1000
	
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
		let vs = Network_videoScreens[Network_userId];
		if(vs) vs.videoElement.style.visibility = "hidden";
		
	private reconnect
		drawText "Lost connection. Trying to reconnect...", size:24
		if Platform.now >= nextReconnect
			print "Trying to reconnect"
			join roomId
			nextReconnect = Platform.now + 7500
	
	private ping
		if Platform.now >= nextPingTime
			for c -> connections
				if c.state != Disconnected
					send c, PingMessage(this.userId, Platform.now)
			nextPingTime = Platform.now + 300
		
	private onPing: Connection c, PingMessage message
		if c.state != Disconnected
			send c, PongMessage(userId, Platform.now-startTime, message.pingTime)
		
	private onPong: Connection c, PongMessage message
		float now = Platform.now
		float pingPongTime = now - message.pingTime
		float estimatedStartTime = now - pingPongTime/2 - message.timeSinceStart
		print "user:"+message.senderId+" count:"+pongCount+" pingPongTime: "+pingPongTime+" estimatedStartTime:"+estimatedStartTime
		eventLog += "user:"+message.senderId+" count:"+pongCount+" pingPongTime: "+pingPongTime+" estimatedStartTime:"+estimatedStartTime
		if pongCount >= 2: estimatedStartTimeTotal += estimatedStartTime
		if ++pongCount >= pingCount
			startConnected startTime: estimatedStartTimeTotal / (pongCount - 2)
			
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
		
	private onConnectedToServer
		// Disabled rejoining with the same id to support testing in two browser tabs
		// if userId == -1
		//	RoomInfo roomInfo = cast Platform.getLocalStorageObject "room"+roomId
		//	userId = roomInfo && roomInfo.time > Platform.now - 3600000*24 ? roomInfo.userId : -1
		print "onConnectedToServer "+roomId+" with user "+userId
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
		print "onJoinResponse room:"+message.roomId+" userId:"+message.userId
		if mode == Reconnecting
			print "onJoinResponse: Reconnecting to "+roomId+" with user "+userId
			int[] partnerIds
			for c -> connections
				if c: print "Connection "+c.userId+" state:"+c.state+" offerByMe:"+c.offerByMe
				else  print "Connection null"
				if c && c.state == Disconnected && c.offerByMe
					partnerIds.add c.userId
			createOffers partnerIds
		else
			eventLog += Platform.dateAndTimeString + " local version:" + Platform.version + " user agent:"+Platform.userAgent+" "
			
			roomId = message.roomId
			userId = message.userId
			Input.users[message.userId] = {id:userId, local:true}
			Platform.setLocalStorageObject "room"+roomId, RoomInfo(Platform.now, userId)
			
			if message.version != Platform.version
				alert "You are using an old version of this application. Please refresh your browser."
			Math.setRandomSeed message.seed
			
			createOffers message.partnerIds
			
			// The first user will enter the "connected" state right away, all later uers will first 
			// ping the existing users to sync the startTime and calculate the networkFrame from it
			if userId == 0: startConnected
	
	private onSignal: SignalMessage message
		print "on signal: "+message.signal.type+" "+message.senderId+" -> "+message.signal.receiverId
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
	
	private Connection createConnection: int partnerId, bool offerByMe
		let connection = connections.find(a.userId == partnerId)
		if connection
			connection.state = Disconnected
			connection.dataChannel = null
		else
			connections.add connection = Connection(partnerId)
		connection.peerConnection = setupPeerConnection(connection)
		connection.offerByMe = offerByMe
		if !Input.users[partnerId]: Input.users[partnerId] = {id:partnerId, local:false}
		return connection
		
	private js void createOffers: int[] partnerIds
		if(!Network_localVideo) await Network_setupLocalVideo(Network_userId);
		let offers = [];
		
		for(let partnerId of partnerIds) {
			try {
				// Peer connection
				let connection = Network_createConnection(partnerId, /*offerByMe*/true)
				let peerConnection = connection.peerConnection
				console.log("createOffers: Created peer connection for partner "+partnerId)
				
				// Data channel
				let dataChannel = peerConnection.createDataChannel("channel", {ordered: false, maxRetransmits: 0})
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
				dataChannel.onmessage = e => Network_onPeerMessage(connection, JSON.parse(e.data));
				console.log("createOffers: Created data channel")
				
				// Video
				Network_setupRemoteVideo(partnerId, peerConnection)
				
				// Offer
				let offer = await peerConnection.createOffer();
				await peerConnection.setLocalDescription(offer);
				console.log("Created offer: ", offer);
				offers.push({receiverId:partnerId, type: "offer", sdp: peerConnection.localDescription.sdp})
				console.log("createOffers: Created and sent offer, waiting for answer");
			}
			catch(e) {
				console.error(e)
			}
		}
		if(offers.length) Network_sendToServer(new OffersMessage(Network_userId, offers));
		
	private js void onReceivedOffer: int partnerId, Signal offer
		try {
			// Peer connection
			let connection = Network_createConnection(partnerId, /*offerByMe*/true)
			let peerConnection = connection.peerConnection
			console.log("onReceivedOffer: created peer connection for partner "+partnerId)
			
			// Data channel
			peerConnection.addEventListener('datachannel', e => {
				console.log("onReceivedOffer: received datachannel")
				let dataChannel = e.channel
				connection.dataChannel = dataChannel
				dataChannel.onopen = e => {
					log("onReceivedOffer: connection opened!")
					Network_logConnectionType(peerConnection);
					Network_onConnectedToPeer(connection, /*isNewUser*/false);
				}
				dataChannel.onmessage = e => Network_onPeerMessage(connection, JSON.parse(e.data));
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
			console.log("onReceivedOffer: Created and sent answer, waiting for connection");
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
		if(connection) await connection.peerConnection.addIceCandidate(new RTCIceCandidate(message.iceCandidate));
		
	private js void send: Connection connection, Message message
		// if(Math.random() < .5) setTimeout(() => Network_dataChannel.send(JSON.stringify(message)), Math.random()*250)
		connection.dataChannel.send(JSON.stringify(message))
		
	private js void setupLocalVideo: int userId
		Network_localVideo = await navigator.mediaDevices.getUserMedia({video: true, audio: true});
		Network_createVideoElement(userId, Network_localVideo, /*local*/true)

	private js void showLocalVideo
		let vs = Network_videoScreens[Network_userId]
		if(vs) vs.videoElement.style.visibility = "visible";
			
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
		el.style = "position:absolute; top:0px; left:0px; z-index:10000;"+(local ? "transform: scaleX(-1)" : "")
		el.autoplay = true
		el.playsinline = true
		el.controls = false
		el.muted = local
		document.body.appendChild(el)
		el.srcObject = stream;
		let vs = Network_videoScreens[userId] || (Network_videoScreens[userId] = new VideoScreenInfo(null, new Vector2, new Vector2))
		vs.videoElement = el
		
	setUserVideoAndColor: int userId = 0, Vector2 pos = {}, float width = 440, Color color = null
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
				if(vs.videoElement) {
					let el = vs.videoElement
					let pixelPos = Input_logicalToPixelPosition(vs.pos)
					let m = graphics_matrix.matrix
					let pixelSizeX = vs.width*m[0]/Platform_pixelRatio
					let pixelSizeY = (vs.width*3/4)*m[3]/Platform_pixelRatio
					el.style.left = (pixelPos.x-pixelSizeX/2)+"px"
					el.style.top = (pixelPos.y-pixelSizeY/2)+"px"
					el.style.width = pixelSizeX+"px"
					el.style.height = pixelSizeY+"px"
				}
			}
		}
		
	internal drawFingers
		for user -> Input.users
			if !local
				drawImage finger, touchPos+{11,34}, frame:user.id
				if color: drawRectangle touchPos+{16,76}, size:{26,8}, color
				
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

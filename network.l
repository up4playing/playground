enum NetworkMessageType: Tick, Ping, Pong, OwnInputsAfterReconnect
enum ConnectionState: Disconnected, Reconnecting, WaitingForFirstTickMessage, Connected

transient class Connection
	int userId
	object peerConnection = null
	object dataChannel = null
	ConnectionState state
	bool offerByMe
	
enum NetworkMode: None, Ping, Local, Connected, Reconnecting
transient class RoomInfo: int time, userId
	
transient unit Snapshot
	int autoSaveCount
	int lastSnapshotSize
	
	Buffer snapshots
	int[] snapshotStarts
	int snapshotEvery = 100
	
	private bool autoSaveAtEndOfStep
	
	inline js void serialize(Buffer buffer) serialize(buffer)
	inline js void deserialize(Buffer buffer) deserialize(buffer)
		
	Buffer save
		Buffer buffer
		serialize(buffer)
		return buffer
		
	restore: Buffer buffer
		deserialize(buffer)
		
	autoSave() autoSaveAtEndOfStep = true
	
	internal onEndOfStep
		if Input.isCertain
			if autoSaveAtEndOfStep and ++autoSaveCount > 5
				let snap = save
				IndexedDB.saveBuffer "snapshot", "{Network.gameId}-0", snap
				lastSnapshotSize = snap.writePos
				
			if Network.frame/snapshotEvery > snapshotStarts.length
				snapshotStarts.add snapshots.writePos
				serialize(snapshots)
			
			autoSaveAtEndOfStep = false
	
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

	reset
		this.writePos = 0
		this.readPos = 0   
		
	js void expandBuffer: int size
		let prevLength = this.buffer.byteLength
		let len = Math.max(prevLength*2, size)
		this.buffer = new ArrayBuffer(len)
		let prevDataView = this.dataView
		let newDataView = new DataView(this.buffer)
		for(let i=0; i<prevLength; i++)
			newDataView.setInt8(i, prevDataView.getInt8(i))
			
		// TEMP: Check if data is still the same after expanding
		Network_log("expand buffer from "+prevLength+" to "+len)
		for(let i=0; i<prevLength; i++)
			if(prevDataView.getInt8(i) != newDataView.getInt8(i))
				Network_log("expand failed at " + i 
				+" expected "+prevDataView.getInt8(i)
				+" got "+newDataView.getInt8(i))
				
		this.dataView = newDataView
		
	inline js void setInt16: int index, int value
		this.dataView.setInt16(index, value)
	
	js void writeInt8: int value
		if(this.writePos+1 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+1)
		this.dataView.setInt8(this.writePos, value)
		this.writePos += 1
	
	js void writeUnsignedInt8: int value
		if(this.writePos+1 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+1)
		this.dataView.setUint8(this.writePos, value)
		this.writePos += 1
	
	js void writeInt16: int value
		if(this.writePos+2 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+2)
		this.dataView.setInt16(this.writePos, value)
		this.writePos += 2
	
	js void writeUnsignedInt16: int value
		if(this.writePos+2 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+2)
		this.dataView.setUint16(this.writePos, value)
		this.writePos += 2
	
	js void writeInt32: int value
		if(this.writePos+4 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+4)
		this.dataView.setInt32(this.writePos, value)
		this.writePos += 4
	
	js void writeFloat64: float value
		if(this.writePos+8 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+8)
		this.dataView.setFloat64(this.writePos, value)
		this.writePos += 8
		
	js void writeBool: bool value
		if(this.writePos+1 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+1)
		this.dataView.setInt8(this.writePos, value ? 1 : 0)
		this.writePos += 1
		
	js void writeString: string value
		let len = value.length
		let size = 4+len*4
		if(this.writePos+size > this.buffer.byteLength)
			this.expandBuffer(this.writePos+size)
		this.dataView.setInt32(this.writePos, len)
		this.writePos += 4
		for(let i=0; i<len; ++i) {
			this.dataView.setInt32(this.writePos, value.charCodeAt(i))
			this.writePos += 4
		}
		
	void writeBuffer: Buffer source
		writeBuffer source, 0, source.writePos
	
	js void writeBuffer: Buffer source
		                 int start
		                 int length
		let readPos = start
		let writePos = this.writePos
		
		// Expand if neccessary
		if(writePos+length+4 > this.buffer.byteLength)
			this.expandBuffer(writePos+length+4)
			
		// Write length
		this.dataView.setInt32(writePos, length)
		writePos += 4
		
		// Write bytes
		let readPosEnd = start + length
		while(readPos < readPosEnd)
			this.dataView.setUint8(writePos++, source.dataView.getUint8(readPos++))
			
		this.writePos = writePos
		
	js void copyFromBuffer: Buffer source
		let readPos = 0
		let length = source.writePos
		let writePos = this.writePos
		
		// Expand if neccessary
		if(writePos+length > this.buffer.byteLength)
			this.expandBuffer(writePos+length)
			
		// Write bytes
		let readPosEnd = readPos + length
		while(readPos < readPosEnd)
			this.dataView.setUint8(writePos++, source.dataView.getUint8(readPos++))
			
		this.writePos = writePos
		
	inline js int peekInt8  := this.dataView.getInt8(this.readPos)
	inline js int peekInt16 := this.dataView.getInt16(this.readPos)
	inline js int peekInt32 := this.dataView.getInt32(this.readPos)
	
	js int readInt8
		return this.dataView.getInt8(this.readPos++)
		
	js int readUnsignedInt8
		return this.dataView.getUint8(this.readPos++)
		
	js int readInt16
		let value = this.dataView.getInt16(this.readPos)
		this.readPos += 2
		return value
		
	js int readUnsignedInt16
		let value = this.dataView.getUint16(this.readPos)
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
		               int writeStart = 0
		let readPos = this.readPos
		let writePos = writeStart
		
		// Read length
		let length = this.dataView.getInt32(readPos)
		readPos += 4
		
		// Expand writeBuffer if neccessary
		if(writeStart+length > writeBuffer.buffer.byteLength)
			writeBuffer.expandBuffer(writeStart+length)
			
		// Read bytes
		let readPosEnd = readPos + length
		while(readPos < readPosEnd)
			writeBuffer.dataView.setUint8(writePos++, this.dataView.getUint8(readPos++))
			
		this.readPos = readPos
		writeBuffer.writePos = writePos
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
	public int smoothStrength = 90
	public bool smoothTouchPosition = true
	
	string logTable = "frame,now,animTime,networkTime,tickTime,drawTime,iteration,restoreTime,replayFrames,replayTime,saveTime,user0,user1,user2,received,uncertain,offset,ahead,avarage,percentile,certainFrame,buffer,checksums,events,send,receive,write,parse,touch\n"
	public string eventLog = ""; sentLog = "", receivedLog="", writeLog="", parseLog = "", touchLog = "", checksumLog = "", debugString = ""
	private float lastNetworkFrame, lastAnimationFrame, drawTime, tickTime, restoreTime, replayTime, saveTime
	private int replayFrames, checkedChecksums
	private string lastError, connectionType
	
	internal const targetFps = 30
	private const pingCount = 6
	private const bufferFrames = 1
	const targetFrameTime = 1000/targetFps
	
	visible NetworkMode mode
	visible int userId = -1
	public bool simulateConnection = true
	
	private object localVideo = null
	
	private float startTime
	private int startInputFrame
	
	visible int frame               // Current frame, will increase by 1 at the end of every step (every targetFrameTime ms)
	private int frames              // Total number of frames we have inputs for
	private int receivedFrames      // We received all remote inputs up to this frame (lowest of all user frames)
	private int uncertainFrame = -1 // The first frame where we don't have inputs from all players
	private int certainFrame        // The last frame where we have inputs from all players
	private Buffer commonState      // A snapshot taken before the first uncertain frame
	
	internal int frameWithNewWatches = 0 // First frame with new watches, do not send watches for frames below this
		
	private float[] checksums
	private bool alertShown
	private int nextReconnect
	private bool isLocalhost
	private bool startInLobby
	private int ahead
	private int[] aheads
	private Buffer sendBuffer
	
	// TEMP
	bool skipAnimationFrame
	bool skipSending
	
	init
		Platform.showDebugInfo = isLocalhost = Platform.url.contains("localhost")
		
	initDatabase
		IndexedDB.start "up4playing", "snapshot", 5

	private startConnected: float startTime = 0
		if mode == Connected: return
		if startTime
			this.startTime = startTime
		else
			resetStartTime
		let user = Input.internalUsers[userId]
		user.startInputFrame 0
		
		int joinFrame = Math.floor((currentTime - this.startTime)/targetFrameTime)
		user.inputs.writeInt32 joinFrame
		user.inputs.writeInt16 cast InputType.Join
		user.collectInputs = true
		
		mode = Connected
		receivedFrames = -1
		certainFrame = -1
		log "Connected", userId, frame, startTime, this.startTime
		saveState
		
	startLocal: userCount = 1
		userId = 0
		mode = Local
		startInLobby = false
		certainFrame = int.maxValue
		Input.internalUsers.clear
		Math.setRandomSeed Math.generateRandomSeed
		initDatabase
		reset
		resetStartTime
		animationFrame
		
	// Clears all inputs and resets the application to the first frame
	stop
		for Input.internalUsers: .inputs.reset; .startInputFrame 0
		frames = 0
		frameWithNewWatches = 0
		startInLobby = false
		goToFrame 0
		lastError = ""
		
	// Calls init functions, creates the local users, resets read positions and starts app
	// This is called on startup, after every code change and when going backwards in the timeline
	reset
		Platform.initApplication
		
		// When the developer changed Platform.userCount, add or remove internal users accordingly
		for i = Input.internalUsers.length -> Platform.userCount
			Input.internalUsers.add {id:i, local:true, collectInputs:true}
		if Input.internalUsers.length > Platform.userCount
			Input.internalUsers.removeRange Platform.userCount, count: Input.internalUsers.length - Platform.userCount
		
		// We always recreating users, because developers might have added fields to NetworkUser or Touch
		// By the time we call startApp, all users need to exist
		Input.users.clear
		for Platform.userCount: Input.users.add {id:i}
			
		// Reset read pos to replay inputs from the beginning
		for Input.internalUsers: inputs.readPos = 0
			
		Math.randomValueIndex = 0
		frame = 0
		lobby.inLobby = startInLobby
		if !startInLobby: startApp
	
	// Steps forward when going to a frame in the future
	// or replays from the beginning when going to a frame in the past
	// This is called after every code change with replay = true 
	// to replay all inputs with the new code from the beginning,
	// and when stepping through the timeline with replay = false
	// to only replay from the beginning when going to a frame in the past
	goToFrame: int targetFrame, replay = false
		if replay: frameWithNewWatches = 0
		if targetFrame < frame or replay: reset
			
		while frame < targetFrame
			step fastFordward:true
		resetStartTime
		animationFrame

	// Smooth out animations by only executing code when we received inputs from everybody	
	smooth: int userId
		    void() code
		if Input.isCertain or this.userId == userId: code
	
	smooth: void() code
		if Input.isCertain: code
			
	// animationFrame --> step --> tick

	// animationFrame  Send tick message, replay state, and call step
	// step            Save state, parse inputs, step physics, process tick, and calculate checksum
	// tick            Clear screen, process application tick, and draw all graphics
		
	// Send tick message, replay state, call step, and logging
	// This is called by the requestAnimationFrame callback.
	// We ensure that step is called every targetFrameTime milliseconds.
	internal animationFrame
		let now = currentTime
		if skipAnimationFrame
			eventLog += " x"
			return
	
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
			
		// Ahead
		float aheadAverage
		int aheadPercentile
		let localPlayer = Input.internalUsers[userId]
		if mode == Connected and Input.users.length > 1
			let receivedCurrentFrames = getReceivedCurrentFrames
			ahead = frame - receivedCurrentFrames
			aheads.add ahead, maxLength:100
			localPlayer.aheadAverage = aheadAverage = aheads.average
			aheadPercentile = smoothStrength ? aheads.percentile(smoothStrength).limit(0, 50) : 0
		
		let targetFrame = Math.floor((now - startTime)/targetFrameTime)+1
		let nextInputFrame = targetFrame
		let frameMinusOffset = targetFrame - aheadPercentile
		certainFrame = mode == Connected ? Math.min(frameMinusOffset, receivedFrames) : int.maxValue

		if mode == Local && targetFrame > frame + targetFps*2
			// After a long pause in local mode, we do not want to process all missed frames, so we adjust the start time
			let prevTargetFrame = targetFrame
			targetFrame = frame
			startTime = now - targetFrame*targetFrameTime
			log "Paused {prevTargetFrame-frame} frames, adjusting startTime. prevTargetTime:{prevTargetFrame} frame:{frame} targetFrame:{Math.floor((now - startTime)/targetFrameTime)}"
		
		if frame < targetFrame
			let startFrame = frame
			try
				// Send each user the inputs that they haven't acknowleged yet
				if mode == Connected
					sendInputs nextInputFrame, targetFrame, aheadAverage
								
				// Replay all frames from the first uncertain frame until the current frame
				// when we received all inputs for frames that we were uncertain about before
				replayState
			
			catch 
				print error
				log error
				lastError = error.message
					
			// Ensure that step is called every targetFrameTime milliseconds
			while frame < targetFrame
				// Step
				step fastFordward:frame < targetFrame-1
				
				// Logs
				try
					logTable += "{frame-1},{now},{now - lastAnimationFrame},{now - lastNetworkFrame},{tickTime.format(fractionDigits:2)},{drawTime.format(fractionDigits:2)},{frame-startFrame}"
					logTable += ",{restoreTime.format(fractionDigits:2)},{replayFrames},{replayTime.format(fractionDigits:2)},{saveTime.format(fractionDigits:2)}"
					logTable += ","+(Input.internalUsers[0] ? Input.internalUsers[0].inputFrame : 0)
					logTable += ","+(Input.internalUsers[1] ? Input.internalUsers[1].inputFrame : 0)
					logTable += ","+(Input.internalUsers[2] ? Input.internalUsers[2].inputFrame : 0)
					logTable += ",{receivedFrames},{uncertainFrame},{frame - receivedFrames},{ahead},{aheadAverage.format(fractionDigits:1)}"
					logTable += ",{aheadPercentile},{certainFrame},{receivedFrames-frameMinusOffset}"
					logTable += ",\"{checksumLog.trim}\",\"{eventLog.trim}\",\"{sentLog.trim}\",\"{receivedLog.trim}\",\"{writeLog.trim}\",\"{parseLog.trim}\",\"{touchLog.trim}\"\n"
					eventLog = ""; sentLog = ""; receivedLog = ""; writeLog = ""; parseLog = ""; touchLog = ""; checksumLog = ""
				
				catch
					print error
					lastError = error.message
				
				// Debug string
				if Platform.showDebugInfo
					debugString = "v{Platform.version} ct:{connectionType} seed:{Math.randomSeed} w:"
					for user -> Input.internalUsers
						if user
							debugString += " " + user.inputs.writePos.format(grouping:true)
					debugString += " as:{Snapshot.autoSaveCount} s:{Snapshot.lastSnapshotSize.format(grouping:true)} a:{ahead} p:{aheadPercentile} av:"
					for user -> Input.internalUsers
						if user
							debugString += "  " + user.aheadAverage.format(fractionDigits:1)
					debugString += " {lastError}"
					
				lastNetworkFrame = now
				
			for Input.internalUsers: if .local: .startInputFrame nextInputFrame	
			
		lastAnimationFrame = now
		if Platform.mode == Play and frame >= frames: Platform.record()
		
	// Save state, parse inputs, step physics, process tick, and calculate checksum
	// This is called in animationFrame and during replays. 
	// All steps except the very last of an animation frame are fast forwared, which means that nothing is drawn.
	// The frame is increment at the end of this function. This means that while processing the frame,
	// frame will point to the current frame. After processing, frame will point to the next frame.
	private step: bool fastFordward = false // If a step is fast forwarted nothing is drawn
		try
			// Set time
			Time.now = Math.round(frame * targetFrameTime)
			Platform.fastForward = fastFordward
			
			// Log
			parseLog += " #{frame}"
			bool isCertain = frame <= certainFrame
			if fastFordward: parseLog += "f"
			if isCertain: parseLog += "c"
				
			// Save a snapshot when we are about to start the frame after the last certain frame where we got all inputs
			saveState
			
			// Parse inputs
			Input.parseInputs(frame, isCertain)
			
			// Physics
			Physics.step
			
			// Tick
			tick
			
			if mode != Local
				// Calculate checksum if we received all inputs for this frame
				if isCertain
					int myChecksum = Framework.checksum					
					let theirChecksum = checksums[frame]
					checksumLog += " <> #{frame} {myChecksum}"
					if !theirChecksum
						checksums[frame] = myChecksum
					else
					if(theirChecksum isApproximately myChecksum)
						checkedChecksums++
					else
						onWrongChecksum
						checkedChecksums = 0
						checksumLog += " MISMATCH saved theirs:{theirChecksum}"
						
				// Take snapshot
				Snapshot.onEndOfStep
			
			
		catch
			print error
			log error
			lastError = error.message
			
		// Cleanup
		for internalUser -> Input.internalUsers
			internalUser?.clearEvent
		for user -> Input.users
			user?.clearEvents
		
		// Send current frame to editor	
		if frames < frame+1: frames = frame+1
		if frameWithNewWatches < frame+1: frameWithNewWatches = frame+1
		if Platform.isDebug and !fastFordward and (Platform.mode == Record or Platform.mode == Play): Platform.sendFrame(frame, frames)
		
		frame++
		
	// Clear screen, process application tick, and draw all graphics
	// This is called in step.
	internal tick
		try
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
		catch
			print error
			log error
			lastError = error.message
			
		drawText debugString, {0, 532}
		drawTime = Time.measure
			graphics.finishFrame
		
	// Send each user the inputs that they haven't acknowleged yet
	// This is called in animationFrame.
	private sendInputs: int nextInputFrame, int targetFrame, float aheadAverage
		let localPlayer = Input.internalUsers[userId]
		for c -> connections
			if c.state == Connected
				let receiver = Input.internalUsers[c.userId]
				let checksumFor = uncertainFrame>1 ? uncertainFrame-1 : frame-1
				sendTickMessage
					to: c
					inputFrame: nextInputFrame-1     // You got all inputs up to and including this frame
					currentFrame: targetFrame-1      // The currently processed frame, used to calculate "ahead"
					aheadAverage: aheadAverage
					
					checksumFor: checksumFor         // The last certain frame with inputs from everybody
					checksum: checksums[checksumFor] // The checksum of the last certain frame
					
					acknowledgePos: receiver.inputs.writePos  // We ackledge that we received up to this input buffer pos
					
					buffer: localPlayer.inputs                // Send inputs that they haven't acknowleged yet
					start: receiver.acknowledgedPos
					end: localPlayer.inputs.writePos
		
	// Save a snapshot when we are about to start the frame after the last certain frame 
	// where we received inputs from all users. This is called at the beginning of a step
	// before we start processing the frame.
	private saveState
		if mode != Connected: return
		if frame == certainFrame+1
			for Input.internalUsers: uncertainReadPos = inputs.readPos
			uncertainFrame = frame
			saveTime = Time.measure
				Snapshot.serialize commonState
			parseLog += " save u:{uncertainFrame} c:{Framework.checksum}"
			// log uncertainFrame, "a:{Framework.objects[0]?.angle}"
	
	// Replay all frames from the first uncertain frame until the current frame
	// when we received all inputs for frames that we were uncertain about before.
	// This is called at the begining of animationFrame before we start stepping.
	private replayState
		if mode != Connected or Input.internalUsers.length == 1: return
		if uncertainFrame != -1 and certainFrame >= uncertainFrame
			// Restore state
			for Input.internalUsers: inputs.readPos = uncertainReadPos
			restoreTime = Time.measure
				Snapshot.deserialize commonState
			parseLog +=  " restore u:{uncertainFrame} c:{Framework.checksum}"
			// log uncertainFrame, "a:{Framework.objects[0]?.angle}"
	
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
		log "##### OUT OF SYNC #####", frame, debugString
		// Platform.setTitle "%%% OUT OF SYNC %%%"
		
		if !alertShown
			alert "Clients out of sync. Please send me the log file that will be created."
			saveLogs
			alertShown = true
			
	log: logstring text
		eventLog += text + "\n"
		// print text
		
	inline js int currentTime := Date.now()
	
	js void startApp
		lobby_inLobby = false
		if(window.app_start) app_start()
		
	private resetStartTime
		startTime = currentTime - frame*targetFrameTime - (targetFrameTime*.5)
		
	resetStartTimeIfNeeded
		if Platform.mode < Play: resetStartTime
		
	Buffer snapshotBuffer
		
	save: int slot
		snapshotBuffer.reset
		Snapshot.serialize snapshotBuffer
		IndexedDB.saveBuffer "snapshot", "{gameId}-{slot}", snapshotBuffer
			print "saved snapshot {gameId}-{slot} ({snapshotBuffer.writePos} bytes)"
		else
			print "save failed"
		
	restore: int slot
		IndexedDB.openBuffer "snapshot", "{gameId}-{slot}"
			Input.handleSetState buffer
			print "restored snapshot {gameId}-{slot} ({buffer.writePos} bytes)"
		else
			print "restore failed"
		
	saveEventStreamAndLogs
		if Input.isCertain
			saveEventStream
			Platform.schedule delay:1000
				saveLogs
			
	internal saveLogs
		let time = Time.current
		Platform.saveTextFile "{Platform.appName} {time.dayShortMonthNameYearString} {time.hourMinuteSecondString} v{Platform.version}.csv", logTable
		Http.post "/saveLog/{gameId}/{roomId}/{userId}", logTable
			log "save logs"
		else
			print "save logs failed {error}"
			
	saveEventStream
		Buffer buffer
		buffer.writeInt32 frame-1
		buffer.writeInt32 frames
		buffer.writeString Math.randomSeed
		buffer.writeBool startInLobby
		buffer.writeInt8 Input.internalUsers.length
		for Input.internalUsers
			buffer.writeInt8 .id
			buffer.writeBool .local
			buffer.writeBuffer .inputs
		let time = Time.current
		Platform.saveBinaryFile "{Platform.appName} {time.dayShortMonthNameYearString} {time.hourMinuteSecondString} v{Platform.version}.state", buffer
		
	openEventStream
		Platform.pause
		Platform.openBinaryFile
			// Read event stream
			frame = buffer.readInt32
			frames = buffer.readInt32
			let randomSeed = buffer.readString
			startInLobby = buffer.readBool
			let userCount = buffer.readInt8
			Input.internalUsers.clear
			for userCount
				InternalUser user
				user.id = buffer.readInt8
				user.local = buffer.readBool
				buffer.readBuffer user.inputs
				Input.internalUsers.add user
				
			// Replay
			for Input.internalUsers
				.collectInputs = true
				.currentFrame = frames-1
				if Platform.isDebug: .local = true
				.startInputFrame frames
			userId = Input.internalUsers.findIndex.local
			certainFrame = int.maxValue
			Platform.sendFrame(frame, frames)
			Math.setRandomSeed randomSeed
			goToFrame targetFrame:frame, replay:true
		
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
		if(Network_socket) {
			Network_log("closeConnection: socket")
			Network_socket.close()
			Network_socket = null
		}
		
	private reconnect
		if currentTime >= nextReconnect
			if(socket)
				log "Existing socket -> resending offers"
				resendOffers
			else
				log "No existing socket -> reconnecting to server"
				join gameId, roomId
			nextReconnect = currentTime + 6000
	
	private ping
		if currentTime >= nextPingTime
			for c -> connections
				if c.state != Disconnected
					sendPingMessage c, currentTime
			nextPingTime = currentTime + 300
		
	private object socket = null
	visible string roomId, gameId
	private Connection[] connections
	
	js void join: string gameId, string roomId
		init()
		Network_startInLobby = true
		Network_gameId = gameId
		Network_roomId = roomId
		Network_log("Network.join "+location.href)
		let socket
		if(Network_isLocalhost) socket = new WebSocket("ws://localhost:3111");
		else                    socket = new WebSocket("wss://"+location.host+":3111");
		socket.onopen = function() {
			Network_log("Websocket open");
			Network_socket = socket
			Network_onConnectedToServer();
		}
		socket.onmessage = function(event) {
			let message = JSON.parse(event.data);
			Network_onMessageFromServer(message);
		}
		socket.onclose = function() {
			Network_log("Websocket closed")
			Network_socket = null
		}
		socket.onerror = ex => {
			Network_log(ex.stack)
		}
		Network_initDatabase();
		
	private onConnectedToServer
		// Disabled rejoining with the same id to support testing in two browser tabs
		// Is this still needed if we have an eventStream?
		// if userId == -1
		// 	RoomInfo roomInfo = cast Platform.getLocalStorageObject "room"+roomId
		// 	userId = roomInfo && roomInfo.time > currentTime - 3600000*24 ? roomInfo.userId : -1
		// 	log "Reconnect to session", roomInfo, userId
		
		// openEventStream
		// 	Math.setRandomSeed eventStream.randomSeed
		// 	for eventStream.users
		// 		Input.internalUsers.add {id:u.id, local:u.local, inputFrame:u.frame, inputs:u.inputs}
		// 	userId = Input.internalUsers.find(local).id
		// 	// receivedFrames = getReceivedFrames
		// 	frame = receivedFrames
		// 	// resetStartTime
		// 	while frame < receivedFrames - 1
		// 		step fastFordward:true
		// 	step
		// 	log "Opening saved eventstream", roomId, frame
		// 	sendToServer JoinMessage roomId, userId, version:Platform.version
		// else
		// frame = 0
		
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
			log "Reconnecting to {roomId} with user {userId}"
			resendOffers
		else
			log Time.dateAndTimeString, Platform.version, Platform.userAgent, message.seed
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
				
	private resendOffers
		int[] partnerIds
		for c -> connections
			if c: log "Connection "+c.userId+" state:"+c.state+" offerByMe:"+c.offerByMe
			else  log "Connection null"
			if c && (c.state == Disconnected || c.state == Reconnecting) && c.offerByMe
				partnerIds.add c.userId
		log "Resending offers", userId, partnerIds
		createOffers partnerIds		
	
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
					let existingUser = Input_internalUsers[partnerId]
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
					console.error(e);
					Network_log(e.stack);
				}
			}
		}
		if(offers.length) Network_sendToServer(new OffersMessage(Network_userId, offers));
		
	private js void onReceivedOffer: int partnerId, Signal offer
		try {
			// Peer connection
			let connection = Network_createConnection(partnerId, /*offerByMe*/false, offer.acknowledgePos)
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
			Network_log(e.stack);
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
				Network_log(e.stack);
			}
		}
		
	private onPeerMessage: Connection c, Buffer buffer
		NetworkMessageType type = cast buffer.readInt16
		if type == Tick: onTickMessage c, buffer; else
		if type == Ping: onPingMessage c, buffer; else
		if type == Pong: onPongMessage c, buffer; else
		if type == OwnInputsAfterReconnect: onOwnInputsAfterReconnect c, buffer;
			
	// TEMP for testing
	Buffer[] testingSendQueue
			
	private void sendTickMessage: Connection to
		                          int inputFrame
		                          int currentFrame
		                          float aheadAverage
		                          int acknowledgePos
		                          int checksumFor
		                          float checksum
		                          Buffer buffer
		                          int start
		                          int end
		sendBuffer.reset
		sendBuffer.writeInt16 cast NetworkMessageType.Tick
		sendBuffer.writeInt32 checksumFor
		sendBuffer.writeFloat64 checksum || 0
		sendBuffer.writeInt32 inputFrame
		sendBuffer.writeInt32 currentFrame
		sendBuffer.writeFloat64 aheadAverage
		sendBuffer.writeInt32 acknowledgePos
		sendBuffer.writeInt32 start
		sendBuffer.writeBuffer buffer, start, end - start
		sentLog += " #{inputFrame} ack:{acknowledgePos} cf:{currentFrame} s:{start} e:{end}"
		
		
		if skipSending
			// TEMP: For testing, we want to press a key to skip sending packages
			let b = Buffer()
			b.copyFromBuffer(sendBuffer)
			testingSendQueue.add b
			sentLog += "x"
			
		else
			send to, sendBuffer
			
			// TEMP: When we release the key, send all queued buffers at once
			if testingSendQueue.length > 0
				sentLog += " sending queue len:{testingSendQueue.length}"
				for queuedBuffer -> testingSendQueue
					send to, queuedBuffer
				testingSendQueue.clear
				
			
	// private js void onTickMessage: Connection c, Buffer buffer
	// 	if(Math.random() < .75) setTimeout(() => Network_onTickMessageActual(c, buffer), Math.random()*500)
		
	// private onTickMessageActual: Connection c, Buffer buffer
	private onTickMessage: Connection c, Buffer buffer
		let sender = Input.internalUsers[c.userId]
		if c.state != Connected: c.state = Connected

		// Checksum
		let checksumFor = buffer.readInt32
		let checksum = buffer.readFloat64
		checksumLog += " <{c.userId}> #{checksumFor} {checksum}"
		if checksum
			let myChecksum = checksums[checksumFor]
			if !myChecksum
				checksums[checksumFor] = checksum
			else
			if(myChecksum isApproximately checksum)
				checkedChecksums++
			else
				onWrongChecksum
				checkedChecksums = 0
				checksumLog += " MISMATCH mine:{myChecksum}"
		
		int inputFrame = buffer.readInt32 
		if inputFrame > sender.inputFrame
			sender.inputFrame = inputFrame
			sender.currentFrame = buffer.readInt32
			sender.aheadAverage = buffer.readFloat64
			sender.acknowledgedPos = buffer.readInt32
			
			let writeStart = buffer.readInt32
			let length = buffer.readBuffer sender.inputs, writeStart
			
			// TEMP for testing
			if(sender.inputs.writePos != writeStart + length)
				Platform.alert("expected write pos:{writeStart + length} actual:{sender.inputs.writePos}")
			
			receivedFrames = getReceivedInputFrames
	
			receivedLog += " [{currentTime}] <{c.userId}> #{sender.inputFrame} a:{sender.acknowledgedPos} cf:{sender.currentFrame} s:{writeStart} e:{sender.inputs.writePos}"
		else
			// Ignore this frame because we already received a later frame
			// Later frames start from the pos we acknowleged (everything before that we definately already received)
			// until the latest available pos, so later frames contain the maximum available information
			
			// This is just for logging and debugging
			let currentFrame = buffer.readInt32 
			let acknowledgedPos = buffer.readInt32
			let writeStart = buffer.readInt32
			let length = buffer.readInt32
			receivedLog += " [{currentTime}] <{c.userId}> irgnoring #{inputFrame} (already at {sender.inputFrame}) a:{acknowledgedPos} s:{writeStart} e:{writeStart+length}"
		
	private void sendOwnInputsAfterReconnectMessage: Connection c
		                                int frame
		                                Buffer buffer
		sendBuffer.reset
		sendBuffer.writeInt16 cast NetworkMessageType.OwnInputsAfterReconnect
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
		sendBuffer.writeInt16 cast NetworkMessageType.Ping
		sendBuffer.writeFloat64 pingTime
		send c, sendBuffer
			
	private onPingMessage: Connection c, Buffer buffer
		log c.state
		if c.state != Disconnected
			let pingTime = buffer.readFloat64
			sendPongMessage c, currentTime-startTime, pingTime
		
	private void sendPongMessage: Connection c, float timeSinceStart, float pingTime
		sendBuffer.reset
		sendBuffer.writeInt16 cast NetworkMessageType.Pong
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
		let internalUser = Input_internalUsers[userId];
		let el = document.createElement('video');
		el.style = "position:absolute; top:0px; left:0px; z-index:10000; visibility:hidden; "+(local ? "transform: scaleX(-1)" : "")
		el.autoplay = true
		el.playsinline = true
		el.controls = false
		el.muted = local
		document.body.appendChild(el)
		el.srcObject = stream;
		internalUser.videoElement = el;
		
	private js void removeVideoElement: int userId
		let internalUser = Input_internalUsers[userId];
		if(internalUser?.videoElement) internalUser.videoElement.remove()
			
	setUserVideoAndColor: int userId = 0, float2 pos = {}, float width = 440, Color color = null
		let user = Input.users[userId]
		if !user: return
		user.videoPosition = pos
		user.videoWidth = width
		user.color = color
		
	internal js void updateVideoScreen
		if(Network_mode == 2/*Local*/ || Network_isLocalhost) {
			for(let user of Input_users) {
				if(user && user.videoWidth) {
					graphics_drawImage(Image_VideoScreen, user.videoPosition, 0, user.videoWidth/440, -1)
				}
			}
		}
		else {
			for(let user of Input_users) {
				if(user) {
					let internetUser = Input_internalUsers[user.id];
					let el = internetUser?.videoElement
					if(el) {
						let pixelPos = Input_logicalToPixelPosition(user.videoPosition)
						let pixelSizeX = user.videoWidth*graphics_totalMatrix.m0/Platform_pixelRatio
						let pixelSizeY = (user.videoWidth*3/4)*graphics_totalMatrix.m3/Platform_pixelRatio
						el.style.left = (pixelPos.x-pixelSizeX/2)+"px"
						el.style.top = (pixelPos.y-pixelSizeY/2)+"px"
						el.style.width = pixelSizeX+"px"
						el.style.height = pixelSizeY+"px"
						el.style.visibility = "visible"
					}
				}
			}
		}
		
	internal drawFingers
		for user -> Input.users
			if user
				let internalUser = Input.internalUsers[user.id]
				if !internalUser.local or Platform.showLocalPointer or Platform.mode == Play or frame < frames
					for user.touches
						if Framework.isVisibleFor .smoothPosition, this.userId
							drawImage finger, .smoothPosition+{11,32}, frame:.isDown ? 1 : 0, layer:int.maxValue
							if user.color
								if user.color == Black
									drawRectangle .smoothPosition+{16,80}, size:{26,10}, user.color, layer:int.maxValue, outlineColor:{"a0a0a0"}, outlineWidth:2
								else
									drawRectangle .smoothPosition+{16,78}, size:{26,10}, user.color, layer:int.maxValue
									
	private js void logConnectionType(object peerConnection)
		setTimeout(async () => {
			let stats = await peerConnection.getStats()
			let candidatePairs = [...stats.values()].filter(s => s.type == "candidate-pair" && s.state == "succeeded")
			let candidatePair = candidatePairs.find(a => a.selected) || candidatePairs[0]
			if(candidatePair) {
				let candidate = stats.get(candidatePair.localCandidateId);
				let ip = candidate.ip || candidate.address
				Network_connectionType = candidate.candidateType
				Network_log("Connection: ", Network_connectionType, ip, candidate)
			} else {
				window.stats = [...stats.values()]
				Network_log("Can't access stats", window.stats)
			}
		}, 5000)

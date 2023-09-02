enum PlatformMode: Pause, Manipulator, Slide, Play, Record
enum OperatingSystem: Windows, Mac, Linux, Android, iOS
enum IntervalMode: JavaScriptInterval, AnimationFrame

// Basic platform functionality
// Screen space
// - has always the reference size (1920 x 1080 by default) on all platforms
// - the origin is in the middle of the screen
//
//          Top              → x
//     Left  +  Right      ↓ 
//         Bottom          y
//
// Pixel space
// - the size in the screen size in pixels of the target platform
// - the origin in the top left corner
transient skipInit unit Platform
	// Configuration
	public userCount = 4
	public supportedUserCount = Range 2..4
	public bool showSafeArea = true
	public bool showDebugInfo = false
	public bool isLocal = false
	public IntervalMode intervalMode = JavaScriptInterval
	
	// Info
	public inline js int appName := appName
	public inline js int version := version
	
	visible OperatingSystem os
	visible bool isMobile
	visible bool isBrowser
	visible bool isDebug
	visible bool isSmallScreen
	public bool isStaging
	
	// Internal
	internal bool engineStarted
	internal PlatformMode mode
	internal bool fastForward
	internal int waitingForInitialData
	
	private inline js void initMedia
		audio_init();
		if(window.Image_init) Image_init();
		if(window.Font_init)  Font_init();
		if(window.Sound_init) Sound_init();
		
	private js void initPlatform
		statistics_init();
		Platform_init();
		graphics_init();
		math_init();
		core_init();
		input_init();
		gizmo_init();
		Loca_init();
		core_log("Loading...")
		Platform_isMobile = false;
		Platform_isBrowser = !window.require;
		let platform = navigator.platform
		Platform_os = platform.startsWith("Win") ? 0 : platform.startsWith("Mac") ? 1 : 2
		if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent) 
			|| /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0,4))) { 
			Platform_isMobile = true;
		}
		if(!Platform_isMobile) 
			window.onresize = e => { 
				graphics_onResize();
				if(Platform_mode < 3/*Pause,Manipulator,Slide*/ && Platform_engineStarted) core_tick(/*draw*/true);
			}
		if(window.app_init) app_init();
		
	// This is called when the application starts for the first time	
	private start: bool isDebug, int userCount, bool simulateConnection, bool showSafeArea
		try
			this.nextHeartbeatTime = 0
			heartbeat "start"
			
			initMedia
			initPlatform
			statistics.startTime = Time.preciseTime
			this.engineStarted = false
			this.isDebug = isDebug
			this.userCount = userCount
			core.simulateConnection = simulateConnection
			this.showSafeArea = showSafeArea
			showDebugInfo = getLocalStorageObject("showDebugInfo") == "true"
			
			await graphics.setup
			graphics.onResize
			// drawLoading
			if mode >= Play: mode = Pause
			let path = url.getUntil("?").split("/")
			let gameId = path[3]
			let roomId = path[4]
				
			// For testing, support joining a room with a given userId using the format /gameId/{roomId}u{userId}
			// because starting the app in two browser tabs overwrites the userId in the local storage
			let userId = -1
			if roomId
				let dashIndex = roomId.indexOf("u")
				if dashIndex != -1
					userId = cast roomId.substring(dashIndex+1)
					roomId = roomId.substring(0,dashIndex)
				
			// If the roomId "staging", "latest" or negative, switch to staging mode (no audio, no fullscreen)
			isStaging = isDebug or roomId == "staging" or roomId == "latest" or roomId?.startsWith("-")
			
			openMedia
				try
					this.engineStarted = true
					statistics.loadTime = Time.preciseTime
					startInterval
					if isDebug || isLocal || roomId == "local" || url.startsWith("file"): core.startLocal
					else                                                                  core.join gameId, roomId, userId
					
					// When the texture is loaded, we start the app in record mode. This starts processing inputs and ticks.
					if !isDebug: record
						
				catch
					sendErrorToEditor .
				finally 
					sendFinished
		catch
			sendErrorToEditor .
			sendFinished
			
		
	// This is called after every code change to replay all inputs with the new code
	private replay: bool updateMedia
		try
			heartbeat "replay"
			if updateMedia
				initMedia
				openMedia
					goToCurrentFrame
			else
				goToCurrentFrame
		catch
			sendErrorToEditor .
			sendFinished
			
	private goToCurrentFrame
		try
			core.goToFrame core.frame-1, replayFromStart:true
		catch
			sendErrorToEditor .
		finally 
			sendFinished
		
			
	object interval
	private js void startInterval
		if(Platform_interval) clearInterval(Platform_interval)
		if(window.tick) return
			
		if(Platform_intervalMode == 0) {
			Platform_interval = setInterval(() => Platform_tick(), 1000/core_targetFps)
		} else {
			window.tick = function() {
				Platform_tick();
				window.requestAnimationFrame(window.tick);
			}
			window.tick();
		}
	
	// This is called every animation frame
	private tick
		heartbeat "tick"
		if mode == Play or mode == Record or waitingForInitialData
			core.animationFrame
				
	private enterSlideMode(PlatformMode mode) this.mode = mode; sendMode
	
	internal stop()    mode = Pause; gizmo.clear; core.stop; sendMode
	internal pause()   mode = Pause; gizmo.clear; audio.stop; core.tick(draw:true); sendMode
	internal record()  core.adjustStartTimeIfNeeded; mode = Record; core.record;  gizmo.clear;  sendMode
	internal play()    core.adjustStartTimeIfNeeded; mode = Play;   gizmo.clear;  sendMode
	
	private goToFrame(int targetFrame) pause(); core.goToFrame(targetFrame)
		
	internal js void sendSelectToEditor: string cursorFile, int cursorPos
		_sendToEditor({type:"select", cursorFile, cursorPos})
	
	internal js void sendDeselectToEditor
		_sendToEditor({type:"deselect"})
	
	internal js void sendStartManipulationToEditor: GizomInfluence[] influences
		_sendToEditor({type:"startManipulation", influences})
	
	internal js void sendMoveManipulationToEditor: GizomInfluence[] influences, int codeId
		_sendToEditor({type:"moveManipulation", influences, codeId})
	
	internal js void sendFrame: int frame, int frames
		_sendToEditor({type:"frame", frame, frames})
	
	internal js void sendWatch: int frame, string text, int location, string file
		_sendToEditor({type:"watch", frame, text, location, file})
	
	internal js void sendClearTimeline:
		_sendToEditor({type:"clearTimeline"})
	
	private js void sendMode
		if(Platform_isDebug) _sendToEditor({type:"setPlatformMode", mode:Platform_mode, frame:core_frame})

	internal inline js void sendErrorToEditor: Error error
		if(window.sendErrorToEditor) _sendErrorToEditor(error)
		else                         console.error(error)
		
	private inline js void sendFinished
		console.log("[app] ----- Finished -----")
		if(Platform_isDebug) _sendToEditor({type:"finished"})
	
	private Time nextHeartbeatTime
	
	private js void heartbeat: string context
		let now = Date.now();
		if(now > Platform_nextHeartbeatTime) {
			console.log("[app]", (now%100000).toLocaleString("en-US", {minimumIntegerDigits:6, useGrouping:true})+" sending heartbeat from "+context);
			Platform_nextHeartbeatTime = now + 3000;
			_sendStringToEditor("~");
		}
		
	private void toggleDebugInfo
		showDebugInfo = !showDebugInfo;
		setLocalStorageObject("showDebugInfo", showDebugInfo ? "true" : "false")
		graphics.updateBaseMatrix
		
	private void toggleSmallScreen
		isSmallScreen = !isSmallScreen;
		print isSmallScreen
		setLocalStorageObject("smallScreen", isSmallScreen ? "true" : "false")
		
	js string generateObjectId
		var result = (Date.now() / 1000 | 0).toString(16)
		for(let i=0; i<16; i++)
			result += (Math.random() * 16 | 0).toString(16)
		return result.toLowerCase()
		
	js object stack
		try      { _ }
		catch(e) { return e.stack }
		
	inline js void debugger
		debugger
		

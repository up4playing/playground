enum PlatformMode: Pause, Manipulator, Slide, Play, Record
enum ScaleMode: Auto, FixedWidth, FixedHeight, None
enum AnchorMode: TopLeft, TopCenter, Center
enum OperatingSystem: Windows, Mac, Linux, Android, iOS
enum TickMode: Interval, AnimationFrame

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
	public userCount = 2
	public supportedUserCount = Range 2..4
	public bool showSafeArea = true
	public bool showDebugInfo = false
	public bool isLocal = false
	public TickMode tickMode = Interval
	public Vector2 referenceSize = {1920, 1080}
	public ScaleMode scaleMode = Auto, effectiveScaleMode
	public AnchorMode anchor = Center
	
	// Info
	public inline js string url := location.href
	public inline js string host := location.host
	public protocalAndHost := host ? "https://"+host : "http://localhost"
	
	public inline js int appName := appName
	public inline js int version := version
	public inline js int userAgent := navigator.userAgent.replace(/,/g," ")
	public inline js float usedMemory := performance.memory.usedJSHeapSize
	
	visible OperatingSystem os
	visible bool isMobile
	visible bool isBrowser
	visible bool isDebug
	public bool isStaging
	
	visible Vector2 pixelSize
	visible Vector2 size
	visible float pixelRatio
	
	// Internal
	private object canvas
	internal object context
	internal Matrix2D baseMatrix
	internal bool engineStarted
	internal PlatformMode mode
	internal bool fastForward
	internal bool isWaitingForInitialData
	
	private inline js void initMedia
		audio_init();
		if(window.Image_init) Image_init();
		if(window.Font_init)  Font_init();
		if(window.Sound_init) Sound_init();
		
	private js void initPlatform
		statistics_init();
		Platform_init();
		Math_init();
		Network_init();
		Input_init();
		gizmo_init();
		Network_log("Loading...")
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
				Platform_onResize();
				if(Platform_mode < 3/*Pause,Manipulator,Slide*/ && Platform_engineStarted) Network_tick(/*draw*/true);
			}
		if(window.app_init) app_init();
		
	private js void onResize
		Platform_canvas = document.getElementById("canvas");
		Platform_context = Platform_canvas.getContext("2d");
		Platform_pixelRatio = window.devicePixelRatio;
		Platform_pixelSize = new Vector2(window.innerWidth*Platform_pixelRatio, window.innerHeight*Platform_pixelRatio, null);
		Platform_canvas.style.width = window.innerWidth + "px";
		Platform_canvas.style.height = window.innerHeight + "px";
		Platform_canvas.width = Platform_pixelSize.x;
		Platform_canvas.height = Platform_pixelSize.y;
		Platform_canvas.imageSmoothingEnabled = true;
		Platform_canvas.imageSmoothingQuality = "high";
		Platform_updateBaseMatrix();
		
	private js void drawLoading
		let text = "Loading..."
		Platform_context.font = "24px Arial"
		Platform_context.fillStyle = "#ffffff"
		Platform_context.textBaseline = "middle"
		let textSize = Platform_context.measureText(text)
		Platform_context.fillText(text, (Platform_pixelSize.x-textSize.width)/2, Platform_pixelSize.y/2)
		
	// Update the base matrix
	// Called when resizing and after calling init() because we could change the scaleMode and anchor in App.init
	private updateBaseMatrix
		let statisticsMargin = showDebugInfo ? statistics.margin : {}
		let referenceSizeWithMargin = referenceSize + statisticsMargin
		Vector2 ratio = {pixelSize.x / referenceSizeWithMargin.x, pixelSize.y / referenceSizeWithMargin.y}
		float scale
		if scaleMode == Auto
			if ratio.x < ratio.y: effectiveScaleMode = FixedWidth;  scale = ratio.x
			else                  effectiveScaleMode = FixedHeight; scale = ratio.y
			size = referenceSizeWithMargin
		else
		if scaleMode == FixedWidth
			effectiveScaleMode = scaleMode
			scale = ratio.x
			size = {referenceSizeWithMargin.x, pixelSize.y/scale}
		else
		if scaleMode == FixedHeight
			effectiveScaleMode = scaleMode
			scale = ratio.y; 
			size = {pixelSize.x/scale, referenceSizeWithMargin.y}
			
		let offsetX = anchor > 0 ? pixelSize.x/2 : 0
		let offsetY = anchor > 1 ? pixelSize.y/2 : 0
		baseMatrix = {scale,0,0,scale,offsetX-(statisticsMargin.x/2)*scale,offsetY-(statisticsMargin.y/2)*scale}
	
	// This is called when the application starts for the first time	
	private start: bool isDebug
		initMedia
		initPlatform
		statistics.startTime = Time.preciseTime
		this.engineStarted = false
		this.isDebug = isDebug
		if !isDebug: showSafeArea = false; Network.simulateConnection = false
		showDebugInfo = getLocalStorageObject("showDebugInfo") == "true"
		
		onResize
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
			this.engineStarted = true
			statistics.loadTime = Time.preciseTime
			startInterval
			if isDebug || isLocal || roomId == "local" || url.startsWith("file"): Network.startLocal userCount:userCount
			else                                                                  Network.join gameId, roomId, userId
			sendEvaluateFinished
			
			// When the texture is loaded, we start the app in record mode. This starts processing inputs and ticks.
			if !isDebug: record
		
	// This is called after every code change to replay all inputs with the new code
	private replay() 
		initMedia
		openMedia
			Network.goToFrame Network.frame-1, replayFromStart:true
			
	object interval
	private js void startInterval
		if(Platform_interval) clearInterval(Platform_interval)
		if(window.tick) return
			
		if(Platform_tickMode == 0) {
			Platform_interval = setInterval(() => Platform_tick(), 1000/Network_targetFps)
		} else {
			window.tick = function() {
				Platform_tick();
				window.requestAnimationFrame(window.tick);
			}
			window.tick();
		}
	
	// This is called every animation frame
	private tick()   if mode == Play or mode == Record or isWaitingForInitialData: Network.animationFrame
	
	private enterSlideMode(PlatformMode mode) this.mode = mode; sendMode
	
	internal stop()    mode = Pause; Network.stop; gizmo.clear; sendMode
	internal pause()   mode = Pause; audio.stop(); gizmo.clear; sendMode
	internal record()  Network.adjustStartTimeIfNeeded; mode = Record; gizmo.clear; sendMode
	internal play()    Network.adjustStartTimeIfNeeded; mode = Play;   gizmo.clear; sendMode
	
	private goToFrame(int targetFrame) Network.goToFrame(targetFrame)
		
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
		if(Platform_isDebug) _sendToEditor({type:"setPlatformMode", mode:Platform_mode, frame:Network_frame})

	private inline js void sendEvaluateFinished
		if(Platform_isDebug) _sendToEditor({type:"evaluateFinished"})

	js void setTitle: string title
		document.title = title
		
	void toggleDebugInfo
		showDebugInfo = !showDebugInfo;
		setLocalStorageObject("showDebugInfo", showDebugInfo ? "true" : "false")
		updateBaseMatrix
		
	inline js void setFullscreen: value = true, forUser = -1
		if(!Platform_isStaging && !Platform_isDebug && (forUser == -1 || Input_localUser?.id == forUser)) {
			try {
				if(value) {
					document.body.requestFullscreen()
				} else {
					document.exitFullscreen()
				}
			} catch {
			}
		}	
		
	js void saveTextFile: string filename, string text
		var element = document.createElement('a');
		element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
		element.setAttribute('download', filename);
		element.style.display = 'none';
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
		
	js void saveBinaryFile: string filename, Buffer buffer
		var binary = '';
		var bytes = new Uint8Array(buffer.buffer);
		var len = bytes.byteLength;
		for (var i = 0; i < len; i++) {
		    binary += String.fromCharCode(bytes[i]);
		}
		var base64 = window.btoa( binary );
		var dataUrl = 'data:text/plain;base64,' + base64;
		
		var element = document.createElement('a');
		element.setAttribute('href', dataUrl);
		element.setAttribute('download', filename);
		element.style.display = 'none';
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
		
	js void openBinaryFile: void(Buffer buffer) then, void(string error) else = null
		fileInput = document.createElement("input")
		fileInput.type = 'file'
		fileInput.style.display = 'none'
		fileInput.onchange = e => {
			var file = e.target.files[0];
			if (!file) {
				else?.("")
				return
			}
			var reader = new FileReader();
			reader.onload = function(e) {
				let buffer = new Buffer(e.target.result, 0, 0, 0);
				document.body.removeChild(fileInput);
				then(buffer);
			}
			reader.onabort = e => {
				else?.(reader.error)
			}
			reader.onerror = e => {
				else?.(reader.error)
			}
			reader.readAsArrayBuffer(file)
		}
		document.body.appendChild(fileInput)
		fileInput.click()
		
	inline js void setLocalStorageObject: string key, dynamic value
		localStorage.setItem(key, JSON.stringify(value))
		
	js dynamic getLocalStorageObject: string key
		let str = localStorage.getItem(key)
		return str ? JSON.parse(str) : null 
		
	inline js void setLocalStorageString: string key, string value
		localStorage.setItem(key, value)
		
	inline js string getLocalStorageString: string key
		(localStorage.getItem(key) || "")
		
	js string generateObjectId
		var result = (Date.now() / 1000 | 0).toString(16)
		for(let i=0; i<16; i++)
			result += (Math.random() * 16 | 0).toString(16)
		return result.toLowerCase()
		
	inline js void vibrate: int duration = 100
		if(navigator.vibrate) navigator.vibrate(duration)
		
	js void saveImage: string dataUrl, string file
		var base64Data = dataUrl.replace(/data:image\/png;base64,/, "");
		var fs = require("fs")
		fs.writeFile(file, base64Data, 'base64', function (err) {
			if(err) log(err)
		});
		
	js string[] showOpenDialog: FileFilter[] filters = null
		const { remote } = require("electron")
		return remote.dialog.showOpenDialogSync({ filters, properties: ['openFile'] })
		
	inline js void debugger
		debugger
		
	js object stack
		try      { _ }
		catch(e) { return e.stack }
		
	inline js void alert: string message
		alert(message)
		log(message)
		
	inline js void sendErrorToEditor: Error error
		if(window.sendErrorToEditor) sendErrorToEditor(error)
		else                         console.error(error)
		
	inline js void delay: Time time
		                  void() then
		setTimeout(then, time)
		
	inline js void copyToClipboard(string text)
		navigator.clipboard.writeText(text)
		
	inline js void setLocation: string url
		location.href = url
		
	js void showIcon
		if(!Platform_isDebug && window.require) {
			const { remote } = require('electron')
			remote.app.dock?.show()
		}
	
	js void hideIcon
		if(!Platform_isDebug && window.require) {
			const { remote } = require('electron')
			remote.app.dock?.hide()
		}
	
	js void show
		if(!Platform_isDebug && window.require) {
			const { remote } = require('electron')
			remote.getCurrentWindow().show()
		}
	
	js void hide
		if(!Platform_isDebug && window.require) {
			const { remote } = require('electron')
			remote.getCurrentWindow().hide()
		}
		
	js void registerGlobalShotcut: string shortcut
		                           void() do
		if(!Platform_isDebug && window.require) {
			const { remote } = require('electron')
			remote.globalShortcut.unregister(shortcut)
			remote.globalShortcut.register(shortcut, () => do())
		}
		
	js void setInterval: int interval
		                 void() code
		setInterval(code, interval)
		
	inline js int setTimeout: Time time
		                      void() code
		setTimeout(code, time)
		
	inline js void clearTimeout: int id
		clearTimeout(id)
		
	inline js string resourcesPath := process.resourcesPath
	
	inline js void pushState: string url
		                      object state = null
		if(Network_isPremiere) history.pushState(state, "", url);
		
	inline js void replaceState: string url
		                         object state = null
		if(Network_isPremiere) history.replaceState(state, "", url);
		
	inline js void back
		if(Network_isPremiere) history.back();
		
	inline js void reload
		if(!Platform_isDebug) location.reload();
			

		
unit File
	js string readPartial: string filename, int offset=0, int length, void(string result) callback
		let fs = require("fs")
		let file = fs.open(filename, "r", (err, file) => {
			fs.read(file, {offset, length}, (err, bytesRead, buffer) => {
				callback(buffer.toString())
				fs.closeSync(file)
			})
		})
		
	js string read: string filename, void(string data) then
		let fs = require("fs")
		fs.readFile(filename, "utf8", (err, data) => {
			then(data)
		})		
		
	js string write: string filename, string data, void() then = null
		if(Network_isPremiere && Input_isCertain) {
			require("fs").writeFile(filename, data, "utf8", (err, data) => {
				then?.()
			})
		}
		
	inline js bool exists: string filename
		require("fs").existsSync(filename)
		
	inline js void createDirectory: string path
		require("fs").mkdirSync(path)
		
struct FileFilter
	string name
	string[] extensions

transient unit IndexedDB
	private object db
	
	js void start: string databaseName, string storeName, int version = 1
		try {
			Network_log("IndexedDB: start");
			IndexedDB_storeName = storeName;
			var request = indexedDB.open(databaseName, version)
			request.onupgradeneeded = e => {
				Network_log("IndexedDB: upgradeneeded");
				IndexedDB_db = e.target.result;
				if(!IndexedDB_db.objectStoreNames.contains(storeName))
					IndexedDB_db.createObjectStore(storeName, { keyPath: "id" });
				Network_log("IndexedDB successfully upgraded to version "+version)
			}
			request.onsuccess = e => {
				IndexedDB_db = e.target.result;
				Network_log("IndexedDB: success");
			}
			request.onerror = e => {
				Network_log("IndexedDB: error "+request.error);
			}
			Network_log("IndexedDB: finished");
		} catch(e) {
			Network_log("IndexedDB: exception "+e.message)
		}
		
	js void open: string storeName, string id, void(object data) then, void() else = null
		try {
			let trans = IndexedDB_db.transaction(storeName, "readonly")
			let req = trans.objectStore(IndexedDB_storeName).get(id)
			req.onsuccess = async e => {
				let result = req.result
				if(result) {
					then(result)
				} @else {
					else?.()
				}
			}
			req.onerror = e => {
				Network_log("Error in IndexedDB.open: "+req.error)
				else?.()
			}
		} catch(e) {
			Network_log("Error in IndexedDB.open: "+e.message)
			else?.()
		}
				
	js void openBuffer: string storeName, string id, void(Buffer buffer) then, void() else = null
		try {
			let trans = IndexedDB_db.transaction(storeName, "readonly")
			let req = trans.objectStore(IndexedDB_storeName).get(id)
			req.onsuccess = async e => {
				let result = req.result
				if(result) {
					let arrayBuffer = await result.data.arrayBuffer()
					let buffer = new Buffer(arrayBuffer, 0, 0, 0)
					then(buffer)
				} @else {
					else?.()
				}
			}
			req.onerror = e => {
				Network_log("Error in IndexedDB.open: "+req.error)
				else?.()
			}
		} catch(e) {
			Network_log("Error in IndexedDB.open: "+e.message)
			else?.()
		}
				
	js void save: string storeName, object data, void() then = null, void() else = null
		try {
			let trans = IndexedDB_db.transaction(storeName, "readwrite")
			trans.onerror = e => {
				Network_log("Error in IndexedDB.save: "+trans.error)
				else?.()
			}
			trans.objectStore(IndexedDB_storeName).put(data).onsuccess = e => {
				then?.()
			}
		} catch(e) {
			Network_log("Error in IndexedDB.save: "+e.message)
			else?.()
		}
		
	js void saveBuffer: string storeName, string id, Buffer buffer, void() then = null, void() else = null
		try {
			let trans = IndexedDB_db.transaction(storeName, "readwrite")
			trans.onerror = e => {
				Network_log("Error in IndexedDB.save: "+trans.error)
				else?.()
			}
			let dataView = new DataView(buffer.buffer, 0, buffer.writePos)
			let data = new Blob([dataView])
			trans.objectStore(IndexedDB_storeName).put({id, data}).onsuccess = e => {
				then?.()
			}
		} catch(e) {
			Network_log("Error in IndexedDB.save: "+e.message)
			else?.()
		}


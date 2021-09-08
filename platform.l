enum PlatformMode: Pause, Pointer, Slide, Play, Record
enum ScaleMode: Auto, FixedWidth, FixedHeight, None
enum AnchorMode: TopLeft, TopCenter, Center

// Basic platform functionality
// Screen space
// - has always the reference size (1920 x 1080 by default) on all platforms
// - the origin is in the middle of the screen
//
//          Top              🡺 x
//     Left  +  Right      🡻 
//        Bottom            y
//
// Pixel space
// - the size in the screen size in pixels of the target platform
// - the origin in the top left corner
transient unit Platform
	public userCount = 2
	public bool showSafeArea = true
	public bool showLocalPointer = false
	public bool showDebugInfo = false
	
	public inline js string url := location.href
	public inline js int version := version
	public inline js int appName := appName
	public inline js int userAgent := navigator.userAgent.replace(/,/g," ")
	
	public float2 referenceSize = {1920, 1080}
	public ScaleMode scaleMode = Auto, effectiveScaleMode
	public AnchorMode anchor = Center
	
	private object canvas = null
	internal object context = null
	visible bool isDebug
	visible float2 pixelSize, size
	visible float pixelRatio
	internal Matrix2D baseMatrix
	internal bool engineStarted
	visible PlatformMode mode
	internal bool fastForward
	visible bool isMobile = true
	
	internal inline js void initApplication
		init()
		Platform_updateBaseMatrix();
		
	private inline js void initCacheAndImages
		_constCache.length = 0;
		_constCache.push(null);
		Image_init();
		
	private js void initPlatform
		Platform_init();
		Math_init();
		Network_init();
		Input_init();
		Platform_isMobile = false;
		if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent) 
			|| /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0,4))) { 
			Platform_isMobile = true;
		}
		if(!Platform_isMobile) 
			window.onresize = e => { 
				Platform_onResize();
				if(Platform_mode == 0/*Pause*/ && Platform_engineStarted) Network_tick();
			}
		
	private js void onResize
		Platform_canvas = document.getElementById("canvas");
		Platform_context = Platform_canvas.getContext("2d");
		Platform_pixelRatio = 1;
		Platform_pixelSize = new float2(window.innerWidth*Platform_pixelRatio, window.innerHeight*Platform_pixelRatio, null);
		Platform_canvas.style.width = window.innerWidth + "px";
		Platform_canvas.style.height = window.innerHeight + "px";
		Platform_canvas.width = Platform_pixelSize.x;
		Platform_canvas.height = Platform_pixelSize.y;
		Platform_canvas.imageSmoothingEnabled = true;
		Platform_canvas.imageSmoothingQuality = "high";
		Platform_updateBaseMatrix();
		
	// Update the base matrix
	// Called when resizing and after calling init() because we could change the scaleMode and anchor in App.init
	private updateBaseMatrix
		float2 ratio = {pixelSize.x / referenceSize.x, pixelSize.y / referenceSize.y}
		float scale
		if scaleMode == Auto
			if ratio.x < ratio.y: effectiveScaleMode = FixedWidth;  scale = ratio.x
			else                  effectiveScaleMode = FixedHeight; scale = ratio.y
			size = referenceSize
		else
		if scaleMode == FixedWidth
			effectiveScaleMode = scaleMode
			scale = ratio.x
			size = {referenceSize.x, pixelSize.y/scale}
		else
		if scaleMode == FixedHeight
			effectiveScaleMode = scaleMode
			scale = ratio.y; 
			size = {pixelSize.x/scale, referenceSize.y}
			
		let offsetX = anchor > 0 ? pixelSize.x/2 : 0
		let offsetY = anchor > 1 ? pixelSize.y/2 : 0
		baseMatrix = {scale,0,0,scale,offsetX,offsetY}
	
	// This is called when the application starts for the first time	
	private start: bool isDebug
		initCacheAndImages
		initPlatform
		this.engineStarted = false
		this.isDebug = isDebug
		if !isDebug: showSafeArea = false
		
		onResize
		if !isDebug: Network.simulateConnection = false
		if mode >= Play: mode = Pause
		let path = url.split("/")
		let gameId = path[3]
		let roomId = path[4]
		
		Image.mainTexture.open
			if isDebug || roomId == "local" || url.startsWith("file"): Network.startLocal userCount:userCount
			else                                                       Network.join gameId, roomId
			this.engineStarted = true
			sendEvaluateFinished
			
			// When the texture is loaded, we start the app in record mode. This starts processing inputs and ticks.
			if !isDebug: record
		
	// This is called after every code change to replay all inputs with the new code
	private replay() 
		initCacheAndImages
		Image.mainTexture.open
			Network.goToFrame Network.frame-1, replay:true
	
	// This is called every animation frame
	private tick()   if mode == Play or mode == Record: Network.animationFrame
	
	private enterSlideMode(PlatformMode mode) this.mode = mode; sendMode
	
	internal stop()    mode = Pause;  Network.stop; sendMode
	internal pause()   mode = Pause;  sendMode
	internal record()  Network.resetStartTimeIfNeeded; mode = Record; sendMode
	internal play()    Network.resetStartTimeIfNeeded; mode = Play;   sendMode
	
	private goToFrame(int targetFrame) Network.goToFrame(targetFrame)
		
	private float2 touchUpPos
	private int locationIndex
	private SourceCodeLocation[] locations
	
	internal handleSlide: InputType inputType, int id, float2 pixelPos, float2 referencePos	
		if Platform.mode == Pointer or Platform.mode == Slide
			int row, column
			string file
			if Platform.mode == Pointer
				let movedSinceTouchUp = (pixelPos manhattanDistanceTo touchUpPos) > 8
				if inputType == TouchUp: touchUpPos = pixelPos
					
				if (inputType == TouchDown and movedSinceTouchUp) or (inputType == TouchUp and !movedSinceTouchUp)
					if movedSinceTouchUp                   
						locationIndex = 0
						locations.clear
						for item -> graphics.items
							if item.location != null and pixelPos.isInsidePoygon item.poly
								SourceCodeLocation[] itemLocations
								item.location.flatten itemLocations
								itemLocations.sort (a.file compareTo b.file) || b.row - a.row || a.column - b.column
								for itemLocations
									if !.file.startsWith("lib")
										locations.add .
					
					if locations.length
						let selectedLocation = locations[locationIndex++ % locations.length]
						row = selectedLocation.row
						column = selectedLocation.column
						file = selectedLocation.file
			sendTouchToEditor id, referencePos, cast inputType, row, column, file
			
	private js void sendTouchToEditor: int id, float2 pos, TouchPhase phase, int row, int column, string file
		_sendToEditor({type:"touch", id, x:pos.x, y:pos.y, phase, row, column, file})
	
	internal js void sendFrame: int frame, int frames
		_sendToEditor({type:"frame", frame, frames})
	
	internal js void sendWatch: int frame, string text, int row, int column, string file
		_sendToEditor({type:"watch", frame, text, row, column, file})
	
	private js void sendMode
		if(Platform_isDebug) _sendToEditor({type:"setPlatformMode", mode:Platform_mode, frame:Network_frame})

	private inline js void sendEvaluateFinished
		if(Platform_isDebug) _sendToEditor({type:"evaluateFinished"})

	js void setTitle: string title
		document.title = title
		
	inline js void requestFullscreen
		try   { if(!Network_isLocalhost && !Platform_isDebug) document.body.requestFullscreen() }
		catch { }
		
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
		
	inline js void setLocalStorageObject: string key, object value
		localStorage.setItem(key, JSON.stringify(value))
		
	js object getLocalStorageObject: string key
		let str = localStorage.getItem(key)
		return str ? JSON.parse(str) : null 
		
	js string generateObjectId
		var result = (Date.now() / 1000 | 0).toString(16)
		for(let i=0; i<16; i++)
			result += (Math.random() * 16 | 0).toString(16)
		return result.toLowerCase()
		
	inline js void vibrate: int duration = 100
		navigator.vibrate(duration)
		
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
		
	js void stack
		try      { _ }
		catch(e) { return e.stack }
		
	inline js void alert: string message
		alert(message)
		log(message)
		
	inline js void pushState: object state, string title, string url = ""
		history.pushState(state, title, url)
		
	inline js void schedule: int delay
		                     void() then
		setTimeout(then, delay)
		
struct FileFilter
	string name
	string[] extensions

transient unit Http	
	js void get: string url, void(object result) code
		let response = await fetch(url)
		code(await response.json())
		
	js void delete: string url 
		         void(object result) code
		         void(string error) else
		try {
			let response = await fetch(url, {method:"DELETE"})
			let result = await response.text()
			code(result)
		} catch(e) {
			else(e.message)
		}
		
	js void put: string url 
		         void(object result) code
		         void(string error) else
		try {
			let response = await fetch(url, {method:"PUT"})
			let result = await response.text()
			code(result)
		} catch(e) {
			else(e.message)
		}
		
	js void put: string url
		         object body
		         void(object result) code
		         void(string error) else
		try {
			let response = await fetch(url, {method:"PUT", body:JSON.stringify(body)})
			let result = await response.json()
			code(result)
		} catch(e) {
			else(e.message)
		}
		
	js void post: string url
		          string body
		          void(object result) code
		          void(string error) else
		try {
			let response = await fetch(url, {method:"POST", body})
			let result = await response.text()
			code(result)
		} catch(e) {
			else(e.message)
		}
		
transient unit IndexedDB
	private object db = null
	
	js void start: string databaseName, string storeName, int version = 1
		try {
			IndexedDB_storeName = storeName;
			var request = indexedDB.open(databaseName, version)
			request.onupgradeneeded = e => {
				IndexedDB_db = e.target.result;
				if(!IndexedDB_db.objectStoreNames.contains(storeName))
					IndexedDB_db.createObjectStore(storeName, { keyPath: "id" });
				Network_log("IndexedDB successfully upgraded to version "+version)
			}
			request.onsuccess = e => {
				IndexedDB_db = e.target.result;
				Network_log("IndexedDB started successfully");
			}
			request.onerror = e => {
				Network_log("Error in IndexedDB.start: "+request.error);
			}
		} catch(e) {
			Network_log("Error in IndexedDB.start: "+e.message)
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


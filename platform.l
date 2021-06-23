enum PlatformMode: Pause, Record, Play, Pointer, Slide
enum ScaleMode: Auto, FixedWidth, FixedHeight, None
enum AnchorMode: TopLeft, TopCenter, Center
		
transient unit Platform
	public userCount = 2
	public bool showSafeArea = true
	public bool showLocalPointer = false
	public bool isLocal = false
	
	public inline js string url := location.href
	public inline js int version := version
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
	private bool engineStarted
	visible PlatformMode mode
	internal bool fastForward
	visible bool isMobile = true
	
	private init
		initHandlers
			
	private inline js void initAll
		init();
		
	private js void initHandlers
		Platform_isMobile = false;
		if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent) 
			|| /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0,4))) { 
			Platform_isMobile = true;
		}
		if(!Platform_isMobile) 
			window.onresize = e => { 
				Platform_resize();
				if(Platform_mode == 0/*Pause*/) Network_tick();
			}
		
	private js void resize
		// Scale canvas
		Platform_canvas = document.getElementById("canvas");
		Platform_context = Platform_canvas.getContext("2d");
		Platform_pixelRatio = 1;
		Platform_pixelSize = new float2(window.innerWidth*Platform_pixelRatio, window.innerHeight*Platform_pixelRatio, null)
		Platform_canvas.style.width = window.innerWidth + "px";
		Platform_canvas.style.height = window.innerHeight + "px";
		Platform_canvas.width = Platform_pixelSize.x
		Platform_canvas.height = Platform_pixelSize.y
		Platform_canvas.imageSmoothingEnabled = true
		Platform_canvas.imageSmoothingQuality = "high"
		
		// Create base matrix
		let ratio = new float2(Platform_pixelSize.x / Platform_referenceSize.x, Platform_pixelSize.y / Platform_referenceSize.y, null);
		let scale
		switch(Platform_scaleMode) {
			case 0:
				if(ratio.x < ratio.y) { Platform_effectiveScaleMode = 1; scale = ratio.x; }
				else                  { Platform_effectiveScaleMode = 2; scale = ratio.y; }
				Platform_size = new float2(Platform_referenceSize.x, Platform_referenceSize.y, null)
				break;
				
			case 1:
				Platform_effectiveScaleMode = Platform_scaleMode
				scale = ratio.x; 
				Platform_size = new float2(Platform_referenceSize.x, Platform_pixelSize.y/scale, null)
				break;
				
			case 2:
				Platform_effectiveScaleMode = Platform_scaleMode
				scale = ratio.y; 
				Platform_size = new float2(Platform_pixelSize.x/scale, Platform_referenceSize.y, null)
				break;
		}
		let offsetX = Platform_anchor > 0 ? Platform_pixelSize.x/2 : 0
		let offsetY = Platform_anchor > 1 ? Platform_pixelSize.y/2 : 0
		Platform_baseMatrix = new Matrix2D(scale,0,0,scale,offsetX,offsetY)
		
	private startEngine: bool isDebug
		init
		this.isDebug = isDebug
		if !isDebug: showSafeArea = false
		this.engineStarted = true
		sendEvaluateFinished
		
	private startApp
		initAll
		resize
		if !isDebug: Network.simulateConnection = false
		if mode <= Play: mode = Pause
		let path = url.split("/")
		let gameId = path[3]
		let roomId = path[4]

		if isDebug || isLocal || roomId == "local" || url.startsWith("file"): Network.startLocal userCount:userCount
		else                                                                  Network.join gameId, roomId
		sendMode
		// Network.tick
		
	private stop()    mode = Pause;  startApp
	private record()  mode = Record; sendMode; Network.resetStartTime
	private play()    mode = Play;   sendMode; Network.resetStartTime
	
	private enterSlideMode(PlatformMode mode) startApp; this.mode = mode; sendMode
	
	private tick
		if mode == Play || mode == Record: Network.animationFrame
		
	float2 touchUpPos
	int locationIndex
	
	handleSide: InputType inputType, int id, float2 pixelPos, float2 referencePos	
		if Platform.mode == Pointer or Platform.mode == Slide
			int row, column
			string file
			if Platform.mode == Pointer
				let movedSinceTouchUp = float2.manhattanDistanceBetween(pixelPos, touchUpPos) > 8
				if inputType == TouchUp: touchUpPos = pixelPos
					
				if (inputType == TouchDown and movedSinceTouchUp) or (inputType == TouchUp and !movedSinceTouchUp)
					if !movedSinceTouchUp: locationIndex++
					else                   locationIndex = 0
					
					for item -> graphics.items
						if item.location != null and pixelPos.isInsidePoygon item.poly
							SourceCodeLocation[] locations
							item.location.flatten locations
							locations.sort (a.file compareTo b.file) || b.row - a.row || a.column - b.column
							let selectedLocation = locations[locationIndex % locations.length]
							row = selectedLocation.row
							column = selectedLocation.column
							file = selectedLocation.file
							break
			sendTouchToEditor id, referencePos, cast inputType, row, column, file
			
	private js void sendTouchToEditor: int id, float2 pos, TouchPhase phase, int row, int column, string file
		_sendToEditor({type:"touch", id, x:pos.x, y:pos.y, phase, row, column, file})
	
	private js void sendMode
		if(Platform_isDebug) _sendToEditor({type:"setPlatformMode", mode:Platform_mode, frame:Network_frame})

	private inline js void sendEvaluateFinished
		if(Platform_isDebug) _sendToEditor({type:"evaluateFinished"})

	js void setTitle: string title
		document.title = title
		
	inline js void requestFullscreen
		try   { document.body.requestFullscreen() }
		catch { }
		
	js void createTextFile: string filename, string text
		var element = document.createElement('a');
		element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
		element.setAttribute('download', filename);
		element.style.display = 'none';
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
		
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
		
	inline js void saveImage: string file
		var url = Platform_canvas.toDataURL('image/png');
		var base64Data = url.replace(/data:image\/png;base64,/, "");
		var fs = require("fs")
		fs.writeFile(file, base64Data, 'base64', function (err) {
			if(err) log(err)
		});
		
	js string[] showOpenDialog: FileFilter[] filters = null
		const { remote } = require("electron")
		return remote.dialog.showOpenDialogSync({ filters, properties: ['openFile'] })
		
	inline js void debugger
		debugger
		
	inline js void pushState: object state, string title, string url = ""
		history.pushState(state, title, url)
		
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

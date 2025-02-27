CompilerSettings
	serializeInternal = false
	serializeExternal = false
	sourceCodeLocation = true
	clone = true
	
class ReferenceSize
	float referenceWidth = 1920
	float forWidthBelow = float.maxValue
	bool isMobile = false
	
enum TickMode: Interval, AnimationFrame
	
skipInit global unit Platform
	public targetFps = 0
	public TickMode tickMode = Interval
	public resetWhenCodeChanged = true
		
	Vector2 size, nativeSize
	float scale
	float debugScale = 1
	ReferenceSize[] referenceSizes
	
	// Environment
	bool isDebug
	global bool isMobile
	bool electron
	
	// Info
	public inline js string url := location.href
	public inline js string host := location.host
	public inline js string basePath := _basePath
	public inline js string protocolAndHost() (location.host && !Platform.isDebug ? location.origin : "http://localhost")
	public inline js string referrer := document.referrer
	public inline js string encodeURIComponent(string value) encodeURIComponent(value)
	public inline js string decodeURIComponent(string value) decodeURIComponent(value)
	public inline js dynamic networkInformation() navigator.connection

	private inline js void initMedia
		this.electron = window?.process?.versions?.electron
		$Image.init?.();
		Font.init?.();
		Sound.init?.();
		audio.init();
		Time.timezoneOffset = new Date().getTimezoneOffset() * 60000
		app.init?.()
		
	private async inline js void initDatabase
		if(typeof(pocketBase) != "undefined") await pocketBase.connect()
			
	async start: bool isDebug
		try
			this.nextHeartbeatTime = 0
			heartbeat "start"
			
			this.isDebug = isDebug
			this.referenceSizes = [
				{1920}
				{960 forWidthBelow:600 isMobile:true}
			]
			this.targetFps = 0
			this.tickMode = Interval
			this.resetWhenCodeChanged = true
			
			initMedia
			initDatabase
			openMedia
				try
					stop
					// We need to call resize again after the first refresh to prevent unwanted scrolling
					Html.resize
					startTickInterval
				catch 
					sendErrorToEditor .
				finally
					sendFinished
		catch 
			sendErrorToEditor .
			sendFinished
		
	js void openMedia: void() success
		let font = new FontFace('OpenSans', `url(${_basePath}OpenSans.woff2)`);
		await font.load();
		document.fonts.add(font);
		success()
		
	js void initAll
		init()
		
	async replay
		try
			heartbeat "replay"
			if resetWhenCodeChanged: Html.reset
			initMedia
			initDatabase
			initAll
			Html.resize
			startApp
			refresh
		catch
			sendErrorToEditor .
		finally
			sendFinished
		
	stop
		Html.reset
		replay
		
	private js void startApp
		if(app.start) app.start()
		
	private js void tick
		Platform.heartbeat("tick")
		if(app.tick) app.tick()
		Time.frame++
		
	private js void startTickInterval
		if(window._tickInterval) {
			clearInterval(_tickInterval)
		}
		if(Platform.targetFps) {
			if(Platform.tickMode == 0) {
				_tickInterval = setInterval(() => Platform.tick(), 1000/Platform.targetFps)
			} else {
				window.tick = function() {
					Platform.tick();
					window.requestAnimationFrame(window.tick);
				}
				window.tick();
			}
		}
		
	internal inline js void sendErrorToEditor: Error error
		if(window._sendErrorToEditor) _sendErrorToEditor(error)
		else                          console.error(error)
		
	private inline js void sendFinished
		console.log("[app] ----- Finished -----")
		if(Platform.isDebug) _sendToEditor({type:"finished"})
			
	Time nextHeartbeatTime = 0
	
	private js void heartbeat: string context
		if(!Platform.isDebug) return
		let now = Date.now();
		if(now > Platform.nextHeartbeatTime) {
			Platform.nextHeartbeatTime = now + 3000;
			_sendStringToEditor("~");
		}
		
	js string generateObjectId
		const timestamp = Math.floor(new Date().getTime() / 1000).toString(16);
		const machineIdentifier = Math.floor(Math.random() * 0xFFFFFF).toString(16).padStart(6, '0');
		const processIdentifier = Math.floor(Math.random() * 0xFFFF).toString(16).padStart(4, '0');
		const counter = Math.floor(Math.random() * 0xFFFFFF).toString(16).padStart(6, '0');
		return (timestamp + machineIdentifier + processIdentifier + counter).toLowerCase();
		
	toggleSmallScreen
		isMobile = !isMobile;
		setLocalStorageString("isMobile", isMobile ? "true" : "false")
		Html.resize
		refresh

	inline js void setLocalStorageString: string key, string value
		localStorage.setItem(key, value)
		
	inline js string getLocalStorageString: string key
		(localStorage.getItem(key) || "")
		
	inline js void setLocalStorageObject: string key, any value
		localStorage.setItem(key, JSON.stringify(value))
		
	js any getLocalStorageObject: string key
		                          any defaultValue = null
		let str = localStorage.getItem(key)
		return str ? JSON.parse(str) : defaultValue
		
	// Shows a dialog box with a given message
	inline js void alert: implicit string message // The message to show
		alert(message)
	
	inline js void openLink: string url
		window.open(url)
		
	inline js void redirect: string url
		location.href = url
		
	inline js void pushState: string url
		                      object state = null
		history.pushState(state, "", url);
		
	inline js void replaceState: string url
		                         object state = null
		history.replaceState(state, "", url);
		
	inline js void copyToClipboard: string text
		navigator.clipboard.writeText(text)
		
	global inline js int delay: Time time
		                        void() do
		setTimeout(do, time)
		
	global inline js async void delay: Time time
		new Promise(resolve => setTimeout(resolve, time))
		
	global inline js int clearDelay: int handle
		clearTimeout(handle)
		
	inline js void onBlur: void() do
		window.onblur = do
		
	inline js void onFocus: void() do
		window.onfocus = do
		
	global inline js int interval: Time time
		                           void() do
		setInterval(do, time)
		
	global inline js int clearInterval: int handle
		clearInterval(handle)
		
	js object stack
		try      { _ }
		catch(e) { return e.stack }
		
	inline js void debugger() debugger
	
	global js void onNavigate: void(string url) do
		window.onpopstate = e => do(location.pathname)
		
	global js void onPaste: void(DateTransfer data) do
		document.onpaste = e => do(e.clipboardData)
		
	inline js void blur() document.activeElement.blur()
	
	js void setMenu: MenuItem[] menuTemplate
		if(!Platform.electron || !document.hasFocus()) return;
		const remote = require('@electron/remote');
		if (process.platform == 'darwin') {
			menuTemplate.unshift({
				label: "",
				submenu: [
					{role: 'about'},
					{type: 'separator'},
					{role: 'hide'},
					{role: 'hideothers'},
					{role: 'unhide'},
					{type: 'separator'},
					{role: 'quit'},
				]
			})
			let menu = remote.Menu.buildFromTemplate(menuTemplate)
			remote.Menu.setApplicationMenu(menu)
		} else {
			let menu = remote.Menu.buildFromTemplate(menuTemplate)
			remote.getCurrentWindow().setMenu(menu)
		}
		
	js async Vector2 getCurrentLocation: enableHighAccuracy = true
		                                 maximumAge = 5000
		                                 timeout = 3000
		return new Promise((resolve, reject) => {
			navigator.geolocation.getCurrentPosition(pos => {
				resolve(new Vector2(pos.coords.longitude, pos.coords.latitude, "geo"))
			}, error => {
				reject(error)
			}, {maximumAge, timeout, enableHighAccuracy})
		})
		
	js async void onDeviceOrientation: void(Angle angle) do
		                               void(string error) else = null
		if(window.ondeviceorientationabsolute !== undefined) {
			window.ondeviceorientationabsolute = e => do(new Angle(1 - (e.alpha || 0)/360, "turn"));
		} else {
			try {
				let response = await DeviceOrientationEvent.requestPermission();
				if (response == "granted") {
					window.ondeviceorientation = e => do(new Angle(1 - (e.webkitCompassHeading || e.alpha || 0)/360, "turn"));
				} else {
					else?.(response);
				}
			} catch(e) {
				else?.(e.message);
			}
		}
		
	js void onCurrentLocation: void(Vector2 location) do
		                       void(string error) else = null
		                       enableHighAccuracy = true
		                       maximumAge = 5000
		                       timeout = 5000
		navigator.geolocation.watchPosition(pos => {
			do(new Vector2(pos.coords.longitude, pos.coords.latitude, "geo"))
		}, e => {
			do(new Vector2(Number.POSITIVE_INFINITY, Number.POSITIVE_INFINITY, "geo"))
			else?.(e.message)
		}, {maximumAge, timeout, enableHighAccuracy})
		
enum lowercase string DataTransferItemKind: String, File
		
interface DataTransferItem
	DataTransferItemKind kind // The kind of drag item, string or file
	string type               // The data item's type, typically a MIME type
	
	inline js async string getAsString
		new Promise(resolve => this.getAsString(a => resolve(a)))
		
	inline js File getAsFile
		this.getAsFile()
		
interface DateTransfer
	DataTransferItem[] items
	
MenuItem
	string label
	string accelerator
	native void() click
	string type = null
	string role = null
	MenuItem[] submenu = null
	bool checked
	
global transient unit System
	// Prints a message to the console
	global js void print: logstring text // The text, variables or expressions to print
		                  SourceCodeLocation location
		console.log(text)
		if(Platform.isDebug) {
			var stringValue = typeof text === "string" ? text : JSON.stringify(text);
			if(stringValue) _sendToEditor({type:"log", value:stringValue, location:location?.start, file:location?.file});
		}
	
global skipInit unit math
	// Generates a random integer
	global js int randomInteger: int min // The inclusive lower bound of the random integer
		                         int max // The exclusive upper bound of the random integer
		return min + Math.floor(Math.random() * (max-min))
	
	global js int randomInteger: int max = 2147483647 // The exclusive upper bound of the random integer
		return Math.floor(Math.random() * max)
	
	// Generates a random float
	global inline js int randomFloat
		Math.random()

skipInit transient float Time
	// The number of milliseconds elapsed since January 1, 1970
	static inline js Time now := Date.now()
	
// A color comprised of a red, green, blue and alpha component
class Color
	global const Color White       = {"#ffffff", "White"}
	global const Color Black       = {"#000000", "Black"}
	global const Color Red         = {"#ef476f", "Red"}
	global const Color Yellow      = {"#ffd166", "Yellow"}
	global const Color Green       = {"#06d6a0", "Green"}
	global const Color Blue        = {"#118ab2", "Blue"}
	global const Color Gray        = {"#3d3d3d", "Gray"}
	global const Color Transparent = {"#00000000", "Transparent"}
		
	const Color TransparentRed     = {"#ff000080", "Transparent Red"}
	
	string hex
	string name
	
	string toString := hex
	
	Color: string hex = ""
		this.hex = hex

	Color: int red = 0
		   int green = 0
		   int blue = 0
		   int alpha = 255
		this.hex = "#" + componentToHex(red) + componentToHex(green) + componentToHex(blue) + componentToHex(alpha)
			
	static js string componentToHex: int c
		var hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
		
	inline js bool == Color other: this?.hex == other?.hex
	inline js bool != Color other: this?.hex != other?.hex
	
	Color withAlpha: float alpha
		return {hex[1..7]+componentToHex(math.floor(alpha*255))}
	
skipInit class Image
	string previewSrc
	string src
	string basePath = Platform.basePath
	
	toString := "url({basePath}{src})"
	
skipInit class Font
	string name
	string src
	
Node WebView
	string url
	
	native void(string url) onWillNavigate
	bool hasHandlers
	
	inline js void downloadURL(string url) this.downloadURL(url)
	inline js void goBack() this.goBack()
	
global unit Html
	Unit defaultUnit = Pixels
	
	private Node parentNode
	private Node currentNode
	private Node currentOverlay
	
	inline js Vector2 scrollPosition() new Vector2(window.pageXOffset, window.pageYOffset/Platform.scale)
	inline js void scrollTo(float x, float y) window.scrollTo(x,y)
	inline js Node get(string id) document.getElementById(id)
	inline js Node documentBody() document.body
	
	js Node getNodeAt(float x, float y) 
		let node = document.elementFromPoint(x, y)
		while(!node.id && node.parentElement)
			node = node.parentElement
		return node
	
	init
		initHandlers
	
	js void initHandlers
		window.onresize = e => {
			Html.resize();
			Html.refresh();
		}

	internal js void reset
		while(document.body.nextSibling) 
			document.body.nextSibling.remove()
		document.body.innerHTML = ""
		input.clear
	
	internal js void resize
		let body = document.body
		if(Platform.referenceSizes?.length > 0) {
			let screenWidth = localStorage.getItem("isMobile") == "true" ? 0 : screen.width
			Platform.referenceSizes.sort((a,b) => a.forWidthBelow - b.forWidthBelow)
			let referenceWidth = 0
			for(let entry of Platform.referenceSizes) {
				if(screenWidth < entry.forWidthBelow) {
					referenceWidth = entry.referenceWidth
					Platform.isMobile = entry.isMobile
					break;
				}
			}
			Platform.scale = window.innerWidth / referenceWidth
			Platform.nativeSize = new Vector2(window.innerWidth, window.innerHeight)
			Platform.size = new Vector2(referenceWidth, referenceWidth * window.innerHeight/window.innerWidth)
			body.style = "background-color: white; font:32px OpenSans"
			body.style.transform = 'none !important'
			body.style.marginRight = '0 !important'
			body.style.marginBottom = '0 !important'
			body.style.width = Platform.size.x+"px"
			const width = body.clientWidth
			const height = body.clientHeight
			body.style.transform = `scale(${Platform.scale})`
			body.style.transformOrigin = '0 0'
			const pullUp = height - height * Platform.scale
			const pullLeft = width - width * Platform.scale
			body.style.marginBottom = `${-pullUp}px`
			body.style.marginRight = `${-pullLeft}px`
			body.className = Platform.isMobile ? "mobile" : ""
			body.style.touchAction = "none"
		} else {
			Platform.isMobile = localStorage.getItem("isMobile") == "true"
			Platform.scale = Platform.isDebug ? Platform.debugScale : 1
			body.style.zoom = Platform.scale
			body.style.font = "32px OpenSans"
			body.className = Platform.isMobile ? "mobile" : ""
			body.style.touchAction = "none"
		}
	
	enableScrolling: bool value
		let style = documentBody.style
		if value
			style.overflow = Visible
			style.position = Static
		else
			style.overflow = Hidden
			style.position = Fixed
			style.top = {0}
			style.bottom = {0}

	private js void setDataAttributes: Node node, dynamic attributes
		if(attributes) {
			let shadowAttributes = node.shadowAttributes || (node.shadowAttributes = new Map)
			for(let key in attributes) {
				let value = attributes[key].toString();
				if(shadowAttributes.get(key) != value) {
					node.setAttribute(key, attributes[key]);
					shadowAttributes.set(key, value);
				}
			}
		}
		
	static js Style expandStyle: Style style
		if(style.size) { 
			style.width  = style.size.x+"px"; 
			style.height = style.size.y+"px";
		}
		if(style.overlay) {
			let rect = document.body.getBoundingClientRect()
			style.position = "fixed"; style.top = 0; style.left = 0; style.width = (window.innerWidth/Platform.scale)+"px"; style.height = (document.body.scrollHeight)+"px"  
		}
		return style 
	
	private js void setStyle: Node node, dynamic style
		// We shouldn't need this because the same line of code can't output less styles than previously
		// A code change always triggers a complete refresh
		// node.style = ""
		if(style) {
			// Always set style (slowest)
			// for(let key in Html.expandStyle(style))
			// 	node.style[key] = style[key]
				
			// Set style if it changed (slow)
			// for(let key in Html.expandStyle(style)) {
			// 	let value = style[key].toString();
			// 	if(node.style[key] != value) {
			// 		node.style[key] = value
			// 	}
			// }
			
			// Check if style has changed using a shadow copy (fastest)
			let shadowStyle = node.shadowStyle || (node.shadowStyle = new Map)
			for(let key in Html.expandStyle(style)) {
				let value = style[key].toString();
				if(shadowStyle.get(key) != value) {
					node.style[key] = value;
					shadowStyle.set(key, value);
				}
			}
				
			// Temporary Backfill. Starting from Chrome 104, Safari 14.1 this is no longer needed.
			// let translate = style.translate
			// if(translate) node.style.transform += "translate("+translate+") "
			// let rotate = style.rotate
			// if(rotate) node.style.transform += "rotate("+rotate+"turn) "
				
			// if(style.targetTranslate || style.targetSize) {
			// 	setTimeout(() => {
			// 		node.style.transform = "translate("+style.targetTranslate+") "
			// 	}, 1000)
			// }
		} else {
			node.shadowStyle = null
		}
		
	private js Style getStyleToRevert: Style originalStyle, Style onHover
		let styleToRevert = {}
		for(let key in onHover) {
			styleToRevert[key] = originalStyle[key] || "" 
		}
		return styleToRevert
				
	js Vector2 getRelativeMousePosition: HtmlEvent event, Node node
		let rect = node.getBoundingClientRect()
		return new Vector2((event.clientX - rect.left)/Platform.scale, (event.clientY - rect.top)/Platform.scale)

	js void setCursorPosition: Node element, int position
		const range = document.createRange();
		const selection = window.getSelection();
		range.setStart(element.childNodes[0], position);
		range.collapse(true);
		selection.removeAllRanges();
		selection.addRange(range);
	
	int nodesCreated
	int nodesUpdated
	
	global void refresh
		// Time.startTimer
		nodesCreated = nodesUpdated = 0
		parentNode = documentBody
		currentNode = parentNode.firstChild
		currentOverlay = documentBody.nextSibling
		app.draw
		while currentNode
			let next = currentNode.nextSibling
			currentNode.remove
			currentNode = next
		while currentOverlay
			let next = currentOverlay.nextSibling
			currentOverlay.remove
			currentOverlay = next
		focusTabIndex = int.minValue
		// Time.printTimer "refresh: {nodesCreated} created, {nodesUpdated} updated"
		// if not overlayNode
		// 	overlayNode = div style:{position:Fixed top:0 left:0 right:0 bottom:0, backgroundColor:Black, opacity:.5}
		// 	body.parentNode.appendChild overlayNode
		
	script: string src
		let node = div tag:"script"
		if !node.src.endsWith(src): node.src = src
		node.onload = refresh
		
	css: string src
		dynamic node = cast div tag:"link"
		node.rel = "stylesheet" 
		if !node.href.endsWith(src): node.href = Platform.basePath + src
		
	style: string text
		return div tag:"style" text
		
	// Lays outs its children in a horizontal row				
	global row: expand Attributes attributes = null // The attributes of the HTML element
		        expand Style style = {}             // The css style of the HTML element
		        void() children = null              // The children of the HTML element
		        SourceCodeLocation location
		style.display = Flex
		style.flexDirection = Row
		return div attributes, style, children, location

	// Lays out its children in a vertical column
	global column: expand Attributes attributes = null // The attributes of the HTML element
		           expand Style style = {}             // The css style of the HTML element
		           void() children = null              // The children of the HTML element
		           SourceCodeLocation location
		style.display = Flex
		style.flexDirection = Column
		return div attributes, style, children, location

	// Lays out its children in a grid
	global grid: expand Attributes attributes = null // The attributes of the HTML element
		         expand Style style = {}             // The css style of the HTML element
		         float[] gridTemplateColumns         // The sizes of the columns
		         void() children = null              // The children of the HTML element
		         SourceCodeLocation location
		style.display = Grid
		string gridTemplateColumnsString
		for gridTemplateColumns
			gridTemplateColumnsString += "{.}fr "
		style.gridTemplateColumns = gridTemplateColumnsString
		return div attributes, style, children, location

	global img: Image image                       // The image to display
		        void(HtmlEvent ev) onClick = null // Called when the user clicks the image
		        expand Attributes attributes = {} // The attributes of the HTML element
		        expand Style style = null         // The css style of the HTML element
		        dynamic data = null               // The data attributes of the element
		        bool visible = true
		        SourceCodeLocation location
		if not visible: return
		if data == null: data = {}
		data.src = Platform.basePath + image.src
		let node = div tag:"img", attributes, style, data, location
		node.onclick = onClick
		return node

	global img: string src                        // The file of the image to display
		        expand Attributes attributes = {} // The attributes of the HTML element
		        expand Style style = null         // The css style of the HTML element
		        SourceCodeLocation location
		return div tag:"img", attributes, style, data:{src:src.startsWith("http") or src.startsWith("data:") or src.startsWith("blob:") ? src : Platform.basePath + src}, location
		
	global img: string src                        // The file of the image to display
		        expand Attributes attributes = {} // The attributes of the HTML element
		        expand Style style = null         // The css style of the HTML element
		        dynamic data                      // The data attributes of the element
		        SourceCodeLocation location
		if data == null: data = {}
		data.src = src.startsWith("http") or src.startsWith("data:") or src.startsWith("blob:") ? src : Platform.basePath + src
		return div tag:"img", attributes, style, data, location

	global link: string text = null
		         string href = "#"
		         expand Attributes attributes = {} // The attributes of the HTML element
		         expand Style style = null         // The css style of the HTML element
		         SourceCodeLocation location
		let node = div text, tag:"a", attributes, style, location
		node.href = href
		return node

	global span: string text = null
		         expand Attributes attributes = {} // The attributes of the HTML element
		         expand Style style = null         // The css style of the HTML element
		         SourceCodeLocation location
		return div text, tag:"span", attributes, style, location
		
	global button: string text = null
		           void(HtmlEvent ev) onClick = null // Called when the user clicks the button
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           SourceCodeLocation location
		let node = div text, tag:"button", attributes, style, location
		node.onclick = onClick
		return node
		
	global button: string text = null
		           bool(HtmlEvent ev) onClick = null // Called when the user clicks the button
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           bool disableAfterClick = false
		           SourceCodeLocation location
		let node = div text, tag:"button", attributes, style, location
		if disableAfterClick
			node.disabled = false
			node.onclick = let success = onClick(.); if not object.isEqualAndSameType(success, false): node.disabled = true
		else
			node.onclick = onClick(.)
		return node
		
	// 	global lottie
	// 	<script type="module" src="https://unpkg.com/@dotlottie/player-component@1.0.0/dist/dotlottie-player.js"></script>
	// <dotlottie-player autoplay controls loop mode="normal"
	//       src="http://dotlottieio.s3-website-us-east-1.amazonaws.com/sample_files/animation-external-image.lottie"
	//       style="width: 320px;height:320px;"></dotlottie-player>
	
	video: string src                        // The file of the video to display 
		   expand Attributes attributes = {} // The attributes of the HTML element 
		   expand Style style = {}           // The css style of the HTML element 
		   SourceCodeLocation location
		style.position = Absolute
		style.zIndex = -1000
		let element = div tag:"video", attributes, style, location, data:{src}
		element.muted = true
		element.autoplay = true
		
	global iframe: string src                        // The url of the content to display
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           dynamic data = {}                 // The data attributes of the element
		           int frameborder = 0
		           string allow = ""
		           string referrerpolicy = ""
		           bool allowfullscreen = true
		           SourceCodeLocation location
		data.frameborder = frameborder
		data.allow = allow
		data.referrerpolicy = referrerpolicy
		data.allowfullscreen = allowfullscreen
		let node = div tag:"iframe", attributes, style, data, location
		if node.src != src: node.src = src
		return node

	global webview: string initialUrl = ""              // The url of the content to display
		            expand Attributes attributes = {} // The attributes of the HTML element
		            expand Style style = null         // The css style of the HTML element
		            dynamic data = null               // The data attributes of the element
		            void(string url) onNavigate = null
		            SourceCodeLocation location
		WebView node = cast div tag:"webview", attributes, style, data, location
		node.onWillNavigate = onNavigate
		if not node.src: node.src = initialUrl
		if !node.hasHandlers
			node.hasHandlers = true
			node.on "will-navigate": if node.onWillNavigate != null: node.onWillNavigate(event.url)
		return node

	global body: expand Attributes attributes = {} // The attributes of the element
		         expand Style style = null         // Apply this css style to the element
		         void() children
		         nocolon void() header
		         SourceCodeLocation location
		let node = div attributes, style, children, location
		let prevParentNode = parentNode
		let prevCurrentNode = currentNode
		parentNode = node
		currentNode = node.firstChild
		header
		parentNode = prevParentNode
		currentNode = prevCurrentNode

	global div: string text = null                // The text content of the element 
		        string tag = "div"                // The tag of element
		        expand Attributes attributes = {} // The attributes of the element
		        expand Style style = null         // Apply this css style to the element
		        dynamic data = {}                 // The data attributes of the element
		        Style onHover = null              // Apply this css style to the element when the user moves their mouse over the element
		        void() children = null            // The children of the element
		        SourceCodeLocation location
		Node node, nextNode
		string sourceLocation = location?.toString
		string key = attributes?.key
		
		if key
			// If a key is specified, we store all nodes in a map on the parent object
			if not parentNode.childrenByKey: parentNode.childrenByKey = {}
			node = parentNode.childrenByKey[key]
			if not node
				// Create new node (with key)
				node = Node.create tag
				parentNode.childrenByKey[key] = node
				nextNode = currentNode
				if nextNode: parentNode.insertBefore node, nextNode
				else         parentNode.appendChild node
				nodesCreated++
			else
				// Resuse existing node (with key)
				nextNode = currentNode ? currentNode.nextSibling : null
				nodesUpdated++
			node.used = true
			
		else	
			if !currentNode or (currentNode.tagName?.toLowerCase != tag or currentNode.sourceLocation != sourceLocation)
				// Create new node
				node = Node.create tag
				nextNode = currentNode
				if nextNode: parentNode.insertBefore node, nextNode
				else         parentNode.appendChild node
				nodesCreated++
			else
				// Resuse existing node
				node = currentNode
				nextNode = currentNode.nextSibling
				nodesUpdated++
		
		setStyle node, style
		setDataAttributes node, data
		
		if attributes != null
			if attributes.id and attributes.id != node.id:           node.id = attributes.id
			if attributes.class and attributes.class != node.class:  node.class = attributes.class
			if attributes.title and attributes.title != node.title:  node.title = attributes.title
			
			if attributes.onClick != null:      node.onclick = attributes.onClick
			if attributes.onLeftClick != null:  node.onclick = attributes.onLeftClick
			if attributes.onRightClick != null: node.oncontextmenu = attributes.onRightClick
			if attributes.onKeyDown != null:    node.onkeydown = attributes.onKeyDown
			if attributes.onKeyUp != null:      node.onkeyup = attributes.onKeyUp
			if attributes.tabIndex:             node.set("tabindex", attributes.tabIndex.toString)
			
		node.sourceLocation = sourceLocation
		if onHover != null
			Style unHover = getStyleToRevert originalStyle:style, onHover
			node.onpointerover = setStyle(node, onHover)
			node.onpointerout  = setStyle(node, unHover)
		
		if text != null
			if node.shadowInnerHtml != text
				node.innerHTML = text
				node.shadowInnerHtml = text
		else
		if children != null or node.hasChildren
			node.shadowInnerHtml = null
			let prevParentNode = parentNode
			parentNode = node
			currentNode = node.firstChild
			if parentNode.childrenByKey
				for parentNode.childrenByKey
					.used = false
			children()
			
			// Remove all children that are no longer used
			if parentNode.childrenByKey
				// If the children have keys, removed all nodes that are not marked as "used"
				for parentNode.childrenByKey
					if not .used
						.remove
						parentNode.childrenByKey.remove key
			else
				// If the chidren don't have keys, remove all remaining nodes, that haven't been reused
				while currentNode
					let next = currentNode.nextSibling
					currentNode.remove
					currentNode = next
			parentNode = prevParentNode
			
		node.hasChildren = children != null
		currentNode = nextNode
		return node
		
	global overlay: expand Attributes attributes = {} // The attributes of the element
		            expand Style style = null         // Apply this css style to the element
		            void() children = null            // The children of the element
		            SourceCodeLocation location
		Node node, nextNode
		string sourceLocation = location?.toString
		
		if !currentOverlay or currentOverlay.sourceLocation != sourceLocation
			node = Node.create "div"
			nextNode = currentOverlay
			if nextNode: documentBody.parentNode.insertBefore node, nextNode
			else         documentBody.parentNode.appendChild node
		else
			node = currentOverlay
			nextNode = currentOverlay.nextSibling
		
		if style == null: style = {}	
		if not style.inset:           style.inset = {0,0,0,0}
		if not style.position:        style.position = Fixed
		setStyle node, style
		
		if attributes != null
			if attributes.id != null:           node.id = attributes.id
			if attributes.class != null:        node.class = attributes.class
			if attributes.onClick != null:      node.onclick = attributes.onClick
			if attributes.onRightClick != null: node.oncontextmenu = attributes.onRightClick
				
		let prevParentNode = parentNode
		let prevCurrentNode = currentNode
		parentNode = node
		currentNode = node.firstChild
		children()
		while currentNode
			let next = currentNode.nextSibling
			currentNode.remove
			currentNode = next
		parentNode = prevParentNode
		currentNode = prevCurrentNode
		
		currentOverlay = nextNode
		return node
		
	// -------------------------------------- Fields with change handlers --------------------------------------
		
	void() currentChangeHandler
	
	global void onChange: stored void() onChange
		                  void() do
		stored void() prevChangeHandler = currentChangeHandler
		currentChangeHandler = onChange
		do
		currentChangeHandler = prevChangeHandler
		
	// ---------- Radio & Toggle ----------
	
	global inline void radio: int model                         // The variable that holds the value. This will be updated when the user clicks the radio button
		                      int value                         // The value of this state of the radio button
		                      Image image                       // The image to display
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      dynamic data = null               // The data attributes of the element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"img", attributes, style, data, location
		node.style.opacity = model == value ? 1 : .3
		node.src = Platform.basePath + image.src
		node.onclick = model = value; changeHandler; refresh

	global inline void radio: int model                         // The variable that holds the value. This will be updated when the user clicks the radio button
		                      int value                         // The value of this state of the radio button
		                      Image image                       // The image to display
		                      inline void() onInput             // Called when the user clicks the radio button
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      dynamic data = null               // The data attributes of the element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"img", attributes, style, data, location
		node.style.opacity = model == value ? 1 : .3
		node.src = Platform.basePath + image.src
		node.onclick = model = value; onInput; changeHandler; refresh

	global inline void toggle: bool model                        // The variable that holds the value. This will be updated when the user clicks the toggle button
		                       Image[] images                    // A list with one image per state of the toggle
		                       expand Attributes attributes = {} // The attributes of the HTML element
		                       expand Style style = null         // The css style of the HTML element
		                       dynamic data = null               // The data attributes of the element
		                       SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"img", attributes, style, data, location
		node.src = Platform.basePath + images[model ? 1 : 0].src
		node.onclick = model = !model; changeHandler; refresh

	global inline void toggle: bool model                        // The variable that holds the value. This will be updated when the user clicks the toggle button
		                       Image[] images                    // A list with one image per state of the toggle
		                       inline void() onInput             // Called when the user clicks the toggle button
		                       expand Attributes attributes = {} // The attributes of the HTML element
		                       expand Style style = null         // The css style of the HTML element
		                       dynamic data = null               // The data attributes of the element
		                       SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"img", attributes, style, data, location
		node.src = Platform.basePath + images[model ? 1 : 0].src
		node.onclick = model = !model; onInput; changeHandler; refresh

	// ---------- Input & TextArea ----------
	
	int focusTabIndex = 0
	
	// Automatic Text Input: Updates the model automatically in with every keystroke
	global inline void field: string model = ""                 // The variable that holds the value. This will be updated when the user changed the text
		                      bool focused = false              // Whether the cursor should be placed in the field
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      dynamic data = {}                 // The data attributes of the element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"input", attributes, style, data, location
		node.value = model
		node.oninput = model = node.value; changeHandler
		if focused: node.focus
		
	// Automatic Text Input: Updates the model automatically in with every keystroke
	global inline void field: string model = ""                 // The variable that holds the value. This will be updated when the user changed the text
		                      bool focused = false              // Whether the cursor should be placed in the field
		                      inline void() onEnter = null      // Called when the user presses the enter key
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"input", attributes, style, location
		node.value = model
		node.oninput = model = node.value; changeHandler
		node.onkeydown = if(ev.keyCode == Enter) onEnter()
		if focused or focusTabIndex == attributes.tabIndex: node.focus
		
	// Manual Text Input: If you specify a onChange handler, the model won't be updated automatically
	global inline void field: string model = ""                  // The variable that holds the value. This will be updated when the user changed the text
		                      bool focused = false               // Whether the cursor should be placed in the field
		                      inline void(string value) onChange // If you specify a onChange handler, the model won't be updated automatically
		                      expand Attributes attributes = {}  // The attributes of the HTML element
		                      expand Style style = null          // The css style of the HTML element
		                      bool realtime = true               // Should onChange be called with every keystroke?
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"input", attributes, style, location
		node.value = model or ""
		if realtime: node.oninput = onChange(node.value); changeHandler
		else         node.onchange = onChange(node.value); changeHandler
		if focused or focusTabIndex == attributes.tabIndex: node.focus
			
	fileInput: string accept = "image/*"
		       string capture = "environment"
		       bool multiple = false
		       void(Node node) onChange = null
		       expand Style style = null
		       SourceCodeLocation location
		dynamic data = {type:"file" accept capture}
		if multiple: data.multiple = true
		let node = div tag:"input", data, style, location
		node.onchange = onChange(node)
		return node
		
	js Promise<string> getDataUrlForFile: File file
		return new Promise((resolve, reject) => {
			const reader = new FileReader();
			reader.onload = e => resolve(e.target.result);
			reader.readAsDataURL(file);	
		})
	
	// Automatic Editable Text: Updates the model automatically in with every keystroke
	global inline void editableText: string model = ""                          // The variable that holds the value. This will be updated when the user changed the text
		                             inline void(string value) onChanged = null // Called after the model changed
		                             int tabIndex = -1
		                             expand Attributes attributes = {}          // The attributes of the HTML element
		                             expand Style style = null                  // The css style of the HTML element
		                             dynamic data = {}                          // The data attributes of the element
		                             bool realtime = false                      // Should onChange be called with every keystroke?
		                             SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div attributes, style, data, location
		if model != node.innerText: node.innerText = model
		node.contentEditable = "plaintext-only"
		let prevModel = model
		if realtime
			node.oninput = model = node.innerText; onChanged(model); changeHandler
		else         
			node.onblur = model = node.innerText; if model != prevModel: onChanged(model); changeHandler
		if focusTabIndex == tabIndex: delay 100: node.focus

	// Automatic Editable Text: Updates the model automatically in with every keystroke
	global inline void editableText: string model = ""                          // The variable that holds the value. This will be updated when the user changed the text
		                             inline void(string value) onChanged = null // Called after the model changed
		                             inline void() onClick = null
		                             int tabIndex = -1
		                             expand Attributes attributes = {}          // The attributes of the HTML element
		                             expand Style style = null                  // The css style of the HTML element
		                             dynamic data = {}                          // The data attributes of the element
		                             bool realtime = false                      // Should onChange be called with every keystroke?
		                             SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div attributes, style, data, location
		if model != node.innerText: node.innerText = model
		node.onclick = onClick
		node.contentEditable = "plaintext-only"
		let prevModel = model
		if realtime
			node.oninput = model = node.innerText; onChanged(model); changeHandler
		else         
			node.onblur = model = node.innerText; if model != prevModel: onChanged(model); changeHandler
		if focusTabIndex == tabIndex: delay 100: node.focus

	// Automatic Text Area: Updates the model automatically in with every keystroke
	global inline void textarea: string model = ""                 // The variable that holds the value. This will be updated when the user changed the text
		                         bool focused = false              // Whether the cursor should be placed in the field
		                         expand Attributes attributes = {} // The attributes of the HTML element
		                         expand Style style = null         // The css style of the HTML element
		                         SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"textarea", attributes, style, location
		node.value = model
		node.style.minHeight = 16px
		node.style.overflow = Scroll; node.style.height = 1px; node.style.height = node.scrollHeight px; node.style.overflow = Hidden
		node.oninput = model = node.value; node.style.overflow = Scroll; node.style.height = 1px; node.style.height = node.scrollHeight px; node.style.overflow = Hidden; changeHandler
		if focused or focusTabIndex == attributes.tabIndex: node.focus

	// ---------- Canvas ----------
	
	dynamic currentContext
	
	global canvas: Vector2 size
		           expand Attributes attributes = {} // The attributes of the HTML element
		           expand Style style = null         // The css style of the HTML element
		           void() draw
		           SourceCodeLocation location
		if style == null: style = {}
		style.width = {size.x}
		style.height = {size.y}
		let canvas = div tag:"canvas", attributes, style, location
		canvas.width = size.x
		canvas.height = size.y 
		currentContext = canvas.context
		if currentContext == null: currentContext = canvas.context = canvas.getContext("2d")
		currentContext.clearRect(0,0,style.width,style.height)
		draw()
		return canvas
		
	global drawRectangle: Vector2 pos
		                  Vector2 size
		                  Color color = Black
		currentContext.fillStyle = color.hex
		currentContext.fillRect(pos.x, pos.y, size.x, size.y)
		
	global drawText: implicit string text
		             Vector2 pos
		             float size = 30
		             Font font = null
		             Color color = Black
		currentContext.fillStyle = color.hex
		string effectiveFont = font ? font.name : "Open Sans"
		currentContext.font = "{size}px {effectiveFont}"
		currentContext.fillText(text, pos.x, pos.y)
	


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
	public TickMode tickMode = Interval
	public targetFps = 20
		
	bool isDebug
	global bool isMobile
	Vector2 size, nativeSize
	float scale
	float debugScale = 1
	ReferenceSize[] referenceSizes
	
	// Info
	public inline js string url := location.href
	public inline js string host := location.host
	public inline js string basePath := _basePath
	public inline js string protocolAndHost() (location.host && !Platform.isDebug ? location.origin : "http://localhost")
	public inline js string encodeURIComponent(string value) encodeURIComponent(value)

	private inline js void initMedia
		$Image.init?.();
		Font.init?.();
		Sound.init?.();
		audio.init();
		Time.timezoneOffset = new Date().getTimezoneOffset() * 60000
		app.init?.()
			
	js void initHandlers
		window.onresize = e => {
			Html.updateScale();
			Html.refresh();
		}
		document.onkeydown = e => {
			let key = e.key
			if(key == "F10") { 
				Platform.toggleSmallScreen();
			}
		}
	
	start: bool isDebug
		try
			this.nextHeartbeatTime = 0
			heartbeat "start"
			
			this.isDebug = isDebug
			this.referenceSizes = [
				{1920}
				{960 forWidthBelow:600 isMobile:true}
			]
			this.targetFps = 20
			this.tickMode = Interval
			
			initMedia
			initHandlers
			openMedia
				try
					stop
					startTickInterval
				catch 
					sendErrorToEditor .
				finally
					sendFinished
		catch 
			sendErrorToEditor .
			sendFinished
		
	js void openMedia: void() success
		let font = new FontFace('OpenSans', 'url(OpenSans.woff2)');
		await font.load();
		document.fonts.add(font);
		success()
		
	js void initAll
		init()
		
	replay
		try
			heartbeat "replay"
			initMedia
			initAll
			Html.updateScale
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
		if(Platform.tickMode == 0) {
			_tickInterval = setInterval(() => Platform.tick(), 1000/Platform.targetFps)
		} else {
			window.tick = function() {
				Platform.tick();
				window.requestAnimationFrame(window.tick);
			}
			window.tick();
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
		
	toggleSmallScreen
		isMobile = !isMobile;
		setLocalStorageString("isMobile", isMobile ? "true" : "false")
		Html.updateScale
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
		
	global inline js void delay: Time time
		                  void() do
		setTimeout(do, time)
		
	global inline js void onBlur: void() do
		window.onblur = do
		
	global inline js int interval: Time time
		                           void(int handle) do
		var handle = setInterval(do, time)
		
	global inline js int clearInterval: int handle
		clearInterval(handle)
		
	inline js void debugger() debugger
	
	global js void onNavigate: void(string url) do
		window.onpopstate = e => do(location.pathname)
	
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
	
	toString := "url({Platform.basePath}{src})"
	
skipInit class Sound
	string src
	
skipInit class Font
	string name
	string src
	
global unit Html
	Unit defaultUnit = Pixels
	
	private Node parentNode
	private Node currentNode
	private Node currentOverlay
	
	inline js Vector2 scrollPosition() new Vector2(window.pageXOffset, window.pageYOffset/Platform.scale)
		
	inline js void scrollTo(float x, float y) window.scrollTo(x,y)
	
	private inline js Node body() document.body
	
	internal js void reset
		while(document.body.nextSibling) 
			document.body.nextSibling.remove()
		document.body.innerHTML = ""
	
	internal js void updateScale
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
		} else {
			Platform.isMobile = localStorage.getItem("isMobile") == "true"
			Platform.scale = Platform.isDebug ? Platform.debugScale : 1
			body.style.zoom = Platform.scale
			body.style.font = "32px OpenSans"
			body.className = Platform.isMobile ? "mobile" : ""
		}
	
	private js void setDataAttributes: Node node, dynamic attributes
		if(attributes)
			for(let key in attributes)
				node.setAttribute(key, attributes[key])
		
	static js Style expandStyle: Style style
		if(style.size) { style.width = style.size.x+"px"; style.height = style.size.y+"px" }
		if(style.overlay) {
			let rect = document.body.getBoundingClientRect()
			style.position = "fixed"; style.top = 0; style.left = 0; style.width = (window.innerWidth/Platform.scale)+"px"; style.height = (document.body.scrollHeight)+"px"  
		}
		return style 
	
	private js void setStyle: Node node, dynamic style
		node.style = ""
		if(style) {
			for(let key in Html.expandStyle(style))
				node.style[key] = style[key]
		}
		
	private js void addStyle: Node node, dynamic style
		if(style) {
			for(let key in style)
				node.style[key] = style[key]
				
			// Temporary Backfill. Starting from Chrome 104, Safari 14.1 this is no longer needed.
			let translate = style.translate
			if(translate) node.style.transform += "translate({translate}) "
			let rotate = style.rotate
			if(rotate) node.style.transform += "rotate({rotate}turn) "
		}
				
	js Vector2 getRelativeMousePosition: HtmlEvent event, Node node
		let rect = node.getBoundingClientRect()
		return new Vector2((event.clientX - rect.left)/Platform.scale, (event.clientY - rect.top)/Platform.scale)

	global void refresh
		parentNode = body
		currentNode = parentNode.firstChild
		currentOverlay = body.nextSibling
		app.render
		while currentNode
			let next = currentNode.nextSibling
			currentNode.remove
			currentNode = next
		while currentOverlay
			let next = currentOverlay.nextSibling
			currentOverlay.remove
			currentOverlay = next

	global row: expand Attributes attributes = null // The attributes of the HTML element
		        expand Style style = {}             // The css style of the HTML element
		        void() children = null              // The children of the HTML element
		        SourceCodeLocation location
		style.display = Flex
		style.flexDirection = Row
		return div attributes, style, children, location

	global column: expand Attributes attributes = null // The attributes of the HTML element
		           expand Style style = {}             // The css style of the HTML element
		           void() children = null              // The children of the HTML element
		           SourceCodeLocation location
		style.display = Flex
		style.flexDirection = Column
		return div attributes, style, children, location

	global img: Image image                       // The image to display
		        void(HtmlEvent ev) onClick = null // Called when the user clicks the image
		        expand Attributes attributes = {} // The attributes of the HTML element
		        expand Style style = null         // The css style of the HTML element
		        dynamic data = null               // The data attributes of the element
		        bool visible = true
		        SourceCodeLocation location
		if not visible: return
		let node = div tag:"img", attributes, style, data, location
		node.src = Platform.basePath + image.src
		node.onclick = onClick
		return node

	global img: string src                        // The file of the image to display
		        expand Attributes attributes = {} // The attributes of the HTML element
		        expand Style style = null         // The css style of the HTML element
		        dynamic data = null               // The data attributes of the element
		        SourceCodeLocation location
		let node = div tag:"img", attributes, style, data, location
		node.src = src.startsWith("http") ? src : Platform.basePath + src
		return node

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
		
	// 	global lottie
	// 	<script type="module" src="https://unpkg.com/@dotlottie/player-component@1.0.0/dist/dotlottie-player.js"></script>
	// <dotlottie-player autoplay controls loop mode="normal"
	//       src="http://dotlottieio.s3-website-us-east-1.amazonaws.com/sample_files/animation-external-image.lottie"
	//       style="width: 320px;height:320px;"></dotlottie-player>
	
	global video: string src                        // The file of the video to display 
		          expand Attributes attributes = {} // The attributes of the HTML element 
		          expand Style style = {}           // The css style of the HTML element 
		          SourceCodeLocation location
		style.position = Absolute
		style.zIndex = -1000
		let element = div tag:"video", attributes, style, location, data:{src}
		element.muted = true
		element.autoplay = true

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
		
		if !currentNode or (currentNode.tagName?.toLowerCase != tag or currentNode.sourceLocation != sourceLocation)
			node = Node.create tag
			nextNode = currentNode
			if nextNode: parentNode.insertBefore node, nextNode
			else         parentNode.appendChild node
		else
			node = currentNode
			nextNode = currentNode.nextSibling
		
		setStyle node, style
		setDataAttributes node, data
		
		if attributes != null
			if attributes.id != null:           node.id = attributes.id
			if attributes.class != null:        node.class = attributes.class
			if attributes.onClick != null:      node.onclick = attributes.onClick
			if attributes.onRightClick != null: node.oncontextmenu = attributes.onRightClick
				
		node.sourceLocation = sourceLocation
		if onHover != null
			node.onmouseover = addStyle(node, onHover)
			node.onmouseout  = setStyle(node, style)
			
		if text
			node.innerHTML = text
		else	
			let prevParentNode = parentNode
			parentNode = node
			currentNode = node.firstChild
			children()
			while currentNode
				let next = currentNode.nextSibling
				currentNode.remove
				currentNode = next
			parentNode = prevParentNode
			
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
			if nextNode: body.parentNode.insertBefore node, nextNode
			else         body.parentNode.appendChild node
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
	
	global inline void input: string model = ""                 // The variable that holds the value. This will be updated when the user changed the text
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
		
	global inline void input: string model = ""                 // The variable that holds the value. This will be updated when the user changed the text
		                      bool focused = false              // Whether the cursor should be placed in the field
		                      inline void() onEnter = null      // Called when the user presses the enter key
		                      expand Attributes attributes = {} // The attributes of the HTML element
		                      expand Style style = null         // The css style of the HTML element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"input", attributes, style, location
		node.value = model
		node.oninput = model = node.value; changeHandler
		node.onkeydown = if(ev.key == "Enter") onEnter()
		if focused: node.focus
		
	global inline void input: string model = ""                  // The variable that holds the value. This will be updated when the user changed the text
		                      bool focused = false               // Whether the cursor should be placed in the field
		                      inline void(string value) onChange // Called when the user changes the text and leaves the field
		                      expand Attributes attributes = {}  // The attributes of the HTML element
		                      expand Style style = null          // The css style of the HTML element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"input", attributes, style, location
		node.value = model
		node.onchange = model = node.value; onChange(node.value); changeHandler
		if focused: node.focus
		
	global inline void input: string model = ""                  // The variable that holds the value. This will be updated when the user changed the text
		                      bool focused = false               // Whether the cursor should be placed in the field
		                      inline void(string value) onInput  // Called after every character the user types
		                      expand Attributes attributes = {}  // The attributes of the HTML element
		                      expand Style style = null          // The css style of the HTML element
		                      SourceCodeLocation location
		stored void() changeHandler = currentChangeHandler
		let node = div tag:"input", attributes, style, location
		node.value = model
		node.oninput = model = node.value; onInput(node.value); changeHandler
		if focused: node.focus

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
		if focused: node.focus


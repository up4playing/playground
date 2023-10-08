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
	public protocolAndHost := host ? "https://"+host : "http://localhost"

	private inline js void initMedia
		if(window.Image_init) Image_init();
		if(window.Font_init)  Font_init();
		if(window.Sound_init) Sound_init();
		if(window.audio_init) audio_init();
		if(window.app_init) app_init()
			
	js void initHandlers
		window.onresize = e => {
			Html_updateScale();
			Html_render();
		}
		document.onkeydown = e => {
			let key = e.key
			if(key == "F10") { 
				Platform_toggleSmallScreen();
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
			Time.frame = 0
			startApp
			Html.updateScale
			Html.render
		catch
			sendErrorToEditor .
		finally
			sendFinished
		
	stop
		Html.reset
		replay
		
	private js void startApp
		if(window.app_start) app_start()
		
	private js void tick
		Platform_heartbeat("tick")
		if(window.app_tick) app_tick()
		Time_frame++
		
	private js void startTickInterval
		if(window._tickInterval) {
			clearInterval(_tickInterval)
		}
		if(Platform_tickMode == 0) {
			_tickInterval = setInterval(() => Platform_tick(), 1000/Platform_targetFps)
		} else {
			window.tick = function() {
				Platform_tick();
				window.requestAnimationFrame(window.tick);
			}
			window.tick();
		}
		
	internal inline js void sendErrorToEditor: Error error
		if(window._sendErrorToEditor) _sendErrorToEditor(error)
		else                          console.error(error)
		
	private inline js void sendFinished
		console.log("[app] ----- Finished -----")
		if(Platform_isDebug) _sendToEditor({type:"finished"})
			
	Time nextHeartbeatTime = 0
	
	private js void heartbeat: string context
		if(!Platform_isDebug) return
		let now = Date.now();
		if(now > Platform_nextHeartbeatTime) {
			console.log("[app]", (now%100000).toLocaleString("en-US", {minimumIntegerDigits:6, useGrouping:true})+" sending heartbeat from "+context);
			Platform_nextHeartbeatTime = now + 3000;
			_sendStringToEditor("~");
		}
		
	toggleSmallScreen
		isMobile = !isMobile;
		setLocalStorageString("isMobile", isMobile ? "true" : "false")
		Html.updateScale
		Html.render

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
		
	global inline js int interval: Time time
		                           void(int handle) do
		var handle = setInterval(do, time)
		
	global inline js int clearInterval: int handle
		clearInterval(handle)
		
	inline js void debugger() debugger
	
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
	
	implicit string toString := hex
	
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
		
	inline js bool operator ==(Color a, Color b) a.hex == b.hex
	inline js bool operator !=(Color a, Color b) a.hex != b.hex
	
	Color withAlpha: float alpha
		return {hex[1..7]+componentToHex(math.floor(alpha*255))}
	
skipInit class Image
	string previewSrc
	string src
	
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
	
	inline js Vector2 scrollPosition() new Vector2(window.pageXOffset, window.pageYOffset/Platform_scale)
	
	private inline js Node body() document.body
	
	internal js void reset
		while(document.body.nextSibling) 
			document.body.nextSibling.remove()
		document.body.innerHTML = ""
	
	internal js void updateScale
		let body = document.body
		if(Platform_referenceSizes?.length > 0) {
			let screenWidth = localStorage.getItem("isMobile") == "true" ? 0 : screen.width
			Platform_referenceSizes.sort((a,b) => a.forWidthBelow - b.forWidthBelow)
			let referenceWidth = 0
			for(let entry of Platform_referenceSizes) {
				if(screenWidth < entry.forWidthBelow) {
					referenceWidth = entry.referenceWidth
					Platform_isMobile = entry.isMobile
					break;
				}
			}
			Platform_scale = window.innerWidth / referenceWidth
			Platform_nativeSize = new Vector2(window.innerWidth, window.innerHeight)
			Platform_size = new Vector2(referenceWidth, referenceWidth * window.innerHeight/window.innerWidth)
			body.style = "background-color: white; font:32px OpenSans"
			body.style.transform = 'none !important'
			body.style.marginRight = '0 !important'
			body.style.marginBottom = '0 !important'
			body.style.width = Platform_size.x+"px"
			const width = body.clientWidth
			const height = body.clientHeight
			body.style.transform = `scale(${Platform_scale})`
			body.style.transformOrigin = '0 0'
			const pullUp = height - height * Platform_scale
			const pullLeft = width - width * Platform_scale
			body.style.marginBottom = `${-pullUp}px`
			body.style.marginRight = `${-pullLeft}px`
		} else {
			Platform_isMobile = localStorage.getItem("isMobile") == "true"
			Platform_scale = Platform_isDebug ? Platform_debugScale : 1
			body.style.zoom = Platform_scale
			body.style.font = "32px OpenSans"
		}
	
	private js void setDataAttributes: Node node, dynamic attributes
		if(attributes)
			for(let key in attributes)
				node.setAttribute(key, attributes[key])
		
	static js void expandStyle: Style style
		if(style.size) { style.width = style.size.x+"px"; style.height = style.size.y+"px" }
		if(style.overlay) {
			let rect = document.body.getBoundingClientRect()
			style.position = "fixed"; style.top = 0; style.left = 0; style.width = (window.innerWidth/Platform_scale)+"px"; style.height = (document.body.scrollHeight)+"px"  
		}
		return style 
	
	private js void setStyle: Node node, dynamic style
		node.style = ""
		if(style) {
			for(let key in Html_expandStyle(style))
				node.style[key] = style[key]
				
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
		return new Vector2((event.clientX - rect.left)/Platform_scale, (event.clientY - rect.top)/Platform_scale)

	void render
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
		// if not overlayNode
		// 	overlayNode = div style:{position:Fixed top:0 left:0 right:0 bottom:0, backgroundColor:Black, opacity:.5}
		// 	body.parentNode.appendChild overlayNode
						
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
		        expand Attributes attributes = {} // The attributes of the HTML element
		        expand Style style = null         // The css style of the HTML element
		        dynamic data = null               // The data attributes of the element
		        SourceCodeLocation location
		let node = div tag:"img", attributes, style, data, location
		node.src = image.src
		return node

	global img: string src                        // The file of the image to display
		        expand Attributes attributes = {} // The attributes of the HTML element
		        expand Style style = null         // The css style of the HTML element
		        dynamic data = null               // The data attributes of the element
		        SourceCodeLocation location
		let node = div tag:"img", attributes, style, data, location
		node.src = src
		return node

	global input: string value = ""                 // The initial value of the input
		          bool focused = false
		          void() onenter = null
		          expand Attributes attributes = {} // The attributes of the HTML element
		          expand Style style = null         // The css style of the HTML element
		          SourceCodeLocation location
		let node = div tag:"input", attributes, style, location
		if focused: node.focus
		if(onenter != null) node.onkeydown = if(ev.key == "Enter") onenter()
		return node
		
	global link: string text = null
		         string href = "#"
		         expand Attributes attributes = {} // The attributes of the HTML element
		         expand Style style = null         // The css style of the HTML element
		         SourceCodeLocation location
		attributes.href = href
		return div text, tag:"a", attributes, style, location

	global span: string text = null
		         expand Attributes attributes = {} // The attributes of the HTML element
		         expand Style style = null         // The css style of the HTML element
		         SourceCodeLocation location
		return div text, tag:"span", attributes, style, location
		
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
		div tag:"video", attributes, style, location, data:{src, autoplay:"autoplay", muted:"muted"}

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
		// if attributes.onClick != null
		// 	node.onclick = attributes.onClick(ev); if(!attributes.passClickToParents) ev.stopPropagation
		// if attributes.onRightClick != null
		// 	node.oncontextmenu = attributes.onRightClick(ev); ev.preventDefault
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
		if not style.inset:           style.inset = PaddingOrMargin(0,0,0,0)
		if not style.position:        style.position = Fixed
		// if not style.backgroundColor: style.backgroundColor = Black
		// if not style.opacity:         style.opacity = .5
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
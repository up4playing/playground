// A color comprised of a red, green, blue and alpha component
immutable Color
	global const Color White       = {"#ffffff", "White"}
	global const Color Black       = {"#000000", "Black"}
	global const Color Red         = {"#ef476f", "Red"}
	global const Color Yellow      = {"#ffd166", "Yellow"}
	global const Color Green       = {"#06d6a0", "Green"}
	global const Color Blue        = {"#118ab2", "Blue"}
	global const Color Gray        = {"#3d3d3d", "Gray"}
		
	const Color TransparentRed     = {"#ff000080", "Transparent Red"}
	
	string hex
	string name
	
	string toString := name or hex
	
	int red()   return hex[1..3].parseInt(16)
	int green() return hex[3..5].parseInt(16)
	int blue()  return hex[5..7].parseInt(16)
	
	Color * float other: return {math.floor(red*other), math.floor(green*other), math.floor(blue*other)}
	
	inline js bool == Color other: this?.hex == other?.hex
	inline js bool != Color other: this?.hex != other?.hex
	
	Color: string hex = ""
		this.hex = hex[0] == "#" ? hex : "#"+hex

	Color: int red = 0
		   int green = 0
		   int blue = 0
		this.hex = "#" + componentToHex(red) + componentToHex(green) + componentToHex(blue)
			
	Color: int red
		   int green
		   int blue
		   int alpha
		this.hex = "#" + componentToHex(red) + componentToHex(green) + componentToHex(blue) + componentToHex(alpha)
			
	static private js string componentToHex: int c
		var hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
		
	Color withAlpha: float alpha
		return {hex[1..7]+componentToHex(math.floor(alpha*255))}
		
enum TextOverflow: Visible, Wrap, Scale, WrapAndScale

// A texture that can be loaded into video memory
immutable Texture
	string file
	Vector2 size
	transient dynamic imageOrCanvas, context
	
	Texture
		if Platform.engineStarted and file
			open
			
	internal js bool ensureIsAvailable()
		if(!this.imageOrCanvas && this.file) {
			this.imageOrCanvas = _htmlImageCache[this.file]
		}
		return this.imageOrCanvas != null
	
	internal js void open
		if(!window._htmlImageCache) _htmlImageCache = {}
		let image = _htmlImageCache[this.file]
		if(!image) {
			return new Promise((resolve, reject) => {
				image = new Image()
				image.onload = e => {
					this.imageOrCanvas = image
					window._htmlImageCache[this.file] = image
					this.size = new Vector2(image.width, image.height, null)
					resolve(this);
				}
				image.src = Platform.getAbsoluteUrl(this.file)
			})
		} else {
			this.imageOrCanvas = image
			this.size = new Vector2(image.width, image.height, null)
			return this
		}
		
	js void setSize: Vector2 size
		if((size.x != this.size.x || size.y != this.size.y) && this.imageOrCanvas) {
			this.imageOrCanvas.width = size.x
			this.imageOrCanvas.height = size.y
		}
		this.size.assign(size);
		
	js void modify: implicit Player[] visibleFor = null // Only make any modification for this player or list of players
		            void() do                           // This block of code will draw on the created image instead of drawing on the screen
		let isVisible = graphics.isVisibleFor(visibleFor)
		if(isVisible) {
			// Save previous canvas
			var prevContext = graphics.context
			var prevPixelSizeX = graphics.pixelSize.x
			var prevPixelSizeY = graphics.pixelSize.y
			var prevItems = graphics.items
			var prevFastForward = Platform.fastForward
			
			// Create canvas
			if(!this.context) {
				this.imageOrCanvas = document.createElement("canvas")
				this.imageOrCanvas.width = this.size.x
				this.imageOrCanvas.height = this.size.y
				this.context = this.imageOrCanvas.getContext("2d")
			}
			
			// Setup canvas
			graphics.context = this.context
			graphics.pixelSize.x = this.size.x
			graphics.pixelSize.y = this.size.y
			graphics.items = []
			Platform.fastForward = false
			var a = graphics.localMatrix.matrix, b = graphics.totalMatrix.matrix
			var a0 = graphics.localMatrix.m0, a1 = graphics.localMatrix.m1, a2 = graphics.localMatrix.m2, a3 = graphics.localMatrix.m3, a4 = graphics.localMatrix.m4, a5 = graphics.localMatrix.m5
			var b0 = graphics.totalMatrix.m0, b1 = graphics.totalMatrix.m1, b2 = graphics.totalMatrix.m2, b3 = graphics.totalMatrix.m3, b4 = graphics.totalMatrix.m4, b5 = graphics.totalMatrix.m5
			graphics.localMatrix.set(1, 0, 0, 1, -this.size.x/2, -this.size.y/2)
			graphics.totalMatrix.set(1, 0, 0, 1, this.size.x/2, this.size.y/2)
			graphics.context.clearRect(0, 0, graphics.pixelSize.x, graphics.pixelSize.y)
			graphics.context.textBaseline = "top"
		}
		
		// Draw on canvas
		do()
			
		if(isVisible) {
			// Draw all display items
			graphics.drawItems()
			
			// Restore previous canvas
			graphics.localMatrix.m0 = a0; graphics.localMatrix.m1 = a1; graphics.localMatrix.m2 = a2; graphics.localMatrix.m3 = a3; graphics.localMatrix.m4 = a4; graphics.localMatrix.m5 = a5
			graphics.totalMatrix.m0 = b0; graphics.totalMatrix.m1 = b1; graphics.totalMatrix.m2 = b2; graphics.totalMatrix.m3 = b3; graphics.totalMatrix.m4 = b4; graphics.totalMatrix.m5 = b5
			graphics.context = prevContext
			graphics.pixelSize.x = prevPixelSizeX
			graphics.pixelSize.y = prevPixelSizeY
			graphics.items = prevItems
			Platform.fastForward = Platform.fastForward
		}
		
// A font that can be used to draw text
skipInit immutable Font
	string name
	string file
	Vector2 offset
	actualHeightFactor = .76
	
	js void open
		if(!window._fontCache) _fontCache = {}
		let font = _fontCache[this.file]
		if(!font) {
			let font = new FontFace(this.name, "url("+Platform.getAbsoluteUrl(this.file)+")");
			await font.load();
			document.fonts.add(font);
			_fontCache[this.file] = font;
			setTimeout(() => this.calculateOffset(), 0)
		}
		this.calculateOffset()
		return this
		
	private js void calculateOffset
		const fontsize = 64.0
		const margin = 32.0
		const canvas = document.createElement("canvas");
		const context=canvas.getContext("2d");
		const w = fontsize*2+margin, h = fontsize*2+margin;
		canvas.height = h;
		canvas.width = w;
		context.textBaseline="top";
		context.font=fontsize+"px "+this.name;
		context.fillStyle="red";
		context.fillText("M", margin, margin);
		let pixels = context.getImageData(0,0,w,h).data;
		
		let minY = 0
		findMinY:
		for(var y=0;y<h;y++) {
			for(var x=0;x<w;x++) {
			    if(pixels[(y*w+x)*4+3] > 0) {
				  minY = y-margin; break findMinY;
			    }
			}
		}
		
		let minX = 0
		findMinX:
		for(var x=0;x<w;x++) {
			for(var y=0;y<h;y++) {
			    if(pixels[(y*w+x)*4+3] > 0) {
        			minX = x-margin; break findMinX;
			    }
			}
		}
		this.offset = new Vector2(minX/fontsize, minY/(fontsize*this.actualHeightFactor))
		// log(this.name+" "+this.offset)

// A single frame of an animated image
internal immutable struct ImageFrame
	float x1, y1, x2, y2, w, h

// An image that can be drawn on the screen and can have several frames of animation
skipInit immutable Image
	string file
	Texture texture
	Vector2 size
	ImageFrame[] frames
	
enum DrawingOrder
	ItemsDrawnFirstWillBeInFront   // Move items to the front of the list to draw them in front
	ItemsDrawnFirstWillBeInTheBack // Move items to the back of the list to draw them in front
		
enum ScaleMode: Auto, FixedWidth, FixedHeight, None
enum AnchorMode: TopLeft, TopCenter, Center
enum HorizontalAlignment: Left, Center, Right
enum VerticalAlignment: Top, Middle, Bottom
enum FontStyle: Normal, Bold
internal immutable ClippingPath: Vector2[] points; bool show
	
internal TextHighlight
	string from
	string to
	Color color
	Color backgroundColor
	float cornerRadius
	Vector2 padding
	Vector2 margin
	bool wrap = true
	
// Draw on the screen
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
transient skipInit global unit graphics
	private object canvas
	internal dynamic context
	internal Matrix2D baseMatrix, totalMatrix, localMatrix
	internal DisplayItem[] items		
	private const alignmentFactor = [0, .5, 1]
	
	public Vector2 referenceSize = {1920, 1080}
	public DrawingOrder drawingOrder = ItemsDrawnFirstWillBeInFront
	public ScaleMode scaleMode = Auto, effectiveScaleMode
	public AnchorMode anchor = Center
	
	public Color topAndBottomMarginColor = null // If the screen is higher than the reference, show a letterbox in this color
	public Color leftAndRightMarginColor = null // If the screen is wider than the reference, show a letterbox in this color
	
	private Vector2 pixelSize
	internal Vector2 size
	internal float pixelRatio
	
	internal async setup: Vector2 referenceSize
		this.referenceSize = referenceSize
	
	internal js void onResize
		graphics.canvas = document.getElementById("canvas");
		graphics.pixelRatio = window.devicePixelRatio;
		graphics.pixelSize = new Vector2(window.innerWidth*graphics.pixelRatio, window.innerHeight*graphics.pixelRatio, null);
		graphics.isSmallScreen = screen.width < 600 || (localStorage.getItem("smallScreen") == "true")
		graphics.canvas.style.width = window.innerWidth + "px";
		graphics.canvas.style.height = window.innerHeight + "px";
		graphics.canvas.width = graphics.pixelSize.x;
		graphics.canvas.height = graphics.pixelSize.y;
		graphics.canvas.imageSmoothingEnabled = true;
		graphics.canvas.imageSmoothingQuality = "high";
		
		graphics.context = graphics.canvas.getContext("2d");
		graphics.updateBaseMatrix()

	// Update the base matrix
	// Called when resizing and after calling init() because we could change the scaleMode and anchor in App.init
	internal updateBaseMatrix
		let statisticsMargin = Platform.showDebugInfo ? statistics.margin : {}
		let referenceSizeWithMargin = referenceSize + statisticsMargin
		Vector2 ratio = {pixelSize.x / referenceSizeWithMargin.x, pixelSize.y / referenceSizeWithMargin.y}
		float scale
		if scaleMode == Auto
			if ratio.x < ratio.y: effectiveScaleMode = FixedWidth;  scale = ratio.x
			else                  effectiveScaleMode = FixedHeight; scale = ratio.y
		else
			effectiveScaleMode = scaleMode
			
		if effectiveScaleMode == FixedWidth
			scale = ratio.x
			size = {referenceSize.x, pixelSize.y/scale}
		else
		if effectiveScaleMode == FixedHeight
			scale = ratio.y; 
			size = {pixelSize.x/scale, referenceSize.y}
			
		let offsetX = anchor > TopLeft   ? pixelSize.x/2 : 0
		let offsetY = anchor > TopCenter ? pixelSize.y/2 : 0
		baseMatrix = {scale,0,0,scale,offsetX-(statisticsMargin.x/2)*scale,offsetY-(statisticsMargin.y/2)*scale}
		
	internal js void startFrame
		graphics.reset()
		if(!Platform.fastForward && !Platform.waitingForInitialData)
			if(!graphics.backgroundColor || graphics.backgroundColor.hex == "#000000") {
				graphics.context.clearRect(0, 0, graphics.pixelSize.x, graphics.pixelSize.y)
			} else {
				graphics.context.fillStyle = graphics.backgroundColor.hex
				graphics.context.fillRect(0, 0, graphics.pixelSize.x, graphics.pixelSize.y)
			}
			graphics.context.textBaseline = "top"
			
	internal reset
		totalMatrix = baseMatrix
		localMatrix.clear
		currentlyVisibleFor = null
		items.clear

	internal finishFrame
		if(Platform.fastForward) return
		for input.internalUsers if .
			.videoElementIndex = 0
		drawItems
		drawMargins
		for input.internalUsers -> user if .
			for user.videoElementIndex to user.videoElements.length
				PeerNetwork.removeVideoElement user.videoElements[.]
			user.videoElements.setLength user.videoElementIndex
			PeerNetwork.setAudioMuted user.audioElement, muted:core.muteInvisibleUsers and user.videoElementIndex == 0
		
	private drawItems
		core.displayItems = items.length
		gizmo.tick
		items.sort b.layer - a.layer
		if drawingOrder == ItemsDrawnFirstWillBeInFront
			items.each <- .draw
		else
			items.each -> .draw
		resetTransform
		
	private js void resetTransform
		graphics.context.resetTransform()
		graphics.context.globalAlpha = 1
				
	internal isVisibleFor: Player[] visibleFor
		if(Platform.fastForward) return false
		// Use currentlyVisibleFor when visibleFor is null or [null]
		let effectiveVisibleFor = visibleFor and (visibleFor.length != 1 or visibleFor[0]) ? visibleFor : currentlyVisibleFor
		return effectiveVisibleFor == null or effectiveVisibleFor.any . == null or .id == input.localUser.id
		
	private Player[] getClickableBy: Player[] visibleFor, Player[] clickableBy
		Player[] effectiveVisibleBy = visibleFor or currentlyVisibleFor
		return effectiveVisibleBy and clickableBy
		     ? effectiveVisibleBy intersectWith clickableBy 
		     : effectiveVisibleBy or clickableBy or players
			
	internal js void drawMargins
		if(graphics.effectiveScaleMode == 1) {
			if(graphics.topAndBottomMarginColor) {
				// Top and Bottom Letterbox
				graphics.resetTransform()
				graphics.context.fillStyle = graphics.topAndBottomMarginColor.hex
				let ratio = graphics.pixelSize.x / graphics.referenceSize.x
				let margin = (graphics.pixelSize.y-graphics.referenceSize.y*ratio)/2
				graphics.context.fillRect(0,0,graphics.pixelSize.x, margin)
				graphics.context.fillRect(0,graphics.pixelSize.y-margin,graphics.pixelSize.x, margin)
			}
		} else 
		if(graphics.effectiveScaleMode == 2) {
			if(graphics.leftAndRightMarginColor) {
				// Left and Right Letterbox
				graphics.resetTransform()
				graphics.context.fillStyle = graphics.leftAndRightMarginColor.hex
				let ratio = graphics.pixelSize.y / graphics.referenceSize.y
				let margin = (graphics.pixelSize.x-graphics.referenceSize.x*ratio)/2
				graphics.context.fillRect(0, 0, margin, graphics.pixelSize.y)
				graphics.context.fillRect(graphics.pixelSize.x-margin, 0, margin, graphics.pixelSize.y)
			}
		}
		
	// ------------------------------------------------------- Image -------------------------------------------------------
	
	// Draw an image. Place a PNG file in the "media" folder and it will automatically be imported.
	// 
	// Example: We place an image called "Idle.png" in the "media" folder. Then, we draw this image at the position {0,0}, scale it to a width of 32 pixels. Only the current player instance will see the image.
	// ```
	//     Player
	//         tick
	//             drawImage Idle, position:{0,0}, size:32, frame:0, visibleFor:me
	// ```
	// Image: drawImage0.png
	global js void drawImage: Image image                         // The image to draw. PNG images in the "media" folder will automatically show up here
		                      Vector2 position = {}               // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                      implicit Vector2 size = {}          // A float scales the image to that width keeping the aspect ratio, a vector stretches the image
		                      implicit Player[] visibleFor = null // Only this player or list of players will see the image
		                      implicit frame = 0                  // The frame to draw from a sequence of images (for example "Walk0.png", "Walk1.png", ...)
		                      implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                         // The opacity of the image (0: fully transparent, 1: fully visible)
		                      Color color = White                 // Tint the image with this color
		                      HorizontalAlignment align = Center  // The horizontal alignment of the image
		                      VerticalAlignment valign = Middle   // The vertical alignment of the image
		                      SourceCodeLocation location
		if(!image?.texture?.ensureIsAvailable()) return
		if(graphics.isVisibleFor(visibleFor)) {
			let f = image.frames[frame % image.frames.length]
			let sizeX = size.x || f.w
			let sizeY = size.y || (sizeX/f.w)*f.h
			let factor = graphics.getScaleImagesAsPointerGetsCloserFactor(position)
			if(factor > 1) { sizeX *= factor; sizeY *= factor }
			graphics.items.push(new DisplayImage(
				graphics.totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX,
				valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY,
				sizeX, sizeY,
				layer, alpha * graphics.currentAlpha, graphics.currentClippingPath, image.file,
				location, position.location, size.location,
				image.texture.imageOrCanvas,
				f.x1, f.y1, f.w, f.h,
				color
			))
		}
	
	// Draw an image and rotate it or flip it vertially or horizontally.
	//
	// Example: Draw the image "Idle" at the position {0,0} and rotate it by 45 degrees.
	// ```
	//     Player
	//         tick
	//             drawImage Idle, position:{0,0}, angle:45°
	// ```
	// Image: drawImage1.png
	global js void drawImage: Image image                         // The image to draw. PNG images in the "media" folder will automatically show up here
		                      Vector2 position = {}               // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                      implicit Vector2 size = {}          // A float scales the image to that width keeping the aspect ratio, a vector stretches the image
		                      implicit Player[] visibleFor = null // Only this player or list of players will see the image
		                      implicit frame = 0                  // The frame to draw from a sequence of images (for example "Walk0.png", "Walk1.png", ...)
		                      implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                         // The opacity of the image (0: fully transparent, 1: fully visible)
		                      Color color = White                 // Tint the image with this color
		                      Angle angle = 0.0                   // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                      flipX = false                       // Mirror the image horizontally
		                      flipY = false                       // Mirror the image vertically
		                      SourceCodeLocation location
		if(angle == 0 && !flipX && !flipY) {
			graphics.drawImage(image, position, size, visibleFor, frame, layer, alpha, color, 1, 1, location)
		} else {
			if(!image.texture?.ensureIsAvailable()) return
			if(graphics.isVisibleFor(visibleFor)) {
				let f = image.frames[frame % image.frames.length]
				let sizeX = size.x || f.w
				let sizeY = size.y || (sizeX/f.w)*f.h
				let factor = graphics.getScaleImagesAsPointerGetsCloserFactor(position)
				if(factor > 1) { sizeX *= factor; sizeY *= factor }
				let matrix = graphics.totalMatrix.clone()
				matrix.move(position)
				matrix.rotate(angle)
				if(flipX || flipY) matrix.scale(new Vector2(flipX ? -1:1, flipY ? -1:1	))
				graphics.items.push(new DisplayImage(
					matrix,
					-sizeX/2,
					-sizeY/2,
					sizeX, sizeY,
					layer, alpha * graphics.currentAlpha, graphics.currentClippingPath, image.file, 
					location, position.location, size.location,
					image.texture.imageOrCanvas,
					f.x1, f.y1, f.w, f.h,
					color
				))
			}
		}

	// Animate of sequence of images with a given number of frames per second.
	//
	// Example: We place a sequence of images called "Walk0.png", "Walk1.png", "Walk2.png", etc... in the "media" folder. Then, we play this sequence with 10 frames per second.
	// ```
	//     Player
	//         tick
	//             drawImage Walk, position:{0,0}, framesPerSecond:10
	// ```
	// Image: drawImage2.gif
	global void drawImage: Image image                         // The image to draw. PNG images in the "media" folder will automatically show up here
		                   Vector2 position = {}               // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                   implicit Vector2 size = {}          // A float scales the image to that width keeping the aspect ratio, a vector stretches the image
		                   implicit Player[] visibleFor = null // Only this player or list of players will see the image
		                   framesPerSecond = 0                 // Animate a sequence of images (for example "Walk0.png", "Walk1.png", ...)
		                   implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                   alpha = 1.0                         // The opacity of the image (0: fully transparent, 1: fully visible)
		                   Color color = White                 // Tint the image with this color
		                   SourceCodeLocation location
		var frame = math.floor(core.frame * math.max(framesPerSecond, 0) / core.targetFps) % image.frames.length;
		drawImage image, position, frame, size, visibleFor, layer, alpha, color, location
	
	// Draw an image, animate it and flip it horizontally or vertically.
	//
	// Example: We place a sequence of images called "Walk0.png", "Walk1.png", "Walk2.png", etc... in the "media" folder. Then, we play this sequence with 10 frames per second and flip each frame horizontally.
	// ```
	//     Player
	//         tick
	//             drawImage Walk, position:{0,0}, framesPerSecond:10, flipX:true
	// ```
	// Image: drawImage3.gif
	global void drawImage: Image image                          // The image to draw. PNG images in the "media" folder will automatically show up here
		                   Vector2 position = {}                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                   implicit Vector2 size = {}           // A float scales the image to that width keeping the aspect ratio, a vector stretches the image
		                   implicit Player[] visibleFor = null  // Only this player or list of players will see the image
		                   framesPerSecond = 0                  // Animate a sequence of images (for example "Walk0.png", "Walk1.png", ...)
		                   implicit int layer = 0               // Higher layers are drawn in front of lower layers
		                   alpha = 1.0                          // The opacity of the image (0: fully transparent, 1: fully visible)
		                   Color color = White                  // Tint the image with this color
		                   Angle angle = 0.0                    // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                   flipX = false                        // Mirror the image horizontally
		                   flipY = false                        // Mirror the image vertically
		                   SourceCodeLocation location
		var frame = math.floor(core.frame * math.max(framesPerSecond, 0) / core.targetFps) % image.frames.length;
		drawImage image, position, frame, size, angle, flipX, flipY, visibleFor, layer, alpha, color, location
	
	// Draw an image and execute code when the player touches or clicks the image.
	//
	// Example: If the current player instance clicks the image or 16 pixels around it, we print the exact position that was clicked. If other players will click the image, nothing will happen.
	// ```
	//     Player
	//         tick
	//             drawImage Idle, position:{0,0}, clickableMargin:{16,16}, clickableBy:me
	//                 print "The image was clicked at {touch.position}"
	// ```
	// Image: drawImage0.png
	global void drawImage: Image image                          // The image to draw. PNG images in the "media" folder will automatically show up here
		                   Vector2 position = {}                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                   implicit Vector2 size = {}           // A float scales the image to that width keeping the aspect ratio, a vector stretches the image
		                   implicit Player[] visibleFor = null  // Only this player or list of players will see the image
		                   implicit Player[] clickableBy = null // Only this player or list of players can touch or click the image
		                   implicit frame = 0                   // The frame to draw from a sequence of images (for example "Walk0.png", "Walk1.png", ...)
		                   implicit layer = 0                   // Higher layers are drawn in front of lower layers
		                   alpha = 1.0                          // The opacity of the image (0: fully transparent, 1: fully visible)
		                   Color color = White                  // Tint the image with this color
		                   Angle angle = 0.0                    // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                   flipX = false                        // Mirror the image horizontally
		                   flipY = false                        // Mirror the image vertically
		                   clickableMargin = Vector2(16,16)     // The margin around the image within which it is clickable
		                   showClickableArea = false            // Highlight the clickable area for debugging
		                   hotkey = Key.None                    // This keyboard shortcut will execute the onClick handler
		                   void(Touch touch) onClick            // Execute this code when the user touches or clicks the image or presses the hotkey
		                   SourceCodeLocation location
		drawImage image, position, frame, size, visibleFor, layer, alpha, color, angle, flipX, flipY, location
			
		// Handle click (only visible buttons are clickable)
		let effectiveClickableBy = getClickableBy(visibleFor, clickableBy)
			if size.x == 0 and size.y == 0: size = image.size; else
			if size.y == 0: size.y = size.x * image.size.y / image.size.x
			input.onTouchDown position, size + clickableMargin, by:effectiveClickableBy, showClickableArea, do:onClick
			if hotkey
				input.onKeyDown hotkey, by:effectiveClickableBy
					onClick null
		
	// ------------------------------------------------------- Text -------------------------------------------------------
	
	// Draw text on the screen.
	//
	// Example: If the current player instance is the winner, we show "You've won!" to the current player instance. To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder and it will automatically be imported.
	// ```
	//     Player
	//         tick
	//             if winner == me
	//                 drawText "You've won!", size:100, color:Black, font:OpenSans, visibleFor:me
	// ```
	// Image: drawText.png
	global drawText: implicit string text                 // A string or anything that can be converted into a string (for example, an interger or a float)
		             Vector2 position = {}                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		             implicit Vector2 size = {}           // The font size of the text
		             Color color = null                   // The color of the text
		             HorizontalAlignment align = Center   // The horizontal alignment of the text
		             VerticalAlignment valign = Middle    // The vertical alignment of the text
		             FontStyle style = Normal             // Whether the text should be bold or normal style
		             Font font = null                     // To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder
		             Color outlineColor = null            // The color of the outline around the text
		             outlineWidth = 0                     // The width of the outline around the text in pixels
		             implicit layer = 0                   // Higher layers are drawn in front of lower layers
		             alpha = 1.0                          // The opacity of the text (0: fully transparent, 1: fully visible)
		             Angle angle = 0.0                    // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		             implicit Player[] visibleFor = null  // Only this player or list of players will see the text
		             implicit Player[] clickableBy = null // Only this player or list of players can touch or click the text
		             clickableMargin = Vector2(16,16)     // The margin around the text within which it is clickable
		             showClickableArea = false            // Highlight the clickable area for debugging
		             hotkey = Key.None                    // This keyboard shortcut will execute the onClick handler
		             overflow = TextOverflow.Scale        // Should text that exceeds the max width be hidden or wrapped?
		             float maxWidth = 0                   // The maximum width of line when overflow is set 'Scale', 'Hidden' or 'Wrap'
		             float lineHeight = 0                 // The height of each line when overflow is set to 'Wrap'
		             void(Touch touch) onClick = null     // Execute this code when the user touches or clicks the text or presses the hotkey
		             SourceCodeLocation location
		
		bool isVisible = isVisibleFor(visibleFor)
		Font effectiveFont = font || currentFont
		int fontSize = math.floor(size.y || size.x || currentFontSize)
		float sizeX, sizeY
		string[] lines = null
		float[] lineOffsets = null
		float effectiveLineHeight
		float offsetX, offsetY
		
		if (overflow == Wrap or overflow == WrapAndScale) and maxWidth
			// Split text into words
			string word
			string[] words
			for text.length
				let c = text[.]
				if c == " "
					if word: words.add word
					word = ""
				else
				if c == "\n"
					words.add word + "\n"
					word = ""
				else
					word += c
			if word: words.add word
				
			// Layout lines
			let spaceWidth = getTextWidth(" ", {x:fontSize}, effectiveFont, style)
			lines = []
			float totalWidth
			string line
			for words as word
				float wordWidth = getTextWidth(word, {x:fontSize}, effectiveFont, style)
				if totalWidth + wordWidth > maxWidth
					if line
						// Finish the line and start a new line with the current word
						lines.add line
						line = word + " "
						totalWidth = wordWidth + spaceWidth
					else
						// A single word is already too wide for the line
						// Create a line with this word start a new empty line
						lines.add word
						line = ""
						totalWidth = 0
				else
					line += word + " "
					totalWidth += wordWidth + spaceWidth
					
				if word[word.length-1] == "\n"
					lines.add line
					line = ""
					totalWidth = 0
					
			if line: lines.add line
			
			// Calculate offset for each line and find widest line
			string widestLine
			sizeX = -1
			lineOffsets = []
			float factor = -alignmentFactor[align]
			for lines
				float lineSizeX = getTextWidth(. size:fontSize)
				lineOffsets.add lineSizeX * factor
				if lineSizeX > sizeX
					sizeX = lineSizeX
					widestLine = .
					
			if overflow == WrapAndScale and sizeX > maxWidth
				// Scale
				fontSize = math.floor(fontSize * maxWidth/sizeX)
				sizeX = getTextWidth(widestLine, {x:fontSize}, effectiveFont, style)
				while sizeX > maxWidth
					sizeX = getTextWidth(widestLine, {x:--fontSize}, effectiveFont, style)
					
				for lines
					lineOffsets[i] = getTextWidth(. size:fontSize)*factor
				
			effectiveLineHeight = lineHeight || fontSize*1.3
			sizeY = lines.length * effectiveLineHeight - (effectiveLineHeight - fontSize * effectiveFont.actualHeightFactor)
							
		else
			if isVisible or onClick != null
				sizeX = getTextWidth(text, {x:fontSize}, effectiveFont, style)
				
				if overflow == Scale and maxWidth
					// Scale
					if sizeX > maxWidth
						fontSize = math.floor(fontSize * maxWidth/sizeX)
						sizeX = getTextWidth(text, {x:fontSize}, effectiveFont, style)
						while sizeX > maxWidth
							sizeX = getTextWidth(text, {x:--fontSize}, effectiveFont, style)
			
			effectiveLineHeight = effectiveLineHeight || fontSize*1.5			
			sizeY = fontSize * effectiveFont.actualHeightFactor
			offsetX = -alignmentFactor[ align]*sizeX
		offsetY = -alignmentFactor[valign]*sizeY
			
		if isVisible
			Matrix2D matrix
			float x, y
			if not angle: matrix = totalMatrix; x = position.x; y = position.y
			else          matrix = totalMatrix.clone().move(position).rotate(angle); x = 0; y = 0
			items.add new DisplayText(
				matrix,
				x + offsetX,
				y + offsetY,
				sizeX, sizeY, 
				layer, alpha * graphics.currentAlpha, currentClippingPath, text, 
				location, position.location, size.location,
				(color || currentColor).hex, 
				outlineColor ? outlineColor.hex : null,
				outlineWidth || currentLineWidth,
				effectiveFont.offset.y*sizeY,
				(style ? "bold ":"")+fontSize+"px "+effectiveFont.name,
				lines,
				lineOffsets,
				effectiveLineHeight
			)
		
		if onClick != null
			// Handle click (only visible buttons are clickable)
			let effectiveClickableBy = getClickableBy(visibleFor, clickableBy)
				Vector2 effectiveSize = {sizeX + clickableMargin.x, sizeY + clickableMargin.y}
				input.onTouchDown position, size:effectiveSize, by:effectiveClickableBy, showClickableArea, do:onClick
				if hotkey
					input.onKeyDown hotkey, by:effectiveClickableBy
						onClick null
						
		return sizeY
		
	// Draw text with segments highlighted which are surrounded by given characters.
	//
	// Example:
	// ```
	//     drawTextWithHighlight "Kate se «da vuelta».", position:{0,0}, highlights:[
	//         { "«"  to: "»"  color:White, backgroundColor:app.primaryColor, padding:{12,3}, cornerRadius:12 }
	//         { "\"" to: "\"" color:White, backgroundColor:app.helpingColor, padding:{12,3}, cornerRadius:12 }
	//     ]
	// ```
	global float drawTextWithHighlight: implicit string text                 // A string or anything that can be converted into a string (for example, an interger or a float)
		                                Vector2 position = {}                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                                TextHighlight[] highlights = []      // Sepecifies which characters surround a sections and how it should be highlighted
		                                implicit Vector2 size = {}           // The font size of the text
		                                Color color = null                   // The color of the text
		                                HorizontalAlignment align = Center   // The horizontal alignment of the text
		                                VerticalAlignment valign = Middle    // The vertical alignment of the text
		                                FontStyle style = Normal             // Whether the text should be bold or normal style
		                                Font font = null                     // To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder
		                                Color outlineColor = null            // The color of the outline around the text
		                                outlineWidth = 0                     // The width of the outline around the text in pixels
		                                implicit layer = 0                   // Higher layers are drawn in front of lower layers
		                                alpha = 1.0                          // The opacity of the text (0: fully transparent, 1: fully visible)
		                                Angle angle = 0.0                    // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                                implicit Player[] visibleFor = null  // Only this player or list of players will see the text
		                                implicit Player[] clickableBy = null // Only this player or list of players can touch or click the text
		                                clickableMargin = Vector2(16,16)     // The margin around the text within which it is clickable
		                                showClickableArea = false            // Highlight the clickable area for debugging
		                                hotkey = Key.None                    // This keyboard shortcut will execute the onClick handler
		                                overflow = TextOverflow.Scale        // Should text that exceeds the max width be hidden or wrapped?
		                                float maxWidth = float.maxValue      // The maximum width of line when overflow is set 'Scale', 'Hidden' or 'Wrap'
		                                float lineHeight = 0                 // The height of each line when overflow is set to 'Wrap'
		                                void(Touch touch) onClick = null     // Execute this code when the user touches or clicks the text or presses the hotkey
		                                SourceCodeLocation location
		bool isVisible = isVisibleFor(visibleFor)
		Font effectiveFont = font || currentFont
		int fontSize = math.floor(size.y || size.x || currentFontSize)
		float sizeX, sizeY
		float effectiveLineHeight = lineHeight or fontSize*1.3
		float offsetX, offsetY
	
		// Split text into words
		string word
		string[] words
		for text.length
			let c = text[.]
			if c == " "
				if word: words.add word
				word = ""
			else
			if c == "\n"
				words.add word + "\n"
				word = ""
			else
				word += c
		if word: words.add word
			
		// Layout lines
		let spaceWidth = getTextWidth(" ", {x:fontSize}, effectiveFont, style)
		TextSegment segment = {}
		TextSegment[] segments = [ segment ]
		TextHighlight highlight
		
		for words as word
			string suffix, prefix
			float suffixWidth, prefixWidth
			TextHighlight startHighlight, endHighlight
			int startIndex
			float expectedSegmentWidth = segment.size.x
			
			if not highlight
				// Find highlight start character
				for highlights
					startIndex = word.indexOf .from
					if startIndex != -1
						startHighlight = .
						if startIndex > 0
							prefix = word[..startIndex]
							prefixWidth = getTextWidth(prefix size:fontSize, effectiveFont, style)
							expectedSegmentWidth += prefixWidth
						word = word[startIndex+1..]
						expectedSegmentWidth += .margin.x + .padding.x*2
						break
						
			if highlight or startHighlight
				// Find highlight end character
				for highlights
					int endIndex = word.indexOf .to, startIndex+1
					if endIndex != -1
						endHighlight = .
						if endIndex < word.length-1
							suffix = word[endIndex+1..]
							suffixWidth = getTextWidth(suffix size:fontSize, effectiveFont, style)
							expectedSegmentWidth += suffixWidth
						word = word[..endIndex]
						break
		
			// Measure current word
			float wordWidth = getTextWidth(word, size:fontSize, effectiveFont, style)
			
			// Is there something in the current line?
			if segment.text or segment.position.x > 0
				expectedSegmentWidth += spaceWidth
				if highlight: expectedSegmentWidth += highlight.margin.x
				
				// Check if the current word still fits in the line
				if segment.position.x + expectedSegmentWidth + wordWidth > maxWidth
					if highlight == null or highlight.wrap
						segments.add segment = {position:{0, segment.position.y}, highlight, size:highlight ? highlight.padding*2 : {}}
					segment.position.x = 0
					segment.position.y += effectiveLineHeight
			
			// Space between words
			if segment.text or segment.position.x > 0
				segment.text += " "
				segment.size.x += spaceWidth
		
			// Start highlight
			if startHighlight
				if prefix
					segment.text += prefix
					segment.size.x += prefixWidth
				highlight = startHighlight
				segments.add segment = { position:{segment.position.x + segment.size.x + highlight.margin.x, segment.position.y}, highlight, size:highlight.padding*2 }
				
			// Add word
			segment.text += word
			segment.size.x += wordWidth
				
			// End highlight
			if endHighlight
				segments.add segment = { position:{segment.position.x + segment.size.x + highlight.margin.x, segment.position.y} }
				highlight = null
				if suffix
					segment.text += suffix
					segment.size.x += suffixWidth
					
			if segment.text[segment.text.length-1] == "\n"
				segments.add segment = {position:{0, segment.position.y + effectiveLineHeight}, highlight, size:highlight ? highlight.padding*2 : {}}

		// Align
		float factor = alignmentFactor[align]
		int lineStartIndex
		float lineWidth
		for segments.length + 1 as index
			let s = segments[index]
			if not s or segment.position.x == 0
				for lineStartIndex to index
					segments[.].position.x -= lineWidth * factor
				lineStartIndex = index
			if index < segments.length
				lineWidth += s.size.x
				
		segments.each.size.y = fontSize
		sizeY = segments ? segments.last.position.y + fontSize : 0
		offsetY = -alignmentFactor[valign]*sizeY
			
		if isVisible
			Matrix2D matrix
			float x, y
			if not angle: matrix = totalMatrix; x = position.x; y = position.y
			else          matrix = totalMatrix.clone().move(position).rotate(angle); x = 0; y = 0
			items.add new DisplayTextWithHighlights(
				matrix,
				x + offsetX,
				y + offsetY,
				sizeX, sizeY, 
				layer, alpha * graphics.currentAlpha, currentClippingPath, text, 
				location, position.location, size.location,
				(color || currentColor).hex, 
				outlineColor ? outlineColor.hex : null,
				outlineWidth || currentLineWidth,
				effectiveFont.offset.y*sizeY,
				(style ? "bold ":"")+fontSize+"px "+effectiveFont.name,
				segments
			)
		
		if onClick != null
			// Handle click (only visible buttons are clickable)
			let effectiveClickableBy = getClickableBy(visibleFor, clickableBy)
				Vector2 effectiveSize = {sizeX + clickableMargin.x, sizeY + clickableMargin.y}
				input.onTouchDown position, size:effectiveSize, by:effectiveClickableBy, showClickableArea, do:onClick
				if hotkey
					input.onKeyDown hotkey, by:effectiveClickableBy
						onClick null
						
		return sizeY
			
	// Draw text around a circle.
	// 
	// Example: Draw text around a circular video
	// ```
	//     drawVideo me, position:pos, shape:Circle, size:radius*2-40
	//     drawCircularText "Made up by", position:pos, size:30, radius, angle:-.07
	// ```
	global drawCircularText: implicit string text                 // A string or anything that can be converted into a string (for example, an interger or a float)
		                     Vector2 position = {}                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                     float size = 0                       // The font size of the text
		                     Color color = null                   // The color of the text
		                     Font font = null                     // To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder
		                     implicit layer = 0                   // Higher layers are drawn in front of lower layers
		                     float radius = 100                   // The radius of the circle to draw the text around
		                     Angle angle = 0                      // The angle of the center of the text in turn (0: top, 0.25: right, 0.5: bottom, -0.25: left)
		                     float spacing = .2                   // The spacing between the letters of the text
		                     implicit Player[] visibleFor = null  // Only this player or list of players will see the text
		                     SourceCodeLocation location
		Font effectiveFont = font || currentFont
		int fontSize = math.floor(size || currentFontSize)
		float totalWidth = graphics.getTextWidth text, fontSize, effectiveFont
		Angle startAngle = angle - totalWidth/2*spacing/radius
		float prevWidth
		for text as letter
			float width = graphics.getTextWidth text[..i+1], fontSize, effectiveFont
			float centerOfLetter = (width+prevWidth)/2
			prevWidth = width
			Angle angleOfLetter = startAngle + centerOfLetter*spacing/radius
			drawText text:letter, position+math.getVectorForAngle(angleOfLetter, radius), fontSize, color, effectiveFont, layer, angleOfLetter, visibleFor, location

	// ------------------------------------------------------- Button -------------------------------------------------------
	
	// Draw a button made up of an image and a text and execute code when its touched or clicked.
	//
	// Example: If the current player instance touches or clicks the image or 16 pixels around it, we print the exact position that was touched. If other players will touch the image, nothing will happen.
	// ```
	//     Player
	//         bool done
	//         tick
	//             if not done
	//                 drawButton "I'm done", image:Button, visibleFor:me
	//                     done = true
	// ```
	// Image: drawButton.png
	global void drawButton: Image image = null                   // The image of the button. PNG images in the "media" folder will automatically show up here
		                    text = ""                            // The text of the button
		                    Vector2 position = {}                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                    implicit Vector2 size = {}           // A float scales the image to that width keeping the aspect ratio, a vector stretches the image
		                    frame = -1                           // The frame from a sequence of images (for example "Button0.png", "Button1.png", ...)
		                    Color textColor = null               // The color of the text
		                    textSize = 24                        // The font size in pixels   
		                    textOffset = Vector2(0,0)            // Draw the text at this offset to the image
		                    clickableMargin = Vector2(16,16)     // The margin around the button within which it is clickable
		                    showClickableArea = false            // Highlight the clickable area for debugging
		                    scaleOnHover = 1.0                   // Scale the button by this factor when the mouse hovers over the button
		                    frameOnHover = 1                     // Draw this frame when the mouse hovers over the button
		                    Color textColorOnHover = null        // Draw the text in this color when the mouse hovers over the button
		                    Image accentImage = null             // Draw this image tited with the accent color on top of the button
		                    Color accentColor = null             // Tint the accent image with this color, defaults to the color of the local player
		                    implicit Player[] visibleFor = null  // Only this player or list of players will see the button
		                    implicit Player[] clickableBy = null // Only this player or list of players can touch or click the button
		                    hotkey = Key.None                    // This keyboard shortcut will execute the onClick handler
		                    implicit layer = 0                   // Higher layers are drawn in front of lower layers
		                    alpha = 1.0                          // The opacity of the button (0: fully transparent, 1: fully visible)
		                    enabled = true                       // When not enabled, the button isn't clickable and is drawn transparently (50% by default)
		                    alphaWhenDisabled = .5               // The opacity of the button will be multiplied with this factor when its disabled
		                    void(Touch touch) onClick = null     // Execute this code when the user touches or clicks the button or presses the hotkey
	                        SourceCodeLocation location
		float scale = 1.0
		Vector2 effectiveSize = image ? getEffectiveSize(image.size, size) : {getTextWidth(text, size:textSize), textSize}
		let effectiveClickableBy = getClickableBy(visibleFor, clickableBy)
		if enabled and effectiveClickableBy and onClick != null
			// Handle click (only visible buttons are clickable)
			Vector2 sizeWithMargin = effectiveSize + clickableMargin
			bool switchFrameOnHover = frameOnHover != -1 and frame == -1 and (image?.frames.length > frameOnHover or accentImage?.frames.length > frameOnHover)
			if switchFrameOnHover or scaleOnHover != 1.0 or textColorOnHover
				input.onTouchOver position, sizeWithMargin, by:effectiveClickableBy
					if textColorOnHover:    textColor = textColorOnHover
					if switchFrameOnHover:  frame = frameOnHover
					if scaleOnHover != 1.0: scale = scaleOnHover
			input.onTouchDown position, sizeWithMargin, by:effectiveClickableBy, showClickableArea, do:onClick
			if hotkey
				input.onKeyDown hotkey, by:effectiveClickableBy
					onClick null
					
		if isVisibleFor(visibleFor)
			if frame == -1: frame = 0
			if scale != 1.0: textSize = math.round(textSize * scale); effectiveSize *= scale
			let effectiveAlpha = enabled ? alpha : alpha * alphaWhenDisabled
			if text:  drawText text, position+textOffset, textSize, textColor, visibleFor, layer, effectiveAlpha, location
			if accentImage
				if not accentColor
					if effectiveClickableBy and effectiveClickableBy[0]: accentColor = effectiveClickableBy[0].color
					else                                                 accentColor = input.localPlayer.color
				drawImage accentImage, position, frame, effectiveSize, visibleFor, layer, effectiveAlpha, location, color:accentColor
			if image: drawImage image, position, frame, effectiveSize, visibleFor, layer, effectiveAlpha, location
			
			
	// ------------------------------------------------------- Rectangle -------------------------------------------------------
	
	// Draw a rectangle on the screen.
	//
	// Example: Draw a white rectangle with a black outline that is 8 pixels wide.
	// ```
	//     app
	//         tick
	//             drawRectangle size:{500,100}, color:White, outlineColor:Black, outlineWidth:8
	// ```
	// Image: drawRectangle.png
	global js void drawRectangle: position = Vector2()                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                          implicit size = Vector2(256,256)    // The size of the rectangle, use a float to draw a square, use a vector to draw a rectangle
		                          Color color = null                  // The color of the area within the rectangle
		                          Color outlineColor = null           // The color of the outline around the rectangle
		                          outlineWidth = 0                    // The width of the outline around the rectangle in pixels
		                          implicit Player[] visibleFor = null // Only this player or list of players will see the rectangle
		                          implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                          alpha = 1.0                         // The opacity of the rectangle (0: fully transparent, 1: fully visible)
		                          HorizontalAlignment align = Center  // The horizontal alignment of the rectangle
		                          VerticalAlignment valign = Middle   // The vertical alignment of the rectangle
		                          SourceCodeLocation location
		if(graphics.isVisibleFor(visibleFor)) {
			let sizeX = size.x
			let sizeY = size.y || size.x
			graphics.items.push(new DisplayRectangle(
				graphics.totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX,
				valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY,
				sizeX, sizeY,
				layer, alpha * graphics.currentAlpha, graphics.currentClippingPath, "Rectangle", 
				location, position.location, size.location,
				color || !outlineColor ? (color || graphics.currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics.currentLineWidth
			))
		}
		
	// Draw a rectangle with rounded corners on the screen.
	//
	// Example: Draw a rounded rectangle at {500,100} with a black outline that is 8 pixels wide and has a corner radius of 20 pixels.
	// ```
	//     app
	//         tick
	//             drawRoundedRectangle size:{500,100}, outlineColor:Black, outlineWidth:8, radius:20
	// ```
	// Image: drawRoundedRectangle.png
	global js void drawRoundedRectangle: position = Vector2()                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                                 implicit size = Vector2(256,256)    // The size of the rectangle, use a float to draw a square, use a vector to draw a rectangle
		                                 radius = 32                         // The radius of the rounded corners
		                                 Color color = null                  // The color of the area within the rectangle
		                                 Color outlineColor = null           // The color of the outline around the rectangle
		                                 outlineWidth = 0                    // The width of the outline around the rectangle in pixels
		                                 implicit Player[] visibleFor = null // Only this player or list of players will see the rectangle
		                                 implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                                 alpha = 1.0                         // The opacity of the rectangle (0: fully transparent, 1: fully visible)
		                                 HorizontalAlignment align = Center  // The horizontal alignment of the rectangle
		                                 VerticalAlignment valign = Middle   // The vertical alignment of the rectangle
		if(graphics.isVisibleFor(visibleFor)) {
			let sizeX = size.x
			let sizeY = size.y || size.x
			graphics.items.push(new DisplayRoundedRectangle(
				graphics.totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX,
				valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY,
				sizeX, sizeY,
				layer, alpha * graphics.currentAlpha, graphics.currentClippingPath, "RoundedRectangle", 
				location, position.location, size.location,
				radius,
				color || !outlineColor ? (color || graphics.currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics.currentLineWidth
			))
		}
		
	// ------------------------------------------------------- Circle -------------------------------------------------------
	
	// Draw a circle on the screen.
	//
	// Example: Draw a white circle with a blue outline and a diameter of 150 pixels.
	// ```
	//     app
	//         tick
	//             drawCircle color:White, outlineColor:#118ab2, outlineWidth:12, size:150
	// ```
	// Image: drawCircle0.png
	// 
	// Example: Draw a white circle with a blue outline and a width of 200 pixels and a height of 100 pixels.
	// ```
	//     app
	//         tick
	//             drawCircle color:White, outlineColor:#118ab2, outlineWidth:12, size:{200, 100}
	// ```
	// Image: drawCircle1.png
	//
	// Example: Draw an arc of 180 degrees (half a circle) starting at an angle of 0 degrees.
	// ```
	//     app
	//         tick
	//             drawCircle outlineColor:#118ab2, outlineWidth:24, size:100, startAngle:0°, angle:180°
	// ```
	// Image: drawCircle2.png
	global js void drawCircle: position = Vector2()                    // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                       implicit Vector2 size = {256,256}       // The size of the circle, use a float to draw a circle, use a vector draw an ellipse
		                       Color color = null                      // The color of the area within the circle
		                       Color outlineColor = null               // The color of the outline around the circle
		                       outlineWidth = 0                        // The width of the outline around the circle in pixels
		                       Angle startAngle = 0                    // Draw an arc with this start angle in turns, measured from the positive x-axis
		                       Angle angle = 1.0                       // Draw an arc with this angle in turns (0.25: quarter circle, 0.5: half circle, 1: full circle)
		                       RotationDirection direction = Clockwise // The circle is drawn in this direction
		                       implicit Player[] visibleFor = null     // Only this player or list of players will see the circle
		                       implicit layer = 0                      // Higher layers are drawn in front of lower layers
		                       alpha = 1.0                             // The opacity of the circle (0: fully transparent, 1: fully visible)
		                       SourceCodeLocation location
		if(graphics.isVisibleFor(visibleFor)) {
			let sizeX = size.x, sizeY = size.y || size.x
			graphics.items.push(new DisplayCircle(
				graphics.totalMatrix, 
				position.x - sizeX/2, 
				position.y - sizeY/2, 
				sizeX, sizeY,
				layer, alpha * graphics.currentAlpha, graphics.currentClippingPath, "Circle", 
				location, position.location, size.location,
				startAngle, angle,
				direction == 1,
				color || !outlineColor ? (color || graphics.currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics.currentLineWidth
			))
		}
		
	// ------------------------------------------------------- Line -------------------------------------------------------
	
	// Draw a line on the screen.
	//
	// Example: Draw a blue line from {-100,0} to {100,0}
	// ```
	//     app
	//         tick
	//             drawLine {-100,0} to {100,0} color:Blue
	// ```
	// Image: drawLine.png
	global js void drawLine: Vector2 from                        // The point to start the line from
		                     nocolon Vector2 to                  // The point to draw the line to
		                     Color color = null                  // The color of the line
		                     width = 0                           // The width of the line in pixels
		                     implicit Player[] visibleFor = null // Only this player or list of players will see the line
		                     implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                     alpha = 1.0                         // The opacity of the line (0: fully transparent, 1: fully visible)
		if(graphics.isVisibleFor(visibleFor)) {
			graphics.items.push(new DisplayLine(
				graphics.totalMatrix,
				from.x, from.y,
				to.x - from.x, to.y - from.y,
				layer, alpha * graphics.currentAlpha, graphics.currentClippingPath, "Line", 
				location, from.location, null,
				to,
				(color || graphics.currentColor).hex,
				width || graphics.currentLineWidth
			))
		}
		
	// Draw a continuous stroke of lines on the screen.
	//
	// Example: Draw a blue stroke of lines through {-50,0}, {0,50} and {100,-50} with a width of 32 pixels
	// ```
	//     app
	//         tick
	//             drawLines [{-50,0}, {0,50}, {100,-50}] color:Blue width:32
	// ```
	// Image: drawLines.png
	global js void drawLines: Vector2[] points                    // A list of points for the line
		                      Vector2 position = {}               // The position all points are relative to 
		                      Color color = null                  // The color of the line
		                      width = 0                           // The width of the line in pixels
		                      smooth = false                      // Smooth the corners of the line
		                      implicit Player[] visibleFor = null // Only this player or list of players will see the line
		                      implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                         // The opacity of the lines (0: fully transparent, 1: fully visible)
		if(graphics.isVisibleFor(visibleFor)) {
			graphics.items.push(new DisplayPolygon(
				graphics.totalMatrix,
				position.x, position.y,
				0, 0,
				layer, alpha * graphics.currentAlpha, graphics.currentClippingPath, "Line", 
				location, position.location, null,
				points,
				null, // no fill color, because we want to draw a line instead of a polygon
				(color || graphics.currentColor).hex,
				width || graphics.currentLineWidth,
				smooth, /*close*/false
			))
		}
		
	// ------------------------------------------------------- Polygon -------------------------------------------------------
	
	// Draw a polygon on the screen.
	//
	// Example: Draw a white polygon with the corners {-50,50}, {0,-50} and {50,50} and a blue outline
	// ```
	//     app
	//         tick
	//             drawPolygon [{-50,50}, {0,-50}, {50,50}] color:White outlineColor:Blue
	// ```
	// Image: drawPolygon.png
	global js void drawPolygon: Vector2[] points                    // A list of points for the polygon
		                        Vector2 position = {0,0}            // The position all polygon points are relative to
		                        Color color = null                  // The color of the area within the polygon
		                        Color outlineColor = null           // The color of the outline around the polygon
		                        outlineWidth = 0                    // The width of the outline around the polygon in pixels
		                        smooth = false                      // Smooth the corners of the polygon
		                        implicit Player[] visibleFor = null // Only this player or list of players will see the polygon
		                        implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                        alpha = 1.0                         // The opacity of the polygon (0: fully transparent, 1: fully visible)
		if(graphics.isVisibleFor(visibleFor)) {
			graphics.items.push(new DisplayPolygon(
				graphics.totalMatrix,
				position.x, position.y,
				0, 0,
				layer, alpha * graphics.currentAlpha, graphics.currentClippingPath, "Polygon", 
				location, position.location, null,
				points,
				color || !outlineColor ? (color || graphics.currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics.currentLineWidth,
				smooth, /*close*/true
			))
		}
		
	// ------------------------------------------------------- Video -------------------------------------------------------
	
	// Draw the video feed showing the given player on the screen.
	//
	// Example: Draw the video feed for the current player instance with a width of 200 pixels
	// ```
	//     Player
	//         tick
	//             drawVideo me, size:200
	// ```
	// Image: drawVideo.png
	global drawVideo: Player player                       // Draw the video showing this player
		              Vector2 position = {}               // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		              implicit Vector2 size = {440}       // A float scales the image to that width keeping the aspect ratio, a vector stretches the video
		              VideoShape shape = Rectangle        // Choose whether the video should be drawn as a rectangle, a square or a circle
		              implicit Player[] visibleFor = null // Only this player or list of players will see the video
		              SourceCodeLocation location
		if isVisibleFor(visibleFor)
			if not size.y: size.y = shape == Rectangle ? size.x * 3/4 : size.x
			if core.mode == Local or !PeerNetwork.enableVideo
				drawImage VideoScreen, position, size, frame:shape == Circle ? 1:0, layer:1000000, location
			else
				items.add DisplayVideo(
					m: totalMatrix,
					x: position.x, y: position.y,
					w: size.x,     h: size.y,
					1000000, alpha:1.0, currentClippingPath, "Video",
					player.id, shape
				)
				
	// ------------------------------------------------------- Pointer -------------------------------------------------------
	
	// Draw a pointer at the mouse position of the given player on the screen.
	//
	// Example: Draw a pointer at the mouce position of the current player instance
	// ```
	//     Player
	//         tick
	//             drawPointer me
	// ```
	// Image: drawPointer.png
	global drawPointer: Player player                  // Show the mouse position of this player
		                ShowPointersMode mode = Remote // Choose whether you want to draw the pointers for local players, remote players or both
		                Color color = null             // The color of the pointer. If this is left out, the player color is used
		if mode == LocalAndRemote
		or (player.id == input.localUser.id and mode == Local)
		or (player.id != input.localUser.id and mode == Remote)
			if !color: color = player.color
			for player.touches
				drawImage finger, .smoothPosition+{11,32}, frame:.isDown ? 1 : 0, layer:int.maxValue
				if color
					if color == Black
						drawRectangle .smoothPosition+{16,80}, size:{26,10}, color, layer:int.maxValue, outlineColor:{"#a0a0a0"}, outlineWidth:2
					else
						drawRectangle .smoothPosition+{16,78}, size:{26,10}, color, layer:int.maxValue

	// ------------------------------------------------------- Texture -------------------------------------------------------
	
	// Draw a texture which you can dynamically load from anywhere
	//
	// Example: Dynamically load the file "Character.png" from the assets folder and draw it on the screen with a width of 100 pixels.
	// ```
	//     app
	//         Texture character = {"Character.png"}
	//         tick
	//             drawTexture character, size:100
	// ```
	// Image: drawTexture0.png
	global js void drawTexture: Texture texture                     // The texture to draw
		                        Vector2 position = {}               // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                        implicit Vector2 size = {}          // A float scales the image to that width keeping the aspect ratio, a vector stretches the image
		                        implicit Player[] visibleFor = null // Only this player or list of players will see the texture
		                        implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                        alpha = 1.0                         // The opacity of the texture (0: fully transparent, 1: fully visible)
		                        Color color = White                 // Tint the texture with this color
		if(!texture?.ensureIsAvailable()) return
		if(graphics.isVisibleFor(visibleFor)) {
			let sizeX = size.x || texture.size.x
			let sizeY = size.y || (sizeX/texture.size.x)*texture.size.y
			graphics.items.push(new DisplayImage(
				graphics.totalMatrix,
				position.x - sizeX/2,
				position.y - sizeY/2,
				sizeX, sizeY,
				layer, alpha * graphics.currentAlpha, graphics.currentClippingPath, texture.file,
				location, position.location, size.location,
				texture.imageOrCanvas,
				0, 0, texture.size.x, texture.size.y,
				color
			))
		}

	// Draw part of a texture which you can dynamically load from anywhere.
	// 
	// Example: Dynamically load the file "Character.png" from the assets folder, take a part of this texture with a size of {16,32} centered around {8,0} and draw it on the screen with a size of {100,200}. 
	// ```
	//     app
	//         Texture character = {"Character.png"}
	//         tick
	//             drawTexture character, sourcePosition:{8,0}, sourceSize:{16,32}, size:{100,200}
	// ```
	// Image: drawTexture1.png
	global js void drawTexture: Texture texture                     // The texture to draw
		                        Vector2 position = {}               // The target position to draw to
		                        Vector2 size = {}                   // The size of the target area to draw to
		                        Vector2 sourcePosition = {}         // The center of the area of the source texture to draw from
		                        Vector2 sourceSize = {}             // The size of the area of the source texture to draw from
		                        implicit Player[] visibleFor = null // Only this player or list of players will see the texture
		                        implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                        alpha = 1.0                         // The opacity of the texture (0: fully transparent, 1: fully visible)
		                        Color color = White                 // Tint the texture with this color
		if(!texture?.ensureIsAvailable()) return
		if(graphics.isVisibleFor(visibleFor)) {
			let sizeX = size.x || texture.size.x
			let sizeY = size.y || (sizeX/texture.size.x)*texture.size.y
			graphics.items.push(new DisplayImage(
				graphics.totalMatrix,
				position.x - sizeX/2,
				position.y - sizeY/2,
				sizeX, sizeY,
				layer, alpha * graphics.currentAlpha, graphics.currentClippingPath, texture.file, 
				location, position.location, size.location,
				texture.imageOrCanvas,
				sourcePosition.x+texture.size.x/2-sourceSize.x/2,
				sourcePosition.y+texture.size.y/2-sourceSize.y/2,
				sourceSize.x, 
				sourceSize.y,
				color
			))
		}
		
	// ------------------------------------------------------- Clear -------------------------------------------------------
	
	// Clear all pixels within a rectangle.
	//
	// Example: Clear all pixels within a rectangle with a width of 100 pixels and a height of 100 pixels
	// ```
	//     app
	//         tick
	//             clearRectangle position:{0,0} size:{100,100}
	// ```
	// Image: clearRectangle.png
	global js void clearRectangle: position = Vector2()                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                           implicit size = Vector2(256,256)    // The size of the rectangle, use a float to clear a square, use a vector to clear a rectangle
		                           implicit Player[] visibleFor = null // Only clear the rectangle for this player or list of players
		                           implicit layer = 0                  // Higher layers are drawn in front of lower layers
                                   HorizontalAlignment align = Center  // The horizontal alignment of the rectangle
                                   VerticalAlignment valign = Middle   // The vertical alignment of the rectangle
		if(graphics.isVisibleFor(visibleFor)) {
			let sizeX = size.x
			let sizeY = size.y || size.x
			graphics.items.push(new DisplayRectangle(
				graphics.totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX,
				valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY,
				sizeX, sizeY,
				layer, 1, graphics.currentClippingPath, "Clear", 
				location, position.location, size.location,
				"clear", null, 0
			))
		}
		
	// ------------------------------------------------------- Transform -------------------------------------------------------

	// Move all drawing operations in a block of code by a given vector.
	//
	// Example: Move an image and a text 500 pixels to the right
	// ```
	//     app
	//         tick
	//             graphics.move {500,0}
	//                 drawText "OK"
	//                 drawImage Button
	// ```
	// Image: graphicsMove.png
	move: Vector2 distance // The distance to move
		  void() code      // All drawing operations within this block will be moved
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.move distance
		totalMatrix.move distance
		code
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
							
	// Rotate all drawing operations in a block of code by a given angle
	//			
	// Example: Rotate an image and a text by 20 degrees.
	// ```
	//     app
	//         tick
	//             graphics.rotate 20°
	//                 drawText "OK"
	//                 drawImage Button
	// ```
	// Image: graphicsRotate.png
	rotate: Angle angle  // The angle in turns (0: no rotation, 1: one full rotation)
		    void() code  // All drawing operations within this block of code will be rotated
		if angle == 0: code; return
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.rotate angle
		totalMatrix.rotate angle
		code
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
	
	// Scale all drawing operations in a block of code by a given factor.
	//
	// Example: Scale an image and a text by to twice their original size.
	// ```
	//     app
	//         tick
	//             graphics.scale 2
	//                 drawText "OK"
	//                 drawImage Button
	// ```
	// Image: graphicsScale.png
	scale: float factor // The factor to scale by
		   void() code  // All drawing operations within this block of code will be scaled
		if factor == 1: code; return
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.scale {factor, factor}
		totalMatrix.scale {factor, factor}
		code
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
	
	// Move, rotate and scale all drawing operations in a block of code.
	//
	// Example: Move an image an a text 500 pixels to the right, rotate them by 90 degrees and scale them to half their original size.
	// ```
	//     app
	//         tick
	//             graphics.transform move:{500,0} rotate:90° scale:.5
	//                 drawText "OK"
	//                 drawImage Button
	// ```
	// Image: graphicsTransform.png
	transform: Vector2 move = Vector2.none  // The distance to move
		       Angle rotate = 0             // The angle in turns (0: no rotation, 1: one full rotation)
		       float scale = 1              // The factor to scale by
		       void() code                  // All drawing operations within this block of code will be moved, rotated and scaled
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		if move
			localMatrix.move move
			totalMatrix.move move
		if scale != 1
			localMatrix.scale {scale, scale}
			totalMatrix.scale {scale, scale}
		if rotate
			localMatrix.rotate rotate
			totalMatrix.rotate rotate
		code
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
	
	// Apply a matrix to all drawing operations in a block of code.
	//
	// Example: Apply the matrix {1 .3 .7 1 0 0} to a text and an image
	// ```
	//     app
	//         tick
	//             graphics.applyMatrix {1 .3 .7 1 0 0}
	//                 drawText "OK"
	//                 drawImage Button
	// ```
	// Image: graphicsApplyMatrix.png
	applyMatrix: Matrix2D matrix // The matrix to apply
		         void() code     // The matrix will be applied to all drawing operation within this block of code
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		this.localMatrix.multiplyLeft matrix
		this.totalMatrix.multiplyLeft matrix
		code
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5
	
	// ------------------------------------------------------- Clip -------------------------------------------------------
	
	// For all drawing operations in a block of code, only pixels inside a given polygon are drawn.
	//
	// Example: Draw three circles and clip all of them within the polygon with the corners {0,-80}, {-100,80}, {100,80}
	// ```
	//     app
	//         tick
	//             graphics.clip points:[{0,-80}, {-100,80}, {100,80}]
	//                 drawCircle {   0, -80}, size:150, color:Blue
	//                 drawCircle {-100,  80}, size:150, color:Blue
	//                 drawCircle { 100,  80}, size:150, color:Blue
	// ```
	// Image: graphicsClip0.png
	//
	// Example: Draw three circles and clip two of them within the polygon with the corners {0,-80}, {-100,80}, {100,80}
	// ```
	//     app
	//         tick
	//             graphics.clip points:[{0,-80}, {-100,80}, {100,80}]
	//                 drawCircle {   0, -80}, size:150, color:Blue
	//                 drawCircle {-100,  80}, size:150, color:Blue
	//             drawCircle { 100,  80}, size:150, color:Blue
	// ```
	// Image: graphicsClip1.png
	clip: Vector2[] points      // A list of points that define the clipping area
		  Vector2 position = {} // The position all points are relative to 
		  bool show = false     // Show the clipping area for debugging
		  void() code           // All drawing operations within this block of code will be clipped
		let prev = currentClippingPath
		currentClippingPath = ClippingPath(show)
		for points: currentClippingPath.points.add position + .
		code()
		currentClippingPath = prev
		
	private ClippingPath currentClippingPath
		
	// ------------------------------------------------------- Visibility -------------------------------------------------------
	
	// All drawing operations in a block of code will only be visible to certain players.
	//
	// Example: Draw a button that is only visible to the current player instance
	// ```
	//     Player
	//         tick
	//             visibleFor me
	//                 drawText "OK"
	//                 drawImage Button
	// ```
	// Image: graphicsVisibleFor.png
	visibleFor: implicit Player[] player // Only this player or list of players will see the drawing operations
		        void() code              // All drawing operations in this block of code will only be visible to the given players
		let prev = currentlyVisibleFor
		currentlyVisibleFor = player
		code()
		currentlyVisibleFor = prev
		return currentlyVisibleFor
		
	private Player[] currentlyVisibleFor = null
		
	// ------------------------------------------------------- Color -------------------------------------------------------
	
	// The default background color for all drawing operations
	const Color backgroundColor = Black
	
	// Teh default player colors
	const Color[] defaultColors = [{"#398CA9", "Blue"}, {"#C01352", "Red"}, {"#16C66E", "Green"}, {"#FFD166", "Yellow"}]
	const Color[] darkDefaultColors = [{"#193742", "Dark Blue"}, {"#470B21", "Dark Red"}, {"#0A3620", "Dark Green"}, {"#4B3F21", "Dark Yellow"}]

	// The default color for all drawing operations
	color
		return currentColor
	color: Color color
		currentColor = color
		return currentColor
	color: Color color
		   void() code
		let prev = currentColor
		currentColor = color
		code()
		currentColor = prev
		return currentColor
	private Color currentColor = {"#ffffff"}
	
	// ------------------------------------------------------- Font -------------------------------------------------------
	
	// The default font for all drawing operations
	font
		return currentFont
	font: Font font
		currentFont = font
		return currentFont
	font: Font font
		  void() code
		let prev = currentFont
		currentFont = font
		code()
		currentFont = prev
		return currentFont
	private Font currentFont = OpenSans
	
	// The default font size for all drawing operations
	fontSize
		return currentFontSize
	fontSize: int fontSize
		currentFontSize = fontSize
		return currentFontSize
	fontSize: int fontSize
		      void() code
		let prev = currentFontSize
		currentFontSize = fontSize
		code()
		currentFontSize = prev
		return currentFontSize
	private currentFontSize = 64
	
	// ------------------------------------------------------- Line Width -------------------------------------------------------
	
	// The default line width for all drawing operations
	lineWidth
		return currentLineWidth
	lineWidth: int lineWidth
		currentLineWidth = lineWidth
		return currentLineWidth
	lineWidth: int lineWidth
		      void() code
		let prev = currentLineWidth
		currentLineWidth = lineWidth
		code()
		currentLineWidth = prev
		return currentLineWidth
	private currentLineWidth = 8
	
	// ------------------------------------------------------- Alpha -------------------------------------------------------
	
	// The default line width for all drawing operations
	alpha
		return currentAlpha
	alpha: float alpha
		currentAlpha = alpha
		return currentAlpha
	alpha: float alpha
		   void() code
		let prev = currentAlpha
		currentAlpha = alpha
		code()
		currentAlpha = prev
		return currentAlpha
	private float currentAlpha = 1.0
	
	// ------------------------------------------------------- Measure text -------------------------------------------------------
	
	// Measures the width of a string in pixels
	global js int getTextWidth: string text                 // The text to get the width of
		                        implicit Vector2 size = {}  // The font size of the text
		                        Font font = null            // The font of the text
		                        FontStyle style = Normal    // Whether the text should be bold or normal style
		if(!text) return 0
		let effectiveFont = font || graphics.currentFont
		let fontSize = size.y || size.x || graphics.currentFontSize
		graphics.context.font =  (style ? "bold ":"")+fontSize+"px "+effectiveFont.name;
		let textSize = graphics.context.measureText(text)
		return textSize.width
		
	// ------------------------------------------------------- Position -------------------------------------------------------
	
	getAbsolutPosition: Vector2 position
		return position.transformed(localMatrix)
		
	getRelativePosition: Vector2 position
		return position.getRelativeTo(localMatrix)
		
	getPixelPosition: Vector2 position
		return position.transformed(totalMatrix) / pixelRatio
		
	getPixelSize: Vector2 size
		return size * {totalMatrix.m0, totalMatrix.m3} / pixelRatio
		
	private Vector2 getEffectiveSize: Vector2 imageSize, Vector2 size
		let sizeX = size.x || imageSize.x
		let sizeY = size.y || (sizeX/imageSize.x)*imageSize.y
		return {sizeX, sizeY}
		
	
	// -------------------------------------------- Scale Image as Pointer Get Closer  -------------------------------------------------------
	
	private Player scaleAsPointerGetsCloserBy = null
	private float scaleAsPointerGetsCloserFactor = 1
	private float scaleAsPointerGetsCloserRadius = 0
	
	scaleImagesAsPointerGetsCloser: Player by = null
		                            factor = 2.0
		                            radius = 200.0
		                            void() do
		let prevBy = scaleAsPointerGetsCloserBy
		let prevFactor = scaleAsPointerGetsCloserFactor
		let prevRadius = scaleAsPointerGetsCloserRadius
		scaleAsPointerGetsCloserBy = by
		scaleAsPointerGetsCloserFactor = factor
		scaleAsPointerGetsCloserRadius = radius
		do
		scaleAsPointerGetsCloserBy = prevBy
		scaleAsPointerGetsCloserFactor = prevFactor
		scaleAsPointerGetsCloserRadius = prevRadius
		
	private getScaleImagesAsPointerGetsCloserFactor: Vector2 position
		if not scaleAsPointerGetsCloserRadius: return 1.0
		let distance = scaleAsPointerGetsCloserBy ? scaleAsPointerGetsCloserBy.pointerPosition.distanceTo(position) : players.min.pointerPosition.distanceTo(position)
		// return math.map distance, 0, scaleAsPointerGetsCloserRadius, scaleAsPointerGetsCloserFactor, 1
		return scaleAsPointerGetsCloserFactor interpolateTo 1 progress:distance 0..scaleAsPointerGetsCloserRadius
		
	// --------------------------------------------- Create and Manipulate Images ---------------------------------------------
	
	// Create an image to draw to
	js void createImage: Vector2 size     // The size of the image
		                 string file = "" // Save the image to a file with this filename
		                 void() code      // This block of code will draw on the created image instead of drawing on the screen
		let prevContext = graphics.context
		let prevPixelSizeX = graphics.pixelSize.x
		let prevPixelSizeY = graphics.pixelSize.y
		let prevItems = graphics.items
		graphics.items = []
		let canvas = document.createElement("canvas")
		canvas.width = size.x
		canvas.height = size.y
		graphics.context = canvas.getContext("2d")
		graphics.pixelSize.x = size.x
		graphics.pixelSize.y = size.y
		let a = graphics.localMatrix.matrix, b = graphics.totalMatrix.matrix
		let a0 = graphics.localMatrix.m0, a1 = graphics.localMatrix.m1, a2 = graphics.localMatrix.m2, a3 = graphics.localMatrix.m3, a4 = graphics.localMatrix.m4, a5 = graphics.localMatrix.m5
		let b0 = graphics.totalMatrix.m0, b1 = graphics.totalMatrix.m1, b2 = graphics.totalMatrix.m2, b3 = graphics.totalMatrix.m3, b4 = graphics.totalMatrix.m4, b5 = graphics.totalMatrix.m5
		graphics.localMatrix.set(1, 0, 0, 1, -size.x/2, -size.y/2)
		graphics.totalMatrix.set(1, 0, 0, 1, size.x/2, size.y/2)
		code()
		graphics.drawItems()
		var dataUrl = canvas.toDataURL("image/png");
		if(file) file.saveImage(dataUrl, file);
		graphics.localMatrix.m0 = a0; graphics.localMatrix.m1 = a1; graphics.localMatrix.m2 = a2; graphics.localMatrix.m3 = a3; graphics.localMatrix.m4 = a4; graphics.localMatrix.m5 = a5
		graphics.totalMatrix.m0 = b0; graphics.totalMatrix.m1 = b1; graphics.totalMatrix.m2 = b2; graphics.totalMatrix.m3 = b3; graphics.totalMatrix.m4 = b4; graphics.totalMatrix.m5 = b5
		graphics.context = prevContext
		graphics.pixelSize.x = prevPixelSizeX
		graphics.pixelSize.y = prevPixelSizeY
		graphics.items = prevItems
		return dataUrl
		
	js void copyScreenshotToClipboard
		graphics.canvas.toBlob((blob) => {
			const item = new ClipboardItem({ 'image/png': blob });
			navigator.clipboard.write([item]);
			log("Copied screenshot to clipboard");
		});
	
	// Directly manipulate the pixels on the screen or an image
	js int[] accessPixel: void(int[] pixels) code // This code can manipulate the pixels
		let imageData = graphics.context.getImageData(0,0,graphics.pixelSize.x, graphics.pixelSize.y)
		code(imageData.data)
		graphics.context.putImageData(imageData, 0, 0)
		
	// --------------------------------------------- Timer ---------------------------------------------
	
	drawTimer: Time startTime, Time duration, Sound completionSound = null, Time timeBeforeCompletionToPlaySound = 4000, void() onComplete = null
		const width = 8
		const margin1 = 8
		const margin2 = margin1 - width/2
		let completion = (Time.now - startTime) / duration
		let time = (1 - completion) * 6000
		
		drawLine {   0        , -540+margin1} to {math.map(time, 0..960, 0, -960+margin2), -540+margin1}, width
		drawLine {-960+margin1, -540+margin2} to {-960+margin1, math.map(time, 960..960+1080, -540+margin2, 540-margin2)}, width
		drawLine {-960+margin2,  540-margin1} to {math.map(time, 960+1080..960+1080+1920, -960+margin2, 960-margin2), 540-margin1}, width
		drawLine { 960-margin1,  540-margin2} to { 960-margin1, math.map(time, 960+1080+1920..960+1080+1920+1080, 540-margin2, -540+margin2)}, width
		drawLine { 960-margin2, -540+margin1} to {math.map(time, 960+1080+1920+1080..960+1080+1920+1080+960, 960-margin2, 0), -540+margin1}, width
		
		if completionSound and Time.now > startTime + duration - timeBeforeCompletionToPlaySound and not completionSound.isPlaying: playSound completionSound
		if onComplete != null and completion >= 1: onComplete

// --------------------------------------------- Gizmo ---------------------------------------------
	
internal immutable struct GizomInfluence
	string file
	int start
	int end
	float[] deltas
	float[] initialValues
	string label

internal immutable struct GizmoOverItem
	DisplayItem item
	SourceCodeLocation location
	
internal skipInit transient unit gizmo
	private DisplayItem[] items
	private Vector2 min, max
	private SourceCodeLocation cursorLocation
	private DisplayItem cursorItem
	private float handleSize
	
	private inline js bool isCursorSet() window._cursorFile
	private inline js string cursorFile() _cursorFile
	private inline js int cursorPos() _cursorPos
	private inline js int codeId() _codeId
	
	private findInfluencedItems
		items.clear
		cursorLocation = null
		if !isCursorSet: return
		
		// Find the item and location at the cursor position
		for graphics.items
			if .positionLocation and (cursorLocation = .positionLocation.find(cursorFile, cursorPos))
				cursorItem = .
				break
			if .location and .location.file == cursorFile and cursorPos >= .location.start and cursorPos <= .location.end
				cursorLocation = .positionLocation?.leaf or .location
				cursorItem = .
				break
			
		// Find all items that are influenced by this location
		// and calculate the min and max of the influenced items
		min.x = float.maxValue; max.x = float.minValue
		min.y = float.maxValue; max.y = float.minValue
		if cursorLocation != null
			for graphics.items
				if .location == cursorLocation or .positionLocation?.find(cursorLocation) != null
					items.add .
					if .x < min.x: min.x = .x
					if .y < min.y: min.y = .y
					if .x + .w > max.x: max.x = .x + .w
					if .y + .h > max.y: max.y = .y + .h
		// handleSize = math.map math.min(max.x-min.x, max.y-min.y) 64..256 start:16 target:32
		handleSize = 16 interpolateTo 32 progress:math.min(max.x-min.x, max.y-min.y) 64..256
	
	internal tick
		if Platform.mode != Manipulator: return
		findInfluencedItems
		
		if items
			// Draw handles
			let size = max - min
			let center = (max + min)/2 
			for Direction.allDirections
				drawImage ResizeHandle, center + size/2*.vector, size:handleSize, location:null, layer:int.maxValue
				
			// Draw selection
			drawRectangle center, size:max-min, outlineColor:{"#437FDF"}, outlineWidth:4, location:null, layer:int.maxValue
			
	private Direction overHandleDirection
	private Vector2 touchDownPos = {float.infinity, float.infinity}
	private bool touchDownInsideGizmo
	private int locationIndex
	private int waitingForCodeId
	private float aspectRatio
	private bool isManipulating
	
	clear
		overHandleDirection = null
		touchDownPos = Vector2.none
		touchDownInsideGizmo = false
		locationIndex = 0
		waitingForCodeId = 0
		aspectRatio = 1
		items.clear
		min = Vector2.none
		max = Vector2.none
	
	internal onTouch: InputType InputType, int id, Vector2 pixelPos, Vector2 referencePos, shift = false, alt = false, cmdOrCtrl = false	
		if Platform.mode != Manipulator: return
		let movedSinceTouchDown = (referencePos manhattanDistanceTo touchDownPos) > 8
		let insideGizmo = referencePos >= gizmo.min and referencePos <= gizmo.max
		if InputType == TouchDown: touchDownPos = referencePos; touchDownInsideGizmo = insideGizmo; else
		if InputType == TouchUp:   touchDownPos = Vector2.none; isManipulating = false
			
		// Which handle are we currently hovering over?
		if items and not touchDownPos
			let center = (min + max)/2
			if referencePos manhattanDistanceTo max < handleSize:               overHandleDirection = Direction.DownRight; else
			if referencePos manhattanDistanceTo min < handleSize:               overHandleDirection = Direction.UpLeft; else
			if referencePos manhattanDistanceTo {max.x, min.y} < handleSize:    overHandleDirection = Direction.UpRight; else
			if referencePos manhattanDistanceTo {min.x, max.y} < handleSize:    overHandleDirection = Direction.DownLeft; else
			if referencePos manhattanDistanceTo {max.x, center.y} < handleSize: overHandleDirection = Direction.Right; else
			if referencePos manhattanDistanceTo {min.x, center.y} < handleSize: overHandleDirection = Direction.Left; else
			if referencePos manhattanDistanceTo {center.x, min.y} < handleSize: overHandleDirection = Direction.Up; else
			if referencePos manhattanDistanceTo {center.x, max.y} < handleSize: overHandleDirection = Direction.Down; else
				                                                                overHandleDirection = null
				
		// If we touch down outside the selection, we select an item immediately, so we can directly move it
		// If we touch up inside the selection without moving, we cycle through all items the pointer is over
		if !overHandleDirection and codeId >= waitingForCodeId
			if (InputType == TouchDown and !insideGizmo)
			or (InputType == TouchUp and touchDownInsideGizmo and !movedSinceTouchDown)
			
				// Collect all items and locations the mouse pointer is over
				GizmoOverItem[] overItems
				for graphics.items -> item
					if pixelPos.isInsidePolygon item.poly
						if item.positionLocation: flattenLocations overItems, item, item.positionLocation; else
						if item.location:         overItems.add {item, item.location}
									
				if overItems.length
					// Select next item cycling through all items the mouse pointer is over
					if InputType == TouchDown: locationIndex = 0
					let selectedStackItem = overItems[locationIndex++ % overItems.length]
					cursorLocation = selectedStackItem.location
					cursorItem = selectedStackItem.item
					Platform.sendSelectToEditor cursorLocation.file, cursorLocation.start
				else
					// Deselect
					locationIndex = 0
					cursorLocation = null
					Platform.sendDeselectToEditor
		
		if cursorLocation
			GizomInfluence[] influences
			if overHandleDirection
				// Resize the item (we are over a handle)
				let handle = overHandleDirection.vector
				let isOrthogonal = handle.x == 0 or handle.y == 0
				let dx = (referencePos.x - touchDownPos.x) * handle.x
				let dy = (referencePos.y - touchDownPos.y) * handle.y
				let deltas = shift or isOrthogonal ? [dx,dy] : aspectRatio < 1 ? [dx,dx*aspectRatio] : [dy/aspectRatio, dy]
				
				// Set cursor
				setCursor isOrthogonal ? (handle.y == 0 ? "ew-resize" : "ns-resize")
				                       : (handle.x == handle.y ? "nwse-resize" : "nesw-resize")
						
				// Adjust size
				for items
					if .sizeLocation
						// Change existing size
						influences.add {.sizeLocation.file, .sizeLocation.start, .sizeLocation.end, deltas}
					else
						// Add new size
						influences.add {cursorLocation.file, cursorLocation.start, cursorLocation.end, deltas, initialValues:[.w,.h], label:"size"}
				
				// Adjust position		
				if not cmdOrCtrl
					if cursorItem.location != cursorLocation
						// Change existing position
						influences.add {cursorLocation.file, cursorLocation.start, cursorLocation.end, deltas:[.5*deltas[0]*handle.x, .5*deltas[1]*handle.y]}
					else
						// Add new position
						influences.add {cursorLocation.file, cursorLocation.end, cursorLocation.end, deltas:[.5*deltas[0]*handle.x, .5*deltas[1]*handle.y], initialValues:[0,0], label:"position"}
				else
				if cursorItem.location != cursorLocation
					// Change existing position
					influences.add {cursorLocation.file, cursorLocation.start, cursorLocation.end, deltas:[0,0]}
					
			else
				// Move the item (we are inside the selection)
				setCursor "auto"
				if cursorItem.location != cursorLocation
					// Change existing position
					influences.add {cursorLocation.file, cursorLocation.start, cursorLocation.end, deltas:[referencePos.x - touchDownPos.x, referencePos.y - touchDownPos.y]}
				else
					// Add new position
					influences.add {cursorLocation.file, cursorLocation.end, cursorLocation.end, deltas:[referencePos.x - touchDownPos.x, referencePos.y - touchDownPos.y], initialValues:[0,0], label:"position"}
				
			// Send manipulation to editor	
			if InputType == TouchMove and touchDownPos and codeId >= waitingForCodeId
				if not isManipulating and movedSinceTouchDown
					// Start manipulation as soon as we dragged more than a certain threshold
					isManipulating = true
					aspectRatio = (max.y - min.y) / (max.x - min.x)
					Platform.sendStartManipulationToEditor influences
					
				if isManipulating
					// Move manipulation
					Platform.sendMoveManipulationToEditor influences, ++waitingForCodeId
			
	private js void setCursor: string cursor
		document.body.style.cursor = cursor
		
	private void flattenLocations: GizmoOverItem[] stack, DisplayItem item, SourceCodeLocation location
		if location.file:  stack.add {item, location}
		if location.right: flattenLocations stack, item, location.right
		if location.left:  flattenLocations stack, item, location.left
			
// --------------------------------------------- Award Screen ---------------------------------------------

awardScreen
	bool active
	tick
		onKeyDown Alt W: active = not active
		if active
			let size = {720, 540}
			forPositions players, grid:{2,2}, delta:size
				drawVideo . position:pos, size
				drawText .score, pos * {2.13, 1.8}, font:ByTheWay
				
// --------------------------------------------- Display Item ---------------------------------------------

internal transient immutable DisplayItem
	float x, y, w, h
	int layer
	float alpha
	ClippingPath clippingPath
	string name
	SourceCodeLocation location
	SourceCodeLocation positionLocation
	SourceCodeLocation sizeLocation
	
	visible float m0, m1, m2, m3, m4, m5
	visible Vector2[] poly

	DisplayItem: Matrix2D m
		m0 = m.m0; m1 = m.m1; m2 = m.m2; m3 = m.m3; m4 = m.m4; m5 = m.m5
		if Platform.isDebug and (w or h)
			poly = [
				{ x,   y   }.transform(m),
				{ x+w, y   }.transform(m),
				{ x+w, y+h }.transform(m),
				{ x,   y+h }.transform(m),
			]
	draw
		
	js void startClipping
		let points = this.clippingPath.points
		if(points.length >= 2) {
			let x = this.x, y = this.y
			let firstPos = points[points.length-1]
			graphics.context.beginPath();
			graphics.context.moveTo(firstPos.x, firstPos.y)
			for(let p of points) graphics.context.lineTo(p.x, p.y)
			if(this.clippingPath.show) {
				graphics.context.fillStyle = "#ff000080"
				graphics.context.fill()
			}
			graphics.context.save()
			graphics.context.clip()
		}
		
	js void endClipping
		if(this.clippingPath.points.length >= 2)
			graphics.context.restore()
			
internal transient DisplayItem DisplayImage
	object htmlImage
	float sx, sy, sw, sh
	Color color
	js void draw
		if(this.alpha == 0) return
		graphics.context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		graphics.context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
			
		if(this.color.hex == "#ffffff" || this.color.hex == "#ffffffff" || this.color == null) {
			try{ graphics.context.drawImage(this.htmlImage, this.sx, this.sy, this.sw, this.sh, this.x, this.y, this.w, this.h) }
			catch(e) { log("DisplayImage: "+e.message) }
		} else {
			// Create offscreen buffer
	        let offscreenCanvas = document.createElement("canvas");
	        offscreenCanvas.width = this.sw;
	        offscreenCanvas.height = this.sh;
	        let offscreenContext = offscreenCanvas.getContext("2d");
			
			// Draw image
			offscreenContext.drawImage(this.htmlImage, this.sx, this.sy, this.sw, this.sh, 0, 0, this.sw, this.sh)
			
			// Multiply tint color
			offscreenContext.fillStyle = this.color.hex;
			offscreenContext.globalCompositeOperation = "multiply";
			offscreenContext.fillRect(0, 0, offscreenCanvas.width, offscreenCanvas.height);
			
			// Apply alpha
			offscreenContext.globalAlpha = 1;
			offscreenContext.globalCompositeOperation = "destination-in";
			offscreenContext.drawImage(this.htmlImage, this.sx, this.sy, this.sw, this.sh, 0, 0, this.sw, this.sh)
				
			// Draw tinted image
	        graphics.context.drawImage(offscreenCanvas, this.x, this.y, this.w, this.h);		
		}
		
		if(this.clippingPath) this.endClipping()

internal transient DisplayItem DisplayText
	string fillStyle, outlineColor
	float outlineWidth
	float offsetY
	string font
	string[] lines = null
	float[] lineOffsets = null
	float lineHeight
	
	js void draw
		if(this.alpha == 0) return
		graphics.context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		graphics.context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
		graphics.context.font = this.font
		if(!this.lines) {
			// Single line
			if(this.outlineColor) {
				graphics.context.lineWidth = this.outlineWidth
				graphics.context.strokeStyle = this.outlineColor
				graphics.context.strokeText(this.name, this.x, this.y)
			}
			graphics.context.fillStyle = this.fillStyle
			graphics.context.fillText(this.name, this.x, this.y - this.offsetY)
		} else {
			// Multiple lines
			let y = this.y
			for(let i=0; i<this.lines.length; i++) {
				let line = this.lines[i];
				let offset = this.lineOffsets[i];
				if(this.outlineColor) {
					graphics.context.lineWidth = this.outlineWidth
					graphics.context.strokeStyle = this.outlineColor
					graphics.context.strokeText(line, this.x + offset, y)
				}
				graphics.context.fillStyle = this.fillStyle
				graphics.context.fillText(line, this.x + offset, y)
				y += this.lineHeight
			}
		}
		
		if(this.clippingPath) this.endClipping()

internal TextSegment
	string text
	TextHighlight highlight
	Vector2 position
	Vector2 size
		
internal transient DisplayItem DisplayTextWithHighlights
	string fillStyle, outlineColor
	float outlineWidth
	float offsetY
	string font
	TextSegment[] segments = null
	
	js void draw
		if(this.alpha == 0) return
		graphics.context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		graphics.context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
		graphics.context.font = this.font
		let y = this.y
		for(let i=0; i<this.segments.length; i++) {
			let segment = this.segments[i];
			if(this.outlineColor) {
				graphics.context.lineWidth = this.outlineWidth
				graphics.context.strokeStyle = this.outlineColor
				graphics.context.strokeText(line, this.x + offset, y)
			}
			let highlight = segment.highlight
			if(highlight) {
				if(highlight.backgroundColor) {
					// Background rectangle
					graphics.context.fillStyle = highlight.backgroundColor.hex
					
					let x = this.x + segment.position.x
					let y = this.y + segment.position.y - highlight.padding.y
					let width = segment.size.x
					let height = segment.size.y + highlight.padding.y*2
					let radius = highlight.cornerRadius
					
					if(radius) {
						// Rounded corners
						graphics.context.beginPath();
						graphics.context.moveTo(x + radius, y);
						graphics.context.lineTo(x + width - radius, y);
						graphics.context.quadraticCurveTo(x + width, y, x + width, y + radius);
						graphics.context.lineTo(x + width, y + height - radius);
						graphics.context.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
						graphics.context.lineTo(x + radius, y + height);
						graphics.context.quadraticCurveTo(x, y + height, x, y + height - radius);
						graphics.context.lineTo(x, y + radius);
						graphics.context.quadraticCurveTo(x, y, x + radius, y);
						graphics.context.closePath();
						graphics.context.fill();
					} else {
						graphics.context.fillRect(x, y, width, height)
					}
				}
			}
			if(highlight) {
				graphics.context.fillStyle = highlight.color ? highlight.color.hex : this.fillStyle
				graphics.context.fillText(segment.text, this.x + segment.position.x + highlight.padding.x, this.y + segment.position.y)
			} else {
				graphics.context.fillStyle = this.fillStyle
				graphics.context.fillText(segment.text, this.x + segment.position.x, this.y + segment.position.y)
			}
		}
		
		if(this.clippingPath) this.endClipping()

internal transient DisplayItem DisplayRectangle
	string color, outlineColor
	float outlineWidth
	js void draw
		if(this.alpha == 0) return
		graphics.context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		graphics.context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
			
		if(this.color == "clear") {
			graphics.context.clearRect(this.x, this.y, this.w, this.h)
		}
		else
		if(this.color) {
			graphics.context.fillStyle = this.color
			graphics.context.fillRect(this.x, this.y, this.w, this.h)
		}
		if(this.outlineColor) {
			graphics.context.lineWidth = this.outlineWidth
			graphics.context.strokeStyle = this.outlineColor
			graphics.context.strokeRect(this.x, this.y, this.w, this.h)
		}
		if(this.clippingPath) this.endClipping()
		
internal transient DisplayItem DisplayRoundedRectangle
	float radius
	string color, outlineColor
	float outlineWidth
	js void draw
		if(this.alpha == 0) return
		graphics.context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		graphics.context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
		let sizeX = this.w, sizeY = this.h, x = this.x, y = this.y, radius = this.radius
		
		// Arcs
		graphics.context.beginPath();
		graphics.context.moveTo(x + radius, y);
		graphics.context.lineTo(x + sizeX - radius, y);
		graphics.context.arcTo(x + sizeX, y, x + sizeX, y + radius, radius);
		graphics.context.lineTo(x + sizeX, y + sizeY - radius);
		graphics.context.arcTo(x + sizeX, y + sizeY, x + sizeX - radius, y + sizeY, radius);
		graphics.context.lineTo(x + radius, y + sizeY);
		graphics.context.arcTo(x, y + sizeY, x, y + sizeY - radius, radius);
		graphics.context.lineTo(x, y + radius);
		graphics.context.arcTo(x, y, x + radius, y, radius);
		graphics.context.closePath();
		
		// Quadratic Curves
		// graphics.context.beginPath();
		// graphics.context.moveTo(x + radius, y);
		// graphics.context.lineTo(x + sizeX - radius, y);
		// graphics.context.quadraticCurveTo(x + sizeX, y, x + sizeX, y + radius);
		// graphics.context.lineTo(x + sizeX, y + sizeY - radius);
		// graphics.context.quadraticCurveTo(x + sizeX, y + sizeY, x + sizeX - radius, y + sizeY);
		// graphics.context.lineTo(x + radius, y + sizeY);
		// graphics.context.quadraticCurveTo(x, y + sizeY, x, y + sizeY - radius);
		// graphics.context.lineTo(x, y + radius);
		// graphics.context.quadraticCurveTo(x, y, x + radius, y);
		// graphics.context.closePath();
		
		if(this.color) {
			graphics.context.fillStyle = this.color
			graphics.context.fill()
		}
		if(this.outlineColor) {
			graphics.context.lineWidth = this.outlineWidth
			graphics.context.strokeStyle = this.outlineColor
			graphics.context.stroke()
		}
		if(this.clippingPath) this.endClipping()
		
internal transient DisplayItem DisplayPolygon
	Vector2[] points
	string color, outlineColor
	float outlineWidth
	bool smooth, close
	js void draw
		if(this.points.length < 2 || this.alpha == 0) return
		graphics.context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		graphics.context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
		let x = this.x, y = this.y
		let points = this.points, startPoint = points[0]
		
		graphics.context.beginPath();
		graphics.context.moveTo(x + startPoint.x, y + startPoint.y)
		
		if(!this.smooth || points.length < 3) {
			for(let i=1, len = points.length; i<len; ++i) {
				let p = points[i]
				graphics.context.lineTo(x + p.x, y + p.y)
			}
		} else {
			for(var i = 1, len = points.length - 2; i<len; i++)
			{
				let p1 = points[i], p2 = points[i + 1]
				graphics.context.quadraticCurveTo(p1.x, p1.y, (p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
			}
			let p1 = points[i], p2 = points[i + 1]
			graphics.context.quadraticCurveTo(p1.x, p1.y, p2.x,p2.y);
		}
		if(this.close || this.color) {
			graphics.context.closePath()
		}
		if(this.color) {
			// Close the polygon and fill it
			graphics.context.fillStyle = this.color
			graphics.context.fill()
		}
		if(this.outlineColor) {
			// Draw outline
			graphics.context.lineWidth = this.outlineWidth
			graphics.context.strokeStyle = this.outlineColor
			graphics.context.stroke()
		}
		if(this.clippingPath) this.endClipping()
		
internal transient DisplayItem DisplayCircle
	float startAngle, angle
	RotationDirection direction
	string color, outlineColor
	float outlineWidth
	js void draw
		if(this.alpha == 0) return
		graphics.context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		graphics.context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
			
		graphics.context.beginPath();
		if(this.w == this.h) {
			let radius = this.w/2
			if(this.angle == 1) {
				graphics.context.arc(this.x+radius, this.y+radius, radius, 0, math.TwoPI, this.direction);
			} else {
				let startAngle = this.startAngle - .25
				graphics.context.arc(this.x+radius, this.y+radius, radius, startAngle*math.TwoPI, (startAngle+this.angle)*math.TwoPI, this.direction);
			}
		} else {
			let radiusX = this.w/2
			let radiusY = this.h/2
			graphics.context.ellipse(this.x+radiusX, this.y+radiusY, radiusX, radiusY, 0, math.TwoPI, this.direction);
		}
		if(this.color) {
			graphics.context.fillStyle = this.color
			graphics.context.fill()
		}
		if(this.outlineColor) {
			graphics.context.lineWidth = this.outlineWidth
			graphics.context.strokeStyle = this.outlineColor
			graphics.context.stroke()
		}
		if(this.clippingPath) this.endClipping()
		
internal transient DisplayItem DisplayLine
	Vector2 end
	string outlineColor
	float outlineWidth
	js void draw
		if(this.alpha == 0) return
		graphics.context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		graphics.context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
		
		graphics.context.beginPath();
		graphics.context.moveTo(this.x,this.y)
		graphics.context.lineTo(this.end.x, this.end.y)
		graphics.context.lineWidth = this.outlineWidth
		graphics.context.strokeStyle = this.outlineColor
		graphics.context.stroke()
		
		if(this.clippingPath) this.endClipping()
			
internal transient DisplayItem DisplayVideo
	int userId
	VideoShape shape
	draw
		InternalUser user = input.internalUsers[userId]
			let videoElement = user.videoElements[user.videoElementIndex]
			               or (user.videoElements[user.videoElementIndex] = PeerNetwork.createVideoElement(user.mediaStream, user.local))
			
			let px = (m0 * x + m2 * y + m4) / graphics.pixelRatio
			let py = (m1 * x + m3 * y + m5) / graphics.pixelRatio
			let sizeX = w*m0 / graphics.pixelRatio
			let sizeY = h*m3 / graphics.pixelRatio
			PeerNetwork.updateVideoElement videoElement, px, py, sizeX, sizeY, radius:shape == Circle ? 10000 : 0
			user.videoElementIndex++


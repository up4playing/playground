// A color comprised of a red, green, blue and alpha component
class Color
	global const Color White   = {"ffffff"}
	global const Color Black   = {"000000"}
	global const Color Red     = {"ef476f"}
	global const Color Yellow  = {"ffd166"}
	global const Color Green   = {"06d6a0"}
	global const Color Blue    = {"118ab2"}
	global const Color Gray    = {"3d3d3d"}
	global const Color TransparentRed   = {"ff000080"}
	string hex
	
	Color: string hex = ""
		   int red = 0
		   int green = 0
		   int blue = 0
		   int alpha = 255
		if hex: this.hex = "#" + hex
		else    this.hex = "#" + componentToHex(red) + componentToHex(green) 
		                       + componentToHex(blue) + componentToHex(alpha)
			
	static js string componentToHex: int c
		var hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
		
	inline js bool operator ==(Color a, Color b) a.hex == b.hex
	inline js bool operator !=(Color a, Color b) a.hex != b.hex
	
// A texture that can be loaded into video memory
class Texture
	string file
	Vector2 size
	
	Texture
		if Platform.engineStarted
			open
			
	js bool ensureIsAvailable()
		if(!this._htmlImage) {
			this._htmlImage = _htmlImageCache[this.file]
		}
		return this._htmlImage != null
	
	js void open
		if(!window._htmlImageCache) _htmlImageCache = {}
		let image = _htmlImageCache[this.file]
		if(!image) {
			return new Promise((resolve, reject) => {
				image = new HTMLImage()
				image.src = this.file.startsWith("http") ? this.file : _basePath+this.file
				image.onload = e => {
					this._htmlImage = image
					window._htmlImageCache[this.file] = image
					this.size = new Vector2(image.width, image.height, null)
					resolve(this);
				}
			})
		} else {
			this._htmlImage = image
			this.size = new Vector2(image.width, image.height, null)
			return this
		}
		
// A font that can be used to draw text
skipInit class Font
	string name
	string file
	Vector2 offset
	actualHeightFactor = .76
	
	js void open
		if(!window._fontCache) _fontCache = {}
		let font = _fontCache[this.file]
		if(!font) {
			// let font = new FontFace(this.name, "url("+_basePath+this.file+")");
			let font = new FontFace(this.name, "url("+this.file+")");
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
		const canvas = document.createElement('canvas');
		const context=canvas.getContext('2d');
		const w = fontsize*2+margin, h = fontsize*2+margin;
		canvas.height = h;
		canvas.width = w;
		context.textBaseline='top';
		context.font=fontsize+'px '+this.name;
		context.fillStyle='red';
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
struct ImageFrame
	float x1, y1, x2, y2, w, h

// An image that can be drawn on the screen and can have several frames of animation
skipInit class Image
	Texture texture
	Vector2 size
	ImageFrame[] frames
	string file
	
enum HorizontalAlignment: Left, Center, Right
enum VerticalAlignment: Top, Middle, Bottom
enum FontStyle: Normal, Bold
class ClippingPath: Vector2[] points; bool show
		
// A collection of functions for drawing on the screen
transient global unit graphics
	internal Matrix2D totalMatrix, localMatrix
	internal DisplayItem[] items
		
	internal js void startFrame
		graphics_reset()
		if(!Platform_fastForward && !Platform_isWaitingForInitialData)
			if(!graphics_backgroundColor || graphics_backgroundColor.hex == "#000000") {
				Platform_context.clearRect(0, 0, Platform_pixelSize.x, Platform_pixelSize.y)
			} else {
				Platform_context.fillStyle = graphics_backgroundColor.hex
				Platform_context.fillRect(0, 0, Platform_pixelSize.x, Platform_pixelSize.y)
			}
			Platform_context.textBaseline = "top"

	internal resetMatrix
		totalMatrix = Platform.baseMatrix
		localMatrix.clear	

	internal reset
		totalMatrix = Platform.baseMatrix
		localMatrix.clear
		currentlyVisibleFor = null
		items.clear

	internal finishFrame
		if(Platform.fastForward) return
		for Input.internalUsers if .
			.videoElementIndex = 0
		drawItems
		drawSafeArea
		for Input.internalUsers -> user if .
			for user.videoElementIndex to user.videoElements.length
				PeerNetwork.removeVideoElement user.videoElements[.]
			user.videoElements.setLength user.videoElementIndex
			PeerNetwork.setAudioMuted user.audioElement, muted:Network.muteInvisibleUsers and user.videoElementIndex == 0
		
	private drawItems
		gizmo.tick
		items.sort b.layer - a.layer
		items.each <- .draw
		resetTransform
		
	private js void resetTransform
		Platform_context.resetTransform()
		Platform_context.globalAlpha = 1
				
	private isVisibleFor: int visibleFor
		if(Platform.fastForward) return false
		if visibleFor != -1: return visibleFor == Input.localUser.id
		else                 return currentlyVisibleFor == null or currentlyVisibleFor.contains(Input.localUser.id)
			
	private isVisibleFor: int[] visibleFor
		if(Platform.fastForward) return false
		let effectiveVisibleFor = visibleFor or currentlyVisibleFor
		return effectiveVisibleFor == null or effectiveVisibleFor.contains(Input.localUser.id)
		
	private int[] getClickableBy: int visibleFor, int clickableBy
		int[] effectiveVisibleBy = visibleFor != -1 ? [visibleFor] : currentlyVisibleFor
		return (effectiveVisibleBy and clickableBy != -1)
		     ? (effectiveVisibleBy.contains(clickableBy) ? [clickableBy] : [])
		     : (effectiveVisibleBy or (clickableBy != -1 ? [clickableBy] : null))
			
	private int[] getClickableBy: int[] visibleFor, int[] clickableBy
		int[] effectiveVisibleBy = visibleFor or currentlyVisibleFor
		return effectiveVisibleBy and clickableBy
		     ? effectiveVisibleBy intersectWith clickableBy 
		     : effectiveVisibleBy or clickableBy
			
	internal js void drawSafeArea
		graphics_resetTransform()
		Platform_context.fillStyle = "#404040"
		if(Platform_showSafeArea) {
			if(Platform_effectiveScaleMode == 1) {
				// Fixed width
				let ratio = Platform_pixelSize.x / Platform_referenceSize.x
				let margin = (Platform_pixelSize.y-Platform_referenceSize.y*ratio)/2
				Platform_context.fillRect(0,0,Platform_pixelSize.x, margin)
				Platform_context.fillRect(0,Platform_pixelSize.y-margin,Platform_pixelSize.x, margin)
			} else if(Platform_effectiveScaleMode == 2) {
				// Fixed height
				let ratio = Platform_pixelSize.y / Platform_referenceSize.y
				let margin = (Platform_pixelSize.x-Platform_referenceSize.x*ratio)/2
				Platform_context.fillRect(0, 0, margin, Platform_pixelSize.y)
				Platform_context.fillRect(Platform_pixelSize.x-margin, 0, margin, Platform_pixelSize.y)
			}
		}
		
	// Moves all subsequent operations by a given vector						
	move: Vector2 distance // The distance to move
		localMatrix.move distance
		totalMatrix.move distance
							
	// Moves all operations in a block by a given vector						
	move: Vector2 distance // The distance to move
		  void() block     // All operations within this block will be moved
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.move distance
		totalMatrix.move distance
		block
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
							
	// Rotates all subsequent operations by a given angle	
	rotate: Angle angle // The angle in turns (one full rotation is 1)
		localMatrix.rotate angle
		totalMatrix.rotate angle
		
	// Rotates all operation in a block by a given angle				
	rotate: Angle angle  // The angle in turns (one full rotation is 1)
		    void() block // All operations within this block will be rotated
		if angle == 0: block; return
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.rotate angle
		totalMatrix.rotate angle
		block
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
	
	// Scales all subsequent operations by a given factor
	scale: float factor // The factor to scale by
		localMatrix.scale {factor, factor}
		totalMatrix.scale {factor, factor}
		
	// Scales all operation in a block by a given factor
	scale: float factor // The factor to scale by
		   void() block // All operations within this block will be scaled
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.scale {factor, factor}
		totalMatrix.scale {factor, factor}
		block
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
	
	global transform: Vector2 move = Vector2.none  // The distance to move
		              float scale = 1              // The factor to scale by
		              Angle rotate = 0             // The angle in turns (0: no rotation, 1: one full rotation)
		              void() do                    // All operations within this block will be scaled
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
		do
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
	
	// Apply a matrix to all subsequent operation
	applyMatrix: Matrix2D matrix
		localMatrix.multiplyRight matrix
		matrix.multiplyRight matrix
	
	// Applies a matrix to all operations in a block
	applyMatrix: Matrix2D matrix // The matrix to appy
		         void() block    // All operations within this block will be scaled
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		this.localMatrix.multiplyLeft matrix
		this.totalMatrix.multiplyLeft matrix
		block
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5
	
	// Directly manipulate the pixels on the screen or an image
	js int[] manipulate: void(int[] pixels) code // This code can manipulate the pixels
		let imageData = Platform_context.getImageData(0,0,Platform_pixelSize.x, Platform_pixelSize.y)
		code(imageData.data)
		Platform_context.putImageData(imageData, 0, 0)
		
	// Creates an image to draw to
	js void createImage: Vector2 size      // The size of the image
		                 string file = "" // Save the image to a file with this filename
		                 void() code      // This code will draw on the created image instead of drawing on the screen
		// let prevCanvas = Platform_canvas
		let prevContext = Platform_context
		let prevPixelSizeX = Platform_pixelSize.x
		let prevPixelSizeY = Platform_pixelSize.y
		let prevItems = graphics_items
		graphics_items = []
		let canvas = document.createElement("canvas")
		canvas.width = size.x
		canvas.height = size.y
		Platform_context = canvas.getContext("2d")
		Platform_pixelSize.x = size.x
		Platform_pixelSize.y = size.y
		let a = graphics_localMatrix.matrix, b = graphics_totalMatrix.matrix
		let a0 = graphics_localMatrix.m0, a1 = graphics_localMatrix.m1, a2 = graphics_localMatrix.m2, a3 = graphics_localMatrix.m3, a4 = graphics_localMatrix.m4, a5 = graphics_localMatrix.m5
		let b0 = graphics_totalMatrix.m0, b1 = graphics_totalMatrix.m1, b2 = graphics_totalMatrix.m2, b3 = graphics_totalMatrix.m3, b4 = graphics_totalMatrix.m4, b5 = graphics_totalMatrix.m5
		graphics_localMatrix.set(1, 0, 0, 1, -size.x/2, -size.y/2)
		graphics_totalMatrix.set(1, 0, 0, 1, size.x/2, size.y/2)
		code()
		graphics_drawItems()
		var dataUrl = canvas.toDataURL('image/png');
		if(file) Platform_saveImage(dataUrl, file);
		graphics_localMatrix.m0 = a0; graphics_localMatrix.m1 = a1; graphics_localMatrix.m2 = a2; graphics_localMatrix.m3 = a3; graphics_localMatrix.m4 = a4; graphics_localMatrix.m5 = a5
		graphics_totalMatrix.m0 = b0; graphics_totalMatrix.m1 = b1; graphics_totalMatrix.m2 = b2; graphics_totalMatrix.m3 = b3; graphics_totalMatrix.m4 = b4; graphics_totalMatrix.m5 = b5
		Platform_context = prevContext
		// canvas = prevCanvas
		Platform_pixelSize.x = prevPixelSizeX
		Platform_pixelSize.y = prevPixelSizeY
		graphics_items = prevItems
		return dataUrl
		
	// The default background color
	Color backgroundColor = Black

	// The default color for all draw operations
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
	private Color currentColor = {"ffffff"}
	
	// The default font for all draw operations
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
	
	// The default font size for all draw operations
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
	
	// The default line width for all draw operations
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
	
	// For all drawings in code block, only pixels inside the given polygon are drawn
	clip: Vector2[] points      // A list of points that define the area to be clipped
		  Vector2 position = {} // The position all points are relative to 
		  bool show = false    // Visualizes the clipping area by shading it transparent red
		if show: drawPolygon position, points, fillColor:TransparentRed
				
	// For all drawings in code block, only pixels inside the given polygon are drawn
	clip: Vector2[] points      // A list of points that define the area to be clipped
		  Vector2 position = {} // The position all points are relative to 
		  bool show = false    // Visualizes the clipping area by shading it transparent red
		  void() code          // All draw operation within this code block will be clipped
		let prev = currentClippingPath
		currentClippingPath = ClippingPath(show)
		for points: currentClippingPath.points.add position + .
		code()
		currentClippingPath = prev
		
	private ClippingPath currentClippingPath
		
	// The default user for which all draw operations will be visible
	visibleFor
		return currentlyVisibleFor
		
	visibleFor: int visibleFor
		        void() code
		let prev = currentlyVisibleFor
		currentlyVisibleFor = visibleFor != -1 ? [visibleFor] : null
		code()
		currentlyVisibleFor = prev
		return currentlyVisibleFor
		
	visibleFor: int[] visibleFor
		        void() code
		let prev = currentlyVisibleFor
		currentlyVisibleFor = visibleFor
		code()
		currentlyVisibleFor = prev
		return currentlyVisibleFor
		
	private int[] currentlyVisibleFor = null
		
	// Returns the width of a string in pixels
	global js int getTextWidth: string text                 // The string to get the width of
		                         implicit Vector2 size = {} // The size of the text
		                        Font font = null            // The font of the text
		                        FontStyle style = Normal    // Whether the text should be bold or normal style
		let effectiveFont = font || graphics_currentFont
		let fontSize = size.y || size.x || graphics_currentFontSize
		Platform_context.font =  (style ? "bold ":"")+fontSize+"px "+effectiveFont.name;
		let textSize = Platform_context.measureText(text)
		return textSize.width
		
	getAbsolutPosition: Vector2 position
		return position.getTransformed(localMatrix)
		
	getPixelPosition: Vector2 position
		return position.getTransformed(totalMatrix) / Platform.pixelRatio
		
	getPixelSize: Vector2 size
		return size * {totalMatrix.m0, totalMatrix.m3} / Platform.pixelRatio
		
	private Vector2 getEffectiveSize: Vector2 imageSize, Vector2 size
		let sizeX = size.x || imageSize.x
		let sizeY = size.y || (sizeX/imageSize.x)*imageSize.y
		return {sizeX, sizeY}
				
	// Draws an image on the screen
	global void drawImage: Image image                // The image to draw
		                   Vector2 position = {}      // The position to draw to
		                   framesPerSecond = 0        // Animate the image with this speed
		                   implicit Vector2 size = {} // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                   visibleFor = -1            // Only this user will see the image
		                   implicit int layer = 0     // Higher layers are drawn in front of lower layers
		                   alpha = 1.0                // The opacity of the image (0: fully transparent, 1: fully visible)
		                   Color color = White        // Tint the image with this color
		                   SourceCodeLocation location
		var frame = Math.floor(Network.frame * Math.max(framesPerSecond, 0) / Network.targetFps) % image.frames.length;
		drawImage image, position, frame, size, visibleFor, layer, alpha, color, location
	
	// Draws an image on the screen
	global void drawImage: Image image                // The image to draw
		                   Vector2 position = {}      // The position to draw to
		                   framesPerSecond = 0        // Animate the image with this speed
		                   implicit Vector2 size = {} // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                   int[] visibleFor           // Only this user will see the image
		                   implicit int layer = 0     // Higher layers are drawn in front of lower layers
		                   alpha = 1.0                // The opacity of the image (0: fully transparent, 1: fully visible)
		                   Color color = White        // Tint the image with this color
		                   SourceCodeLocation location
		var frame = Math.floor(Network.frame * Math.max(framesPerSecond, 0) / Network.targetFps) % image.frames.length;
		drawImage image, position, frame, size, visibleFor, layer, alpha, color, location
	
	// Draws an image on the screen
	global void drawImage: Image image                // The image to draw
		                   Vector2 position = {}      // The position to draw to
		                   framesPerSecond = 0        // Animate the image with this speed
		                   implicit Vector2 size = {} // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                   Angle angle = 0.0          // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                   flipX = false              // Mirror the image horizontally
		                   flipY = false              // Mirror the image vertically
		                   visibleFor = -1            // Only this user will see the image
		                   implicit int layer = 0     // Higher layers are drawn in front of lower layers
		                   alpha = 1.0                // The opacity of the image (0: fully transparent, 1: fully visible)
		                   Color color = White        // Tint the image with this color
		                   SourceCodeLocation location
		var frame = Math.floor(Network.frame * Math.max(framesPerSecond, 0) / Network.targetFps) % image.frames.length;
		drawImage image, position, frame, size, angle, flipX, flipY, visibleFor, layer, alpha, color, location
	
	// Draws an image on the screen
	global void drawImage: Image image                  // The image to draw
		                   Vector2 position = {}        // The position to draw to
		                   frame = 0                    // The frame of the image to draw
		                   implicit Vector2 size = {}   // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                   Angle angle = 0.0            // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                   touchMargin = Vector2(16,16) // The margin around the button within which it is touchable
		                   showTouchArea = false        // Show the area within which the button is touchable
		                   visibleFor = -1              // Only this user will see the button
		                   clickableBy = -1             // Only this user can click the button
		                   hotkey = Key.None            // This keyboard shortcut will execute the onClick handler
		                   implicit layer = 0           // Higher layers are drawn in front of lower layers
		                   alpha = 1.0                  // The opacity of the button 0: fully transparent, 1: fully visible)
		                   Color color = White          // Tint the image with this color
		                   void(Touch touch) onClick    // Execute this code when the user clicks on the image or presses the hotkey
		                   SourceCodeLocation location
		drawImage image, position, frame, size, angle, visibleFor, layer, alpha, color, location
			
		// Handle click (only visible buttons are clickable)
		int[] effectiveClickableBy = getClickableBy(visibleFor, clickableBy)
		Input.onTouchDownWithin position, image.size + touchMargin, userId:effectiveClickableBy, showTouchArea
			onClick touch
		if hotkey
			Input.onKeyDown hotkey, userId:effectiveClickableBy
				onClick null
		
	// Draws an image on the screen
	global js void drawImage: Image image                // The image to draw
		                      Vector2 position = {}      // The position to draw to
		                      frame = 0                  // The frame of the image to draw
		                      implicit Vector2 size = {} // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                      visibleFor = -1            // Only this user will see the image
		                      implicit layer = 0         // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                // The opacity of the image (0: fully transparent, 1: fully visible)
		                      Color color = White        // Tint the image with this color
		                      SourceCodeLocation location
		if(!image.texture?.ensureIsAvailable()) return
		if(graphics_isVisibleFor(visibleFor)) {
			let f = image.frames[frame % image.frames.length]
			let sizeX = size.x || f.w
			let sizeY = size.y || (sizeX/f.w)*f.h
			graphics_items.push(new DisplayImage(
				graphics_totalMatrix,
				position.x-sizeX/2,
				position.y-sizeY/2,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, image.file,
				location, position.location, size.location,
				image.texture._htmlImage,
				f.x1, f.y1, f.w, f.h,
				color
			))
		}
	
	global js void drawImage: Image image                // The image to draw
		                      Vector2 position = {}      // The position to draw to
		                      frame = 0                  // The frame of the image to draw
		                      implicit Vector2 size = {} // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                      int[] visibleFor           // Only this user will see the image
		                      implicit layer = 0         // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                // The opacity of the image (0: fully transparent, 1: fully visible)
		                      Color color = White        // Tint the image with this color
		                      SourceCodeLocation location
		if(!image.texture?.ensureIsAvailable()) return
		if(graphics_isVisibleFor2(visibleFor)) {
			let f = image.frames[frame % image.frames.length]
			let sizeX = size.x || f.w
			let sizeY = size.y || (sizeX/f.w)*f.h
			graphics_items.push(new DisplayImage(
				graphics_totalMatrix,
				position.x-sizeX/2,
				position.y-sizeY/2,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, image.file,
				location, position.location, size.location,
				image.texture._htmlImage,
				f.x1, f.y1, f.w, f.h,
				color
			))
		}
	
	// Draws an image on the screen
	global js void drawImage: Image image                // The image to draw
		                      Vector2 position = {}      // The position to draw to
		                      frame = 0                  // The frame of the image to draw
		                      implicit Vector2 size = {} // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                      Angle angle = 0.0          // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                      flipX = false              // Mirror the image horizontally
		                      flipY = false              // Mirror the image vertically
		                      visibleFor = -1            // Only this user will see the image
		                      implicit layer = 0         // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                // The opacity of the image (0: fully transparent, 1: fully visible)
		                      Color color = White        // Tint the image with this color
		                      SourceCodeLocation location
		if(!image.texture?.ensureIsAvailable()) return
		if(graphics_isVisibleFor(visibleFor)) {
			let f = image.frames[frame % image.frames.length]
			let sizeX = size.x || f.w
			let sizeY = size.y || (sizeX/f.w)*f.h
			let matrix = graphics_totalMatrix.clone()
			matrix.move(position)
			matrix.rotate(angle)
			if(flipX || flipY) matrix.scale(new Vector2(flipX ? -1:1, flipY ? -1:1	))
			graphics_items.push(new DisplayImage(
				matrix,
				-sizeX/2,
				-sizeY/2,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, image.file, 
				location, position.location, size.location,
				image.texture._htmlImage,
				f.x1, f.y1, f.w, f.h,
				color
			))
		}
	
	global js void drawImage: Image image                // The image to draw
		                      Vector2 position = {}      // The position to draw to
		                      frame = 0                  // The frame of the image to draw
		                      implicit Vector2 size = {} // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                      Angle angle = 0.0          // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                      flipX = false              // Mirror the image horizontally
		                      flipY = false              // Mirror the image vertically
		                      int[] visibleFor           // Only this user will see the image
		                      implicit layer = 0         // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                // The opacity of the image (0: fully transparent, 1: fully visible)
		                      Color color = White        // Tint the image with this color
		                      SourceCodeLocation location
		if(!image.texture?.ensureIsAvailable()) return
		if(graphics_isVisibleFor2(visibleFor)) {
			let f = image.frames[frame % image.frames.length]
			let sizeX = size.x || f.w
			let sizeY = size.y || (sizeX/f.w)*f.h
			let matrix = graphics_totalMatrix.clone()
			matrix.move(position)
			matrix.rotate(angle)
			if(flipX || flipY) matrix.scale(new Vector2(flipX ? -1:1, flipY ? -1:1	))
			graphics_items.push(new DisplayImage(
				matrix,
				-sizeX/2,
				-sizeY/2,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, image.file, 
				location, position.location, size.location,
				image.texture._htmlImage,
				f.x1, f.y1, f.w, f.h,
				color
			))
		}
	
	const alignmentFactor = [0, .5, 1]
	
	// Draws text on the screen
	global js void drawText: string text                        // The text to draw
		                     Vector2 position = {}              // The position to draw to
		                     implicit Vector2 size = {}         // The size of the text
		                     Color color = null                 // The color of the text
		                     HorizontalAlignment align = Center // The horizontal alignment of the text
		                     VerticalAlignment valign = Middle  // The vertical alignment of the text
		                     FontStyle style = Normal           // Whether the text should be bold or normal style
		                     Font font = null                   // The font of the text
		                     Color outlineColor = null          // The color of the outline around the text
		                     outlineWidth = 0                   // The width of the outline around the text
		                     visibleFor = -1                    // Only this user will see the image
		                     implicit layer = 0                 // Higher layers are drawn in front of lower layers
		                     alpha = 1.0                        // The opacity of the text (0: fully transparent, 1: fully visible)
		                     SourceCodeLocation location
		if(graphics_isVisibleFor(visibleFor)) {
			let effectiveFont = font || graphics_currentFont
			let fontSize = size.y || size.x || graphics_currentFontSize
			let contextFont = (style ? "bold ":"")+fontSize+"px "+effectiveFont.name;
			Platform_context.font = contextFont
			let textSize = Platform_context.measureText(text)
			let sizeX = textSize.width
			let sizeY = fontSize*effectiveFont.actualHeightFactor
			graphics_items.push(new DisplayText(
				graphics_totalMatrix, 
				position.x - graphics_alignmentFactor[ align]*sizeX,
				position.y - graphics_alignmentFactor[valign]*sizeY,
				sizeX, sizeY, 
				layer, alpha, graphics_currentClippingPath, text, 
				location, position.location, size.location,
				(color || graphics_currentColor).hex, 
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth,
				effectiveFont.offset.y*sizeY,
				contextFont
			))
		}
		
	global js void drawText: string text                        // The text to draw
		                     Vector2 position = {}              // The position to draw to
		                     implicit Vector2 size = {}         // The size of the text
		                     Color color = null                 // The color of the text
		                     HorizontalAlignment align = Center // The horizontal alignment of the text
		                     VerticalAlignment valign = Middle  // The vertical alignment of the text
		                     FontStyle style = Normal           // Whether the text should be bold or normal style
		                     Font font = null                   // The font of the text
		                     Color outlineColor = null          // The color of the outline around the text
		                     outlineWidth = 0                   // The width of the outline around the text
		                     int[] visibleFor                   // Only this user will see the image
		                     implicit layer = 0                 // Higher layers are drawn in front of lower layers
		                     alpha = 1.0                        // The opacity of the text (0: fully transparent, 1: fully visible)
		                     SourceCodeLocation location
		if(graphics_isVisibleFor2(visibleFor)) {
			let effectiveFont = font || graphics_currentFont
			let fontSize = size.y || size.x || graphics_currentFontSize
			let contextFont = (style ? "bold ":"")+fontSize+"px "+effectiveFont.name;
			Platform_context.font = contextFont
			let textSize = Platform_context.measureText(text)
			let sizeX = textSize.width
			let sizeY = fontSize*effectiveFont.actualHeightFactor
			graphics_items.push(new DisplayText(
				graphics_totalMatrix, 
				position.x - graphics_alignmentFactor[ align]*sizeX,
				position.y - graphics_alignmentFactor[valign]*sizeY,
				sizeX, sizeY, 
				layer, alpha, graphics_currentClippingPath, text, 
				location, position.location, size.location,
				(color || graphics_currentColor).hex, 
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth,
				effectiveFont.offset.y*sizeY,
				contextFont
			))
		}
		
	// Draws an image on the screen
	global void drawButton: Image image = null           // The image to draw
		                    text = ""                    // The text to draw
		                    Vector2 position = {}        // The position to draw to
		                    Color textColor = null       // The color of the text
		                    frame = 0                    // The frame of the image of the image to draw
		                    implicit Vector2 size = {}   // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                    fontSize = 18                // The font size in pixels
		                    touchMargin = Vector2(16,16) // The margin around the button within which it is touchable
		                    textOffset = Vector2(0,0)    // Draw the text at this offset
		                    showTouchArea = false        // Show the area within which the button is touchable
		                    visibleFor = -1              // Only this user will see the button
		                    implicit layer = 0           // Higher layers are drawn in front of lower layers
		                    alpha = 1.0                  // The opacity of the button (0: fully transparent, 1: fully visible)
	                        SourceCodeLocation location
		if isVisibleFor(visibleFor)
			if text:  drawText text, position+textOffset, fontSize, textColor, visibleFor, layer, alpha, location
			if image: drawImage image, position, frame, size, visibleFor, layer, alpha, location
			
	// Draws a button that consists of an image and a text
	global void drawButton: Image image = null            // The image of the button
		                    text = ""                     // The text of the button
		                    Vector2 position = {}         // The position to draw to
		                    Color textColor = null        // The color of the text
		                    frame = 0                     // The frame of the image
		                    implicit Vector2 size = {}    // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                    fontSize = 18                 // The font size in pixels   
		                    touchMargin = Vector2(16,16)  // The margin around the button within which it is touchable
		                    textOffset = Vector2(0,0)     // Draw the text at this offset
		                    showTouchArea = false         // Show the area within which the button is touchable
		                    visibleFor = -1               // Only this user will see the button
		                    clickableBy = -1              // Only this user can click the button
		                    hotkey = Key.None             // This keyboard shortcut will execute the onClick handler
		                    implicit layer = 0            // Higher layers are drawn in front of lower layers
		                    alpha = 1.0                   // The opacity of the button 0: fully transparent, 1: fully visible)
		                    void(Touch touch) onClick     // Execute this code when the user clicks the button or presses the hotkey
	                        SourceCodeLocation location
		if isVisibleFor(visibleFor)
			if text:  drawText text, position+textOffset, fontSize, textColor, visibleFor, layer, alpha, location
			if image: drawImage image, position, frame, size, visibleFor, layer, alpha, location
			
		// Handle click (only visible buttons are clickable)
		int[] effectiveClickableBy = getClickableBy(visibleFor, clickableBy)
		Vector2 effectiveSize = image ? getEffectiveSize(image.size, size) : {getTextWidth(text), fontSize}
		Input.onTouchDownWithin position, effectiveSize + touchMargin, userId:effectiveClickableBy, showTouchArea
			onClick touch
		if hotkey
			Input.onKeyDown hotkey, userId:effectiveClickableBy
				onClick null
			
	global void drawButton: Image image = null            // The image of the button
		                    text = ""                     // The text of the button
		                    Vector2 position = {}         // The position to draw to
		                    Color textColor = null        // The color of the text
		                    frame = 0                     // The frame of the image
		                    implicit Vector2 size = {}    // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                    fontSize = 18                 // The font size in pixels   
		                    textOffset = Vector2(0,0)     // Draw the text at this offset
		                    touchMargin = Vector2(16,16)  // The margin around the button within which it is touchable
		                    showTouchArea = false         // Show the area within which the button is touchable
		                    int[] visibleFor = null       // Only this user will see the button
		                    int[] clickableBy = null      // Only this user can click the button
		                    hotkey = Key.None             // This keyboard shortcut will execute the onClick handler
		                    implicit layer = 0            // Higher layers are drawn in front of lower layers
		                    alpha = 1.0                   // The opacity of the button 0: fully transparent, 1: fully visible)
		                    void(Touch touch) onClick     // Execute this code when the user clicks the button or presses the hotkey
	                        SourceCodeLocation location
		if isVisibleFor(visibleFor)
			if text:  drawText text, position+textOffset, fontSize, textColor, visibleFor, layer, alpha, location
			if image: drawImage image, position, frame, size, visibleFor, layer, alpha, location
			
		// Handle click (only visible buttons are clickable)
		int[] effectiveClickableBy = getClickableBy(visibleFor, clickableBy)
		Vector2 effectiveSize = image ? getEffectiveSize(image.size, size) : {getTextWidth(text), fontSize}
		Input.onTouchDownWithin position, effectiveSize + touchMargin, userId:effectiveClickableBy, showTouchArea
			onClick touch
		if hotkey
			Input.onKeyDown hotkey, userId:effectiveClickableBy
				onClick null
			
	// Draws a rectangle on the screen
	global js void drawRectangle: position = Vector2()               // The center of the rectangle
		                          implicit size = Vector2(256,256)   // The size of the rectangle, use a float to draw a square, use a vector to draw a rectangle
		                          Color fillColor = null             // The color of the area within the rectangle
		                          Color outlineColor = null          // The color of the outline around the rectangle
		                          outlineWidth = 0                   // The width of the outline around the rectangle
		                          visibleFor = -1                    // Only this user will see the rectangle
		                          implicit layer = 0                 // Higher layers are drawn in front of lower layers
		                          alpha = 1.0                        // The opacity of the rectange 0: fully transparent, 1: fully visible)
		                          HorizontalAlignment align = Center // The horizontal alignment of the rectangle
		                          VerticalAlignment valign = Middle  // The vertical alignment of the rectangle
		                          SourceCodeLocation location
		if(graphics_isVisibleFor(visibleFor)) {
			let sizeX = size.x
			let sizeY = size.y || size.x
			graphics_items.push(new DisplayRectangle(
				graphics_totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX,
				valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, "Rectangle", 
				location, position.location, size.location,
				fillColor || !outlineColor ? (fillColor || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	global js void drawRectangle: position = Vector2()               // The center of the rectangle
		                          implicit size = Vector2(256,256)   // The size of the rectangle, use a float to draw a square, use a vector to draw a rectangle
		                          Color fillColor = null             // The color of the area within the rectangle
		                          Color outlineColor = null          // The color of the outline around the rectangle
		                          outlineWidth = 0                   // The width of the outline around the rectangle
		                          int[] visibleFor                   // Only this user will see the rectangle
		                          implicit layer = 0                 // Higher layers are drawn in front of lower layers
		                          alpha = 1.0                        // The opacity of the rectange 0: fully transparent, 1: fully visible)
		                          HorizontalAlignment align = Center // The horizontal alignment of the rectangle
		                          VerticalAlignment valign = Middle  // The vertical alignment of the rectangle
		                          SourceCodeLocation location
		if(graphics_isVisibleFor2(visibleFor)) {
			let sizeX = size.x
			let sizeY = size.y || size.x
			graphics_items.push(new DisplayRectangle(
				graphics_totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX,
				valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, "Rectangle", 
				location, position.location, size.location,
				fillColor || !outlineColor ? (fillColor || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	// Draws a circle on the screen
	global js void drawCircle: position = Vector2()       // The center of the circle
		                       implicit Vector2 size = {256,256} // The size of the circle, use a float to draw a circle, use a vector draw an ellipse
		                       Color fillColor = null     // The color of the area within the circle
		                       Color outlineColor = null  // The color of the outline around the circle
		                       outlineWidth = 0           // The width of the outline around the circle
		                       Angle startAngle = -.25    // Draws an arc with this start angle in turns, measured from the positive x-axis
		                       Angle angle = 1.0          // Draws an arc with this angle in turns (0.25: quarter circle, 0.5: half circle, 1: full circle)
		                       RotationDirection direction = Clockwise // The circle is drawn in this direction
		                       visibleFor = -1            // Only this user will see the circle
		                       implicit layer = 0         // Higher layers are drawn in front of lower layers
		                       alpha = 1.0                // The opacity of the circle (0: fully transparent, 1: fully visible)
		                       SourceCodeLocation location
		if(graphics_isVisibleFor(visibleFor)) {
			let sizeX = size.x, sizeY = size.y || size.x
			graphics_items.push(new DisplayCircle(
				graphics_totalMatrix, 
				position.x - sizeX/2, 
				position.y - sizeY/2, 
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, "Circle", 
				location, position.location, size.location,
				startAngle, angle,
				direction == 1,
				fillColor || !outlineColor ? (fillColor || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	global js void drawCircle: position = Vector2()      // The center of the circle
		                       implicit Vector2 size = {256,256} // The size of the circle, use a float to draw a circle, use a vector draw an ellipse
		                       Color fillColor = null    // The color of the area within the circle
		                       Color outlineColor = null // The color of the outline around the circle
		                       outlineWidth = 0          // The width of the outline around the circle
		                       Angle startAngle = -.25   // Draws an arc with this start angle in turns, measured from the positive x-axis
		                       Angle angle = 1.0         // Draws an arc with this angle in turns (0.25: quarter circle, 0.5: half circle, 1: full circle)
		                       RotationDirection direction = Clockwise // The circle is drawn in this direction
		                       int[] visibleFor          // Only this user will see the circle
		                       implicit layer = 0        // Higher layers are drawn in front of lower layers
		                       alpha = 1.0               // The opacity of the circle (0: fully transparent, 1: fully visible)
		                       SourceCodeLocation location
		if(graphics_isVisibleFor2(visibleFor)) {
			let sizeX = size.x, sizeY = size.y || size.x
			graphics_items.push(new DisplayCircle(
				graphics_totalMatrix, 
				position.x - sizeX/2, 
				position.y - sizeY/2, 
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, "Circle", 
				location, position.location, size.location,
				startAngle, angle,
				direction == 1,
				fillColor || !outlineColor ? (fillColor || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	// Draws a texture on the screen
	global js void drawTexture: Texture texture              // The texture to draw
		                        Vector2 position = {}        // The position to draw to
		                        implicit Vector2 size = {}   // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                        visibleFor = -1              // Only this user will see the texture
		                        implicit int layer = 0       // Higher layers are drawn in front of lower layers
		                        alpha = 1.0                  // The opacity of the texture (0: fully transparent, 1: fully visible)
		                        Color color = White        // Tint the image with this color
		if(!texture?.ensureIsAvailable()) return
		if(graphics_isVisibleFor(visibleFor)) {
			let sizeX = size.x || texture.size.x
			let sizeY = size.y || (sizeX/texture.size.x)*texture.size.y
			graphics_items.push(new DisplayImage(
				graphics_totalMatrix,
				position.x - sizeX/2,
				position.y - sizeY/2,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, texture.file,
				location, position.location, size.location,
				texture._htmlImage,
				0, 0, texture.size.x, texture.size.y,
				color
			))
		}

	// Draws a texture on the screen
	global js void drawTexture: Texture texture             // The texture to draw
		                        Vector2 position = {}       // The target position to draw to
		                        Vector2 size = {}           // The target size of the area to draw
		                        Vector2 sourcePosition = {} // The center of the area of the source texture
		                        Vector2 sourceSize = {}     // The size of the area of the source texture
		                        visibleFor = -1             // Only this user will see the texture
		                        implicit int layer = 0      // Higher layers are drawn in front of lower layers
		                        alpha = 1.0                 // The opacity of the texture (0: fully transparent, 1: fully visible)
		                        Color color = White        // Tint the image with this color
		if(!image.texture?.ensureIsAvailable()) return
		if(graphics_isVisibleFor(visibleFor)) {
			let sizeX = size.x || texture.size.x
			let sizeY = size.y || (sizeX/texture.size.x)*texture.size.y
			graphics_items.push(new DisplayImage(
				graphics_totalMatrix,
				position.x - sizeX/2,
				position.y - sizeY/2,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, texture.file, 
				location, position.location, size.location,
				texture._htmlImage,
				sourcePosition.x+texture.size.x/2-sourceSize.x/2,
				sourcePosition.y+texture.size.y/2-sourceSize.y/2,
				sourceSize.x, 
				sourceSize.y,
				color
			))
		}
		
	// Draws a polygon on the screen
	global js void drawPolygon: Vector2[] points           // A list of points for the polygon
		                        Vector2 position = {0,0}   // The position all points are relative to 
		                        Color fillColor = null     // The color of the area within the polygon
		                        Color outlineColor = null  // The color of the outline around the polygon
		                        outlineWidth = 0           // The width of the outline around the polygon
		                        smooth = false             // Smooth the corners of the polygon
		                        visibleFor = -1            // Only this user will see the polygon
		                        implicit int layer = 0     // Higher layers are drawn in front of lower layers
		                        alpha = 1.0                // The opacity of the polygon (0: fully transparent, 1: fully visible)
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayPolygon(
				graphics_totalMatrix,
				position.x, position.y,
				0, 0,
				layer, alpha, graphics_currentClippingPath, "Polygon", 
				location, position.location, null,
				points,
				fillColor || !outlineColor ? (fillColor || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth,
				smooth, /*close*/true
			))
		}
		
	// Draws a rectangle with rounded corners on the screen
	global js void drawRoundedRectangle: position = Vector2()               // The center of the rectangle
		                                 implicit size = Vector2(256,256)   // The size of the rectangle, use a float to draw a square, use a vector to draw a rectangle
		                                 radius = 32                        // The radius of the rounded corners
		                                 Color fillColor = null             // The color of the area within the rectangle
		                                 Color outlineColor = null          // The color of the outline around the rectangle
		                                 outlineWidth = 0                   // The width of the outline around the rectangle
		                                 visibleFor = -1                    // Only this user will see the rectangle
		                                 implicit int layer = 0             // Higher layers are drawn in front of lower layers
		                                 alpha = 1.0                        // The opacity of the rectangle (0: fully transparent, 1: fully visible)
		                                 HorizontalAlignment align = Center // The horizontal alignment of the rectangle
		                                 VerticalAlignment valign = Middle  // The vertical alignment of the rectangle
		if(graphics_isVisibleFor(visibleFor)) {
			let sizeX = size.x
			let sizeY = size.y || size.x
			graphics_items.push(new DisplayRoundedRectangle(
				graphics_totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX,
				valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, "RoundedRectangle", 
				location, position.location, size.location,
				radius,
				fillColor || !outlineColor ? (fillColor || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	// Draws a line on the screen
	global js void drawLine: Vector2 from           // The point to start the line from
		                     nocolon Vector2 to     // The point to draw the line to
		                     Color color = null     // The color of the outline around the line
		                     width = 0              // The width of the outline around the line
		                     visibleFor = -1        // Only this user will see the line
		                     implicit int layer = 0 // Higher layers are drawn in front of lower layers
		                     alpha = 1.0            // The opacity of the line (0: fully transparent, 1: fully visible)
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayLine(
				graphics_totalMatrix,
				from.x, from.y,
				to.x - from.x, to.y - from.y,
				layer, alpha, graphics_currentClippingPath, "Line", 
				location, from.location, null,
				to,
				(color || graphics_currentColor).hex,
				width || graphics_currentLineWidth
			))
		}
		
	// Draws a continuous stroke of lines
	global js void drawLines: Vector2[] points       // A list of points for the line
		                      Vector2 position = {}  // The position all points are relative to 
		                      Color color = null     // The color of the line
		                      width = 0              // The width of the line
		                      smooth = false         // Smooth the corners of the line
		                      visibleFor = -1        // Only this user will see the line
		                      implicit int layer = 0 // Higher layers are drawn in front of lower layers
		                      alpha = 1.0            // The opacity of the lines (0: fully transparent, 1: fully visible)
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayPolygon(
				graphics_totalMatrix,
				position.x, position.y,
				0, 0,
				layer, alpha, graphics_currentClippingPath, "Line", 
				location, position.location, null,
				points,
				null, // no fill color, because we want to draw a line instead of a polygon
				(color || graphics_currentColor).hex,
				width || graphics_currentLineWidth,
				smooth, /*close*/false
			))
		}
		
		
	// Clears all pixels within a rectangle
	global js void clearRectangle: position = Vector2()             // The position of the rectangle to clear
		                           implicit size = Vector2(256,256) // The size of the rectangle, use a float to clear a square, use a vector to clear a rectangle
		                           visibleFor = -1                  // Only clear the rectangle for this user
		                           implicit layer = 0               // Higher layers are process after lower layers
		if(graphics_isVisibleFor(visibleFor)) {
			let sizeX = size.x
			let sizeY = size.y || size.x
			graphics_items.push(new DisplayRectangle(
				graphics_totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX,
				valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, "Clear", 
				location, position.location, size.location,
				"clear", null, 0
			))
		}
		
	const Color[] defaultColors = [{"398CA9"},{"C01352"},{"16C66E"},{"FFD166"}]
	setUserColor: int userId
		          Color color = null
		let user = Input.usersById[userId]
			user.color = color || defaultColors[user.index]
		
	global drawPointer: int userId
		                Color color = null
		                bool showLocalPointer = Input.showLocalPointer
		if userId != Input.localUser.id or showLocalPointer
			let user = Input.usersById[userId]
				if !color: color = user.color
				for user.touches
					drawImage finger, .smoothPosition+{11,32}, frame:.isDown ? 1 : 0, layer:int.maxValue
					if color
						if color == Black
							drawRectangle .smoothPosition+{16,80}, size:{26,10}, color, layer:int.maxValue, outlineColor:{"a0a0a0"}, outlineWidth:2
						else
							drawRectangle .smoothPosition+{16,78}, size:{26,10}, color, layer:int.maxValue

	global drawVideo: int userId
		              Vector2 position = {}
		              implicit Vector2 size = {440}
		              VideoShape shape = Rectangle
		              visibleFor = -1      // Only clear the rectangle for this user
		              implicit layer = 0   // Higher layers are process after lower layers
		              SourceCodeLocation location
		if isVisibleFor(visibleFor)
			if not size.y: size.y = shape == Rectangle ? size.x * 3/4 : size.x
			if Network.mode == Local or !PeerNetwork.enableVideo
				NetworkUser user = Input.usersById[userId]
				drawImage VideoScreen, position, size, frame:shape == Circle ? 1:0, layer:1000000, location
			else
				items.add DisplayVideo(
					m: totalMatrix,
					x: position.x, y: position.y,
					w: size.x,     h: size.y,
					layer, alpha:1.0, currentClippingPath, "Video",
					userId, shape
				)
				
	global drawVideo: int userId
		              Vector2 position = {}
		              implicit Vector2 size = {440, 330}
		              VideoShape shape = Rectangle
		              int[] visibleFor          // Only clear the rectangle for this user
		              implicit layer = 0        // Higher layers are process after lower layers
		if isVisibleFor(visibleFor)
			if not size.y: size.y = size.x * 3/4
			if Network.mode == Local or !PeerNetwork.enableVideo
				NetworkUser user = Input.usersById[userId]
				drawImage VideoScreen, position, size, frame:0, layer:1000000
			else
				items.add DisplayVideo(
					m: totalMatrix,
					x: position.x, y: position.y,
					w: size.x,     h: size.y,
					layer, alpha:1.0, currentClippingPath, "Video",
					userId, shape
				)

struct GizomInfluence
	string file
	int start
	int end
	float[] deltas
	float[] initialValues
	string label

struct GizmoOverItem
	DisplayItem item
	SourceCodeLocation location
	
skipInit unit gizmo
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
		handleSize = Math.map Math.min(max.x-min.x, max.y-min.y) 64..256 start:16 target:32
	
	internal tick
		findInfluencedItems
		
		if items
			// Draw handles
			let size = max - min
			let center = (max + min)/2 
			for Direction.allDirections
				drawImage ResizeHandle, center + size/2*.vector, size:handleSize, location:null, layer:int.maxValue
				
			// Draw selection
			drawRectangle center, size:max-min, outlineColor:{"437FDF"}, outlineWidth:4, location:null, layer:int.maxValue
			
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
	
	internal onTouch: InputType inputType, int id, Vector2 pixelPos, Vector2 referencePos, shift = false, alt = false, cmdOrCtrl = false	
		if Platform.mode != Manipulator: return
		let movedSinceTouchDown = (referencePos manhattanDistanceTo touchDownPos) > 8
		let insideGizmo = referencePos >= gizmo.min and referencePos <= gizmo.max
		if inputType == TouchDown: touchDownPos = referencePos; touchDownInsideGizmo = insideGizmo; else
		if inputType == TouchUp:   touchDownPos = Vector2.none; isManipulating = false
			
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
			if (inputType == TouchDown and !insideGizmo)
			or (inputType == TouchUp and touchDownInsideGizmo and !movedSinceTouchDown)
			
				// Collect all items and locations the mouse pointer is over
				GizmoOverItem[] overItems
				for graphics.items -> item
					if pixelPos.isInsidePoygon item.poly
						if item.positionLocation: flattenLocations overItems, item, item.positionLocation; else
						if item.location:         overItems.add {item, item.location}
									
				if overItems.length
					// Select next item cycling through all items the mouse pointer is over
					if inputType == TouchDown: locationIndex = 0
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
			if inputType == TouchMove and touchDownPos and codeId >= waitingForCodeId
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
		
transient class DisplayItem
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
			Platform_context.beginPath();
			Platform_context.moveTo(firstPos.x, firstPos.y)
			for(let p of points) Platform_context.lineTo(p.x, p.y)
			if(this.clippingPath.show) {
				Platform_context.fillStyle = "#ff000080"
				Platform_context.fill()
			}
			Platform_context.save()
			Platform_context.clip()
		}
		
	js void endClipping
		if(this.clippingPath.points.length >= 2)
			Platform_context.restore()
			
transient DisplayItem DisplayImage
	object htmlImage
	float sx, sy, sw, sh
	Color color
	js void draw
		if(this.alpha == 0) return
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		Platform_context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
			
		if(this.color.hex == "#ffffff") {
			try{ Platform_context.drawImage(this.htmlImage, this.sx, this.sy, this.sw, this.sh, this.x, this.y, this.w, this.h) }
			catch(e) { log("DisplayImage: "+e.message) }
		} else {
			// Create offscreen buffer
	        let offscreenCanvas = document.createElement('canvas');
	        offscreenCanvas.width = this.sw;
	        offscreenCanvas.height = this.sh;
	        let offscreenContext = offscreenCanvas.getContext('2d');
			
			// Draw image
			offscreenContext.drawImage(this.htmlImage, this.sx, this.sy, this.sw, this.sh, 0, 0, this.sw, this.sh)
			
			// Multiply tint color
			offscreenContext.fillStyle = this.color.hex;
			offscreenContext.globalCompositeOperation = 'multiply';
			offscreenContext.fillRect(0, 0, buffer.width, buffer.height);
			
			// Apply alpha
			offscreenContext.globalAlpha = 1;
			offscreenContext.globalCompositeOperation = 'destination-in';
			offscreenContext.drawImage(this.htmlImage, this.sx, this.sy, this.sw, this.sh, 0, 0, this.sw, this.sh)
				
			// Draw tinted image
	        Platform_context.drawImage(buffer, this.x, this.y, this.w, this.h);		
		}
		
		if(this.clippingPath) this.endClipping()

transient DisplayItem DisplayText
	string fillStyle, outlineColor
	float outlineWidth
	float offsetY
	string font
	js void draw
		if(this.alpha == 0) return
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		Platform_context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
			
		Platform_context.font = this.font
		if(this.outlineColor) {
			Platform_context.lineWidth = this.outlineWidth
			Platform_context.strokeStyle = this.outlineColor
			Platform_context.strokeText(this.name, this.x, this.y)
		}
		Platform_context.fillStyle = this.fillStyle
		Platform_context.fillText(this.name, this.x, this.y - this.offsetY)
		
		if(this.clippingPath) this.endClipping()
		
transient DisplayItem DisplayRectangle
	string fillColor, outlineColor
	float outlineWidth
	js void draw
		if(this.alpha == 0) return
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		Platform_context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
			
		if(this.fillColor == "clear") {
			Platform_context.clearRect(this.x, this.y, this.w, this.h)
		}
		else
		if(this.fillColor) {
			Platform_context.fillStyle = this.fillColor
			Platform_context.fillRect(this.x, this.y, this.w, this.h)
		}
		if(this.outlineColor) {
			Platform_context.lineWidth = this.outlineWidth
			Platform_context.strokeStyle = this.outlineColor
			Platform_context.strokeRect(this.x, this.y, this.w, this.h)
		}
		if(this.clippingPath) this.endClipping()
		
transient DisplayItem DisplayRoundedRectangle
	float radius
	string fillColor, outlineColor
	float outlineWidth
	js void draw
		if(this.alpha == 0) return
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		Platform_context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
		let sizeX = this.w, sizeY = this.h, x = this.x, y = this.y, radius = this.radius
		
		// Arcs
		Platform_context.beginPath();
		Platform_context.moveTo(x + radius, y);
		Platform_context.lineTo(x + sizeX - radius, y);
		Platform_context.arcTo(x + sizeX, y, x + sizeX, y + radius, radius);
		Platform_context.lineTo(x + sizeX, y + sizeY - radius);
		Platform_context.arcTo(x + sizeX, y + sizeY, x + sizeX - radius, y + sizeY, radius);
		Platform_context.lineTo(x + radius, y + sizeY);
		Platform_context.arcTo(x, y + sizeY, x, y + sizeY - radius, radius);
		Platform_context.lineTo(x, y + radius);
		Platform_context.arcTo(x, y, x + radius, y, radius);
		Platform_context.closePath();
		
		// Quadratic Curves
		// Platform_context.beginPath();
		// Platform_context.moveTo(x + radius, y);
		// Platform_context.lineTo(x + sizeX - radius, y);
		// Platform_context.quadraticCurveTo(x + sizeX, y, x + sizeX, y + radius);
		// Platform_context.lineTo(x + sizeX, y + sizeY - radius);
		// Platform_context.quadraticCurveTo(x + sizeX, y + sizeY, x + sizeX - radius, y + sizeY);
		// Platform_context.lineTo(x + radius, y + sizeY);
		// Platform_context.quadraticCurveTo(x, y + sizeY, x, y + sizeY - radius);
		// Platform_context.lineTo(x, y + radius);
		// Platform_context.quadraticCurveTo(x, y, x + radius, y);
		// Platform_context.closePath();
		
		if(this.fillColor) {
			Platform_context.fillStyle = this.fillColor
			Platform_context.fill()
		}
		if(this.outlineColor) {
			Platform_context.lineWidth = this.outlineWidth
			Platform_context.strokeStyle = this.outlineColor
			Platform_context.stroke()
		}
		if(this.clippingPath) this.endClipping()
		
transient DisplayItem DisplayPolygon
	Vector2[] points
	string fillColor, outlineColor
	float outlineWidth
	bool smooth, close
	js void draw
		if(this.points.length < 2 || this.alpha == 0) return
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		Platform_context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
		let x = this.x, y = this.y
		let points = this.points, startPoint = points[0]
		
		Platform_context.beginPath();
		Platform_context.moveTo(x + startPoint.x, y + startPoint.y)
		
		if(!this.smooth || points.length < 3) {
			for(let i=1, len = points.length; i<len; ++i) {
				let p = points[i]
				Platform_context.lineTo(x + p.x, y + p.y)
			}
		} else {
			for(var i = 1, len = points.length - 2; i<len; i++)
			{
				let p1 = points[i], p2 = points[i + 1]
				Platform_context.quadraticCurveTo(p1.x, p1.y, (p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
			}
			let p1 = points[i], p2 = points[i + 1]
			Platform_context.quadraticCurveTo(p1.x, p1.y, p2.x,p2.y);
		}
		if(this.close) {
			Platform_context.closePath()
		}
		if(this.fillColor) {
			// Close the polygon and fill it
			Platform_context.lineTo(x + startPoint.x, y + startPoint.y)
			Platform_context.fillStyle = this.fillColor
			Platform_context.fill()
		}
		if(this.outlineColor) {
			// Draw outline
			Platform_context.lineWidth = this.outlineWidth
			Platform_context.strokeStyle = this.outlineColor
			Platform_context.stroke()
		}
		if(this.clippingPath) this.endClipping()
		
enum RotationDirection: Clockwise, CounterClockwise
		
transient DisplayItem DisplayCircle
	float startAngle, angle
	RotationDirection direction
	string fillColor, outlineColor
	float outlineWidth
	js void draw
		if(this.alpha == 0) return
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		Platform_context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
			
		Platform_context.beginPath();
		if(this.w == this.h) {
			let radius = this.w/2
			if(this.angle == 1) {
				Platform_context.arc(this.x+radius, this.y+radius, radius, 0, Math_TwoPI, this.direction);
			} else {
				Platform_context.arc(this.x+radius, this.y+radius, radius, this.startAngle*Math_TwoPI, (this.startAngle+this.angle)*Math_TwoPI, this.direction);
			}
		} else {
			let radiusX = this.w/2
			let radiusY = this.h/2
			Platform_context.ellipse(this.x+radiusX, this.y+radiusY, radiusX, radiusY, this.startAngle*Math_TwoPI, (this.startAngle+this.angle)*Math_TwoPI, this.direction);
		}
		if(this.fillColor) {
			Platform_context.fillStyle = this.fillColor
			Platform_context.fill()
		}
		if(this.outlineColor) {
			Platform_context.lineWidth = this.outlineWidth
			Platform_context.strokeStyle = this.outlineColor
			Platform_context.stroke()
		}
		if(this.clippingPath) this.endClipping()
		
transient DisplayItem DisplayLine
	Vector2 end
	string outlineColor
	float outlineWidth
	js void draw
		if(this.alpha == 0) return
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		Platform_context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
		
		Platform_context.beginPath();
		Platform_context.moveTo(this.x,this.y)
		Platform_context.lineTo(this.end.x, this.end.y)
		Platform_context.lineWidth = this.outlineWidth
		Platform_context.strokeStyle = this.outlineColor
		Platform_context.stroke()
		
		if(this.clippingPath) this.endClipping()
			
transient DisplayItem DisplayVideo
	int userId
	VideoShape shape
	draw
		InternalUser user = Input.internalUsers[userId]
			let videoElement = user.videoElements[user.videoElementIndex]
			               or (user.videoElements[user.videoElementIndex] = PeerNetwork.createVideoElement(user.mediaStream, user.local))
			
			let px = (m0 * x + m2 * y + m4) / Platform.pixelRatio
			let py = (m1 * x + m3 * y + m5) / Platform.pixelRatio
			let sizeX = w*m0 / Platform.pixelRatio
			let sizeY = h*m3 / Platform.pixelRatio
			PeerNetwork.updateVideoElement videoElement, px, py, sizeX, sizeY, radius:shape == Circle ? 10000 : 0
			user.videoElementIndex++


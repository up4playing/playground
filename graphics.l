// A color comprised of a red, green, blue and alpha component
class Color
	global const Color White   = {"ffffff", "White"}
	global const Color Black   = {"000000", "Black"}
	global const Color Red     = {"ef476f", "Red"}
	global const Color Yellow  = {"ffd166", "Yellow"}
	global const Color Green   = {"06d6a0", "Green"}
	global const Color Blue    = {"118ab2", "Blue"}
	global const Color Gray    = {"3d3d3d", "Gray"}
	global const Color TransparentRed   = {"ff000080", "Transparent Red"}
	string hex
	string name
	
	string toString := name or hex
	
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
				image = new Image()
				image.onload = e => {
					this._htmlImage = image
					window._htmlImageCache[this.file] = image
					this.size = new Vector2(image.width, image.height, null)
					resolve(this);
				}
				image.src = this.file.startsWith("http") ? this.file : _basePath+this.file
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
	string file
	Texture texture
	Vector2 size
	ImageFrame[] frames
	
enum HorizontalAlignment: Left, Center, Right
enum VerticalAlignment: Top, Middle, Bottom
enum FontStyle: Normal, Bold
class ClippingPath: Vector2[] points; bool show
		
// Draw on the screen
transient global unit graphics
	internal Matrix2D totalMatrix, localMatrix
	internal DisplayItem[] items
		
	private const alignmentFactor = [0, .5, 1]
		
	internal js void startFrame
		graphics_reset()
		if(!Platform_fastForward && !Platform_waitingForInitialData)
			if(!graphics_backgroundColor || graphics_backgroundColor.hex == "#000000") {
				Platform_context.clearRect(0, 0, Platform_pixelSize.x, Platform_pixelSize.y)
			} else {
				Platform_context.fillStyle = graphics_backgroundColor.hex
				Platform_context.fillRect(0, 0, Platform_pixelSize.x, Platform_pixelSize.y)
			}
			Platform_context.textBaseline = "top"


	internal reset
		totalMatrix = Platform.baseMatrix
		localMatrix.clear
		currentlyVisibleFor = null
		items.clear

	internal finishFrame
		if(Platform.fastForward) return
		for input.internalUsers if .
			.videoElementIndex = 0
		drawItems
		drawSafeArea
		for input.internalUsers -> user if .
			for user.videoElementIndex to user.videoElements.length
				PeerNetwork.removeVideoElement user.videoElements[.]
			user.videoElements.setLength user.videoElementIndex
			PeerNetwork.setAudioMuted user.audioElement, muted:core.muteInvisibleUsers and user.videoElementIndex == 0
		
	private drawItems
		core.displayItems = items.length
		gizmo.tick
		items.sort b.layer - a.layer
		items.each <- .draw
		resetTransform
		
	private js void resetTransform
		Platform_context.resetTransform()
		Platform_context.globalAlpha = 1
				
	private isVisibleFor: Player[] visibleFor
		if(Platform.fastForward) return false
		let effectiveVisibleFor = visibleFor or currentlyVisibleFor
		return effectiveVisibleFor == null or effectiveVisibleFor.any.id == input.localUser.id
		
	private Player[] getClickableBy: Player[] visibleFor, Player[] clickableBy
		Player[] effectiveVisibleBy = visibleFor or currentlyVisibleFor
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
		
	// ------------------------------------------------------- Image -------------------------------------------------------
	
	// Draw an image. Place a PNG file in the "media" folder and it will automatically be imported
	// Example: We place an image called "Idle.png" in the "media" folder. Then, we draw this image at the position {0,0}, scale it to a width of 32 pixels and make it visible for the current player instance.
	//     Player
	//         tick
	//             drawImage Idle, position:{0,0}, size:32, frame:0, visibleFor:me
	// Image: drawImage0.png
	global js void drawImage: Image image                         // The image to draw. PNG images in the "media" folder will automatically show up here.
		                      Vector2 position = {}               // The position to draw to
		                      implicit Vector2 size = {}          // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                      frame = 0                           // The frame of the image to draw
		                      implicit Player[] visibleFor = null // Only this player or list of players will see the image
		                      implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                         // The opacity of the image (0: fully transparent, 1: fully visible)
		                      Color color = White                 // Tint the image with this color (white for no tint)
		                      HorizontalAlignment align = Center  // The horizontal alignment of the image
		                      VerticalAlignment valign = Middle   // The vertical alignment of the image
		                      SourceCodeLocation location
		if(!image.texture?.ensureIsAvailable()) return
		if(graphics_isVisibleFor(visibleFor)) {
			let f = image.frames[frame % image.frames.length]
			let sizeX = size.x || f.w
			let sizeY = size.y || (sizeX/f.w)*f.h
			graphics_items.push(new DisplayImage(
				graphics_totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX,
				valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY,
				sizeX, sizeY,
				layer, alpha, graphics_currentClippingPath, image.file,
				location, position.location, size.location,
				image.texture._htmlImage,
				f.x1, f.y1, f.w, f.h,
				color
			))
		}
	
	// Draw image and rotate it or flip it vertially or horizontally
	// Example: Draw the image "Idle" at the position {0,0} and rotate it by 45.
	//     Player
	//         tick
	//             drawImage Idle, position:{0,0}, angle:45°
	// Image: drawImage1.png
	global js void drawImage: Image image                         // The image to draw
		                      Vector2 position = {}               // The position to draw to
		                      frame = 0                           // The frame of the image to draw
		                      implicit Vector2 size = {}          // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                      Angle angle = 0.0                   // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                      flipX = false                       // Mirror the image horizontally
		                      flipY = false                       // Mirror the image vertically
		                      implicit Player[] visibleFor = null // Only this player or list of players will see the image
		                      implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                         // The opacity of the image (0: fully transparent, 1: fully visible)
		                      Color color = White                 // Tint the image with this color (white for no tint)
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

	// Play an animation with a given number of frames per second
	// Example: We place a sequence of images called "Walk0.png", "Walk1.png", "Walk2.png", ... in the "media" folder. Then, we play this sequence with 10 frames per second.
	//     Player
	//         tick
	//             drawImage Walk, position:{0,0}, framesPerSecond:10
	// Image: drawImage2.gif
	global void drawImage: Image image                         // The image to draw
		                   Vector2 position = {}               // The position to draw to
		                   framesPerSecond = 0                 // Animate the image with this speed
		                   implicit Vector2 size = {}          // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                   implicit Player[] visibleFor = null // Only this player or list of players will see the image
		                   implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                   alpha = 1.0                         // The opacity of the image (0: fully transparent, 1: fully visible)
		                   Color color = White                 // Tint the image with this color (white for no tint)
		                   SourceCodeLocation location
		var frame = math.floor(core.frame * math.max(framesPerSecond, 0) / core.targetFps) % image.frames.length;
		drawImage image, position, frame, size, visibleFor, layer, alpha, color, location
	
	// Draw an image, animate it and flip it horizontally or vertically
	// Example: Play the animation "Walk" with 10 frames per second and flip each frame horizontally.
	//     Player
	//         tick
	//             drawImage Walk, position:{0,0}, framesPerSecond:10, flipX:true
	// Image: drawImage3.gif
	global void drawImage: Image image                          // The image to draw
		                   Vector2 position = {}                // The position to draw to
		                   framesPerSecond = 0                  // Animate the image with this speed
		                   implicit Vector2 size = {}           // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                   Angle angle = 0.0                    // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                   flipX = false                        // Mirror the image horizontally
		                   flipY = false                        // Mirror the image vertically
		                   implicit Player[] visibleFor = null  // Only this player or list of players will see the image
		                   implicit int layer = 0               // Higher layers are drawn in front of lower layers
		                   alpha = 1.0                          // The opacity of the image (0: fully transparent, 1: fully visible)
		                   Color color = White                  // Tint the image with this color (white for no tint)
		                   SourceCodeLocation location
		var frame = math.floor(core.frame * math.max(framesPerSecond, 0) / core.targetFps) % image.frames.length;
		drawImage image, position, frame, size, angle, flipX, flipY, visibleFor, layer, alpha, color, location
	
	// Draw an image and execute code when the player touches or clicks the image
	// Example: If the current player instance clicks the image or 16 pixels around it, we print the exact position that was clicked. If other players will click the image, nothing will happen.
	//     Player
	//         tick
	//             drawImage Idle, position:{0,0}, touchMargin:{16,16}, clickableBy:me
	//                 print "The image was clicked at {touch.position}"
	// Image: drawImage0.png
	global void drawImage: Image image                          // The image to draw
		                   Vector2 position = {}                // The position to draw to
		                   frame = 0                            // The frame of the image to draw
		                   implicit Vector2 size = {}           // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                   Angle angle = 0.0                    // Rotate the image by this angle in turns (0: no rotation, 1: one full rotation)
		                   touchMargin = Vector2(16,16)         // The margin around the button within which it is touchable
		                   showTouchArea = false                // Show the area within which the button is touchable
		                   implicit Player[] visibleFor = null  // Only this player or list of players will see the button
		                   implicit Player[] clickableBy = null // Only this player or list of players can click the button
		                   hotkey = Key.None                    // This keyboard shortcut will execute the onClick handler
		                   implicit layer = 0                   // Higher layers are drawn in front of lower layers
		                   alpha = 1.0                          // The opacity of the button 0: fully transparent, 1: fully visible)
		                   Color color = White                  // Tint the image with this color (white for no tint)
		                   void(Touch touch) onClick            // Execute this code when the user clicks on the image or presses the hotkey
		                   SourceCodeLocation location
		drawImage image, position, frame, size, angle, visibleFor, layer, alpha, color, location
			
		// Handle click (only visible buttons are clickable)
		let effectiveClickableBy = getClickableBy(visibleFor, clickableBy)
		if size.x == 0 and size.y == 0: size = image.size
		input.onTouchDownWithin position, size + touchMargin, by:effectiveClickableBy, showTouchArea, do:onClick
		if hotkey
			input.onKeyDown hotkey, by:effectiveClickableBy
				onClick null
		
	// ------------------------------------------------------- Text -------------------------------------------------------
	
	// Draw text on the screen
	// Example: If the current player instance clicks the image or 16 pixels around it, we print the exact position that was clicked. If other players will click the image, nothing will happen. To use a custom font, just copy a TTF, WOFF or WOFF2 file to the media folder and it will automatically be imported.
	//     Player
	//         tick
	//             if winner == me
	//                 drawText "You've won!", size:100, color:Black, font:OpenSans, visibleFor:me
	// Image: drawText.png
	global js void drawText: implicit string text                // The text to draw
		                     Vector2 position = {}               // The position to draw to
		                     implicit Vector2 size = {}          // The size of the text
		                     Color color = null                  // The color of the text
		                     HorizontalAlignment align = Center  // The horizontal alignment of the text
		                     VerticalAlignment valign = Middle   // The vertical alignment of the text
		                     FontStyle style = Normal            // Whether the text should be bold or normal style
		                     Font font = null                    // To use a custom font, just copy a TTF, WOFF or WOFF2 file to the media folder
		                     Color outlineColor = null           // The color of the outline around the text
		                     outlineWidth = 0                    // The width of the outline around the text
		                     implicit Player[] visibleFor = null // Only this player or list of players will see the text
		                     implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                     alpha = 1.0                         // The opacity of the text (0: fully transparent, 1: fully visible)
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
		
	// ------------------------------------------------------- Button -------------------------------------------------------
	
	// Draw a button made up of an image and a text and execute the given code when its clicked
	// Example: If the current player instance clicks the image or 16 pixels around it, we print the exact position that was clicked. If other players will click the image, nothing will happen.
	//     Player
	//         bool done
	//         tick
	//             if not done
	//                 drawButton "I'm done", image:Button, visibleFor:me
	//                     done = true
	// Image: drawButton.png
	global void drawButton: Image image = null                   // The image of the button
		                    text = ""                            // The text of the button
		                    Vector2 position = {}                // The position to draw to
		                    Color textColor = null               // The color of the text
		                    frame = 0                            // The frame of the image
		                    implicit Vector2 size = {}           // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                    fontSize = 18                        // The font size in pixels   
		                    textOffset = Vector2(0,0)            // Draw the text at this offset
		                    touchMargin = Vector2(16,16)         // The margin around the button within which it is touchable
		                    showTouchArea = false                // Show the area within which the button is touchable
		                    implicit Player[] visibleFor = null  // Only this player or list of players will see the button
		                    implicit Player[] clickableBy = null // Only this player or list of players can click the button
		                    hotkey = Key.None                    // This keyboard shortcut will execute the onClick handler
		                    implicit layer = 0                   // Higher layers are drawn in front of lower layers
		                    alpha = 1.0                          // The opacity of the button (0: fully transparent, 1: fully visible)
		                    enabled = true                       // When not enabled, the button can't be clicked and is drawn transparently (50% by default)
		                    alphaWhenDisabled = .5               // The opacity of the button will be multiplied with this factor when its disabled
		                    void(Touch touch) onClick = null     // Execute this code when the user clicks the button or presses the hotkey
	                        SourceCodeLocation location
		if isVisibleFor(visibleFor)
			let effectiveAlpha = enabled ? alpha : alpha * alphaWhenDisabled
			if text:  drawText text, position+textOffset, fontSize, textColor, visibleFor, layer, effectiveAlpha, location
			if image: drawImage image, position, frame, size, visibleFor, layer, effectiveAlpha, location
			
		if enabled and onClick != null
			// Handle click (only visible buttons are clickable)
			let effectiveClickableBy = getClickableBy(visibleFor, clickableBy)
			Vector2 effectiveSize = image ? getEffectiveSize(image.size, size) : {getTextWidth(text), fontSize}
			input.onTouchDownWithin position, effectiveSize + touchMargin, by:effectiveClickableBy, showTouchArea, do:onClick
			if hotkey
				input.onKeyDown hotkey, by:effectiveClickableBy
					onClick null
			
	// ------------------------------------------------------- Rectangle -------------------------------------------------------
	
	// Draw a rectangle on the screen
	// Example: Draw a white rectangle with a black outline that's 8 pixel wide.
	//     app
	//         tick
	//             drawRectangle size:{500,100}, color:White, outlineColor:Black, outlineWidth:8
	// Image: drawRectangle.png
	global js void drawRectangle: position = Vector2()                // The center of the rectangle
		                          implicit size = Vector2(256,256)    // The size of the rectangle, use a float to draw a square, use a vector to draw a rectangle
		                          Color color = null                  // The color of the area within the rectangle
		                          Color outlineColor = null           // The color of the outline around the rectangle
		                          outlineWidth = 0                    // The width of the outline around the rectangle
		                          implicit Player[] visibleFor = null // Only this player or list of players will see the rectangle
		                          implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                          alpha = 1.0                         // The opacity of the rectange 0: fully transparent, 1: fully visible)
		                          HorizontalAlignment align = Center  // The horizontal alignment of the rectangle
		                          VerticalAlignment valign = Middle   // The vertical alignment of the rectangle
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
				color || !outlineColor ? (color || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	// Draw a rectangle with rounded corners on the screen
	// Example: Draw a rounded rectangle with a black outline that's 8 pixel wide and a corner radius of 20 pixels.
	//     app
	//         tick
	//             drawRoundedRectangle size:{500,100}, outlineColor:Black, outlineWidth:8, radius:20
	// Image: drawRoundedRectangle.png
	global js void drawRoundedRectangle: position = Vector2()                // The center of the rectangle
		                                 implicit size = Vector2(256,256)    // The size of the rectangle, use a float to draw a square, use a vector to draw a rectangle
		                                 radius = 32                         // The radius of the rounded corners
		                                 Color color = null                  // The color of the area within the rectangle
		                                 Color outlineColor = null           // The color of the outline around the rectangle
		                                 outlineWidth = 0                    // The width of the outline around the rectangle
		                                 implicit Player[] visibleFor = null // Only this player or list of players will see the rectangle
		                                 implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                                 alpha = 1.0                         // The opacity of the rectangle (0: fully transparent, 1: fully visible)
		                                 HorizontalAlignment align = Center  // The horizontal alignment of the rectangle
		                                 VerticalAlignment valign = Middle   // The vertical alignment of the rectangle
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
				color || !outlineColor ? (color || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	// ------------------------------------------------------- Circle -------------------------------------------------------
	
	// Draw a circle on the screen
	// Example: Draw a white circle with a blue outline and a diameter of 150 pixels
	//     app
	//         tick
	//             drawCircle color:White, outlineColor:#118ab2, outlineWidth:12, size:150
	// Image: drawCircle0.png
	// Example: Draw a white circle with a blue outline and a width of 150 pixels and a height of 100 pixels
	//     app
	//         tick
	//             drawCircle color:White, outlineColor:#118ab2, outlineWidth:12, size:{200, 100}
	// Image: drawCircle1.png
	// Example: Draw an arc of 180° (half a circle) starting a angle 0°
	//     app
	//         tick
	//             drawCircle outlineColor:#118ab2, outlineWidth:24, size:100, startAngle:0°, angle:180°
	// Image: drawCircle2.png
	global js void drawCircle: position = Vector2()                    // The center of the circle
		                       implicit Vector2 size = {256,256}       // The size of the circle, use a float to draw a circle, use a vector draw an ellipse
		                       Color color = null                      // The color of the area within the circle
		                       Color outlineColor = null               // The color of the outline around the circle
		                       outlineWidth = 0                        // The width of the outline around the circle
		                       Angle startAngle = -.25                 // Draw an arc with this start angle in turns, measured from the positive x-axis
		                       Angle angle = 1.0                       // Draw an arc with this angle in turns (0.25: quarter circle, 0.5: half circle, 1: full circle)
		                       RotationDirection direction = Clockwise // The circle is drawn in this direction
		                       implicit Player[] visibleFor = null     // Only this player or list of players will see the circle
		                       implicit layer = 0                      // Higher layers are drawn in front of lower layers
		                       alpha = 1.0                             // The opacity of the circle (0: fully transparent, 1: fully visible)
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
				color || !outlineColor ? (color || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	// ------------------------------------------------------- Line -------------------------------------------------------
	
	// Draw a line on the screen
	// Example: Draw a blue line from {-100,0} to {100,0}
	//     app
	//         tick
	//             drawLine {-100,0} to {100,0} color:Blue
	// Image: drawLine.png
	global js void drawLine: Vector2 from                        // The point to start the line from
		                     nocolon Vector2 to                  // The point to draw the line to
		                     Color color = null                  // The color of the outline around the line
		                     width = 0                           // The width of the outline around the line
		                     implicit Player[] visibleFor = null // Only this player or list of players will see the line
		                     implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                     alpha = 1.0                         // The opacity of the line (0: fully transparent, 1: fully visible)
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
		
	// Draw a continuous stroke of lines on the screen
	// Example: Draw a blue stroke of lines through {-50,0}, {0,50} and {100,-50} with a width of 32 pixels
	//     app
	//         tick
	//             drawLines [{-50,0}, {0,50}, {100,-50}] color:Blue width:32
	// Image: drawLines.png
	global js void drawLines: Vector2[] points                    // A list of points for the line
		                      Vector2 position = {}               // The position all points are relative to 
		                      Color color = null                  // The color of the line
		                      width = 0                           // The width of the line
		                      smooth = false                      // Smooth the corners of the line
		                      implicit Player[] visibleFor = null // Only this player or list of players will see the line
		                      implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                         // The opacity of the lines (0: fully transparent, 1: fully visible)
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
		
	// ------------------------------------------------------- Polygon -------------------------------------------------------
	
	// Draw a polygon on the screen
	// Example: Draw a white polygon with the corners {-50,50}, {0,-50} and {50,50} with a blue outline
	//     app
	//         tick
	//             drawPolygon [{-50,50}, {0,-50}, {50,50}] color:White outlineColor:Blue
	// Image: drawPolygon.png
	global js void drawPolygon: Vector2[] points                    // A list of points for the polygon
		                        Vector2 position = {0,0}            // The position all points are relative to 
		                        Color color = null                  // The color of the area within the polygon
		                        Color outlineColor = null           // The color of the outline around the polygon
		                        outlineWidth = 0                    // The width of the outline around the polygon
		                        smooth = false                      // Smooth the corners of the polygon
		                        implicit Player[] visibleFor = null // Only this player or list of players will see the polygon
		                        implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                        alpha = 1.0                         // The opacity of the polygon (0: fully transparent, 1: fully visible)
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayPolygon(
				graphics_totalMatrix,
				position.x, position.y,
				0, 0,
				layer, alpha, graphics_currentClippingPath, "Polygon", 
				location, position.location, null,
				points,
				color || !outlineColor ? (color || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth,
				smooth, /*close*/true
			))
		}
		
	// ------------------------------------------------------- Video -------------------------------------------------------
	
	// Draw the video feed showing the given player on the screen
	// Example: Draw the video feed for the current player instance with a width of 200 pixels
	//     Player
	//         tick
	//             drawVideo me, size:200
	// Image: drawVideo.png
	global drawVideo: Player player                       // Draw the video showing this player
		              Vector2 position = {}               // The position of the video
		              implicit Vector2 size = {440}       // The size of the video
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
	
	// Draw a pointer at the mouse position of the given player on the screen
	// Draw the video feed showing the given player on the screen
	// Example: Draw a pointer at the mouce position of the current player instance
	//     Player
	//         tick
	//             drawPointer me
	// Image: drawPointer.png
	global drawPointer: Player player                    // Show the mouse position of this player
		                Color color = null               // The color of pointer. If this is left out, the player color is used
		                showPointer = input.showPointers // Choose whether you want to draw the pointers for local player, remote players or both
		if showPointer == All
		or (player == input.localPlayer and showPointer == Local)
		or (player != input.localPlayer and showPointer == Remote)
			if !color: color = player.color
			for player.touches
				drawImage finger, .smoothPosition+{11,32}, frame:.isDown ? 1 : 0, layer:int.maxValue
				if color
					if color == Black
						drawRectangle .smoothPosition+{16,80}, size:{26,10}, color, layer:int.maxValue, outlineColor:{"a0a0a0"}, outlineWidth:2
					else
						drawRectangle .smoothPosition+{16,78}, size:{26,10}, color, layer:int.maxValue

	// ------------------------------------------------------- Texture -------------------------------------------------------
	
	// Draw a texture which you can dynamically load from a file from anywhere
	// Example: Dynamically load the file "Character.png" from the assets folder and draw it on the screen with a width of 100 pixels.
	//     app
	//         Texture character = {"Character.png"}
	//         tick
	//             drawTexture character, size:100
	// Image: drawTexture0.png
	global js void drawTexture: Texture texture                     // The texture to draw
		                        Vector2 position = {}               // The position to draw to
		                        implicit Vector2 size = {}          // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
		                        implicit Player[] visibleFor = null // Only this player or list of players will see the texture
		                        implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                        alpha = 1.0                         // The opacity of the texture (0: fully transparent, 1: fully visible)
		                        Color color = White                 // Tint the image with this color (white for no tint)
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

	// Draw part of a texture
	// Example: Dynamically load the file "Character.png" from the assets folder, take a part of this texture with a size of {16,32} centered around {8,0} and draw it on the screen with a size of {100,200}. 
	//     app
	//         Texture character = {"Character.png"}
	//         tick
	//             drawTexture character, sourcePosition:{8,0}, sourceSize:{16,32}, size:{100,200}
	// Image: drawTexture1.png
	global js void drawTexture: Texture texture                     // The texture to draw
		                        Vector2 position = {}               // The target position to draw to
		                        Vector2 size = {}                   // The target size of the area to draw
		                        Vector2 sourcePosition = {}         // The center of the area of the source texture
		                        Vector2 sourceSize = {}             // The size of the area of the source texture
		                        implicit Player[] visibleFor = null // Only this player or list of players will see the texture
		                        implicit int layer = 0              // Higher layers are drawn in front of lower layers
		                        alpha = 1.0                         // The opacity of the texture (0: fully transparent, 1: fully visible)
		                        Color color = White                 // Tint the image with this color (white for no tint)
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
				sourcePosition.x+texture.size.x/2-sourceSize.x/2,
				sourcePosition.y+texture.size.y/2-sourceSize.y/2,
				sourceSize.x, 
				sourceSize.y,
				color
			))
		}
		
	// ------------------------------------------------------- Clear -------------------------------------------------------
	
	// Clear all pixels within a rectangle
	// Example: Clear all pixel within a rectangle with a width of 100 pixels and a height of 100 pixels
	//     app
	//         tick
	//             clearRectangle position:{0,0} size:{100,100}
	// Image: clearRectangle.png
	global js void clearRectangle: position = Vector2()                // The position of the rectangle to clear
		                           implicit size = Vector2(256,256)    // The size of the rectangle, use a float to clear a square, use a vector to clear a rectangle
		                           implicit Player[] visibleFor = null // Only clear the rectangle for this player or list of players
		                           implicit layer = 0                  // Higher layers are drawn in front of lower layers
                                   HorizontalAlignment align = Center  // The horizontal alignment of the rectangle
                                   VerticalAlignment valign = Middle   // The vertical alignment of the rectangle
		if(graphics_isVisibleFor(visibleFor)) {
			let sizeX = size.x
			let sizeY = size.y || size.x
			graphics_items.push(new DisplayRectangle(
				graphics_totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX,
				valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY,
				sizeX, sizeY,
				layer, 1, graphics_currentClippingPath, "Clear", 
				location, position.location, size.location,
				"clear", null, 0
			))
		}
		
	// ------------------------------------------------------- Transform -------------------------------------------------------

	// Moves all operations in a block of code by a given vector
	// Example: Draw both an image and a text at {500,0}
	//     app
	//         tick
	//             graphics.move {500,0}
	//                 drawText "OK"
	//                 drawImage Button
	// Image: graphicsMove.png
	move: Vector2 distance // The distance to move
		  void() code      // All operations within this block will be moved
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.move distance
		totalMatrix.move distance
		code
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
							
	// Rotates all operation in a block of code by a given angle				
	// Example: Rotate both an image and a text by 20°
	//     app
	//         tick
	//             graphics.rotate 20°
	//                 drawText "OK"
	//                 drawImage Button
	// Image: graphicsRotate.png
	rotate: Angle angle  // The angle in turns (one full rotation is 1)
		    void() code  // All operations within this block will be rotated
		if angle == 0: code; return
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.rotate angle
		totalMatrix.rotate angle
		code
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
	
	// Scales all operation in a block of code by a given factor
	// Example: Scale both an image and a text by a factor of 2
	//     app
	//         tick
	//             graphics.scale 2
	//                 drawText "OK"
	//                 drawImage Button
	// Image: graphicsScale.png
	scale: float factor // The factor to scale by
		   void() code  // All operations within this block will be scaled
		if factor == 1: code; return
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.scale {factor, factor}
		totalMatrix.scale {factor, factor}
		code
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
	
	transform: Vector2 move = Vector2.none  // The distance to move
		       float scale = 1              // The factor to scale by
		       Angle rotate = 0             // The angle in turns (0: no rotation, 1: one full rotation)
		       void() code                  // All operations within this block will be scaled
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
	
	// Applies a matrix to all operations in a block of code
	// Example: Apply the matrix {1 .3 .7 1 0 0} to a text and an image
	//     app
	//         tick
	//             graphics.applyMatrix {1 .3 .7 1 0 0}
	//                 drawText "OK"
	//                 drawImage Button
	// Image: graphicsApplyMatrix.png
	applyMatrix: Matrix2D matrix // The matrix to appy
		         void() code     // All operations within this block will be scaled
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		this.localMatrix.multiplyLeft matrix
		this.totalMatrix.multiplyLeft matrix
		code
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5
	
	// ------------------------------------------------------- Clip -------------------------------------------------------
	
	// For all drawings in code block, only pixels inside the given polygon are drawn
	// Example: Draw three circles and clip all of them within the polygon with the corner {0,-80}, {-100,80}, {100,80}
	//     app
	//         tick
	//             graphics.clip points:[{0,-80}, {-100,80}, {100,80}]
	//                 drawCircle {   0, -80}, size:150, color:Blue
	//                 drawCircle {-100,  80}, size:150, color:Blue
	//                 drawCircle { 100,  80}, size:150, color:Blue
	// Image: graphicsClip0.png
	// Example: Draw three circles and clip two of them within the polygon with the corner {0,-80}, {-100,80}, {100,80}
	//     app
	//         tick
	//             graphics.clip points:[{0,-80}, {-100,80}, {100,80}]
	//                 drawCircle {   0, -80}, size:150, color:Blue
	//                 drawCircle {-100,  80}, size:150, color:Blue
	//             drawCircle { 100,  80}, size:150, color:Blue
	// Image: graphicsClip1.png
	clip: Vector2[] points      // A list of points that define the area to be clipped
		  Vector2 position = {} // The position all points are relative to 
		  bool show = false     // Visualizes the clipping area by shading it transparent red
		  void() code           // All draw operation within this code block will be clipped
		let prev = currentClippingPath
		currentClippingPath = ClippingPath(show)
		for points: currentClippingPath.points.add position + .
		code()
		currentClippingPath = prev
		
	private ClippingPath currentClippingPath
		
	// ------------------------------------------------------- Visibility -------------------------------------------------------
	
	// All draw operations in a block of code will only be visible to the given player
	// Example: Draw a button that is only visible to the current player instance
	//     Player
	//         tick
	//             visibleFor me
	//                 drawText "OK"
	//                 drawImage Button
	// Image: graphicsVisibleFor.png
	visibleFor: implicit Player[] player
		        void() code
		let prev = currentlyVisibleFor
		currentlyVisibleFor = player
		code()
		currentlyVisibleFor = prev
		return currentlyVisibleFor
		
	private Player[] currentlyVisibleFor = null
		
	// ------------------------------------------------------- Color -------------------------------------------------------
	
	// The default background color
	const Color backgroundColor = Black
	
	// Teh default player colors
	const Color[] defaultColors = [{"398CA9", "Blue"}, {"C01352", "Red"}, {"16C66E", "Green"}, {"FFD166", "Yellow"}]

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
	
	// ------------------------------------------------------- Font -------------------------------------------------------
	
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
	
	// ------------------------------------------------------- Line Width -------------------------------------------------------
	
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
	
	// ------------------------------------------------------- Measure text -------------------------------------------------------
	
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
		
	// ------------------------------------------------------- Position -------------------------------------------------------
	
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
		
	// --------------------------------------------- Create and Manipulate Images ---------------------------------------------
	
	// Creates an image to draw to
	js void createImage: Vector2 size     // The size of the image
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
	
	// Directly manipulate the pixels on the screen or an image
	js int[] accessPixel: void(int[] pixels) code // This code can manipulate the pixels
		let imageData = Platform_context.getImageData(0,0,Platform_pixelSize.x, Platform_pixelSize.y)
		code(imageData.data)
		Platform_context.putImageData(imageData, 0, 0)
		
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
		handleSize = math.map math.min(max.x-min.x, max.y-min.y) 64..256 start:16 target:32
	
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
					if pixelPos.isInsidePoygon item.poly
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
	string color, outlineColor
	float outlineWidth
	js void draw
		if(this.alpha == 0) return
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		Platform_context.globalAlpha = this.alpha
		if(this.clippingPath) this.startClipping()
			
		if(this.color == "clear") {
			Platform_context.clearRect(this.x, this.y, this.w, this.h)
		}
		else
		if(this.color) {
			Platform_context.fillStyle = this.color
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
	string color, outlineColor
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
		
		if(this.color) {
			Platform_context.fillStyle = this.color
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
	string color, outlineColor
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
		if(this.close || this.color) {
			Platform_context.closePath()
		}
		if(this.color) {
			// Close the polygon and fill it
			Platform_context.fillStyle = this.color
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
	string color, outlineColor
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
				Platform_context.arc(this.x+radius, this.y+radius, radius, 0, math_TwoPI, this.direction);
			} else {
				Platform_context.arc(this.x+radius, this.y+radius, radius, this.startAngle*math_TwoPI, (this.startAngle+this.angle)*math_TwoPI, this.direction);
			}
		} else {
			let radiusX = this.w/2
			let radiusY = this.h/2
			Platform_context.ellipse(this.x+radiusX, this.y+radiusY, radiusX, radiusY, 0, math_TwoPI, this.direction);
		}
		if(this.color) {
			Platform_context.fillStyle = this.color
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
		InternalUser user = input.internalUsers[userId]
			let videoElement = user.videoElements[user.videoElementIndex]
			               or (user.videoElements[user.videoElementIndex] = PeerNetwork.createVideoElement(user.mediaStream, user.local))
			
			let px = (m0 * x + m2 * y + m4) / Platform.pixelRatio
			let py = (m1 * x + m3 * y + m5) / Platform.pixelRatio
			let sizeX = w*m0 / Platform.pixelRatio
			let sizeY = h*m3 / Platform.pixelRatio
			PeerNetwork.updateVideoElement videoElement, px, py, sizeX, sizeY, radius:shape == Circle ? 10000 : 0
			user.videoElementIndex++


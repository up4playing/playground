// A color comprised of a red, green, blue and alpha component
class Color
	global const Color White   = {"ffffff"}
	global const Color Black   = {"000000"}
	global const Color Red     = {"ef476f"}
	global const Color Yellow  = {"ffd166"}
	global const Color Green   = {"06d6a0"}
	global const Color Blue    = {"118ab2"}
	global const Color Gray    = {"073b4c"}
	global const Color TransparentRed   = {"ef476f80"}
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
	float2 size
	
	Texture
		if Platform.engineStarted
			open
	
	js void open: void() callback = null
		if(!window._htmlImageCache) _htmlImageCache = {}
		let image = _htmlImageCache[this.file]
		if(!image) {
			image = new HTMLImage()
			image.src = this.file
			image.onload = e => {
				this._htmlImage = image
				window._htmlImageCache[this.file] = image
				this.size = new float2(image.width, image.height, null)
				callback?.();
			}
		} else {
			this._htmlImage = image
			this.size = new float2(image.width, image.height, null)
			callback?.()
		}

// A single frame of an animated image
struct ImageFrame
	float x1, y1, x2, y2, w, h

// An image that can be drawn on the screen and can have several frames of animation
class Image
	Texture texture
	float2 size
	ImageFrame[] frames
	string file
	
enum HorizontalAlignment: Left, Center, Right
enum VerticalAlignment: Top, Middle, Bottom
enum FontStyle: Normal, Bold
class ClippingPath: float2[] points; bool show
		
// A collection of functions for drawing on the screen
transient global unit graphics
	internal Matrix2D totalMatrix, localMatrix
	internal DisplayItem[] items
		
	internal js void startFrame
		graphics_reset()
		if(!Platform_fastForward)
			Platform_context.clearRect(0,0,Platform_pixelSize.x, Platform_pixelSize.y)

	internal js void reset
		Matrix2D_assign_Matrix2D(graphics_totalMatrix, Platform_baseMatrix);
		graphics_localMatrix.clear();
		graphics_currentlyVisibleFor = -1
		graphics_items.length = 0
		if(!Platform_fastForward)
			Platform_context.textBaseline = "hanging"

	internal finishFrame
		if(Platform.fastForward) return
		drawItems
		drawSafeArea
		
	private drawItems
		items.sort b.layer - a.layer
		for <- items: draw	
				
	private isVisibleFor: int user
		if(Platform.fastForward) return false
		let visibleFor = user != -1 ? user : currentlyVisibleFor
		return visibleFor == -1 || visibleFor == Network.userId
			
	internal js void drawSafeArea
		Platform_context.fillStyle = "#404040"
		Platform_context.setTransform(1,0,0,1,0,0)
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
	move: float2 distance // The distance to move
		localMatrix.move distance
		totalMatrix.move distance
							
	// Moves all operations in a block by a given vector						
	move: float2 distance // The distance to move
		  void() block    // All operations within this block will be moved
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.move distance
		totalMatrix.move distance
		block
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
							
	// Rotates all subsequent operations by a given angle	
	rotate: float angle // The angle in radians
		localMatrix.rotate angle
		totalMatrix.rotate angle
		
	// Rotates all operation in a block by a given angle				
	rotate: float angle  // The angle in radians
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
	js void createImage: float2 size      // The size of the image
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
	private Color currentColor = White
	
	// The default font for all draw operations
	font
		return currentFont
	font: string font
		currentFont = font
		return currentFont
	font: string font
		  void() code
		let prev = currentFont
		currentFont = font
		code()
		currentFont = prev
		return currentFont
	private currentFont = "Arial"
	
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
	private currentFontSize = 20
	
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
	clip: float2 pos
		  float2[] points
		  bool show = false
		  void() code
		let prev = currentClippingPath
		currentClippingPath = ClippingPath(show)
		for points: currentClippingPath.points.add pos + p
		code()
		currentClippingPath = null
		return currentColor
	private ClippingPath currentClippingPath = null
		
	// The default user for which all draw operations will be visible
	visibleFor
		return currentlyVisibleFor
	visibleFor: int user
		currentlyVisibleFor = user
		return currentlyVisibleFor
	visibleFor: int user
		        void() code
		let prev = currentlyVisibleFor
		currentlyVisibleFor = user
		code()
		currentlyVisibleFor = prev
		return currentlyVisibleFor
	private currentlyVisibleFor = -1
		
	// Returns the width of a string in pixels
	global js int getTextWidth: string text              // The string to get the width of
		                        size = 18                // The size of the font in pixels
		                        font = ""                // The font of the text
		                        FontStyle style = Normal // Whether the text should be bold or normal style
		Platform_context.font = (style ? "bold ":"")+(size || graphics_currentFontSize)+"px "+(font || graphics_currentFont)
		let textSize = Platform_context.measureText(text)
		return textSize.width
		
	// Draws an image on the screen
	global void drawImage: Image image            // The image to draw
		                   float2 position = {}   // The position to draw to
		                   framesPerSecond = 0    // Animate the image with this speed
		                   scale = 1.0            // Scale the image by this factor
		                   visibleFor = -1        // Only this user will see the image
		                   implicit int layer = 0 // Higher layers are drawn in front of lower layers
		var frame = Math.floor(Network.frame * Math.max(framesPerSecond, 0) / Network.targetFps) % image.frames.length;
		drawImage image, position, frame, scale, visibleFor, layer
	
	// Draws an image on the screen
	global js void drawImage: Image image          // The image to draw
		                      float2 position = {} // The position to draw to
		                      frame = 0            // The frame of the image to draw
		                      scale = 1.0          // Scale the image by this factor
		                      visibleFor = -1      // Only this user will see the image
		                      implicit layer = 0   // Higher layers are drawn in front of lower layers
		if(!image.texture || !image.texture._htmlImage) return
		if(graphics_isVisibleFor(visibleFor)) {
			let f = image.frames[frame % image.frames.length]
			graphics_items.push(new DisplayImage(
				graphics_totalMatrix,
				position.x-f.w/2*scale,
				position.y-f.h/2*scale,
				f.w*scale,
				f.h*scale,
				layer, graphics_currentClippingPath, image.file, position.location,
				image.texture._htmlImage,
				f.x1, f.y1, f.w, f.h
			))
		}
	
	// Draws an image on the screen
	global js void drawImage: Image image          // The image to draw
		                      float2 position = {} // The position to draw to
		                      frame = 0            // The frame of the image to draw
		                      scale = 1.0          // Scale the image by this factor
		                      angle = 0.0          // Rotate the image by this angle in radians
		                      visibleFor = -1      // Only this user will see the image
		                      implicit layer = 0   // Higher layers are drawn in front of lower layers
		if(!image.texture || !image.texture._htmlImage) return
		if(graphics_isVisibleFor(visibleFor)) {
			let f = image.frames[frame % image.frames.length]
			let matrix = graphics_totalMatrix.clone()
			matrix.move(position)
			matrix.rotate(angle)
			graphics_items.push(new DisplayImage(
				matrix,
				-f.w/2*scale,
				-f.h/2*scale,
				f.w*scale,
				f.h*scale,
				layer, graphics_currentClippingPath, image.file, position.location, 
				image.texture._htmlImage,
				f.x1, f.y1, f.w, f.h
			))
		}
	
	// Draws text on the screen
	global js void drawText: string text                        // The text to draw
		                     position = float2()                // The position to draw to
		                     size = 0                           // The font size in pixels
		                     Color color = null                 // The color of the text
		                     HorizontalAlignment align = Center // The horizontal alignment of the text
		                     VerticalAlignment valign = Middle  // The vertical alignment of the text
		                     FontStyle style = Normal           // Whether the text should be bold or normal style
		                     font = ""                          // The font of the text
	                         Color outlineColor = null          // The color of the outline around the text
	                         outlineWidth = 0                   // The width of the outline around the text
		                     visibleFor = -1                    // Only this user will see the image
		                     implicit layer = 0                 // Higher layers are drawn in front of lower layers
		if(graphics_isVisibleFor(visibleFor)) {
			let contextFont = (style ? "bold ":"")+(size || graphics_currentFontSize)+"px "+(font || graphics_currentFont);
			Platform_context.font = contextFont
			let textSize = Platform_context.measureText(text)
			let fillStyle = (color || graphics_currentColor).hex
			let w = textSize.width
			let h = size || graphics_currentFontSize
			let x = align  == 0 ? position.x : align  == 1 ? position.x-w*.5 : position.x-w
			let y = valign == 0 ? position.y : valign == 1 ? position.y-h*.365 : position.y-h
			graphics_items.push(new DisplayText(
				graphics_totalMatrix, x, y, w, h, layer, graphics_currentClippingPath, text, 
				position.location, 
				fillStyle, 
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth,
				contextFont
			))
		}
		
	// Draws an image on the screen
	global void drawButton: Image image = null          // The image to draw
		                    text = ""                   // The text to draw
		                    float2 position = {}        // The position to draw to
		                    Color textColor = null      // The color of the text
		                    frame = 0                   // The frame of the image of the image to draw
		                    scale = 1.0                 // Scale the image by this factor
		                    fontSize = 18               // The font size in pixels
		                    touchMargin = float2(16,16) // The margin around the button within which it is touchable
		                    showTouchArea = false       // Show the area within which the button is touchable
		                    visibleFor = -1             // Only this user will see the button
		                    implicit layer = 0          // Higher layers are drawn in front of lower layers
		if isVisibleFor(visibleFor)
			if image: drawImage image, position, frame, scale, visibleFor, layer
			if text:  drawText text, position, fontSize, textColor, visibleFor, layer
			
	// Draws a button that consists of an image and a text
	global void drawButton: Image image = null               // The image of the button
		                    text = ""                        // The text of the button
		                    float2 position = {}             // The position to draw to
		                    Color textColor = null           // The color of the text
		                    frame = 0                        // The frame of the image
		                    scale = 1.0                      // Scale the image by this factor
		                    fontSize = 18                    // The font size in pixels   
		                    touchMargin = float2(16,16)      // The margin around the button within which it is touchable
		                    textOffset = float2()
		                    showTouchArea = false            // Show the area within which the button is touchable
		                    visibleFor = -1                  // Only this user will see the button
		                    clickableBy = -1                 // Only this user can click the button
		                    implicit layer = 0               // Higher layers are drawn in front of lower layers
		                    void(Touch touch) onClick = null // Execute this code when the user clicks the button
		if isVisibleFor(visibleFor)
			if image: drawImage image, position, frame, scale, visibleFor, layer
			if text:  drawText text, position+textOffset, fontSize, textColor, visibleFor, layer
			
		// Handle click
		// Only visible buttons can be clickable
		let userId = clickableBy != -1 ? clickableBy : visibleFor != -1 ? visibleFor : currentlyVisibleFor
		Input.onTouchDownWithin position, image.size*scale + touchMargin, userId, showTouchArea
			onClick touch
			
	// Draws a rectangle on the screen
	global js void drawRectangle: position = float2()       // The center of the rectangle
		                          size = float2(32,32)      // The size of the rectangle
		                          Color fillColor = null    // The color of the area within the rectangle
		                          Color outlineColor = null // The color of the outline around the rectangle
		                          outlineWidth = 0          // The width of the outline around the rectangle
		                          visibleFor = -1           // Only this user will see the rectangle
		                          implicit layer = 0        // Higher layers are drawn in front of lower layers
		                          HorizontalAlignment align = Center // The horizontal alignment of the rectangle
		                          VerticalAlignment valign = Middle  // The vertical alignment of the rectangle
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayRectangle(
				graphics_totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-size.x*.5 : position.x-size.x,
				valign == 0 ? position.y : valign == 1 ? position.y-size.y*.5 : position.y-size.y,
				size.x, size.y,
				layer, graphics_currentClippingPath, "Rectangle", position.location,
				fillColor || !outlineColor ? (fillColor || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	// Draws a circle on the screen
	global js void drawCircle: position = float2()       // The center of the circle
		                       radius = 32.0             // The radius of the circle
		                       Color fillColor = null    // The color of the area within the circle
		                       Color outlineColor = null // The color of the outline around the circle
		                       outlineWidth = 0          // The width of the outline around the circle
		                       startAngle = 0            // Draws an arc with this start angle in radians, measured from the positive x-axis
		                       endAngle = Math.PI * 2    // Draws an arc with this end angle in radians, measured from the positive x-axis
		                       RotationDirection direction = Clockwise
		                       visibleFor = -1           // Only this user will see the circle
		                       implicit layer = 0        // Higher layers are drawn in front of lower layers
		if(graphics_isVisibleFor(visibleFor)) {
			let diameter = radius*2
			graphics_items.push(new DisplayCircle(
				graphics_totalMatrix, 
				position.x, position.y, diameter, diameter,
				layer, graphics_currentClippingPath, "Circle", position.location,
				radius, startAngle, endAngle,
				direction == 1,
				fillColor || !outlineColor ? (fillColor || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	// Draws a texture on the screen
	global js void drawTexture: Texture texture        // The texture to draw
		                        float2 position = {}   // The position to draw to
		                        scale = 1.0            // Scale the texture by this factor
		                        visibleFor = -1        // Only this user will see the texture
		                        implicit int layer = 0 // Higher layers are drawn in front of lower layers
		if(!texture || !texture._htmlImage) return
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayImage(
				graphics_totalMatrix,
				position.x-texture.size.x/2*scale,
				position.y-texture.size.y/2*scale,
				texture.size.x*scale,
				texture.size.y*scale,
				
				layer, graphics_currentClippingPath, texture.file, position.location,
				texture._htmlImage,
				0, 0, texture.size.x, texture.size.y
			))
		}

	// Draws a texture on the screen
	global js void drawTexture: Texture texture            // The texture to draw
		                        float2 position = {}       // The target position to draw to
		                        float2 size = {}           // The target size of the area to draw
		                        float2 sourcePosition = {} // The center of the area of the source texture
		                        float2 sourceSize = {}     // The size of the area of the source texture
		                        visibleFor = -1            // Only this user will see the texture
		                        implicit int layer = 0     // Higher layers are drawn in front of lower layers
		if(!texture || !texture._htmlImage) return
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayImage(
				graphics_totalMatrix,
				position.x - size.x/2,
				position.y - size.y/2,
				size.x,
				size.y,
				
				layer, graphics_currentClippingPath, texture.file, position.location, 
				texture._htmlImage,
				
				sourcePosition.x+texture.size.x/2-sourceSize.x/2,
				sourcePosition.y+texture.size.y/2-sourceSize.y/2,
				sourceSize.x, 
				sourceSize.y, 
			))
		}
		
	// Draws a polygon on the screen
	global js void drawPolygon: float2[] points           // A list of points for the polygon
		                        float2 position = {0,0}   // The position all points are relative to 
		                        Color fillColor = null    // The color of the area within the polygon
		                        Color outlineColor = null // The color of the outline around the polygon
		                        outlineWidth = 0          // The width of the outline around the polygon
		                        visibleFor = -1           // Only this user will see the polygon
		                        implicit int layer = 0    // Higher layers are drawn in front of lower layers
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayPolygon(
				graphics_totalMatrix,
				position.x, position.y,
				0, 0,
				layer, graphics_currentClippingPath, "Polygon", position.location,
				points,
				fillColor || !outlineColor ? (fillColor || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	// Draws a rectangle with rounded corners on the screen
	global js void drawRoundedRectangle: position = float2()       // The center of the rectangle
		                                 size = float2(32,32)      // The size of the rectangle
		                                 radius = 32               // The radius of the rounded corners
		                                 Color fillColor = null    // The color of the area within the rectangle
		                                 Color outlineColor = null // The color of the outline around the rectangle
		                                 outlineWidth = 0          // The width of the outline around the rectangle
		                                 visibleFor = -1           // Only this user will see the rectangle
		                                 implicit int layer = 0    // Higher layers are drawn in front of lower layers
		                                 HorizontalAlignment align = Center // The horizontal alignment of the rectangle
		                                 VerticalAlignment valign = Middle  // The vertical alignment of the rectangle
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayRoundedRectangle(
				graphics_totalMatrix,
				align == 0  ? position.x : align  == 1 ? position.x-size.x*.5 : position.x-size.x,
				valign == 0 ? position.y : valign == 1 ? position.y-size.y*.5 : position.y-size.y,
				size.x, size.y,
				layer, graphics_currentClippingPath, "RoundedRectangle", position.location,
				radius,
				fillColor || !outlineColor ? (fillColor || graphics_currentColor).hex : null,
				outlineColor ? outlineColor.hex : null,
				outlineWidth || graphics_currentLineWidth
			))
		}
		
	// Draws a polygon on the screen
	global js void drawLine: float2 start
		                     float2 end 
		                     Color color = null // The color of the outline around the line
		                     width = 0          // The width of the outline around the line
		                     visibleFor = -1           // Only this user will see the line
		                     implicit int layer = 0    // Higher layers are drawn in front of lower layers
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayLine(
				graphics_totalMatrix,
				start.x, start.y,
				end.x - start.x, end.y - start.y,
				layer, graphics_currentClippingPath, "Line", start.location,
				end,
				color ? color.hex : null,
				width || graphics_currentLineWidth
			))
		}
		
	// Clears all pixels within a rectangle
	global js void clearRectangle: position = float2()  // The position of the rectangle to clear
		                           size = float2(32,32) // The size of the rectangle to clear
		                           visibleFor = -1      // Only clear the rectangle for this user
		                           implicit layer = 0   // Higher layers are process after lower layers
		if(graphics_isVisibleFor(visibleFor)) {
			graphics_items.push(new DisplayRectangle(
				graphics_totalMatrix, position.x-size.x/2, position.y-size.y/2, size.x, size.y, layer, graphics_currentClippingPath, "Rectangle", position.location, "clear", null, 0
			))
		}

transient class DisplayItem
	float x, y, w, h
	int layer
	ClippingPath clippingPath
	string name
	SourceCodeLocation location
	
	visible float m0, m1, m2, m3, m4, m5
	visible float2[] poly
	
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
	js void draw
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		if(this.clippingPath) this.startClipping()
		
		try{ Platform_context.drawImage(this.htmlImage, this.sx, this.sy, this.sw, this.sh, this.x, this.y, this.w, this.h) }
		catch(e) { log("DisplayImage: "+e.message) }
		
		if(this.clippingPath) this.endClipping()

transient DisplayItem DisplayText
	string fillStyle, outlineColor
	float outlineWidth
	string font
	js void draw
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		if(this.clippingPath) this.startClipping()
			
		Platform_context.font = this.font
		if(this.outlineColor) {
			Platform_context.lineWidth = this.outlineWidth
			Platform_context.strokeStyle = this.outlineColor
			Platform_context.strokeText(this.name, this.x, this.y)
		}
		Platform_context.fillStyle = this.fillStyle
		Platform_context.fillText(this.name, this.x, this.y)
		
		if(this.clippingPath) this.endClipping()
		
transient DisplayItem DisplayRectangle
	string fillColor, outlineColor
	float outlineWidth
	js void draw
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
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
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		if(this.clippingPath) this.startClipping()
		let sizeX = this.w, sizeY = this.h, x = this.x, y = this.y, radius = this.radius
		
		Platform_context.beginPath();
		Platform_context.moveTo(x + radius, y);
		Platform_context.lineTo(x + sizeX - radius, y);
		Platform_context.quadraticCurveTo(x + sizeX, y, x + sizeX, y + radius);
		Platform_context.lineTo(x + sizeX, y + sizeY - radius);
		Platform_context.quadraticCurveTo(x + sizeX, y + sizeY, x + sizeX - radius, y + sizeY);
		Platform_context.lineTo(x + radius, y + sizeY);
		Platform_context.quadraticCurveTo(x, y + sizeY, x, y + sizeY - radius);
		Platform_context.lineTo(x, y + radius);
		Platform_context.quadraticCurveTo(x, y, x + radius, y);
		Platform_context.closePath();
		
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
	float2[] points
	string fillColor, outlineColor
	float outlineWidth
	js void draw
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		if(this.points.length >= 2) {
			if(this.clippingPath) this.startClipping()
			let x = this.x, y = this.y
			
			let firstPos = this.points[this.points.length-1]
			Platform_context.beginPath();
			Platform_context.moveTo(x + firstPos.x, y + firstPos.y)
			for(let p of this.points)
				Platform_context.lineTo(x + p.x, y + p.y)
				
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
		}
		
enum RotationDirection: Clockwise, CounterClockwise
		
transient DisplayItem DisplayCircle
	float radius, startAngle, endAngle
	RotationDirection direction
	string fillColor, outlineColor
	float outlineWidth
	js void draw
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		if(this.clippingPath) this.startClipping()
			
		Platform_context.beginPath();
		Platform_context.arc(this.x, this.y, this.radius, this.startAngle, this.endAngle, this.direction);
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
	float2 end
	string outlineColor
	float outlineWidth
	js void draw
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		if(this.clippingPath) this.startClipping()
		
		Platform_context.beginPath();
		Platform_context.moveTo(this.x,this.y)
		Platform_context.lineTo(this.end.x, this.end.y)
		Platform_context.lineWidth = this.outlineWidth
		Platform_context.strokeStyle = this.outlineColor
		Platform_context.stroke()
		
		if(this.clippingPath) this.endClipping()
		
// A sound
struct Sound
	string file
	Sound() open
	
	js void open
		if(!window._audioCache) _audioCache = {}
		this._sound = _audioCache[this.file]
		if(!this.audio) {
			this.audio = window._audioCache[this.file] = new Audio()
			this.audio.src = this.file
		}

// A collection of functions for playing audio 
transient global unit audio
	global js void playSound: Sound sound
		sound.audio.play()

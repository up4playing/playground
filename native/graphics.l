// A color comprised of a red, green, blue and alpha component
immutable struct Color
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
	int red, green, blue, alpha
	
	// string toString := name or hex
	
	Color: string hex = ""
		this.hex = hex
		this.red   = hex.length >= 3 ? int.fromHex(hex[1..3]) : 0
		this.green = hex.length >= 5 ? int.fromHex(hex[3..5]) : 0
		this.blue  = hex.length >= 7 ? int.fromHex(hex[5..7]) : 0
		this.alpha = hex.length >= 9 ? int.fromHex(hex[7..9]) : 255

	// Color: int red = 0
	// 	   int green = 0
	// 	   int blue = 0
	// 	   int alpha = 255
	// 	this.hex = "#" + componentToHex(red) + componentToHex(green) + componentToHex(blue) + componentToHex(alpha)
			
	// static js string componentToHex: int c
	// 	var hex = c.toString(16);
	// 	return hex.length == 1 ? "0" + hex : hex;
		
	// inline js bool operator ==(Color a, Color b) a.hex == b.hex
	// inline js bool operator !=(Color a, Color b) a.hex != b.hex
	
	// Color withAlpha: float alpha
	// 	return {hex[1..7]+componentToHex(math.floor(alpha*255))}

immutable skipInit class Font
	string name
	string file
	cpp void open

cpp(SDL.h, SDL_Texture) immutable class SDL_Texture
cpp(SDL.h, SDL_Surface) immutable class SDL_Surface
cpp(SDL.h, SDL_Renderer) immutable class SDL_Renderer

immutable class Texture
	string file
	Vector2 size
	
	internal #sdl1.2 SDL_Surface *surface
	internal #sdl2 SDL_Texture *texture
	
	cpp #sdl1.2 void open
		surface = IMG_Load(file.c_str());
	
	cpp #sdl2 void open
		SDL_Surface *bgSurface = IMG_Load(file.c_str());
		texture = SDL_CreateTextureFromSurface(graphics::renderer, bgSurface);
		
// A single frame of an animated image
immutable struct ImageFrame
	float x1, y1, x2, y2, w, h

// An image that can be drawn on the screen and can have several frames of animation
skipInit immutable class Image
	string file
	Texture texture
	Vector2 size
	ImageFrame[] frames

enum ScaleMode: Auto, FixedWidth, FixedHeight, None
enum AnchorMode: TopLeft, TopCenter, Center
enum HorizontalAlignment: Left, Center, Right
enum VerticalAlignment: Top, Middle, Bottom
enum FontStyle: Normal, Bold
	
global skipInit unit graphics
	internal DisplayItem[] items
	internal #sdl1.2 SDL_Surface *video
	internal #sdl1.2 SDL_Surface *screen
	internal #sdl2 SDL_Renderer *renderer
	
	public Vector2 referenceSize = {640, 480}
	public ScaleMode scaleMode = Auto, effectiveScaleMode
	public AnchorMode anchor = Center
	
	private Vector2 offset
	private float scale
	visible Vector2 pixelSize
	visible Vector2 size
	visible bool isFullscreen = false
	
	private isVisibleFor: Player[] visibleFor
		return true
		
	cpp(SDL_image.h, SDL_ttf.h) #sdl1.2 void init
		const int FONT_SIZE = 64;
		IMG_Init(IMG_INIT_PNG);
		TTF_Init();
		
		pixelSize = Vector2::new_(referenceSize.x, referenceSize.y);
		video = SDL_SetVideoMode(pixelSize.x, pixelSize.y, 32, SDL_HWSURFACE | SDL_DOUBLEBUF);
		screen = SDL_CreateRGBSurface(SDL_HWSURFACE, pixelSize.x, pixelSize.y, 32, 0, 0, 0, 0);

		// if(isFullscreen) {
		// 	SDL_DisplayMode displayMode;
		// 	SDL_GetCurrentDisplayMode(0, &displayMode);
		// 	pixelSize = Vector2::new_(displayMode.w, displayMode.h);
		// } else {
		// 	pixelSize = Vector2::new_(referenceSize.x, referenceSize.y);
		// }
		
		// SDL_Window *window = SDL_CreateWindow("Application", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, pixelSize.x, pixelSize.y, 0);
		// SDL_Window *window = SDL_CreateWindow("Application", 1000, 100, pixelSize.x, pixelSize.y, 0);
		
		// if(isFullscreen) SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN);
		// renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
		graphics::updateBaseMatrix();
		
	cpp(SDL_image.h, SDL_ttf.h) #sdl2 void init
		const int FONT_SIZE = 64;
		IMG_Init(IMG_INIT_PNG);
		TTF_Init();
		
		if(isFullscreen) {
			SDL_DisplayMode displayMode;
			SDL_GetCurrentDisplayMode(0, &displayMode);
			pixelSize = Vector2::new_(displayMode.w, displayMode.h);
		} else {
			pixelSize = Vector2::new_(referenceSize.x, referenceSize.y);
		}
		
		// SDL_Window *window = SDL_CreateWindow("Application", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, pixelSize.x, pixelSize.y, 0);
		SDL_Window *window = SDL_CreateWindow("Application", 100, 100, pixelSize.x, pixelSize.y, 0);
		
		if(isFullscreen) SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN);
		renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
		graphics::updateBaseMatrix();
		
	updateBaseMatrix
		Vector2 ratio = {pixelSize.x / referenceSize.x, pixelSize.y / referenceSize.y}
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
			scale = ratio.y
			size = {pixelSize.x/scale, referenceSize.y}
		offset = {anchor >= TopCenter ? pixelSize.x/2 : 0, anchor >= Center ? pixelSize.y/2 : 0}
		
	global cpp void drawTexture: Texture texture
		                         Vector2 position = {0,0}
		
	// ------------------------------------------------------- Image -------------------------------------------------------
	
	// Draw an image. Place a PNG file in the "media" folder and it will automatically be imported
	// Example: We place an image called "Idle.png" in the "media" folder. Then, we draw this image at the position {0,0}, scale it to a width of 32 pixels. Only the current player instance will see the image.
	//     Player
	//         tick
	//             drawImage Idle, position:{0,0}, size:32, frame:0, visibleFor:me
	// Image: drawImage0.png
	global void drawImage: Image image                         // The image to draw. PNG images in the "media" folder will automatically show up here
		                      Vector2 position = {}               // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                      implicit Vector2 size = {}          // A float scales the image to that width keeping the aspect ratio, a vector stretches the image
		                      implicit Player[] visibleFor = []   // Only this player or list of players will see the image
		                      implicit frame = 0                  // The frame to draw from a sequence of images (for example "Walk0.png", "Walk1.png", ...)
		                      implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                         // The opacity of the image (0: fully transparent, 1: fully visible)
		                      Color color = White                 // Tint the image with this color
		                      HorizontalAlignment align = Center  // The horizontal alignment of the image
		                      VerticalAlignment valign = Middle   // The vertical alignment of the image
		if(isVisibleFor(visibleFor))
			let f = image.frames[frame % image.frames.length]
			float unscaledSizeX = size.x ? size.x : f.w
			float sizeX = unscaledSizeX * scale
			float sizeY = (size.y ? size.y : (unscaledSizeX/f.w)*f.h) * scale
			float posX = (align == Left ? position.x : align  == Center ? position.x-sizeX*.5 : position.x-sizeX) + offset.x
			float posY = (valign == Top ? position.y : valign == Middle ? position.y-sizeY*.5 : position.y-sizeY) + offset.y
			items.add DisplayImage(
				cast posX, cast posY, cast sizeX, cast sizeY, 
				layer, alpha,
				image.texture, 
				cast f.x1, cast f.y1, cast f.w, cast f.h
			)
		
	// ------------------------------------------------------- Text -------------------------------------------------------
	
	// Draw text on the screen
	// Example: If the current player instance is the winner, we show "You've won!" to the current player instance. To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder and it will automatically be imported.
	//     Player
	//         tick
	//             if winner == me
	//                 drawText "You've won!", size:100, color:Black, font:OpenSans, visibleFor:me
	// Image: drawText.png
	global drawText: implicit string text                // A string or anything that can be converted into a string (for example, an interger or a float)
		                      Vector2 position = {}               // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                      implicit Vector2 size = {}          // The size of the text
		                      Color color = White                 // The color of the text
		                      HorizontalAlignment align = Center  // The horizontal alignment of the text
		                      VerticalAlignment valign = Middle   // The vertical alignment of the text
		                      FontStyle style = Normal            // Whether the text should be bold or normal style
		                      Font font = null                    // To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder
		                      Color outlineColor = White          // The color of the outline around the text
		                      outlineWidth = 0                    // The width of the outline around the text in pixels
		                      implicit Player[] visibleFor = []   // Only this player or list of players will see the text
		                      implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                         // The opacity of the text (0: fully transparent, 1: fully visible)
	
	// ------------------------------------------------------- Rectangle -------------------------------------------------------
	
	// Draw a rectangle on the screen
	// Example: Draw a white rectangle with a black outline that is 8 pixels wide.
	//     app
	//         tick
	//             drawRectangle size:{500,100}, color:White, outlineColor:Black, outlineWidth:8
	// Image: drawRectangle.png
	global drawRectangle: position = Vector2()                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                  implicit size = Vector2(256,256)    // The size of the rectangle, use a float to draw a square, use a vector to draw a rectangle
		                  Color color = White                 // The color of the area within the rectangle
		                  Color outlineColor = White          // The color of the outline around the rectangle
		                  outlineWidth = 0                    // The width of the outline around the rectangle in pixels
		                  implicit Player[] visibleFor = []   // Only this player or list of players will see the rectangle
		                  implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                  alpha = 1.0                         // The opacity of the rectangle (0: fully transparent, 1: fully visible)
		                  HorizontalAlignment align = Center  // The horizontal alignment of the rectangle
		                  VerticalAlignment valign = Middle   // The vertical alignment of the rectangle
		
		if(isVisibleFor(visibleFor))
			float sizeX = size.x * scale
			float sizeY = (size.y ? size.y : size.x) * scale
			float posX = (align == Left ? position.x : align  == Center ? position.x-sizeX*.5 : position.x-sizeX) + offset.x
			float posY = (valign == Top ? position.y : valign == Middle ? position.y-sizeY*.5 : position.y-sizeY) + offset.y
			items.add DisplayRectangle(
				cast posX, cast posY, cast sizeX, cast sizeY, 
				layer, alpha, color, outlineWidth
			)

	startFrame
		items.clear
		
	finishFrame
		startRendering
		items.sort a.layer - b.layer
		items.each <- .draw
		finishRendering
		
	private cpp #sdl2 void startRendering
	    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
	    SDL_RenderClear(renderer);
		
	private cpp #sdl2 void finishRendering
		SDL_RenderPresent(renderer);
		
	private cpp #sdl1.2 void startRendering
		SDL_FillRect(screen, nullptr, SDL_MapRGB(screen->format, 255, 255, 255));
		
	private cpp #sdl1.2 void finishRendering
		SDL_BlitSurface(screen, nullptr, video, nullptr);
		SDL_Flip(video);
		
transient immutable DisplayItem
	int x, y, w, h
	int layer
	float alpha
	draw

transient DisplayItem DisplayImage
	Texture texture
	int sx, sy, sw, sh
	
	cpp #sdl1.2 void draw
		SDL_Rect sourceRect = { (short)sx, (short)sy, (unsigned short)sw, (unsigned short)sh };
		SDL_Rect targetRect = { (short)x,  (short)y,  (unsigned short)w,  (unsigned short)h };
		SDL_BlitSurface(texture->surface, &sourceRect, graphics::screen, &targetRect);
	
	cpp #sdl2 void draw
		SDL_Rect sourceRect = { sx, sy, sw, sh };
		SDL_Rect targetRect = { x, y, w, h };
		SDL_RenderCopy(graphics::renderer, texture->texture, &sourceRect, &targetRect);

transient DisplayItem DisplayRectangle
	Color color
	int borderWidth

	cpp #sdl1.2 void draw
		// Fill rectangle
		SDL_Rect fillRect = { (short)x, (short)y, (unsigned short)w, (unsigned short)h };
		Uint32 fillColor = SDL_MapRGBA(graphics::screen->format, color.red, color.green, color.blue, color.alpha);
		SDL_FillRect(graphics::screen, &fillRect, fillColor);

		// If there's a border, draw it
		if(borderWidth > 0) {
			// Top
			SDL_Rect topRect = { (short)x, (short)y, (unsigned short)w, (unsigned short)borderWidth };
			SDL_FillRect(graphics::screen, &topRect, fillColor);
			// Bottom
			SDL_Rect bottomRect = { (short)x, (short)(y+h-borderWidth), (unsigned short)w, (unsigned short)borderWidth };
			SDL_FillRect(graphics::screen, &bottomRect, fillColor);
			// Left
			SDL_Rect leftRect = { (short)x, (short)y, (unsigned short)borderWidth, (unsigned short)h };
			SDL_FillRect(graphics::screen, &leftRect, fillColor);
			// Right
			SDL_Rect rightRect = { (short)(x+w-borderWidth), (short)y, (unsigned short)borderWidth, (unsigned short)h };
			SDL_FillRect(graphics::screen, &rightRect, fillColor);
		}

	cpp #sdl2 void draw
		// Fill rectangle
		SDL_Rect fillRect = { x, y, w, h };
		SDL_SetRenderDrawColor(graphics::renderer, color.red, color.green, color.blue, color.alpha);
		SDL_RenderFillRect(graphics::renderer, &fillRect);

		// If there's a border, draw it
		if(borderWidth > 0) {
			// Top
			SDL_Rect topRect = { x, y, w, borderWidth };
			SDL_RenderFillRect(graphics::renderer, &topRect);
			// Bottom
			SDL_Rect bottomRect = { x, y+h-borderWidth, w, borderWidth };
			SDL_RenderFillRect(graphics::renderer, &bottomRect);
			// Left
			SDL_Rect leftRect = { x, y, borderWidth, h };
			SDL_RenderFillRect(graphics::renderer, &leftRect);
			// Right
			SDL_Rect rightRect = { x+w-borderWidth, y, borderWidth, h };
			SDL_RenderFillRect(graphics::renderer, &rightRect);
		}
	
transient DisplayItem DisplayText
	string text
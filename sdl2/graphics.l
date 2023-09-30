// A color comprised of a red, green, blue and alpha component
immutable Color
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
	
	// string toString := name or hex
	
	// Color: string hex = ""
	// 	this.hex = hex

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

enum ScaleMode: Auto, FixedWidth, FixedHeight, None
enum AnchorMode: TopLeft, TopCenter, Center
enum HorizontalAlignment: Left, Center, Right
enum VerticalAlignment: Top, Middle, Bottom
enum FontStyle: Normal, Bold
	
global skipInit unit graphics
	SDL_Renderer *renderer
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
		
	cpp(SDL_image.h, SDL_ttf.h) void init
		const int FONT_SIZE = 64;
		IMG_Init(IMG_INIT_PNG);
		TTF_Init();
		
		if(isFullscreen) {
			SDL_DisplayMode displayMode;
			SDL_GetCurrentDisplayMode(0, &displayMode);
			pixelSize = Vector2(displayMode.w, displayMode.h);
		} else {
			pixelSize = Vector2(referenceSize.x, referenceSize.y);
		}
		
		// SDL_Window *window = SDL_CreateWindow("Application", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, pixelSize.x, pixelSize.y, 0);
		SDL_Window *window = SDL_CreateWindow("Application", 1000, 100, pixelSize.x, pixelSize.y, 0);
		
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
		SDL_Rect bgRect = {0, 0, (int)size.x, (int)size.y};
		SDL_RenderCopy(renderer, texture->texture, NULL, &bgRect);
		
	// Draw an image. Place a PNG file in the "media" folder and it will automatically be imported
	// Example: We place an image called "Idle.png" in the "media" folder. Then, we draw this image at the position {0,0}, scale it to a width of 32 pixels. Only the current player instance will see the image.
	//     Player
	//         tick
	//             drawImage Idle, position:{0,0}, size:32, frame:0, visibleFor:me
	// Image: drawImage0.png
	global cpp void drawImage: Image image                         // The image to draw. PNG images in the "media" folder will automatically show up here
		                      Vector2 position = {}               // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                      implicit Vector2 size = {}          // A float scales the image to that width keeping the aspect ratio, a vector stretches the image
		                      implicit Player[] visibleFor = []   // Only this player or list of players will see the image
		                      implicit frame = 0                  // The frame to draw from a sequence of images (for example "Walk0.png", "Walk1.png", ...)
		                      implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                         // The opacity of the image (0: fully transparent, 1: fully visible)
		                      Color color = White                 // Tint the image with this color
		                      HorizontalAlignment align = Center  // The horizontal alignment of the image
		                      VerticalAlignment valign = Middle   // The vertical alignment of the image
		if(graphics::isVisibleFor(visibleFor)) {
			auto f = image->frames[frame];
			double unscaledSizeX = size.x ? size.x : f.w;
			double sizeX = unscaledSizeX * scale;
			double sizeY = (size.y ? size.y : (unscaledSizeX/f.w)*f.h) * scale;
			double posX = (align == 0  ? position.x : align  == 1 ? position.x-sizeX*.5 : position.x-sizeX) + offset.x;
			double posY = (valign == 0 ? position.y : valign == 1 ? position.y-sizeY*.5 : position.y-sizeY) + offset.y;
			SDL_Rect sourceRect = { (int)f.x1, (int)f.y1, (int)f.w, (int)f.h };
			SDL_Rect targetRect = { (int)posX, (int)posY, (int)sizeX, (int)sizeY };
			// system::print("size.x:"+std::to_string(size.x));
			// system::print("f.w:"+std::to_string(f.w));
			// system::print("sizeX:"+std::to_string(sizeX));
			SDL_RenderCopy(renderer, image->texture->texture, &sourceRect, &targetRect);
		}
		
	global cpp void drawText: implicit string text                // A string or anything that can be converted into a string (for example, an interger or a float)
		                      Vector2 position = {}               // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                      implicit Vector2 size = {}          // The size of the text
		                      Color color = null                  // The color of the text
		                      HorizontalAlignment align = Center  // The horizontal alignment of the text
		                      VerticalAlignment valign = Middle   // The vertical alignment of the text
		                      FontStyle style = Normal            // Whether the text should be bold or normal style
		                      Font font = null                    // To use a custom font, just copy a TTF, WOFF or WOFF2 file to the "media" folder
		                      Color outlineColor = null           // The color of the outline around the text
		                      outlineWidth = 0                    // The width of the outline around the text in pixels
		                      implicit Player[] visibleFor = []   // Only this player or list of players will see the text
		                      implicit layer = 0                  // Higher layers are drawn in front of lower layers
		                      alpha = 1.0                         // The opacity of the text (0: fully transparent, 1: fully visible)

	cpp void startFrame
	    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
	    SDL_RenderClear(renderer);
		
	cpp void finishFrame
		SDL_RenderPresent(renderer);
		
immutable skipInit class Font
	string name
	string file
	cpp void open

cpp(SDL.h, SDL_Texture) immutable class SDL_Texture
cpp(SDL.h, SDL_Renderer) immutable class SDL_Renderer

immutable class Texture
	string file
	Vector2 size
	SDL_Texture *texture
	
	cpp void open
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

		
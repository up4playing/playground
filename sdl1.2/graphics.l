global skipInit unit graphics
	SDL_Renderer renderer
	public Vector2 referenceSize = {1080, 1920}
	visible Vector2 pixelSize
	visible Vector2 size
		
	cpp(SDL_image.h, SDL_ttf.h) void init
		const int FONT_SIZE = 64;
		IMG_Init(IMG_INIT_PNG);
		TTF_Init();
		
		SDL_DisplayMode displayMode;
		SDL_GetCurrentDisplayMode(0, &displayMode);
		size = Vector2(displayMode.w, displayMode.h);
		
		SDL_Window *window = SDL_CreateWindow(
			"LiveTime Window", 
			SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 
			size.x, size.y, 0
		);
		SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN);
		renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
		
	// updateBaseMatrix
	// 	Vector2 ratio = {pixelSize.x / referenceSize.x, pixelSize.y / referenceSize.y}
	// 	float scale
	// 	if scaleMode == Auto
	// 		if ratio.x < ratio.y: effectiveScaleMode = FixedWidth;  scale = ratio.x
	// 		else                  effectiveScaleMode = FixedHeight; scale = ratio.y
	// 		size = referenceSize
	// 	else
	// 	if scaleMode == FixedWidth
	// 		effectiveScaleMode = scaleMode
	// 		scale = ratio.x
	// 		size = {referenceSize.x, pixelSize.y/scale}
	// 	else
	// 	if scaleMode == FixedHeight
	// 		effectiveScaleMode = scaleMode
	// 		scale = ratio.y; 
	// 		size = {pixelSize.x/scale, referenceSize.y}
			
	// 	let offsetX = anchor > 0 ? pixelSize.x/2 : 0
	// 	let offsetY = anchor > 1 ? pixelSize.y/2 : 0
	// 	baseMatrix = {scale,0,0,scale,offsetX-(statisticsMargin.x/2)*scale,offsetY-(statisticsMargin.y/2)*scale}

		
	global cpp void drawTexture: Texture texture
		                         Vector2 position = {0,0}
		SDL_Rect bgRect = {0, 0, (int)size.x, (int)size.y};
		SDL_RenderCopy(renderer, texture->texture, NULL, &bgRect);
		
	global cpp void drawImage: Image image
		                       Vector2 position = {0,0}
		                       int frame = 0
		auto f = image->frames[frame];
		SDL_Rect sourceRect = { (int)f.x1, (int)f.y1, (int)f.w, (int)f.h };
		SDL_Rect targetRect = { (int)position.x, (int)position.y, (int)(f.w*2), (int)(f.h*2.4) };
		SDL_RenderCopy(renderer, image->texture->texture, &sourceRect, &targetRect);
		
	cpp void startFrame
	    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
	    SDL_RenderClear(renderer);
		
	cpp void finishFrame
		SDL_RenderPresent(renderer);
		
immutable class Font
	string name
	string file
	cpp void open

cpp(SDL.h, SDL_Texture) immutable class SDL_Texture
cpp(SDL.h, SDL_Renderer) immutable class SDL_Renderer

immutable class Texture
	string file
	Vector2 size
	SDL_Texture texture
	
	cpp void open
		system::print(file);
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

		
skipInit unit Platform
	userCount = 1
	bool running
	
	cpp(SDL.h) void initMedia
		SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
		graphics::init();
		Image::init();
		Font::init();
		audio::init();
		
	cpp void initPlatform
		core::init();
		Platform::init();
		app::init();
		
	cpp(thread, chrono) void start
		system::print(std::string("------------------------------------------ ")+std::string(_appName)+std::string(" Version ")+std::to_string(_buildVersion)+std::string(" ------------------------------------------"));
		Platform::initMedia();
		Platform::initPlatform();
		Platform::openMedia();
		core::startLocal();
		
		// Sound
		// Mix_Chunk *sfx = Mix_LoadWAV("sfx/hop.wav");
		// Mix_Chunk *bgm = Mix_LoadWAV("bgm/Mars.wav");
		
		// Font
		// const int FONT_SIZE = 64;
		// const SDL_Color COLOR_BLACK = {0, 0, 0, 255};
		// TTF_Font *font = TTF_OpenFont("font/MMXSNES.ttf", FONT_SIZE);
		// SDL_Surface *surface = TTF_RenderUTF8_Solid(font, "Hello World v5", COLOR_BLACK);
		// SDL_Texture *text = SDL_CreateTextureFromSurface(renderer, surface);
		// int textW, textH;
		// SDL_QueryTexture(text, NULL, NULL, &textW, &textH);
		
		// SDL_Surface *bgSurface = IMG_Load("img/battleback8.png");
		// SDL_Texture *background = SDL_CreateTextureFromSurface(renderer, bgSurface);
		
		// Mix_PlayChannel(-1, bgm, -1);
		
		SDL_Event event;
		running = true;
		while (running) {
			while (SDL_PollEvent(&event)) {
				switch(event.type) {
					case SDL_QUIT:    running = false; break;
					case SDL_KEYDOWN: input::handleKeyEvent(InputType_KeyDown, event.key.keysym.scancode, (Key)event.key.keysym.sym); break;
					case SDL_KEYUP:   input::handleKeyEvent(InputType_KeyUp,   event.key.keysym.scancode, (Key)event.key.keysym.sym); break;
				}
			}
			core::animationFrame();
			// std::this_thread::sleep_for(std::chrono::milliseconds(16));
		}
		// Mix_HaltChannel(-1);
		
		// Mix_FreeChunk(sfx);
		// Mix_FreeChunk(bgm);
		// TTF_CloseFont(font);
		
		// SDL_DestroyTexture(text);
		// SDL_DestroyTexture(background);
		// SDL_DestroyRenderer(renderer);
		// SDL_DestroyWindow(window);
		
		// SDL_FreeSurface(surface);
		// SDL_FreeSurface(bgSurface);
		
		Mix_Quit();
		TTF_Quit();
		IMG_Quit();
		SDL_Quit();
		
	quit
		running = false	
		
	// cpp(thread, chrono) void sleep: Time time
	// 	std::this_thread::sleep_for(std::chrono::milliseconds(time));
		



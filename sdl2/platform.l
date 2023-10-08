unit Platform
	cpp(SDL.h) void initMedia
		SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO);
		graphics::init();
		Image::init();
		Font::init();
		audio::init();
		
	cpp void start
		Platform::initMedia();
		Platform::openMedia();
		init();
		app::start();
		
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
		bool done = false;
		while (!done) {
			while (SDL_PollEvent(&event)) {
				if (event.type == SDL_QUIT) {
					done = true;
				} else if (event.type == SDL_KEYUP) {
					switch (event.key.keysym.scancode) {
						case SDL_SCANCODE_SPACE:
							// Mix_PlayChannel(-1, sfx, 0);
							break;
						case SDL_SCANCODE_ESCAPE:
							done = true;
							break;
						default:
							break;
					}
				}
			}
		
			graphics::startFrame();
			app::tick();
			graphics::finishFrame();
		
			// SDL_Rect textRect = {(width - textW) / 2, (height - textH) / 2, textW, textH};
			// SDL_RenderCopy(renderer, text, NULL, &textRect);
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



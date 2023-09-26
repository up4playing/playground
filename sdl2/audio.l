global skipInit unit audio
	cpp(SDL2/SDL_mixer.h) void init
		const int AUDIO_CHUNK_SIZE = 512;
		Mix_Init(MIX_INIT_OGG);
		Mix_OpenAudio(
			MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, 
			MIX_DEFAULT_CHANNELS, AUDIO_CHUNK_SIZE
		);
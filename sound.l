// A sound
class Sound
	string file
	float fadeVolume = 1
	
	// Sound() open
	// js void open
	// 	if(!window._audioCache) {
	// 		_audioCache = {}
	// 	}
	// 	this.audio = _audioCache[this.file]
	// 	if(!this.audio) {
	// 		this.audio = window._audioCache[this.file] = new Audio()
	// 		this.audio.src = this.file
	// 	} else {
	// 		this.audio.pause();
	// 	}
		
	js void volume: float value
		this.fadeVolume = value
		if(this.audio) this.audio.volume = this.fadeVolume * audio_volume
		
	js void updateVolume
		if(this.audio) this.audio.volume = this.fadeVolume * audio_volume
		
	js void stop
		if(!Platform_fastForward && this.audio) {
			this.audio.pause()
		}
		
	js void play
		if(!Platform_fastForward) {
			this.fadeVolume = 1
			// this.audio.volume = audio_volume
			// this.audio.currentTime = 0
			this.audio = new Audio();
			this.audio.src = this.file;
			this.audio.volume = audio_volume;
			this.audio.play();
		}
		
	fadeOut: int duration = 3000
		     int delay = 0
		fx.add FadeSoundEffect startTime:Time.now+delay, duration, this, startValue:1, delta:-1
		return this

// A collection of functions for playing audio
transient global unit audio
	const float[] volumeLevels = [0, .01, .02, .04, .08, .16, .32, .64, 1]
	float volumeLevel = 8
	float volume = volumeLevels[volumeLevel]
	
	// TEMP!!!
	// mute: int forUser = -1
	// 	if forUser == -1 or forUser == Network.userId
	// 		volumeLevel = 0
	// 		volume = volumeLevels[volumeLevel]
	
	// decreaseVolume: int forUser = -1
	// 	if forUser == -1 or forUser == Network.userId
	// 		volumeLevel = Math.limit(volumeLevel-1, min:0, max:volumeLevels.length-1)
	// 		volume = volumeLevels[volumeLevel]
	
	// increaseVolume: int forUser = -1
	// 	if forUser == -1 or forUser == Network.userId
	// 		volumeLevel = Math.limit(volumeLevel+1, min:0, max:volumeLevels.length-1)
	// 		volume = volumeLevels[volumeLevel]
	// 		print volume, forUser
	
	global playSound: Sound sound, int delay = 0
		if Time.frame == 0
			fx.add PlaySoundEffect startTime:Math.ceil(Time.now+Network.targetFrameTime)+delay, sound
		else
		if delay
			fx.add PlaySoundEffect startTime:Time.now+delay, sound
		else	
			sound.play
		
	js void pause
		if(window._audioCache) {
			for(let key in _audioCache) {
				_audioCache[key].pause();
			}
		}

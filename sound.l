// A sound
class Sound
	string file
	float fadeVolume = 1
	
	js void open
		return new Promise((resolve, reject) => {
			this.audio = new Audio();
			this.audio.oncanplaythrough = () => resolve();
			this.audio.onerror = () => reject();
			this.audio.src = this.file;			
		})
		
	js void volume: float value
		this.fadeVolume = value
		if(this.audio) this.audio.volume = this.fadeVolume * audio_volume
		
	js void updateVolume
		if(this.audio) this.audio.volume = this.fadeVolume * audio_volume
		
	js void stop
		if(Input_isCertain && this.audio) {
			this.audio.pause()
		}
		
	js void play
		if(Input_isCertain && !(Platform_isDebug && Platform_fastForward)) {
			this.fadeVolume = 1;
			this.audio = new Audio();
			this.audio.src = this.file;
			this.audio.volume = audio_volume;
			this.audio.play();
		}
		
	fadeOut: int duration = 3000
		     int delay = 0
		fx.add FadeSoundEffect startTime:Time.now+delay, duration, smooth:false, this, startValue:1, delta:-1
		return this

// A collection of functions for playing audio
transient global unit audio
	const float[] volumeLevels = [0, 0.0001, 0.0002, 0.0005, 0.001, 0.002, 0.005, .01, .02, .04, .08, .16, .32, .64, 1]
	float volumeLevel = 10
	float volume = volumeLevels[volumeLevel]
	
	mute: int forUser = -1
		if forUser == -1 or forUser == Input.localUser?.id
			volumeLevel = 0
			volume = volumeLevels[volumeLevel]
	
	decreaseVolume: int forUser = -1
		if forUser == -1 or forUser == Input.localUser?.id
			volumeLevel = Math.limit(volumeLevel-1, min:0, max:volumeLevels.length-1)
			volume = volumeLevels[volumeLevel]
	
	increaseVolume: int forUser = -1
		if forUser == -1 or forUser == Input.localUser?.id
			volumeLevel = Math.limit(volumeLevel+1, min:0, max:volumeLevels.length-1)
			volume = volumeLevels[volumeLevel]
			print volume, forUser
	
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

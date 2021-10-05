// A sound
class Sound
	string file
	Sound() open
	
	js void open
		if(!window._audioCache) {
			_audioCache = {}
		}
		this.audio = _audioCache[this.file]
		if(!this.audio) {
			this.audio = window._audioCache[this.file] = new Audio()
			this.audio.src = this.file
		} else {
			this.audio.pause();
		}
		this.audio.currentTime = 0
		this.audio.volume = 1
		
	js void volume: float value
		this.audio.volume = value
		
	js void stop
		if(!Platform_fastForward) {
			this.audio.pause()
			this.audio.currentTime = 0
		}
		
	js void play
		if(!Platform_fastForward) {
			this.audio.currentTime = 0
			this.audio.volume = 1
			this.audio.play()
		}
		
	fadeOut: int duration = 3000
		     int delay = 0
		fx.add FadeSoundEffect startTime:Time.now+delay, duration, this, startValue:1, delta:-1
		return this

// A collection of functions for playing audio
transient global unit audio
	global playSound: Sound sound
		if Time.frame == 0
			fx.add PlaySoundEffect startTime:Math.ceil(Time.now+Network.targetFrameTime), sound
		else
			sound.play
		
	js void pause
		if(window._audioCache) {
			for(let key in _audioCache) {
				_audioCache[key].pause();
			}
		}

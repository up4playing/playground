// A sound
skipInit class Sound
	string file
	float fadeVolume = 1
	
	js void open
		return new Promise((resolve, reject) => {
			this.nextAudio = new Audio();
			this.nextAudio.oncanplaythrough = () => resolve();
			this.nextAudio.onerror = () => reject();
			this.nextAudio.src = this.file;			
		})
		
	js void volume: float value
		this.fadeVolume = value
		if(this.audio) this.audio.volume = this.fadeVolume * audio_volume
		
	js void updateVolume
		if(this.audio) this.audio.volume = this.fadeVolume * audio_volume
		
	js void stop
		if(this.audio) this.audio.pause()
		
	play
		// We can play sounds immediately to ensure there is no lag
		// If a sound turns out to be wrong after receiving new inputs, we stop it
		let playingSound = audio.playingSounds.find.sound == this and .frame == Time.frame
		if !playingSound
			audio.playingSounds.add playingSound = {this, frame:Time.frame, isConfirmed:true}
			if not Network.isReplay: doPlay playingSound
		else
			playingSound.isConfirmed = true
			
	js void currentTime: float value
		if(this.audio) this.audio.currentTime = value
		
	private js void doPlay: PlayingSound ps
		// Recreate audio if it was lost during serialization
		if(!this.nextAudio) this.preloadForNextPlayback();
			
		// Play audio
		this.fadeVolume = 1;
		this.audio = this.nextAudio;
		this.audio.volume = audio_volume;
		this.audio.onended = () => audio_playingSounds.remove(ps);
		this.audio.play();
		this.preloadForNextPlayback()
		
	private js void preloadForNextPlayback()
		this.nextAudio = new Audio();
		this.nextAudio.src = this.file;
		
	isPlaying
		return audio.playingSounds.any.sound == this and .frame < Time.frame
		
	fadeOut: Time duration = 3000
		     Time delay = 0
		fx.add FadeSoundEffect startTime:Time.now+delay, duration, smooth:false, this, startValue:1, delta:-1
		return this

transient class PlayingSound
	Sound sound
	int frame
	bool isConfirmed
	
// A collection of functions for playing audio
transient global skipInit unit audio
	const float[] volumeLevels = [0, 0.0001, 0.0002, 0.0005, 0.001, 0.002, 0.005, .01, .02, .04, .08, .16, .32, .64, 1]
	int volumeLevel = 10
	float volume = volumeLevels[volumeLevel]
	PlayingSound[] playingSounds
	
	internal startFrame
		playingSounds.each.isConfirmed = false
		
	internal finishFrame
		// Stop sounds that turned out to be wrong after receiving new inputs
		playingSounds.each: if .frame == Time.frame and !.isConfirmed: .sound.stop
		
	stop
		playingSounds.each.sound.stop
	
	mute: int forUser = -1
		if forUser == -1 or forUser == Input.localUser?.id
			volumeLevel = 0
			volume = volumeLevels[volumeLevel]
			playingSounds.each.sound.updateVolume
	
	adjustVolume: int delta = 1, int forUser = -1
		if forUser == -1 or forUser == Input.localUser?.id
			volumeLevel = Math.limit(volumeLevel+delta, min:0, max:volumeLevels.length-1)
			volume = volumeLevels[volumeLevel]
			playingSounds.each.sound.updateVolume
	
	global playSound: Sound sound, Time delay = 0, bool smooth = false
		if Time.frame == 0
			fx.add PlaySoundEffect startTime:Math.ceil(Time.now+Network.targetFrameTime)+delay, sound, smooth
		else
		if delay
			fx.add PlaySoundEffect startTime:Time.now+delay, sound, smooth
		else
		if not smooth or Input.isCertain
			sound.play

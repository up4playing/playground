// A sound
skipInit class Sound
	string file
	transient dynamic audioElement
	
	js void open
		return new Promise((resolve, reject) => {
			this.nextAudioElement = new Audio();
			this.nextAudioElement.oncanplaythrough = () => resolve();
			this.nextAudioElement.onerror = () => reject();
			this.nextAudioElement.src = _basePath+this.file;			
		})
		
	js void stop
		if(this.audioElement) this.audioElement.pause()
		
	js void currentTime: float value
		if(this.audioElement) this.audioElement.currentTime = value
		
	js void play
		// Recreate audio if it was lost during serialization
		if(!this.nextAudioElement) this.preloadForNextPlayback();
			
		audio.playingSounds.push(this);
		this.audioElement = this.nextAudioElement;
		this.audioElement.volume = audio.volume;
		this.audioElement.onended = () => audio.playingSounds.remove(this);
		this.audioElement.play();
		this.preloadForNextPlayback()
		
	internal js void preloadForNextPlayback
		this.nextAudioElement = new Audio();
		this.nextAudioElement.src = _basePath+this.file;

transient class PlayingSound
	Sound sound
	int frame
	bool isConfirmed
	
// A collection of functions for playing audio
transient global skipInit unit audio
	const float[] volumeLevels = [0, 0.0001, 0.0002, 0.0005, 0.001, 0.002, 0.005, .01, .02, .04, .08, .16, .32, .64, 1]
	int volumeLevel = 14
	float volume = volumeLevels[volumeLevel]
	Sound[] playingSounds
	
	global playSound: Sound sound
		sound.play
	
	stop
		playingSounds.each.stop
		playingSounds.clear
	
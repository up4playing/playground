global unit fx
	internal Effect[] effects
	add: Effect effect
		effects.add effect
		
	tick
		let now = Time.now
		for effects <-
			if now >= .startTime and (not .smooth or Network.isSmooth)
				float f = .duration ? (now - .startTime)/.duration : 1
				if f >= 1: f = 1; effects.removeAt i
				.tick f
				
	global delay: Time time = 0
		          bool smooth = false
		          stored void() do
		add RunEffect startTime:Time.now+time, smooth, do
				
class Effect
	Time startTime
	Time duration
	bool smooth
	tick: float f

Effect FadeEffect
	Object object
	float startValue, delta
	bool removeWhenDone
	tick(float f) 
		object.alpha = startValue + delta * f
		if f >= 1 and removeWhenDone: Framework.objects.remove object
		
Effect MoveEffect
	Object object
	Vector2 startValue, delta
	tick(float f) object.position = startValue + delta * f
		
Effect ScaleEffect
	Object object
	implicit Vector2 startValue
	implicit Vector2 delta
	tick(float f) object.size = startValue + delta * f
	
Effect FadeSoundEffect
	float startValue, delta
	private dynamic audioElement
	
	FadeSoundEffect: Sound sound
		this.audioElement = sound.audioElement
	tick(float f)
		if audioElement == null: return
		audioElement.volume = (startValue + delta * f) * audio.volume
		if f >= 1: audioElement.pause
			
Effect PlaySoundEffect
	Sound sound
	tick(float f) sound.play
	
Effect RunEffect
	void() do
	tick(float f) do()
	


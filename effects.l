global unit fx
	internal Effect[] effects
	add: Effect effect
		effects.add effect
		
	removeForObject: Object object
		effects.removeWhere.object == object
		
	endOfPrevEffect: Object object
		let lastEffect = effects[-1]
		if lastEffect?.object == object
			return Math.max(Time.now, lastEffect.startTime + lastEffect.duration)
		return Time.now
		
	internal tick
		let now = Time.now
		for effects <-
			if now >= .startTime
				float f = .duration ? (now - .startTime)/.duration : 1
				if f >= 1: f = 1; effects.removeAt i
				.tick f
				
	global delay: Time time = 0
		          stored void() do
		add DelayEffect startTime:Time.now+time, do
				
class Effect
	Time startTime
	Time duration
	Object object
	tick: float f
	
Effect FadeEffect
	float startValue, delta
	bool removeWhenDone
	tick(float f) 
		object.alpha = startValue + delta * f
		if f >= 1 and removeWhenDone: Framework.objects.remove object
		
Effect MoveEffect
	Vector2 startValue, delta
	tick(float f) object.position = startValue + delta * f
		
Effect ScaleEffect
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
	
Effect DelayEffect
	void() do
	tick(float f) do()
	


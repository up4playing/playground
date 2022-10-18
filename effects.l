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
				
	global delay: Time time
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
	float startValue, delta
	tick(float f) object.scale = startValue + delta * f
		
Effect RadiusEffect
	CircleObject object
	float startValue, delta
	tick(float f) object.radius = startValue + delta * f
	
Effect FadeSoundEffect
	Sound sound
	float startValue, delta
	tick(float f) 
		sound.volume = startValue + delta * f
		if f >= 1: sound.stop
			
Effect PlaySoundEffect
	Sound sound
	tick(float f) sound.play
	
Effect RunEffect
	void() do
	tick(float f) do()
	


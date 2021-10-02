unit fx
	private Effect[] effects
	add: Effect effect
		effects.add effect
		
	tick
		let now = Time.now
		for i,e <- effects
			if now >= e.startTime
				float f = e.duration ? (now - e.startTime)/e.duration : 1
				if f >= 1: f = 1; effects.removeAt i
				e.tick f
				
	run: int delay
		 void() code
		add RunEffect startTime:Time.now+delay, code
				
class Effect
	int startTime
	int duration
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
	float2 startValue, delta
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
	void() code = null
	tick(float f) code()
	


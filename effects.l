unit effects
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
				
class Effect
	int startTime
	int duration
	tick: float f

Effect MoveEffect
	Object object
	float2 startValue, delta
	tick(float f) object.position = startValue + delta * f
		
Effect FadeEffect
	Object object
	float startValue, delta
	tick(float f) object.alpha = startValue + delta * f
		
Effect ScaleEffect
	Object object
	float startValue, delta
	tick(float f) object.scale = startValue + delta * f


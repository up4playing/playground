immutable EaseFunction
	float(float x) function
	
	// Interpolate linearly without easing
	global const EaseFunction None    = { x }
		
	// Ease in with a sine function
	global const EaseFunction InSin = { 1 - math.cos(.25*x) }
	
	// Ease out with a sine function
	global const EaseFunction OutSin = { math.sin(.25*x) }
		
	// Ease in and out with a sine function
	global const EaseFunction InOutSin = { -(math.cos(.5*x) - 1) *.5 }
		
	// Ease in with a quadratic function
	global const EaseFunction InQuadratic  = { x * x }
	
	// Ease out with a quadratic function
	global const EaseFunction OutQuadratic  = { 1 - (1 - x) * (1 - x) }
		
	// Ease in and out with a quadratic function
	global const EaseFunction InOutQuadratic  = { x < 0.5 ? 2 * x * x : 1 - math.pow(-2 * x + 2, 2) / 2 }
		
	// Ease out with a cubic function
	global const EaseFunction InCubic  = { x * x * x }
		
	// Ease out with a cubic function
	global const EaseFunction OutCubic  = { 1 - math.pow(1 - x, 3) }
		
	// Ease in and out with a cubic function
	global const EaseFunction InOutCubic  = { x < 0.5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3) / 2 }
		
	// Ease out with a quartic function
	global const EaseFunction InQuartic  = { x * x * x * x }
		
	// Ease out with a quartic function
	global const EaseFunction OutQuartic  = { 1 - math.pow(1 - x, 4) }
		
	// Ease in and out with a quartic function
	global const EaseFunction InOutQuartic  = { x < 0.5 ? 8 * x * x * x * x : 1 - math.pow(-2 * x + 2, 4) / 2 }
		
	// Bounce back in the beginning
	global const EaseFunction InBack = { 2.70158 * x * x * x - 1.70158 * x * x }
		
	// Bounce back in the end
	global const EaseFunction OutBack = { 1 + 2.70158 * math.pow(x - 1, 3) + 1.70158 * math.pow(x - 1, 2) }
		
	// Bounce back in the beginning and the end
	global const EaseFunction InOutBack = { x < 0.5 ? (math.pow(2 * x, 2) * ((2.70158 + 1) * 2 * x - 2.70158)) / 2 : (math.pow(2 * x - 2, 2) * ((2.70158 + 1) * (x * 2 - 2) + 2.70158) + 2) / 2 }
	
struct float
	// Interpolates to another value
	inline float interpolateTo: float target   // The target value to interpolate to
		                        float progress // The progress of the interpolation (0: return the start value, 1: returns the target value)
		math.map(progress, start:this, target)
		
	inline float interpolateTo: float target   // The target value to interpolate to
		                        float progress // Between "from" and "to" ("from" returns the start value, "to" returns the target value)
		                        float from     // The beginning of the input range, if "progress" is "from" or less, the start value is returned
		                        float to       // The end of the input range, if "progress" is "to" or more, the target value is returned
		math.map(progress, from, to, start:this, target)
		
	// Interpolates to another value
	inline float interpolateTo: float target      // The target value to interpolate to
		                        float progress    // The progress of the interpolation (0: return the start value, 1: returns the target value)
		                        EaseFunction ease // The easing function to apply (e.g InQuad, OutBack, ...)
		math.map(progress, from:0, to:1, start:this, target, ease)
	
	// Animate the float to a target value over a given period of time	
	inline animateTo: float target        // The target value to animate to
		              Time delay = 0      // The delay before the animation starts
		              Time duration = 300 // The duration of the animation
		fx.interpolate this, target, delay, duration, this = .
	
	// Animate the float to a target value over a given period of time	
	inline animateTo: float target        // The target value to animate to
		              Time delay = 0      // The delay before the animation starts
		              Time duration = 300 // The duration of the animation
		              EaseFunction ease   // The easing function to apply
		fx.interpolate this, target, delay, duration, ease, this = .

struct Vector2
	// Interpolates to another vector
	interpolateTo: Vector2 target  // The target position to interpolate to
		           float progress  // The progress of the interpolation (0: return the start vector, 1: returns the target vector)
		if progress <= 0: return this
		if progress >= 1: return target
		let iprogress = 1 - progress
		return new Vector2(x * iprogress + target.x * progress, y * iprogress + target.y * progress)

	// Interpolates to another vector
	interpolateTo: Vector2 target  // The target position to interpolate to
		           Time startTime
		           Time duration = 300
		let progress = (Time.now - startTime) / duration
		if progress <= 0: return this
		if progress >= 1: return target
		let iprogress = 1 - progress
		return new Vector2(x * iprogress + target.x * progress, y * iprogress + target.y * progress)

	// Interpolates to another vector
	interpolateTo: Vector2 target  // The target position to interpolate to
		           float progress  // The progress of the interpolation (0: return the start vector, 1: returns the target vector)
		           EaseFunction ease
		if progress <= 0: return this
		if progress >= 1: return target
		progress = ease.function(progress)
		let iprogress = 1 - progress
		return new Vector2(x * iprogress + target.x * progress, y * iprogress + target.y * progress)

	// Interpolates to another vector
	interpolateTo: Vector2 target  // The target position to interpolate to
		           Time startTime
		           Time duration = 300
		           EaseFunction ease
		let progress = (Time.now - startTime) / duration
		if progress <= 0: return this
		if progress >= 1: return target
		progress = ease.function(progress)
		let iprogress = 1 - progress
		return new Vector2(x * iprogress + target.x * progress, y * iprogress + target.y * progress)

	// // Interpolates to another vector
	interpolateTo: Vector2 target // The target position to interpolate to
		           float progress // Between "from" and "to" ("from" returns the start value, "to" returns the target value)
		           float from     // The beginning of the input range, if "progress" is "from" or less, the start value is returned
		           float to       // The end of the input range, if "progress" is "to" or more, the target value is returned
		if progress <= from: return this
		if progress >= to: return target
		let factor = (progress-from) / (to-from)
		return new Vector2(x + (target.x-x)*factor, y + (target.y-y)*factor)

	// // Interpolates to another vector
	interpolateTo: Vector2 target    // The target position to interpolate to
		           float progress    // Between "from" and "to" ("from" returns the start value, "to" returns the target value)
		           float from        // The beginning of the input range, if "progress" is "from" or less, the start value is returned
		           float to          // The end of the input range, if "progress" is "to" or more, the target value is returned
		           EaseFunction ease // The easing function to apply
		if progress <= from: return this
		if progress >= to: return target
		let factor = ease.function((progress-from) / (to-from))
		return new Vector2(x + (target.x-x)*factor, y + (target.y-y)*factor)
		
	// Animate the vector to a target vector over a given period of time
	inline animateTo: Vector2 target      // The target vector to animate to
		              Time delay = 0      // The delay before the animation starts
		              Time duration = 300 // The duration of the animation
		fx.interpolate this, target, delay, duration, this.x = .x; this.y = .y

	// Animate the vector to a target vector over a given period of time
	inline animateTo: Vector2 target      // The target vector to animate to
		              Time delay = 0      // The delay before the animation starts
		              Time duration = 300 // The duration of the animation
		              EaseFunction ease   // The easing function to apply
		fx.interpolate this, target, delay, duration, ease, this.x = .x; this.y = .y

Color
	// Interpolates to another color
	Color interpolateTo: Color target
		                 float progress
		if progress <= 0: return this
		if progress >= 1: return target
		let iprogress = 1 - progress
		return {
			math.floor(red   * iprogress + target.red   * progress)
			math.floor(green * iprogress + target.green * progress)
			math.floor(blue  * iprogress + target.blue  * progress)
		}
		
	// Animate the color to a target vector over a given period of time
	inline animateTo: Color target        // The target color to animate to
		              Time delay = 0      // The delay before the animation starts
		              Time duration = 300 // The duration of the animation
		fx.interpolate this, target, delay, duration, this = .
	
global skipInit unit math
	// Maps a value from an input range to an output range
	map: float progress // The input value 
		 float from     // The beginning of the input range
		 float to       // The end of the input range
		 float start    // The lowest possible output value, will be returned for values smaller than "from".
		 float target   // The highest possible output value, will be returned for values larger than "to".
		if progress <= from: return start
		if progress >= to:   return target
		let factor = (progress-from) / (to-from)
		return start + (target-start) * factor
			
	// Maps a value from an input range to an output range
	map: float progress  // The input value 
		 float start     // The lowest possible output value, will be returned for values smaller than "from".
		 float target    // The highest possible output value, will be returned for values larger than "to".
		if progress <= 0: return start
		if progress >= 1: return target
		return start + (target-start) * progress
			
	// // Maps a value from an input range to an output range
	map: float progress    // The input value 
		 float from = 0    // The beginning of the input range
		 float to = 1      // The end of the input range
		 float start = 0   // The lowest possible output value, will be returned for values smaller than "from".
		 float target = 1  // The highest possible output value, will be returned for values larger than "to".
		 EaseFunction ease // The easing function to apply
		if progress <= from: return start
		if progress >= to:   return target
		let factor = ease.function((progress-from) / (to-from))
		return start + (target-start) * factor
		
	// // Maps a value from an input range to an output range
	// map: Time value        // The input value 
	// 	 Time from = 0     // The beginning of the input range
	// 	 Time to = 1       // The end of the input range
	// 	 float start = 0   // The lowest possible output value, will be returned for values smaller than "from".
	// 	 float target = 1  // The highest possible output value, will be returned for values larger than "to".
	// 	if value <= from: return start
	// 	if value >= to:   return target
	// 	let factor = (value-from) / (to-from)
	// 	return start + (target-start) * factor
		
	// Maps a value from an input range to an output range
	// map: float value    // The input value 
	// 	 float from = 0 // The beginning of the input range
	// 	 float to = 1   // The end of the input range
	// 	 Vector2 start  // The start output position, will be returned for values smaller than "from".
	// 	 Vector2 target // The target output position, will be returned for values larger than "to".
	// 	if value <= from: return start
	// 	if value >= to:   return target
	// 	let factor = (value-from) / (to-from)
	// 	return start + (target-start) * factor
			
	// // Maps a value from an input range to an output range
	// map: float value       // The input value 
	// 	 float from = 0    // The beginning of the input range
	// 	 float to = 1      // The end of the input range
	// 	 Vector2 start     // The start output position, will be returned for values smaller than "from".
	// 	 Vector2 target    // The target output position, will be returned for values larger than "to".
	// 	 EaseFunction ease // The easing function to apply
	// 	if value <= from: return start
	// 	if value >= to:   return target
	// 	let factor = (value-from) / (to-from)
	// 	return start + (target-start) * ease.function(factor)
		
	global interpolate: float from = 0
		                float to = 1
		                Time startTime = 0
		                Time duration = 1
		let value = Time.now - startTime
		if value <= 0:        return from
		if value >= duration: return to
		return from + (to-from) * (value/duration)
		
	global interpolate: Color from
		                Color to
		                Time startTime = 0
		                Time duration = 1
		return from interpolateTo to, (Time.now - startTime)/duration
	
global unit fx
	internal Animation[] animations
	add: Animation animation
		animations.add animation
		
	removeForObject: Object object
		animations.removeWhere.object == object
		
	endOfPrevAnimation: Object object
		let lastAnimation = animations.last
		if lastAnimation?.object == object
			return math.max(Time.now, lastAnimation.startTime + lastAnimation.duration)
		return Time.now
		
	internal tick
		let now = Time.now
		for animations <-
			if now >= .startTime
				float f = .duration ? (now - .startTime)/.duration : 1
				if f >= 1: f = 1; animations.removeAt i
				.tick f
				
	global delay: Time time = 0
		          stored void() do
		add DelayAnimation startTime:Time.now+time, do
		
	// Animate a variable to a target value over a given period of time
	global inline animate: float variable = 0   // The variable to animate
		                   float to = 1         // The target value to animate to
		                   Time delay = 0       // The delay before the animation starts
		                   Time duration = 300  // The duration of the animation
		interpolate variable, to, delay, duration, variable = .
		
	// Animate a variable to a target value over a given period of time
	global inline animate: float variable = 0   // The variable to animate
		                   float to = 1         // The target value to animate to
		                   Time delay = 0       // The delay before the animation starts
		                   Time duration = 300  // The duration of the animation
		                   EaseFunction ease    // The easing function to apply
		interpolate variable, to, delay, duration, ease, variable = .
		
	// Animate a variable to a target value over a given period of time
	global inline animate: Vector2 variable    // The variable to animate
		                   Vector2 to          // The target vector to animate to
		                   Time delay = 0      // The delay before the animation starts
		                   Time duration = 300 // The duration of the animation
		interpolate variable, to, delay, duration, variable = .
		
	// Animate a variable to a target value over a given period of time
	global inline animate: Vector2 variable    // The variable to animate
		                   Vector2 to          // The target vector to animate to
		                   Time delay = 0      // The delay before the animation starts
		                   Time duration = 300 // The duration of the animation
		                   EaseFunction ease   // The easing function to apply
		interpolate variable, to, delay, duration, ease, variable = .
		
	// Animate a variable to a target value over a given period of time
	global inline animate: Color variable      // The variable to animate
		                   Color to            // The target color to animate to
		                   Time delay = 0      // The delay before the animation starts
		                   Time duration = 300 // The duration of the animation
		interpolate variable, to, delay, duration, variable = .
		
	interpolate: float from = 0
		         float to = 1
		         stored void(float progress) do
		         Time delay = 0
		         Time duration = 300
		add InterpolateAnimation startTime:Time.now+delay, duration, do:do(from + (to - from) * .)
				
	interpolate: float from = 0
		         float to = 1
		         stored void(float progress) do
		         Time delay = 0
		         Time duration = 300
		         EaseFunction ease
		add InterpolateAnimation startTime:Time.now+delay, duration, do:do(ease.function(from + (to - from) * .))
				
	interpolate: Vector2 from
		         Vector2 to
		         stored void(Vector2 progress) do
		         Time delay = 0
		         Time duration = 300
		add InterpolateAnimation startTime:Time.now+delay, duration, do:do(from interpolateTo target:to, progress)
				
	interpolate: Vector2 from
		         Vector2 to
		         stored void(Vector2 progress) do
		         Time delay = 0
		         Time duration = 300
		         EaseFunction ease
		add InterpolateAnimation startTime:Time.now+delay, duration, do:do(from interpolateTo target:to, progress, ease)
				
	interpolate: Color from
		         Color to
		         stored void(Color progress) do
		         Time delay = 0
		         Time duration = 300
		add InterpolateAnimation startTime:Time.now+delay, duration, do:do(from interpolateTo target:to, progress)
				
	global defer: stored void() do
		add DelayAnimation startTime:Time.now, do
	
transient global skipInit unit audio
	global playSound: Sound sound
		              Time delay = 0
		              bool needsToBeCertain = false
		if needsToBeCertain and not input.isCertain: return
		
		if Time.frame == 0
			fx.add PlaySoundAnimation startTime:math.ceil(Time.now+core.targetFrameTime)+delay, sound
		else
		if delay
			fx.add PlaySoundAnimation startTime:Time.now+delay, sound
		else
			sound.play	
				
immutable Animation
	Time startTime
	Time duration
	Object object
	tick: float progress
	
Animation FadeAnimation
	float startValue, delta
	bool removeWhenDone
	tick(float progress) 
		object.alpha = startValue + delta * progress
		if progress >= 1 and removeWhenDone: Framework.objects.remove object
		
Animation MoveAnimation
	Vector2 startValue, delta
	tick(float progress) object.position = startValue + delta * progress
		
Animation ScaleAnimation
	implicit Vector2 startValue
	implicit Vector2 delta
	tick(float progress) object.size = startValue + delta * progress
	
Animation RotateAnimation
	implicit Angle startValue
	implicit Angle delta
	tick(float progress) object.angle = startValue + delta * progress
	
Animation FadeSoundAnimation
	float startValue, delta
	Sound sound
	tick(float progress)
		if sound == null: return
		sound.volume = startValue + delta * progress
		if progress >= 1: sound.stop
			
Animation PlaySoundAnimation
	Sound sound
	tick(float progress) sound.play
	
Animation DelayAnimation
	void() do
	tick(float progress) do()
	
Animation InterpolateAnimation
	void(float progress) do
	tick(float progress) do(progress)


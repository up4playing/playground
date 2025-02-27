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
		
	global js async void delay: Time time
		return new Promise((resolve, reject) => {
			setTimeout(resolve, time);
		})
		
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
		
struct float
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
	// Animate the color to a target vector over a given period of time
	inline animateTo: Color target        // The target color to animate to
		              Time delay = 0      // The delay before the animation starts
		              Time duration = 300 // The duration of the animation
		fx.interpolate this, target, delay, duration, this = .

transient global skipInit unit audio
	global playSound: Sound sound
		              Time delay = 0
		              bool needsToBeCertain = false
		if needsToBeCertain and not input.isCertain: return
		
		if Time.frame == 0
			fx.add PlaySoundAnimation startTime:math.ceil(Time.now+core.frameTime)+delay, sound
		else
		if delay
			fx.add PlaySoundAnimation startTime:Time.now+delay, sound
		else
			sound.play	
				
	global static playSound: Sound sound
		              nocolon Time at = 0
		              bool needsToBeCertain = false
		if needsToBeCertain and not input.isCertain: return
		if Time.now >= at and Time.now < math.floor at + core.frameTime
			sound.play
				
internal immutable Animation
	Time startTime
	Time duration
	Object object
	tick: float progress
	
internal Animation FadeAnimation
	float startValue, delta
	bool removeWhenDone
	tick(float progress) 
		object.alpha = startValue + delta * progress
		if progress >= 1 and removeWhenDone: Framework.objects.remove object
		
internal Animation MoveAnimation
	Vector2 startValue, delta
	tick(float progress) object.position = startValue + delta * progress
		
internal Animation ScaleAnimation
	implicit Vector2 startValue
	implicit Vector2 delta
	tick(float progress) object.size = startValue + delta * progress
	
internal Animation RotateAnimation
	implicit Angle startValue
	implicit Angle delta
	tick(float progress) object.angle = startValue + delta * progress
	
internal Animation FadeSoundAnimation
	float startValue, delta
	Sound sound
	tick(float progress)
		if sound == null: return
		sound.volume = startValue + delta * progress
		if progress >= 1: sound.stop
			
internal Animation PlaySoundAnimation
	Sound sound
	tick(float progress) sound.play
	
internal Animation DelayAnimation
	void() do
	tick(float progress) do()
	
internal Animation InterpolateAnimation
	void(float progress) do
	tick(float progress) do(progress)


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
		
	global interpolate: float from = 0
		                float to = 1
		                Time startTime = 0
		                Time duration = 1
		let value = Time.now - startTime
		if value <= 0:        return from
		if value >= duration: return to
		return from + (to-from) * (value/duration)


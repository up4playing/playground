global unit fx
	internal Animation[] animations
	add: Animation animation
		animations.add animation
		
	removeForObject: Object object
		animations.removeWhere.object == object
		
	endOfPrevAnimation: Object object
		let lastAnimation = animations[-1]
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
				
Animation
	Time startTime
	Time duration
	Object object
	tick: float f
	
Animation FadeAnimation
	float startValue, delta
	bool removeWhenDone
	tick(float f) 
		object.alpha = startValue + delta * f
		if f >= 1 and removeWhenDone: Framework.objects.remove object
		
Animation MoveAnimation
	Vector2 startValue, delta
	tick(float f) object.position = startValue + delta * f
		
Animation ScaleAnimation
	implicit Vector2 startValue
	implicit Vector2 delta
	tick(float f) object.size = startValue + delta * f
	
Animation FadeSoundAnimation
	float startValue, delta
	private dynamic audioElement
	
	FadeSoundAnimation: Sound sound
		this.audioElement = sound.audioElement
	tick(float f)
		if audioElement == null: return
		audioElement.volume = (startValue + delta * f) * audio.volume
		if f >= 1: audioElement.pause
			
Animation PlaySoundAnimation
	Sound sound
	tick(float f) sound.play
	
Animation DelayAnimation
	void() do
	tick(float f) do()
	


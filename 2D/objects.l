unit Framework
	Object[] objects
	Object[] selectedObjects
	
	// Evaluate: Immediately remove objects to avoid problems in
	// - graphics.setUserVideo (updating video object that will be removed)
	// - Coin.transferToNeighbor (the just removed coin is still their in updateNeighbors)
	Object[] toBeRemoved
	
	clear: bool includingLockedObjects = false
		for objects <-
			if not .locked or includingLockedObjects: objects.removeAt i
				
	clearAtEndOfFrame
		for objects
			if not .locked: toBeRemoved.add .
		
	removeWhere: bool(Object value) condition
		for objects -> obj
			if condition obj
				toBeRemoved.add obj
				
	tick
		fx.tick
		objects.eachChangable.tick
		onTouchUp: deselect touch.by
		
		if toBeRemoved
			toBeRemoved.each.siblings.remove .
			toBeRemoved.clear
		
	deselect: Player player
		selectedObjects[player.id] = null
		
	debugString
		let result = ""
		for objects: result +=  .debugString
		return result
		
// Draw on the screen
transient global unit graphics
	setPlayerVideo: Player player
		            Vector2 pos = {}
		            implicit Vector2 size = {440}
		            VideoShape shape = Rectangle
		
		// Use the following when multiline selectors are supported
		// VideoObject videoObject = cast Framework.objects.find
		// 	if .type == VideoObject
		// 		VideoObject v = cast .
		// 		return v.userId == userId
		// 	return false
		let videoObject = getVideoObject player
			
		// if !videoObject or Framework.toBeRemoved.contains(videoObject): videoObject = VideoObject(userId)
		if !videoObject: videoObject = VideoObject(player)
		videoObject.position = pos
		videoObject.size = size
		videoObject.shape = shape
		videoObject.locked = true
		
	private VideoObject getVideoObject: Player player
		for Framework.objects
			if .type == VideoObject
				VideoObject v = cast .
				if v.player.id == player.id
					return v
		return null
		
enum Side: Front, Back
		
class Object
	Vector2 position
	implicit Vector2 size
	Angle angle
	float alpha = 1
	implicit Player[] visibleFor = null
	int layer = 0
	bool locked
	SourceCodeLocation location
	
	visible siblings := Framework.objects
	internal debugString := "(Object pos:{position.x} {position.y})"
	internal tick
	
	Object
		siblings.add this
		
	removeImmediately
		siblings.remove this
		
	removeAtEndOfFrame
		Framework.toBeRemoved.add this
		
	moveToFront() siblings.moveToFront this
	moveToBack()  siblings.moveToBack this
		
	moveTo: Vector2 pos
		    Time duration = 1000
		    Time delay = 0
		Vector2 startPosition = position
		
		// When chaining serveral move animations together, continue where the last one left off
		MoveAnimation moveAnimation = cast fx.animations.findLast.type == MoveAnimation and .object == this
			startPosition = moveAnimation.startValue + moveAnimation.delta

		let delta = pos - startPosition
		fx.add MoveAnimation startTime:fx.endOfPrevAnimation(this)+delay, duration, this, startPosition, delta
		return this
		
	moveAndScaleTo: Vector2 position
		            implicit Vector2 size
		            Time duration = 1000
		            Time delay = 0
		Vector2 startPosition = this.position
		Vector2 startSize = this.size
		Vector2 endSize = size.y ? size : {size.x, size.x * startSize.y/startSize.x}
		
		// When chaining serveral move animations together, continue where the last one left off
		MoveAnimation moveAnimation = cast fx.animations.findLast.type == MoveAnimation and .object == this
			startPosition = moveAnimation.startValue + moveAnimation.delta

		let startTime = fx.endOfPrevAnimation(this)+delay
		fx.add MoveAnimation startTime, duration, this, startPosition, delta:position - startPosition
		fx.add ScaleAnimation startTime, duration, this, startSize, delta:endSize - startSize
		return this
		
	moveTo: Vector2 pos
		    float speed = 1
		    Time delay = 0
		let delta = pos - position
		let duration = math.floor(delta.length / speed)
		fx.add MoveAnimation startTime:fx.endOfPrevAnimation(this)+delay, duration, this, startValue:position, delta
		return this
		
	fadeIn: Time duration = 100
		    Time delay = 0
		alpha = 0
		fx.add FadeAnimation startTime:fx.endOfPrevAnimation(this)+delay, duration, this, startValue:0, delta:1
		return this
		
	fadeOut: Time duration = 100
		     Time delay = -100
		     bool removeWhenDone = true
		float startValue = alpha
		
		// When chaining serveral fade animations together, continue where the last one left off
		// If the last fade animation is already a fade out, don't do anything
		FadeAnimation lastFadeAnimation = cast fx.animations.findLast.type == FadeAnimation and .object == this
			if lastFadeAnimation.startValue + lastFadeAnimation.delta <= 0: 
				return
			startValue = lastFadeAnimation.startValue + lastFadeAnimation.delta
				
		fx.add FadeAnimation startTime:fx.endOfPrevAnimation(this)+delay, duration, this, startValue, delta:-startValue, removeWhenDone
		return this
		
	scaleTo: implicit Vector2 size
		     Time duration = 1000
		     Time delay = 0
		fx.add ScaleAnimation startTime:fx.endOfPrevAnimation(this)+delay, duration, this, startValue:this.size, delta:size-this.size
		return this
		
	do:   stored void() do
		  Time delay = 0
		fx.add DelayAnimation startTime:fx.endOfPrevAnimation(this)+delay, duration:0, this, do
		
	playSound: Sound sound
		       Time delay = 0
		fx.add PlaySoundAnimation startTime:fx.endOfPrevAnimation(this)+delay, duration:0, this, sound

	fadeAndScaleIn: float startScale = 3
		            Time duration = 200
		            Time delay = 0
		alpha = 0
		let startTime = fx.endOfPrevAnimation(this)+delay
		fx.add ScaleAnimation startTime, duration, this, startValue:startScale*size, delta:(1-startScale)*size
		fx.add FadeAnimation  startTime, duration, this, startValue:0, delta:1
		return this
		
	fadeScaleAndRotateIn: float startScale = 3
		                  Angle startAngle = -.0625
		                  //Angle startAngle = -.08
		                  Angle endAngle = 0
		                  Time duration = 200
		                  Time delay = 0
		alpha = 0
		let startTime = fx.endOfPrevAnimation(this)+delay
		fx.add RotateAnimation startTime, duration, this, startValue:startAngle, delta:endAngle-startAngle
		fx.add ScaleAnimation  startTime, duration, this, startValue:startScale*size, delta:(1-startScale)*size
		fx.add FadeAnimation   startTime, duration, this, startValue:0, delta:1
		return this
		
	removeAnimations
		fx.removeForObject this
		
Object RectangleObject
	Color color = White
	override tick
		drawRectangle position, size, color, visibleFor, layer, alpha

Object CircleObject
	Color color = White
	override tick
		drawCircle position, size, color:color, visibleFor, layer

global transient unit System
	global visualize: Vector2 position = {}
		              Color color = White
		              logstring text = ""
		              SourceCodeLocation location
		VisualizeObject(position, color, index:core.watchIndex, text)
		if Platform.isDebug and core.frame >= core.frameWithNewWatches and location
			Platform.sendWatch core.frame, text:text or position.toString, location.start, location.file
		core.watchIndex++

Object VisualizeObject
	Color color = White
	int index
	string text
	
	override tick
		drawText index, position, color:Black, layer:int.maxValue, size:30
		drawText text, position+{0,32}, color, layer:int.maxValue, size:14
		drawCircle position, size, color, layer:int.maxValue

Object TextObject
	string text
	Font font
	Color color = White
	HorizontalAlignment align = Center // The horizontal alignment of the text
	VerticalAlignment valign = Middle  // The vertical alignment of the text
	
	override tick
		drawText text, position, size, angle, color, align, valign, font, visibleFor, alpha, layer
		
Object ImageObject
	Image image
	
	ImageObject
		if size.x == 0 and size.y == 0: size = image.size
	
	override tick
		drawImage image, position, size, angle, alpha, visibleFor, layer
		
Object Effect
	Image image
	int framesPerSecond = 15
	private startFrame = Time.frame
	
	Effect
		if size.x == 0 and size.y == 0: size = image.size
	
	override tick
		var frame = math.floor((Time.frame - startFrame) * math.max(framesPerSecond, 0) / core.targetFps)
		if frame < image.frames.length
			drawImage image, position, size, alpha, visibleFor, layer, frame, location
		else
			Framework.objects.remove this
		
Object VideoObject
	Player player
	VideoShape shape
	override tick
		drawVideo player, position, size, shape
			
Object Button
	Image image                  // The image of the button
    text = ""                    // The text of the button
    Vector2 position = {}        // The position to draw to
    Color textColor = White      // The color of the text
    frame = 0                    // The frame of the image
	implicit Vector2 size = {}   // The size of the image, use a float to keep the aspect ratio, use a vector to strech the image
    fontSize = 18                // The font size in pixels   
    clickableMargin = {16,16}        // The margin around the button within which it is clickable
    textOffset = {}              // Draw the text at this offset
	scaleOnHover = 1.0                   // Scale the button by this factor when the mouse hovers over the button
	frameOnHover = 1                     // Draw this frame when the mouse hovers over the button
    showClickableArea = false        // Show the area within which the button is clickable
    implicit Player[] clickableBy = null // Only this user can click the button
    implicit layer = 0           // Higher layers are drawn in front of lower layers
    alpha = 1.0                  // The opacity of the button 0: fully transpart, 1: fully visible)
	enabled = true               // When not enabled, the button can't be clicked and is drawn transparently (50% by default)
	alphaWhenDisabled = .5       // The opacity of the button will be multiplied with this factor when its disabled
	Key hotkey                   // This keyboard shortcut will execute the onClick handler
    void(Touch touch) onClick    // Execute this code when the user clicks the button
	bool removeOnClick = false   // Remove the button after the user clicks it
	
	override tick
		drawButton image, text, position, textColor, frame, size, fontSize, clickableMargin, textOffset, scaleOnHover, frameOnHover, showClickableArea, visibleFor, clickableBy, hotkey, layer, alpha, enabled, alphaWhenDisabled
		onClick:
			if removeOnClick: this.removeAtEndOfFrame
			onClick(touch)

struct Particle
	Vector2 pos, speed
	Angle angle, rotationSpeed
	int frame

enum ParticleMode: Burst, OneParticlePerImageFrame
	
Object ParticleSystem
	private Particle[] particles
	Image image = starParticle
	minSpeed = 10.0
	maxSpeed = 25.0
	particlesPerBurst = 30
	burstInterval = 500
	Time nextBurst = -1
	bursts = 10
	gravity = 1.0
	maxRotationSpeed  = .05
	mode = ParticleMode.Burst
	angleSpread = 1.0
	
	private int burst
	debugString := "(ParticleSystem {position.x} {position.y} {particles.length})"
	
	override tick
		if Time.now > nextBurst
			if mode == OneParticlePerImageFrame
				for image.frames.length
					let angle = -math.randomFloat .5
					let speedFactor = math.randomFloat(minSpeed to maxSpeed)
					particles.add Particle
						pos: position
						speed: math.getVectorForAngle(angle, speedFactor)
						angle: 0
						rotationSpeed: math.randomFloat(-maxRotationSpeed to maxRotationSpeed)
						frame: .
				nextBurst = Time.maxValue
			else
				for particlesPerBurst
					let angle = -math.randomFloat angleSpread
					let speedFactor = math.randomFloat(minSpeed to maxSpeed)
					particles.add Particle
						pos: position
						speed: math.getVectorForAngle(angle, speedFactor)
						angle
						frame: math.randomInteger(image.frames.length)
						rotationSpeed: math.randomFloat(-maxRotationSpeed to maxRotationSpeed)
				nextBurst = ++burst < bursts ? Time.now + burstInterval : Time.maxValue

		for particles <-
			graphics.move .pos
				graphics.rotate .angle
					drawImage image, frame:.frame
			.pos += .speed
			.speed.y += gravity
			.angle += .rotationSpeed
			if .pos.y > graphics.size.y/2
				particles.removeAt i
		
		if particles.length == 0	
			removeImmediately

Object Menu
	position = {920, -500}
	Vector2 popupPosition
	MenuItem[] items
	includeDefaultItems = true
	overlayColor = #000000b0
	locked = true
	
	visible bool active
		
	Menu
		if includeDefaultItems
			items.insert {image:New,  "New Game",        onClick:core.restart}, 0
			items.add    {image:Save, "Save Game"        onClick:core.saveEventStreamAndLogs}
			items.add    {image:Back, "Back to Lobby",   onClick:lobby.show}
			items.add    {image:Quit, "Exit Fullscreen", onClick:Platform.setFullscreen false, forPlayer:touch.by}
		
	override tick
		bool doNotClose
		if active
			forPositions items, center:popupPosition, delta:{0,60} -> item
				drawText .label, pos+{-60}, size:30, align:Left, layer:int.maxValue
				if item.type == Button
					if .image: drawImage .image, pos+{-120}, layer:int.maxValue
					onTouchDown pos, size:{500,60}, do:item.onClick(true, touch)
				else
				if item.type == Check
					drawImage .image or Checkbox, pos+{-120}, layer:int.maxValue, frame:item.value ? 1 : 0
					onTouchDown pos, size:{500,60}
						item.value = !item.value
						item.onClick(item.value, touch)
						doNotClose = true
					
			drawRectangle popupPosition, outlineColor:White, color:Black, size:{500,60+items.length*60}, outlineWidth:3, layer:int.maxValue
			drawRectangle size:{1920,1080}, color:overlayColor, layer:int.maxValue
			
			if not doNotClose
				onTouchDownAny
					active = false
				
		drawImage Menu, position, location, layer
			active = true
		
enum MenuItemType: Button, Check, Radio
		
class MenuItem
	immutable Image image
	immutable string label
	immutable MenuItemType type = Button
	bool value
	immutable void(bool value, Touch touch) onClick


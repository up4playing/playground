unit Timeline
	Effect[] effects
	int lastEndTime
	
	startTrack
		lastEndTime = 0
	
	move: Object object
		  Vector2 pos
		  float speed = 1
		
		Vector2 startPos = object.targetPos != Vector2.none ? object.targetPos : object.position
		Vector2 delta = pos - startPos
		object.targetPos = pos
		
		effects.add Effect startTime: lastEndTime || Platform.now, duration: Math.floor delta.length / speed
			object.position = startPos + delta * f
			if f >= 1: object.targetPos = Vector2.none
	
	moveAndScale: Object object
		  Vector2 pos
		  float scale
		  int duration = 1
		
		Vector2 startPos = object.targetPos != Vector2.none ? object.targetPos : object.position
		Vector2 deltaPos = pos - startPos
		object.targetPos = pos
		float startScale = object.scale
		float deltaScale = scale - startScale
		
		effects.add Effect startTime: lastEndTime || Platform.now, duration
			object.position = startPos + deltaPos * f
			object.scale = startScale + deltaScale * f
			if f >= 1: object.targetPos = Vector2.none
				
	remove: Object object
		effects.add Effect startTime: lastEndTime || Platform.now
			object.remove
				
	playSound: Sound sound
		effects.add Effect startTime: lastEndTime || Platform.now
			audio.playSound sound
				
	do: void(float f) code,
		int duration = 0
		effects.add Effect startTime: lastEndTime || Platform.now, duration
			code f
				
	tick
		let now = Platform.now
		for i,e <- effects
			if now >= e.startTime
				float f = e.duration ? (now - e.startTime)/e.duration : 1
				if f >= 1: f = 1; effects.removeAt i
				e.onTick f
			
class Effect
	int startTime
	int duration
	void(float f) onTick
	Effect
		Timeline.lastEndTime = startTime + duration

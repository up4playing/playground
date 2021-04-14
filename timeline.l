unit Timeline
	Effect[] effects
	int lastEndTime
	
	startTrack
		lastEndTime = 0
	
	move: Item item
		  Vector2 pos
		  float speed = 1
		
		Vector2 startPos = item.targetPos != Vector2.none ? item.targetPos : item.position
		Vector2 delta = pos - startPos
		item.targetPos = pos
		
		effects.add Effect startTime: lastEndTime || Platform.now, duration: Math.floor delta.length / speed
			item.position = startPos + delta * f
			if f >= 1: item.targetPos = Vector2.none
	
	moveAndScale: Item item
		  Vector2 pos
		  float scale
		  int duration = 1
		
		Vector2 startPos = item.targetPos != Vector2.none ? item.targetPos : item.position
		Vector2 deltaPos = pos - startPos
		item.targetPos = pos
		float startScale = item.scale
		float deltaScale = scale - startScale
		
		effects.add Effect startTime: lastEndTime || Platform.now, duration
			item.position = startPos + deltaPos * f
			item.scale = startScale + deltaScale * f
			if f >= 1: item.targetPos = Vector2.none
				
	remove: Item item
		effects.add Effect startTime: lastEndTime || Platform.now
			item.remove
				
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

app
	Vector2 birdPos = {100,0}, birdSpeed = {10, 0}	
	tick
		drawText "Hello World", {100, 100}, font:ShadowedSerif
		drawImage Bird, birdPos
		drawImage Background

		birdPos += birdSpeed
		birdSpeed.y += 2
		onTouchDown: birdSpeed.y = -10


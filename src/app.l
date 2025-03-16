app
	Vector2 birdPos = {10,0}, birdSpeed = {10, 0}

	init
		Platform.isLocal = true

	tick
		drawText "Hello World", {0,100}
		drawImage Bird, birdPos
		drawImage Background

		birdPos += birdSpeed
		birdSpeed.y += 2
		onTouchDown: birdSpeed.y = -10

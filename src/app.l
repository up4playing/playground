app
	Vector2 birdPos = {10,0}, birdSpeed = {10, 0}

	init
		Platform.isLocal = true

	tick
		drawImage Bird, birdPos
		drawImage Background

		birdPos += birdSpeed
		birdSpeed.y += 2
		onTouchDown: birdSpeed.y = -10

	main01
		print "main01"

	main02
		print "main02"

	main03
		print "main03"

	gameOver
		print "gameOver"

	flyOver01
		print "flyOver01"

	flyOver02
		print "flyOver02"

	flyOver03
		print "flyOver03"

Player
	tick
		drawText "Player"

unit lobby
	tick
		int count = Input.users.length
		int width = 1200/count, offset = -width*(count-1)/2
		for count: Network.setUserVideoAndColor(i, {offset+width*i, -50}, width)

		// drawButton Button, "Start", {0, 450} onClick: Platform.requestFullscreen; Network.startApp
		drawButton Button, "Start", {0, 450} onClick: Network.startApp
		// drawButton Button, "Save Logs", {0, 500} onClick: Platform.createTextFile "log.csv", Network.log
		drawButton Button, "Save Game", {0, 500} onClick: Network.save
		// drawText "Version "+Platform.version, {0, -540}
		// drawText cast Network.eventStreamSize, {0, -516}

unit lobby
	float2[] dots
	bool inLobby = true
	
	tick
		int count = Input.users.length
		int width = 1200/count, offset = -width*(count-1)/2
		for count: Network.setUserVideoAndColor(i, {offset+width*i, -50}, width)

		// drawButton Button, "Start", {0, 450} onClick: Platform.requestFullscreen; Network.startApp
		drawButton Button, "Start", {0, 450} onClick: Network.startApp
		// drawButton Button, "Save Logs", {0, 500} onClick: Platform.createTextFile "log.csv", Network.log
		drawButton Button, "Save Logs", {0, 500} onClick: Network.saveLogs
		drawText "Version "+Platform.version, {0, -540}
		drawText cast Network.eventStreamSize, {0, -516}
		
		Input.onTouchDown: dots.add touch.position
		for dots: drawCircle d
		
	serialize: Buffer buffer
		buffer.writeBool(inLobby)
		
	deserialize: Buffer buffer
		inLobby = buffer.readBool()
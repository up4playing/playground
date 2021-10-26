unit lobby
	bool inLobby = true
	
	tick
		if Network.error or Network.errorMessage
			drawText Network.error, size:40
			drawText Network.errorMessage, size:14, position:{0,40}
			return
			
		int count = Input.users.length
		float width = 1200/count, offset = -width*(count-1)/2
		for Input.users: Network.setUserVideoAndColor(.id, {offset+width*.index, -50}, width)

		drawButton Button, "Start", {0, 435} onClick: Platform.requestFullscreen; Network.startApp
		// drawButton Button, "Save Logs", {0, 485} onClick: Network.saveLogs

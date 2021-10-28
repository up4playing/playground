unit lobby
	bool inLobby = true
	
	tick
		if Network.error or Network.errorMessage
			drawText Network.error, size:40
			drawText Network.errorMessage, size:14, position:{0,40}
			return
			
		int count = Input.users.length
			float width = count<2 ? 1200.0 : 1920/count, offset = -width*(count-1)/2
			for Input.users: Network.setUserVideoAndColor(.id, {offset+width*.index, -50}, width)
		else
			Network.setLocalVideo({0,-50}, 1200)
			
		if Network.mode == Ping
			drawText "Connecting...", {0,450}
		else
		if Network.mode == Connected
			drawButton Button, "Start", {0, 450} onClick: Platform.requestFullscreen; Network.startApp
		// drawButton Button, "Save Logs", {0, 485} onClick: Network.saveLogs

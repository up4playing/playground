unit lobby
	bool inLobby = true
	bool enableFullscreen = true
	// Vector2[] points
	
	tick
		if PeerNetwork.error or Network.errorMessage
			drawText PeerNetwork.error, size:40
			drawText Network.errorMessage, size:14, position:{0,40}
			return
			
		int count = Input.users.length
			float width = count<2 ? 1200.0 : 1920/count, offset = -width*(count-1)/2
			for Input.users
				Vector2 pos = {offset+width*.index, -50}
				drawVideo .id, pos, {width}
				if .isReady
					drawImage ThumbsUp, pos+{-74,width*3/8+36}
					drawText "I'm ready", pos+{30,width*3/8+40}, size:32, font:OpenSans
			
		// Place points with a click for testing
		// Input.onTouchDown: points.add .position.clone
		// points.each drawCircle ., radius:50
			
		if Network.mode == Ping
			drawText "Connecting...", {0,450}
		else
		if Network.mode == Connected or Network.mode == Local
			for Input.users
				if !.isReady
					drawButton Button, "Start", {0, 450}, visibleFor:.id
						if enableFullscreen: Platform.setFullscreen true forUser:touch.userId
						Input.usersById[touch.userId].isReady = true
						if Input.users.all.isReady
							Network.startApp

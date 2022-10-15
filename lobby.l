unit lobby
	bool inLobby = true
	bool enableFullscreen = true
	// Vector2[] points
	
	int ticks
	
	tick
		if Platform.isStaging
			// The delta value has to be the same for all users, we use it to check if everybody is in sync
			drawText "delta:{ticks-Time.frame} ticks:{ticks}", size:40, position:{-900, -520}, align:Left
			ticks++
		
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
			drawText "Connecting..."
		else
		if Input.users.length withinInclusively Platform.supportedUserCount
			for Input.users
				if !.isReady
					drawButton Button, "Start", {0, 450}, visibleFor:.id
						if enableFullscreen: Platform.setFullscreen true forUser:touch.userId
						Input.usersById[touch.userId].isReady = true
						if Input.users.all.isReady
							Network.startApp

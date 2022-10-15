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
				Vector2 pos = {offset+width*.index, 0}
				drawVideo .id, pos, {width}
				if .isReady
					let text = Loca.language == English ? "I'm ready" : "Ich bin bereit"
					let basePos = pos+{-(graphics.getTextWidth(text, size:32)+28)/2,width*3/8+40}
					drawImage ThumbsUp, basePos
					drawText text, basePos+{32,4}, size:32, font:OpenSans, align:Left
			
		// Place points with a click for testing
		// Input.onTouchDown: points.add .position.clone
		// points.each drawCircle ., radius:50
		
		if Loca.supportedLanguages.length > 1
			forPositions Loca.supportedLanguages, right:{930,-510}, delta:{40}
				drawImage Flag[i], pos, frame:Loca.language == cast(i) ? 1 : 0
					Loca.language = cast(i)
			
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

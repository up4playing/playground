unit lobby
	bool inLobby = true
	
	tick
		if Network.error or Network.errorMessage
			drawText Network.error, size:40
			drawText Network.errorMessage, size:14, position:{0,40}
			return
			
		int count = Input.users.length
			float width = count<2 ? 1200.0 : 1920/count, offset = -width*(count-1)/2
			for Input.users
				Vector2 pos = {offset+width*.index, -50}
				Network.setUserVideoAndColor(.id, pos, width)
				if .isReady
					drawImage ThumbsUp, pos+{-74,width*3/8+36}
					drawText "I'm ready", pos+{30,width*3/8+40}, size:32, font:OpenSans
		else
			Network.setLocalVideo({0,-50}, 1200)
			
		if Network.mode == Ping
			drawText "Connecting...", {0,450}
		else
		if Network.mode == Connected or Network.mode == Local
			for Input.users
				if !.isReady
					drawButton Button, "Start", {0, 450}, visibleFor:.id
						Platform.requestFullscreen
						Input.usersById[touch.userId].isReady = true
						if Input.users.all.isReady
							Network.startApp

unit lobby
	bool inLobby = true
	bool enableFullscreen = true
	Vector2[] points
	
	int ticks
	
	tick
		tickSettings
		if Platform.isStaging
			// The delta value has to be the same for all users, we use it to check if everybody is in sync
			drawText "delta:{ticks-Time.frame} ticks:{ticks}", size:20, position:{-940, 520}, align:Left
			ticks++
			
			drawButton Button, "Send Statistics", {864,498}
				input.isCertain = true
				statistics.send round:-2 game:-2
		
		if PeerNetwork.error or core.errorMessage
			drawText PeerNetwork.error, size:40
			drawText core.errorMessage, size:14, position:{0,40}
			return
			
		int count = players.length
			float width = count<2 ? 900.0 : 1920/count, offset = -width*(count-1)/2
			for players
				Vector2 pos = {offset+width*.index, 0}
				drawVideo ., pos, width
				if .isReadyInLobby
					let text = Loca.language == English ? "I'm ready" : "Ich bin bereit"
					let basePos = pos+{-(graphics.getTextWidth(text, size:32)+28)/2,width*3/8+40}
					drawImage ThumbsUp, basePos
					drawText text, basePos+{32,4}, size:32, font:OpenSans, align:Left
			
		// Place points with a click for testing
		if core.drawPointsForTesting
			onTouchDown: points.add .position.clone
				points.each drawCircle ., size:50
		
		if Loca.supportedLanguages.length > 1
			forPositions Loca.supportedLanguages, end:{930,-510}, delta:{40}
				drawImage Flag[i], pos, frame:Loca.language == cast(i) ? 1 : 0
					Loca.setLanguage cast(i)
			
		if core.mode == Ping
			drawText "Connecting...", size:32
		else
		if players.length withinInclusively Platform.supportedUserCount
			for players
				if !.isReadyInLobby
					drawButton Button, "Start", {0, 450}, visibleFor:.
						if enableFullscreen: Platform.setFullscreen true forPlayer:touch.by
						input.playersById[touch.by.id].isReadyInLobby = true
						if players.all.isReadyInLobby
							core.startApp
							
	private showSettings = false
	
	tickSettings
		if not input.localUser: return
		drawImage settingsIcon, {-920,-500}, touchableBy:input.localPlayer, size:32
			showSettings = !showSettings
			
		if showSettings
			Vector2 pos = {-650,-500}
			
			if PeerNetwork.devices.videoInput
				drawImage cameraIcon, pos
				forPositions PeerNetwork.devices.videoInput start:pos+{36} delta:{0,26} -> device
					drawText .label, pos, size:18, align:Left, color:PeerNetwork.videoInputId == .deviceId ? Green : White
					onTouchDownWithin pos+{200,0}, size:{400,30}, showTouchArea:false, by:input.localPlayer
						PeerNetwork.setVideoInput device.deviceId
				pos += {450}
			
			if PeerNetwork.devices.audioInput
				drawImage microphoneIcon, pos
				forPositions PeerNetwork.devices.audioInput start:pos+{36} delta:{0,26} -> device
					drawText .label, pos, size:18, align:Left, color:PeerNetwork.audioInputId == .deviceId ? Green : White
					onTouchDownWithin pos+{200,0}, size:{400,30}, showTouchArea:false, by:input.localPlayer
						PeerNetwork.setAudioInput device.deviceId
				pos += {550}
				
			if PeerNetwork.devices.audioOutput	
				drawImage speakerIcon, pos
				forPositions PeerNetwork.devices.audioOutput start:pos+{36} delta:{0,26} -> device
					drawText .label, pos, size:18, align:Left, color:PeerNetwork.audioOutputId == .deviceId ? Green : White
					onTouchDownWithin pos+{200,0}, size:{400,30}, showTouchArea:false, by:input.localPlayer
						PeerNetwork.setAudioOutput device.deviceId

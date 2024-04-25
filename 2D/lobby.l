unit lobby
	bool inLobby = true
	bool enableFullscreen = true
	Vector2[] points
	
	// Names
	LobbyTextField[] fields
	int showNameIndex = 1
	bool editNames
	const nameSuggestions = [
		"Heiko"
		"Bianca"
		"Bjarne"
		"Tim"
		
		"Christian"
		"Svend"
		"Holger"
		
		"Joe"
		"Kevin"
		
		"Simonas"
		"Dominik"
		"Felix"
		"Edi"
		"Matthias"
		"Phillip"
		"Jürgen"
		"Jakob"
		"Christopher"
		
		"Krzysztof"
		"Chuck"
		"Markus"
		"Nick"
		"Marijn"
		
		"Carina"
		"Beatrice"
		"Talea"
		"Tanja"
		"Yvonne"
	]
		
	show
		Framework.clear includingLockedObjects:true
		fields.clear
		inLobby = true
		showNameIndex = 1
		editNames = false
		players.each.isReadyInLobby = false
		audio.stop
	
	tick
		tickSettings
		if Platform.isStaging: drawText "Version:{Platform.buildVersion}", size:20, position:{-940, 520}, align:Left
		if PeerNetwork.error or core.errorMessage
			drawText PeerNetwork.error, size:40
			drawText core.errorMessage, size:14, position:{0,40}
			return
		
		// Control show names
		onKeyDown by host
			let alt = pressedBy.keysCurrentlyDown.contains Alt
			if key == A and alt
				setupFields newHost:pressedBy
			else
			if key == Y and alt
				showName players[showNameIndex++ % players.length]
			else
			if key == Tab and alt
				showNameIndex = (showNameIndex+1) % players.length
			else
			if key == Enter or key == Tab or key == Right
				switchFieldFocus 1
			else
			if key == Left
				switchFieldFocus -1
			
		int count = players.length
			float videoWidth = count<2 ? 900.0 : 1920/count
			float offset = -videoWidth*(count-1)/2
			float halfVideoHeight = videoWidth*3/8
			
			for players -> player, playerIndex
				Vector2 pos = {offset+videoWidth*.index, 0}
				drawVideo ., pos, videoWidth
				
				// Start button
				let text = not .isReadyInLobby ? "START" : Loca.language == German ? "Ich bin bereit" : "I'm ready"
				drawStandardButton text, pos+{0,halfVideoHeight+90}, accentColor:.color, enabled:!.isReadyInLobby, clickableBy:player
					if enableFullscreen: Platform.setFullscreen true forPlayer:touch.by
					input.playersById[touch.by.id].isReadyInLobby = true
					if players.all.isReadyInLobby
					and players.length withinInclusively Platform.supportedUserCount
						fields.clear
						restart
				
				let field = fields.find.player == player
					// Set field position
					field.position = pos + {0, -halfVideoHeight-(players.length<=2 ? 85 : 120)}
					if field.effect: field.effect.position = field.position + {0,-190}
					if field.particleSystem: field.particleSystem.position = field.position
						
					if editNames
						// Suggestions
						for nameSuggestions -> name
							drawButton name, position:pos+{-150+100*(i%4),halfVideoHeight+150+20*math.floor(i/4)}, textSize:14, textColor:#808080, textColorOnHover:White, visibleFor:host
								fields[playerIndex].text = player.name = name
								
						// Circle indicating the first player name to show
						if showNameIndex == playerIndex
							drawCircle field.position+{0,60}, size:20, visibleFor:host

		// Place points with a click for testing
		if core.drawPointsForTesting
			onTouchDown: points.add .position.clone
				points.each drawCircle ., size:50
		
		// Switch language
		if Loca.supportedLanguages.length > 1
			forPositions Loca.supportedLanguages, end:{930,-510}, delta:{40}
				drawImage Flag[i], pos, frame:Loca.language == cast(i) ? 1 : 0
					Loca.setLanguage cast(i)
			
		// Connecting text
		if core.mode == Ping
			drawText "Connecting...", size:32
		
	setupFields: Player newHost
		input.host = newHost
		this.showNameIndex = host.index + 1
		Framework.clear
		fields.clear
		if not editNames
			editNames = true
			players.each createField ., visibleFor:host
			fields[0].focus
		else
			editNames = false
			input.showPointers = false
			
	switchFieldFocus: int delta
		let focusIndex = fields.indexWhere.isFocused
		focusIndex = (focusIndex + delta) % fields.length
		fields.each.focus focusIndex == i
			
	showName: Player player
		let field = createField player
		.. fadeScaleAndRotateIn startScale:5 startAngle:-.08  endAngle:-.01
		// Effect(image:FireballBlue, position:field.position+{0,70}, size:1000)
		// Effect(image:FireballSoft, position:field.position+{30,70}, size:1000, framesPerSecond:12)
		// Effect(image:GranadeExplosion, position:field.position+{0,-200}, size:1000)
		// Effect(image:NukeCone, position:field.position+{0,-150}, size:1000)
		field.effect = Effect(image:Nuke, size:1000)
		field.particleSystem = ParticleSystem(image:Spark, bursts:1, gravity:.5, minSpeed:10 maxSpeed:20, angleSpread:.5)
		playSound LobbyImpact
		
	createField: Player player, implicit Player[] visibleFor = null
		let field = LobbyTextField(text:player.name, player, visibleFor, editableBy:host, color:White, size:100, font:ByTheWay, angle:-.01, onChanged:player.name = .)
		fields.add field
		return field
	
	tickSettings
		for players -> player
			graphics.visibleFor player
				drawImage settingsIcon, {-920,-500}, size:32
					player.showSettingsInLobby = !player.showSettingsInLobby
					
				if player.showSettingsInLobby
					Vector2 pos = {-650,-500}
					
					drawImage cameraIcon, pos
					forPositions 10 start:pos+{36} delta:{0,26}
						let device = PeerNetwork.devices.videoInput[i]
							drawText device.label, pos, size:18, align:Left, color:PeerNetwork.videoInputId == device.deviceId ? player.color : White
						onTouchDown pos+{200,0}, size:{400,30} by player
							PeerNetwork.setVideoInput device?.deviceId, player
					pos += {450}
					
					drawImage microphoneIcon, pos
					forPositions 10 start:pos+{36} delta:{0,26}
						let device = PeerNetwork.devices.audioInput[i]
							drawText device.label, pos, size:18, align:Left, color:PeerNetwork.audioInputId == device.deviceId ? player.color : White
						onTouchDown pos+{200,0}, size:{400,30} by player
							PeerNetwork.setAudioInput device?.deviceId, player
					pos += {550}
						
					if PeerNetwork.devices.audioOutput	
						drawImage speakerIcon, pos
					forPositions 10 start:pos+{36} delta:{0,26}
						let device = PeerNetwork.devices.audioOutput[i]
							drawText device.label, pos, size:18, align:Left, color:PeerNetwork.audioOutputId == device.deviceId ? player.color : White
						onTouchDown pos+{200,0}, size:{400,30} by player
							PeerNetwork.setAudioOutput device?.deviceId, player
						
Player
	bool showSettingsInLobby
	
Object LobbyTextField
	string text
	Font font
	Color color = White
	Player player
	Object effect, particleSystem // Error "The member 'color' can't be a contructor" after this was added
	
	Player editableBy
	float width = 600
	void(string text) onChanged
	
	visible bool isFocused
	private Time lastTypeTime
	
	clear
		text = ""
		isFocused = false
		
	focus: bool isFocused = true
		this.isFocused = isFocused
		lastTypeTime = Time.now
		
	tick
		let c = isFocused and ((Time.now%1000) < 500)
		onTouchDownAny by editableBy
			focus false
		onTouchDown position+{0,size.x/2}, {width,size.x*2}, by:editableBy
			focus true
		if isFocused
			onType by editableBy
				text += .; lastTypeTime = Time.now
				if onChanged != null: onChanged text
			onKeyDown Backspace by editableBy
				if text: text = text.substring(0, text.length-1)
				lastTypeTime = Time.now
				if onChanged != null: onChanged text
					
		drawText text, position+{0, 0}, size, angle, alpha, align:Center, font:ByTheWay, visibleFor
		
		if isFocused and (((Time.now - lastTypeTime)%1500) < 750)
			let textWidth = graphics.getTextWidth text, size, font:ByTheWay
			drawText "|", position+{textWidth/2, 0}, size, angle, alpha, align:Center, font:ByTheWay, visibleFor:editableBy

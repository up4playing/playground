unit lobby
	bool inLobby = true
	bool enableFullscreen = true
	Vector2[] points
	
	// Names
	LobbyTextField[] fields
	int showNameIndex = 1
	Player host
	bool editNames
	const nameSuggestions = [
		"Heiko"
		"Bianca"
		"Bjarne"
		"Tim"
		"Simonas"
		"Holger"
		"Dominik"
		"Kevin"
		"Felix"
		"Matthias"
		"Jakob"
		"Joe"
		"Phillip"
		"Edi"
		"Jürgen"
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
		players.each.isReadyInLobby = false
		audio.stop
	
	tick
		tickSettings
		
		// Control show names
		// onKeyDown Alt key:Enter: setupFields host:pressedBy
		// onKeyDown Alt key:Right by host: showName players[showNameIndex++ % players.length]
		onKeyDown by host
			let alt = pressedBy.keysCurrentlyDown.contains Alt
			if key == Enter and alt
				setupFields host:pressedBy
			else
			if key == Right and alt
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
			
		// fields.each.tick
		if Platform.isStaging: drawText "Version:{Platform.buildVersion}", size:20, position:{-940, 520}, align:Left
			
		if PeerNetwork.error or core.errorMessage
			drawText PeerNetwork.error, size:40
			drawText core.errorMessage, size:14, position:{0,40}
			return
			
		int count = players.length
			float videoWidth = count<2 ? 900.0 : 1920/count
			float offset = -videoWidth*(count-1)/2
			float halfVideoHeight = videoWidth*3/8
			
			for players -> player, playerIndex
				Vector2 pos = {offset+videoWidth*.index, 0}
				drawVideo ., pos, videoWidth
				
				// drawButton "START", pos+{0,280}, image:Button, accentImage:ButtonAccent, accentColor:.color, textColorOnHover:Black, enabled:!.isReadyInLobby
				let text = not .isReadyInLobby ? "START" : Loca.language == German ? "Ich bin bereit" : "I'm ready"
				drawButton text, pos+{0,halfVideoHeight+90}, image:Button, accentImage:ButtonAccent, accentColor:.color, textColorOnHover:Black, enabled:!.isReadyInLobby
					if enableFullscreen: Platform.setFullscreen true forPlayer:touch.by
					input.playersById[touch.by.id].isReadyInLobby = true
					if players.all.isReadyInLobby
					and players.length withinInclusively Platform.supportedUserCount
						fields.clear
						restart
				
				let field = fields.find.player == player
					field.position = pos + {0, -halfVideoHeight-(players.length<=2 ? 85 : 120)}
					if field.effect: field.effect.position = field.position + {0,-190}
					if field.particleSystem: field.particleSystem.position = field.position
						
					if editNames		
						for nameSuggestions -> name
							drawButton name, position:pos+{-150+100*(i%4),halfVideoHeight+150+20*math.floor(i/4)}, textSize:14, textColor:#808080, textColorOnHover:White, visibleFor:host
								fields[playerIndex].text = player.name = name
						if showNameIndex == playerIndex
							drawCircle field.position+{0,60}, size:20, visibleFor:host
						
				// if .isReadyInLobby
				// 	let text = Loca.language == English ? "I'm ready" : "Ich bin bereit"
				// 	let basePos = pos+{-(graphics.getTextWidth(text, size:32)+28)/2,width*3/8+150}
				// 	drawImage ThumbsUp, basePos
				// 	drawText text, basePos+{32,4}, size:32, font:OpenSans, align:Left
			
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
			
		// players[0].name = "Heiko"
		// players[1].name = "Bianca"
		// players[2].name = "Bjarne"
		// players[3].name = "Tim"
		Framework.tick
		
	setupFields: Player host
		this.host = host
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
		// .. do ParticleSystem(position, image:Spark, mode:Burst, bursts:1, gravity:.5)
		// Effect(image:FireballBlue, position:field.position+{0,70}, size:1000)
		// Effect(image:FireballSoft, position:field.position+{30,70}, size:1000, framesPerSecond:12)
		// Effect(image:GranadeExplosion, position:field.position+{0,-200}, size:1000)
		// Effect(image:NukeCone, position:field.position+{0,-150}, size:1000)
		field.effect = Effect(image:Nuke, size:1000)
		// delay 100 milliseconds
		// ParticleSystem(position, image:Spark, mode:Burst, bursts:1, gravity:.2, minSpeed:5 maxSpeed:15, angleSpread:.5)
		field.particleSystem = ParticleSystem(image:Spark, bursts:1, gravity:.5, minSpeed:10 maxSpeed:20, angleSpread:.5)
		playSound Score
		
	createField: Player player, implicit Player[] visibleFor = null
		let field = LobbyTextField(text:player.name, player, visibleFor, editableBy:host, color:White, size:100, font:ByTheWay, angle:-.01, onChanged:player.name = .)
		fields.add field
		return field
				
	// getPlayerPos: Player player
	// 	int count = players.length
	// 	if count == 0: return {0,0}
	// 	float width = count<2 ? 900.0 : 1920/count, offset = -width*(count-1)/2
	// 	return {offset+width*player.index, 0}
							
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
		onTouchDownWithin position+{0,size.x/2}, {width,size.x*2}, by:editableBy
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

enum NetworkMode: None, Ping, Local, Connected
	
MonoBehaviour LiveTime
	private cs void systemInit
		Core.init();
		Input.init();
		system.init();
		
	Start
		systemInit
		Core.startLocal
		
	Update
		Input.collectMouseEvents
		Input.collectTiltFiveEvents
		Core.step
		
unit Platform
	userCount = 2
		
skipInit unit Core
	NetworkMode mode
	bool simulateConnection = true
	int frame
	int frames
	bool isPremiere
	bool startInLobby
	
	startLocal
		mode = Local
		Input.internalUsers.clear
		// Math.setRandomSeed Math.generateRandomSeed 
		stop
		
	// Clear all inputs and reset the application to the first frame
	stop
		for Input.internalUsers if .
			.inputs.reset
			.startInputFrame 0
		// startTime = serverStartTime = currentTime
		frames = 0
		// frameWithNewWatches = 0
		startInLobby = false
		// errorMessage = ""
		// audio.stop
		isPremiere = true
		// startTime = serverStartTime = currentTime
		reset
		// animationFrame
				
	// Keep inputs, call init functions, create the local users, reset read positions and start app
	// This is called on startup, after every code change and when going backwards in the timeline
	reset
		Input.users.clear
		Input.usersById.clear
		// errorMessage = ""
		// HTMLElement.clear
		// Math.randomValueIndex = 0
		frame = 0
		// certainFrame = int.maxValue
		// uncertainFrame = -1
		// smoothFrame = 0
		Input.isCertain = true
		// lobby.inLobby = startInLobby
		// Time.now = serverStartTime
		// audio.stop
		// initAll
		
		if !startInLobby
			// When the developer changed Platform.userCount, add or remove internal users accordingly
			for Input.internalUsers.length to Platform.userCount
				Input.internalUsers.add {id:i, local:true, collectInputs:true}
			if Input.internalUsers.length > Platform.userCount
				Input.internalUsers.removeRange Platform.userCount, count: Input.internalUsers.length - Platform.userCount
			
			// We always recreating users, because developers might have added fields to NetworkUser or Touch
			// By the time we call startApp, all users need to exist
			// for Input.internalUsers withIndex:true -> internalUser
			for Input.internalUsers -> internalUser
				CoreUser user = {id:.id, index:i}
				Input.usersById[.id] = user
				Input.users.add user
				
			// Set local user
			Input.localUser = Input.localUser?.id < Input.internalUsers.length ? Input.internalUsers[Input.localUser.id] : Input.internalUsers[0]
			
		// Reset read pos to replay inputs from the beginning
		for Input.internalUsers if .
			.inputs.readPos = 0
			
		if !startInLobby: startApp
		// if simulateRollback: saveState
			
	startApp
		app.start	
	
	step
		Time.now = Time.realTime
		Input.parseInputs Time.frame, true
		tick
		
		// Cleanup
		for Input.internalUsers if .
			.clearEvent
		Input.users.each.clearEvents
		
		// Advance frame
		Time.frame++
		if frames < frame: frames = frame
					
	tick
		graphics.startFrame
		app.tick
		graphics.finsishFrame
	

enum NetworkMode: None, Ping, Local, Connected
		
skipInit unit core
	NetworkMode mode = Local
	int frame
	Time startTime
	internal const targetFps = 30
	const targetFrameTime = 1000/targetFps
	
	startLocal
		// mode = Local
		// input.internalUsers.clear
		// math.setRandomSeed math.generateRandomSeed 
		// initDatabase
		stop
		
	// Clear all inputs and reset the application to the first frame
	stop
		// for input.internalUsers if .
		// 	.inputs.reset
		// 	.startInputFrame 0
		startTime = Time.realTime
		// startTime = serverStartTime = currentTime
		// frames = 0
		// frameWithNewWatches = 0
		// watchIndex = 0
		// startInLobby = false
		// errorMessage = ""
		// audio.stop
		// isPremiere = true
		// startTime = serverStartTime = currentTime
		reset
		// animationFrame
		
		
	// Keep inputs, call init functions, create the local players, reset read positions and start app
	// This is called on startup, after every code change and when going backwards in the timeline
	reset
		players.clear
		frame = 0
		for Platform.userCount
			players.add {index:i, id:i}
		// input.playersById.clear
		// errorMessage = ""
		// HTMLElement.clear
		// math.randomValueIndex = 0
		// watchIndex = 0
		// input.isCertain = true
		// lobby.inLobby = startInLobby
		// Time.now = serverStartTime
		// snapshotFrame = -1
		// checksums.clear
		// lastChecksumFrame = -1
		// audio.stop
		initAll
		startApp
		
		// if !startInLobby
		// 	// When the developer changed Platform.userCount, add or remove internal users accordingly
		// 	for input.internalUsers.length to Platform.userCount
		// 		input.internalUsers.add {id:i, local:true, collectInputs:true}
		// 	if input.internalUsers.length > Platform.userCount
		// 		input.internalUsers.removeRange Platform.userCount..input.internalUsers.length
			
		// 	// We always recreating players, because developers might have added fields to Player or Touch
		// 	// By the time we call startApp, all players need to exist
		// 	for input.internalUsers -> internalUser
		// 		Player user = {id:.id, index:i}
		// 		input.playersById[.id] = user
		// 		players.add user
				
		// 	// Set local user
			// let localUserId = input.localUser?.id < input.internalUsers.length ? input.localUser.id : 0
		// 	input.localUser = input.internalUsers[localUserId]
		// 	input.localPlayer = input.playersById[localUserId]
			input.localPlayer = players[0]
			input.updatePlayers
			
		// // Reset read pos to replay inputs from the beginning
		// for input.internalUsers if .
		// 	.inputs.readPos = 0
			
		// if !startInLobby: startApp
		// if simulateRollback: checkSaveState
		
	private cpp void initAll
		::init();
		
	private cpp void startApp
		app::start();
		
	animationFrame
		Time.now = Time.realTime
		let targetFrame = math.floor((Time.now - startTime)/targetFrameTime)+1
		// print "animation frame", Time.now, startTime, Time.now - startTime, frame, targetFrame
		if frame < targetFrame
			step
			
	step
		// print "step", frame
		input.parseInputs Time.frame
		tick
		frame++
		
	tick
		graphics.startFrame
		app.tick
		graphics.finishFrame
		
		

global skipInit unit math
	init
		initDefaultRandomGenerator
		
	cpp(cstdlib, ctime) void initDefaultRandomGenerator
		std::srand(std::time(nullptr));
		
	// Generates a random integer
	global inline cpp(cstdlib, cmath) int randomInteger: int from // The inclusive lower bound of the random integer
		                                          int to // The exclusive upper bound of the random integer
		(from + std::floor(std::rand() * (to-from)))
	
	global inline cpp(cstdlib, cmath) int randomInteger: int to = 2147483647 // The exclusive upper bound of the random integer
		(from + std::floor(std::rand() * (to-from)))
	
	// Generates a random float
	global inline cpp(cstdlib) int randomFloat: float from
		                                 float to
		(from + std::rand() * (to-from))
	
	global inline cpp(cstdlib) int randomFloat: float to = 1.0
		(std::rand() * to)
		

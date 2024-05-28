app
	int clicks
	
	init
		core.testLobby = true
		core.drawPointsForTesting = true
		PeerNetwork.relayMode = Always
		
	tick
		drawImage Rat, frame:0, onClick:clicks++
		drawText clicks, {0,-100}

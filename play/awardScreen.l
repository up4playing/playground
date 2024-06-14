awardScreen
	bool active
	tick
		onKeyDown Alt W: active = not active
		if active
			let size = {720, 540}
			forPositions players, grid:{2,2}, delta:size
				drawVideo . position:pos, size
				drawText .score, pos * {2.13, 1.8}, font:ByTheWay		
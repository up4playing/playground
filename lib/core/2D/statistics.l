skipInit transient unit statistics
	const Color backgroundColor = {"#202020"}
	internal draw
		Vector2 startPos = position + size
		Vector2 labelPos = position + {size.x/2, -12}
		const height = size.y - 20
		int graphIndex = 0
		for graphs -> s
			if .set != currentSet: continue
			string text = "{.label}: {.lastValue.format(fractionDigits:1)}"
			drawRectangle labelPos, {8,8}, color:.color, align:Left
			drawText text, labelPos+{11, -2}, align:Left, size:12
			labelPos.x += graphics.getTextWidth(text, size:12) + 50
			
			int len = math.min(.values.length, size.x.round)
			float prevY = 0
			for len
				let value = s.values[s.values.length-1-i]
				Vector2 pos = {startPos.x - i, startPos.y - (value/maxValue).atMost(1)*height + graphIndex}
				if i: drawRectangle pos, size:{4, prevY-pos.y+4}, color:s.color, valign:Top
				prevY = pos.y
			graphIndex++
				
		// Draw infos
		for infos <-
			let x = (core.frame - .frame)/framesPerValue
			if x > size.x: break
			drawText cast .value, {position.x + size.x - x, position.y + 10*.index}, size:8, valign:Top
				
		if core.errorMessage: drawText core.errorMessage, position, align:Left, size:12, color:{"#ffff00"}
		drawText "#{core.frame} {maxValue}", {position.x+size.x-8, labelPos.y}, align:Right, size:12
		drawRectangle position, size, color:backgroundColor, align:Left, valign:Top
		
internal unit networkVisualizer
	internal draw
		if core.simulateInputsForTesting
			for players -> player
				drawCircle {1110+player.index*20, -540+posForPlayer[player.index]}, size:20, color:.color
		
		// // AheadMin
		// let minY = 510 - getHeightForFrame(core.frame-core.aheadMin+1)
		// drawLine {960,minY} to {1100,minY} width:3
		// drawText cast core.aheadMin, {1110, minY}, size:20, align:Left
		
		// Draw bar to visualizue up to which frame we got input from each player
		for players -> player
			let internaluser = input.internalUsers[.id]
				// BufferFrames
				let bufferY = 510 - getHeightForFrame(core.frame-internaluser.bufferFrames+1)
				drawLine {960,bufferY} to {1100,bufferY} width:3, color:.color
				drawText cast internaluser.bufferFrames, {1110, bufferY}, size:20, color:.color, align:Left
		
				drawRectangle {984+player.index*32, 510} size:{24, getHeightForFrame(internaluser.inputFrame)}, valign:Bottom, color:.color
		
		// Replay from
		if core.replayFrom != -1
			let bufferY = 510 - getHeightForFrame(core.replayFrom)
			drawLine {960,bufferY} to {1100,bufferY} width:3, color:White
			drawText cast(core.frame - core.replayFrom), {1110, bufferY}, size:20, color:White, align:Left

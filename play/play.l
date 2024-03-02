// Draw on the screen
transient skipInit global unit graphics
	// Draw a button with the default style
	// Example: If the current player instance touches or clicks the image or 16 pixels around it, we print the exact position that was touched. If other players will touch the image, nothing will happen.
	//     Player
	//         bool done
	//         tick
	//             if not done
	//                 drawButton "I'm done", visibleFor:me
	//                     done = true
	// Image: drawButton.png
	global void drawStandardButton: text = ""                            // The text of the button
		                            Vector2 position = {}                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                            Color accentColor = null             // Tint the accent image with this color, defaults to the color of the local player
		                            implicit Player[] visibleFor = null  // Only this player or list of players will see the button
		                            implicit Player[] touchableBy = null // Only this player or list of players can touch or click the button
		                            hotkey = Key.None                    // This keyboard shortcut will execute the onTouch handler
		                            implicit layer = 0                   // Higher layers are drawn in front of lower layers
		                            alpha = 1.0                          // The opacity of the button (0: fully transparent, 1: fully visible)
		                            enabled = true                       // When not enabled, the button isn't touchable and is drawn transparently (50% by default)
		                            void(Touch touch) onTouch = null     // Execute this code when the user touches or clicks the button or presses the hotkey
	                                SourceCodeLocation location
		drawButton Button, accentImage:ButtonAccent, textColorOnHover:Black, textSize:24, text, position, accentColor, visibleFor, touchableBy, hotkey, layer, alpha, enabled, onTouch, location
		
	// Draw a large button with the default style
	// Example: If the current player instance touches or clicks the image or 16 pixels around it, we print the exact position that was touched. If other players will touch the image, nothing will happen.
	//     Player
	//         bool done
	//         tick
	//             if not done
	//                 drawButton "I'm done", visibleFor:me
	//                     done = true
	// Image: drawButton.png
	global void drawLargeButton: text = ""                            // The text of the button
		                         Vector2 position = {}                // By default, {0,0} is the center, {-960,-540} is the top left, {960,540} is the bottom right
		                         Color accentColor = null             // Tint the accent image with this color, defaults to the color of the local player
		                         implicit Player[] visibleFor = null  // Only this player or list of players will see the button
		                         implicit Player[] touchableBy = null // Only this player or list of players can touch or click the button
		                         hotkey = Key.None                    // This keyboard shortcut will execute the onTouch handler
		                         implicit layer = 0                   // Higher layers are drawn in front of lower layers
		                         alpha = 1.0                          // The opacity of the button (0: fully transparent, 1: fully visible)
		                         enabled = true                       // When not enabled, the button isn't touchable and is drawn transparently (50% by default)
		                         void(Touch touch) onTouch = null     // Execute this code when the user touches or clicks the button or presses the hotkey
	                             SourceCodeLocation location
		drawButton LargeButton, accentImage:LargeButtonAccent, textColorOnHover:Black, textSize:24, text, position, accentColor, visibleFor, touchableBy, hotkey, layer, alpha, enabled, onTouch, location

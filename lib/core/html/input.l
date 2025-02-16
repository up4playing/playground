enum Key
	None         =   0
	Backspace    =   8
	Tab          =   9
	Enter        =  13
	Shift        =  16
	Ctrl         =  17
	Alt          =  18
	Pause        =  19
	CapsLock     =  20
	Escape       =  27
	Space        =  32
	PageUp       =  33
	PageDown     =  34
	End          =  35
	Home         =  36
	Left         =  37
	Up           =  38
	Right        =  39
	Down         =  40
	Insert       =  45
	Delete       =  46
	Number0      =  48
	Number1      =  49
	Number2      =  50
	Number3      =  51
	Number4      =  52
	Number5      =  53
	Number6      =  54
	Number7      =  55
	Number8      =  56
	Number9      =  57
	A            =  65
	B            =  66
	C            =  67
	D            =  68
	E            =  69
	F            =  70
	G            =  71
	H            =  72
	I            =  73
	J            =  74
	K            =  75
	L            =  76
	M            =  77
	N            =  78
	O            =  79
	P            =  80
	Q            =  81
	R            =  82
	S            =  83
	T            =  84
	U            =  85
	V            =  86
	W            =  87
	X            =  88
	Y            =  89
	Z            =  90
	LeftMetaKey  =  91
	RightMetaKey =  92
	Select       =  93
	Numpad0      =  96
	Numpad1      =  97
	Numpad2      =  98
	Numpad3      =  99
	Numpad4      = 100
	Numpad5      = 101
	Numpad6      = 102
	Numpad7      = 103
	Numpad8      = 104
	Numpad9      = 105
	Multiply     = 106
	Add          = 107
	Subtract     = 109
	DecimalPoint = 110
	Divide       = 111
	F1           = 112
	F2           = 113
	F3           = 114
	F4           = 115
	F5           = 116
	F6           = 117
	F7           = 118
	F8           = 119
	F9           = 120
	F10          = 121
	F11          = 122
	F12          = 123
	F13          = 124
	F14          = 125
	F15          = 126
	F16          = 127
	F17          = 128
	F18          = 129
	F19          = 130
	F20          = 131
	F21          = 132
	F22          = 133
	F23          = 134
	F24          = 135
	NumLock      = 144
	ScrollLock   = 145
	SemiColon    = 186
	EqualSign    = 187
	Comma        = 188
	Dash         = 189
	Period       = 190
	ForwardSlash = 191
	GraveAccent  = 192
	OpenBracket  = 219
	BackSlash    = 220
	CloseBraket  = 221
	SingleQuote  = 222
	
KeyListener
	Key key
	void(Key key) do
	
// Phase of a touch or a click
enum TouchPhase: Still, Down, Move, Up, Canceled
		
enum TouchType: Left, Middle, Right, Touch, Pen

// A touch or a click
class Touch
	int id            // A unique identifier for the pointer causing the event (for example, a finger)
	TouchPhase phase  // Still, Down, Move, Up
	TouchType type    // Left, Middle, Right, Touch, Pen
	Vector2 position  // The position of the touch reletive to the page
	string touchedId  // The id of the touched html node
	bool shiftKey     // Is the shift key down?
	bool altKey       // Is the alt key down?
	bool ctrlKey      // Is the control key down?
	bool metaKey      // Is the meta key ("Command" on Mac, "Windows" on Windows) down?
	
unit input
	KeyListener[] keyDownListeners
	// void(Vector2 position, Vector2 delta, bool isPinch)[] scrollListeners
	
	init
		initHandlers
		
	js void initHandlers
		document.onkeydown = ev => {
			if(ev.key == "F10") { 
				Platform.toggleSmallScreen();
			}
			for(let listener of input.keyDownListeners) {
				if(ev.keyCode == listener.key) {
					listener.do.invoke(ev.keyCode)
					ev.preventDefault();
					ev.stopPropagation();
					return false;
				}
			}
		}
		
		// if(window._handlersInitialized) return
		// window._handlersInitialized = true
		// window.addEventListener('wheel', ev => {
		// 	if(input.scrollListeners.length > 0) {
		// 		ev.preventDefault();
		// 		ev.stopPropagation();
		// 		for(let listener of input.scrollListeners) {
		// 			listener.invoke(new Vector2(ev.clientX/Platform.scale, ev.clientY/Platform.scale, "px"), new Vector2(-ev.deltaX, ev.deltaY, "px"), ev.ctrlKey);
		// 		}
		// 		return false;			
		// 	}
		// }, {passive: false})

	clear
		keyDownListeners.clear
		// scrollListeners.clear
	
	onKeyDown: Key key
		       stored void(Key key) do
		keyDownListeners.add {key, do}
		
	// onScroll: stored void(Vector2 position, Vector2 delta, bool isPinch) do
	// 	scrollListeners.add do
	

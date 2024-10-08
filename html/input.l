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
enum TouchPhase: Still, Down, Move, Up
		
enum TouchType: Left, Middle, Right, Touch, Pen

// A touch or a click
class Touch
	int id
	TouchPhase phase
	TouchType type
	Vector2 position
	
unit input
	KeyListener[] keyDownListeners
	void(Vector2 position, Vector2 delta, bool isPinch)[] scrollListeners
	void(Touch touch)[] touchDownListeners, touchMoveListeners, touchUpListeners
	Touch[] touches
	
	init
		initHandlers
	
	js void initHandlers
		document.body.onpointerdown = e => {
			let id = e.pointerId;
			let touch = new Touch(id, 1, input.getTouchType(e.pointerType, e.button), new Vector2(e.pageX/Platform.scale, e.pageY/Platform.scale, "px"));
			input.touches.push(touch);
			for(let listener of input.touchDownListeners)
				listener.invoke(touch);
			e.preventDefault();
			e.stopPropagation();
		}
		document.body.onpointermove = e => {
			let id = e.pointerId;
			let touch = input.touches.find(a => a.id == id);
			if(touch) {
				touch.position.x = e.pageX/Platform.scale;
				touch.position.y = e.pageY/Platform.scale;
				for(let listener of input.touchMoveListeners)
					listener.invoke(touch);
			}
			e.preventDefault();
			e.stopPropagation();
		}
		document.body.onpointerup = e => {
			let id = e.pointerId;
			let index = input.touches.indexWhere(a => a.id == id, 0);
			if(index != -1) {
				let touch = input.touches[index];
				input.touches.splice(index, 1);
				for(let listener of input.touchUpListeners)
					listener.invoke(touch);
			}
			e.preventDefault();
			e.stopPropagation();
		}
		window.oncontextmenu = e => {
			e.preventDefault();
			e.stopPropagation();
			return false;
		}
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
		if(!window._isWheelHandlerSet) {
			window._isWheelHandlerSet = true
			window.addEventListener('wheel', e => {
				if(input.scrollListeners.length > 0) {
					e.preventDefault();
					e.stopPropagation();
					for(let listener of input.scrollListeners) {
						listener.invoke(new Vector2(e.clientX/Platform.scale, e.clientY/Platform.scale), new Vector2(-e.deltaX, e.deltaY), e.ctrlKey);
					}
					return false;			
				}
			}, {passive: false})
		}
		
	internal TouchType getTouchType: string pointerType, int button,
		if pointerType == "mouse": return cast button.limit(0..2)
		if pointerType == "touch": return Touch
			                       return Pen
			
	clear
		keyDownListeners.clear	
		scrollListeners.clear
		touchDownListeners.clear	
		touchMoveListeners.clear
		touchUpListeners.clear
	
	onKeyDown: Key key
		       stored void(Key key) do
		keyDownListeners.add {key, do}
		
	onTouchDown: stored void(Touch touch) do
		touchDownListeners.add do
		
	onTouchMove: stored void(Touch touch) do
		touchMoveListeners.add do
		
	onTouchUp: stored void(Touch touch) do
		touchUpListeners.add do
		
	onScroll: stored void(Vector2 position, Vector2 delta, bool isPinch) do
		scrollListeners.add do
	

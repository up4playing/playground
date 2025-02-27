js HTMLElement
class Node
	string id // A unique string to indentify a specic element, often used to style a single element
	
	// A string to assign a class to one or more elements, often used to style several elements
	inline js string class() this.className
	
	// A string to assign a class to one or more elements, often used to style several elements
	inline js string class(string value) this.className = value
	
	string tagName
	string title
	Style style
	string innerHTML
	string innerText
	string shadowInnerHtml
	string value
	string src
	Node firstChild
	Node nextSibling
	Node parentNode
	float scrollHeight
	string href
	
	bool muted
	bool autoplay
	bool disabled
	int tabindex
	string contentEditable
	dynamic context
	float width
	float height
	
	string sourceLocation
	bool hasChildren
	File[] files
	bool complete // Is the resouce completely loaded?
	
	Node[string] childrenByKey
	bool used
		
	inline js Node remove() this.remove()
	inline js void appendChild(Node node) this.appendChild(node)
	inline js void insertBefore(Node newNode, Node referenceNode) this.insertBefore(newNode, referenceNode)
	inline js void setSelectionRange(int from, int to) this.setSelectionRange(from, to)
	inline js void select() this.select()
	inline js void setCursorPosition(int index) Html.setCursorPosition(this, index)
	inline js void focus() this.focus()
	inline js void scrollToBottom() this.scrollTo(0, this.scrollHeight)
	inline js void scrollIntoView() this.scrollIntoView()
	inline js void on(string eventName, void(dynamic event) listener) this.addEventListener(eventName, listener)
	inline js dynamic getContext(string type) this.getContext(type)
		
	native void(HtmlEvent ev) onclick
	native void(HtmlEvent ev) oncontextmenu
	native void(PointerEvent ev) onpointerdown
	native void(PointerEvent ev) onpointermove
	native void(PointerEvent ev) onpointerup
	native void(PointerEvent ev) onpointerover
	native void(PointerEvent ev) onpointerout
	native void(PointerEvent ev) onpointercancel
	
	native void(HtmlKeyboardEvent ev) onkeydown
	native void(HtmlKeyboardEvent ev) onkeyup
	native void(HtmlEvent ev) oninput
	native void(HtmlEvent ev) onchange
	native void(HtmlEvent ev) onload
	native void(HtmlEvent ev) onblur
	
	inline js void set(string name, string value) this.setAttribute(name, value)
	inline js void get(string name) this.getAttribute(name)
	
	static inline js Node create(string tagName = "div") document.createElement(tagName);
	inline js void click() this.click()
	
	inline js void animate: Style from
		                    Style to
		                    Time duration = 1 seconds
		                    AnimationFill fill = Forwards
		                    easing = "linear"
		this.animate([Html.expandStyle(from), Html.expandStyle(to)], {@duration:duration, @fill:fill, @easing:easing})
		
	Touch[] touches
	
	onTouchDown: void(Touch touch, Touch[] touches, Node node, PointerEvent event) do
		this.onpointerdown = {
			if this.touches == null: this.touches = []
			TouchType type
			if ev.pointerType == Mouse: type = cast ev.button.limit(0..2); else
			if ev.pointerType == Touch: type = Touch; else
				                        type = Pen
			Touch touch = {phase:Down, id:ev.pointerId, type, position:new Vector2(ev.pageX/Platform.scale, ev.pageY/Platform.scale, Pixels)}
			touch.shiftKey = ev.shiftKey
			touch.ctrlKey = ev.ctrlKey
			touch.altKey = ev.altKey
			touch.metaKey = ev.metaKey
			this.touches.add touch
			do(touch, touches, this, ev)
		}
	
	onTouchMove: void(Touch touch, Touch[] touches, Node node, PointerEvent event) do
		this.onpointermove = {
			if this.touches == null: this.touches = []
			Touch touch = this.touches.find.id == ev.pointerId
			if touch
				touch.phase = Move
				touch.position.x = ev.pageX/Platform.scale
				touch.position.y = ev.pageY/Platform.scale
				do(touch, touches, this, ev)
		}
	
	onTouchUp: void(Touch touch, Touch[] touches, Node node, PointerEvent event) do
		this.onpointerup = {
			if this.touches == null: this.touches = []
			int index = this.touches.indexWhere.id == ev.pointerId
			if index != -1
				let touch = this.touches[index]
				touch.phase = Up
				touch.position.x = ev.pageX/Platform.scale
				touch.position.y = ev.pageY/Platform.scale
				touch.shiftKey = ev.shiftKey
				touch.ctrlKey = ev.ctrlKey
				touch.altKey = ev.altKey
				touch.metaKey = ev.metaKey
				Node touchedNode = Html.getNodeAt(ev.pageX, ev.pageY)
				touch.touchedId = touchedNode ? touchedNode.id : ""
				this.touches.removeAt(index)
				do(touch, touches, this, ev)
		}
		
	onTouchCancel: void(Touch touch, Touch[] touches, Node node, PointerEvent event) do
		this.onpointercancel = {
			if this.touches == null: this.touches = []
			int index = this.touches.indexWhere.id == ev.pointerId
			if index != -1
				let touch = this.touches[index]
				touch.phase = Canceled
				this.touches.removeAt(index)
				do(touch, touches, this, ev)
		}
		
	js void onScroll: void(Vector2 position, Vector2 delta, bool isPinch) do
		this.onwheel = ev => {
			ev.preventDefault();
			ev.stopPropagation();
			do(new Vector2(ev.clientX/Platform.scale, ev.clientY/Platform.scale, "px"), new Vector2(-ev.deltaX, ev.deltaY, "px"), ev.ctrlKey);
		}
		
	inline js void captureTouch(Touch touch) this.setPointerCapture(touch.id)
		
enum lowercase string PointerType: Mouse, Pen, Touch
	
immutable PointerEvent
	Node target             // The element that triggered the event
	Node currentTarget      // The element to the event handler is attached to
	int pointerId           // A unique identifier for the pointer causing the event (for example, a finger)
	PointerType pointerType // Mouse, Pen, or Touch
	int button              // The mouse button that was pressed to trigger the event
	stopPropagation         // Mark the event as handled and prevent its parent elements from receiving the event
	preventDefault          // Prevent the default action (for example, showing the context menu on a right click)
	int pageX               // The X coordinate of the pointer relative to the whole document
	int pageY               // The Y coordinate of the pointer relative to the whole document
	bool shiftKey           // Is the shift key down?
	bool altKey             // Is the alt key down?
	bool ctrlKey            // Is the control key down?
	bool metaKey            // Is the meta key ("Command" on Mac, "Windows" on Windows) down?
	
	// The position of the pointer relative to the whole document
	inline js Vector2 position() new Vector2(this.pageX/Platform.scale, this.pageY/Platform.scale)

immutable HtmlEvent
	Node target        // The element that triggered the event
	Node currentTarget // The element to the event handler is attached to
	int button         // The mouse button that was pressed to trigger the event
	stopPropagation    // Mark the event as handled and prevent its parent elements from receiving the event
	preventDefault     // Prevent the default action (for example, showing the context menu on a right click)
		
	inline Vector2 relativeTouchPosition() Html.getRelativeMousePosition(this, this.currentTarget)
	inline js Vector2 touchPosition() new Vector2(this.clientX/Platform.scale, this.clientY/Platform.scale)

immutable HtmlKeyboardEvent
	Key keyCode        // A system and implementation dependent numerical code identifying the unmodified pressed key
	Node target        // The element that triggered the event
	Node currentTarget // The element to the event handler is attached to
	stopPropagation    // Mark the event as handled and prevent its parent elements from receiving the event
	preventDefault     // Prevent the default action (for example, showing the context menu on a right click)

enum Unit
	Pixels = "px" // Pixels
	Percent = "%" // Makes the value relative to its parent's value
	Fraction = "fr" // A fraction of the available space
	
	Centimeters = "cm" // Centimeters
	Millimeters = "mm" // Millimeters
	QuarterMillimeters = "Q" // Quarter-Millimeters
	Inches = "in" // Inches
	Picas = "pc" // Picas
	Points = "pt" // Points
	
	Em = "em" // Font size of the parent (for font-size), font size of the element itself (for other properties)
	Ex = "ex" // x-height of the element's font.
	Ch = "ch" // The advance measure (width) of the glyph "0" of the element's font
	Rem = "rem" // Font size of the root element
	
	LineHeight = "lh" // Line height of the element
	RootLineHeight = "rlh" // Line height of the root element
	
	ViewportWidth = "vw" // 1% of the viewport's width
	ViewportHeigh = "vh" // 1% of the viewport's height
	ViewportMin = "vmin" // 1% of the viewport's smaller dimension
	ViewportMax = "vmax" // 1% of the viewport's larger dimension
	ViewportBlock = "vb" // 1% of the size of the initial block in the direction of the root element's block axis
	ViewportInline = "vi" // 1% of the size of the initial block in the direction of the root element's inline axis
	
	SmallViewportWidth = "svw" // 1% of the small viewport's width (without the address bar on mobile)
	SmallViewportHeight = "svh" // 1% of the small viewport's height (without the address bar on mobile)
	LargeViewportWidth = "lvw" // 1% of the large viewport's width (with the address bar on mobile)
	LargeViewportHeight = "lvh" // 1% of the large viewport's height (with the address bar on mobile)
	DynamicViewportWidth = "dvw" // 1% of the dynamic viewport's width (with the address bar on mobile if visible)
	DynamicViewportHeight = "dvh" // 1% of the dynamic viewport's height (with the address bar on mobile if visible)
		
	GeoLocation = "geo" // A geographic location on earth (x:longitude, y:latitude)
	
	Turns = "turn"    // Turns (one full rotation is 1)
	Radians = "rad"   // Radians (one full rotation is 2π)
	Degrees = "deg"   // Degrees (one full rotation is 360)
	Gradians = "grad" // Gradiants (one full rotation is 400)
	
	Auto = "auto"
	None = "none"
	
struct Dimension
	global const Dimension auto = {unit:Auto} // Automatically adjust the value to distribute the space evenly
		
	float value        // The value in the specified unit
	Unit unit = Pixels // The unit of the value (Pixels, Percent, Centimeters, Points, ViewportHeight, ViewportWidth, ...)
	
	string toString := unit == Auto ? "auto" : "{value}{unit}"
	bool toBool := value != 0
	
struct Vector2
	float x // The x coordinate of the vector
	float y // The y coordinate of the vector
	Unit unit = Pixels // The unit of the vector (Pixels, Percent, Centimeters, Points, ViewportHeight, ...)
	
	// Used to specify that the vector is not set or invalid
	static inline Vector2 none() Vector2(float.infinity, float.infinity, None)
	
	// {float.minValue, float.minValue}
	static inline Vector2 minValue() Vector2(float.minValue, float.minValue, Pixels)
	
	// {float.maxValue, float.maxValue}
	static inline Vector2 maxValue() Vector2(float.maxValue, float.maxValue, Pixels)
	
	// {0,0}
	static inline Vector2 zero() Vector2(0, 0, Pixels)
		
	// A string representation of the vector
	toString := "{x}{unit} {y}{unit}"
	
	// Returns true if the vector is not equal to Vector2.none
	bool toBool := (x != float.infinity || y != float.infinity)
		
	// Creates a copy of the vector with the same values
	Vector2 clone() := {x, y, unit}
	
	inline js Vector2 assignReference(Vector2 value) (this = value)
		
	Vector2 assign Vector2 other: x = other.x; y = other.y; unit = other.unit; return this
		
	Vector2 + Vector2 other:   return {x + other.x, y + other.y}
	Vector2 - Vector2 other:   return {x - other.x, y - other.y}
	Vector2 * Vector2 other:   return {x * other.x, y * other.y}
	Vector2 / Vector2 other:   return {x / other.x, y / other.y}
	
	Vector2 * float other:     return {x * other, y * other}
	Vector2 / float other:     return {x / other, y / other}
		
	// The length of the vector
	length := math.sqrt(x * x + y * y)
		
	// A vector with each coordinate rounded down to an integer value
	floor := Vector2(math.floor(x), math.floor(y))
	
	// A vector with each coordinate rounded down to an integer value
	ceil := Vector2(math.ceil(x), math.ceil(y))
		
	// A vector with the sign of each coordinate flipped
	inverse := Vector2(-x, -y)
		
	// A vector that points in the same direction, but has a length of 1
	normalized
		let len = math.sqrt(x * x + y * y)
		return len != 0 ? Vector2(x / len, y / len) : Vector2(0, 0)
		
	// The distance to another vector
	distanceTo: Vector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return math.sqrt(x*x + y*y)

	
enum AnimationFill
	None = "none"
	Forwards = "forwards"
	Backwards = "backwards"
	Both = "both"
	
struct float
	inline Dimension toDimension() Dimension(this, Html.defaultUnit)
		
	// Pixels
	inline Dimension px()          Dimension(this, Pixels)
		
	// Makes the value relative to its parent's value
	inline Dimension percent()     Dimension(this, Percent)
		
	// A fraction of the available space
	inline Dimension fr()          Dimension(this, Fraction)
		
	// Font size of the parent (for font-size), font size of the element itself (for other properties)
	inline Dimension em()          Dimension(this, Em)
		
	// Font size of the root element
	inline Dimension rem()         Dimension(this, Rem)
		
	// Percentage of the viewport's width
	inline Dimension vw()          Dimension(this, ViewportWidth)
		
	// Percentage of the viewport's height
	inline Dimension vh()          Dimension(this, ViewportHeigh)
		
	// Percentage of the small viewport's width (without the address bar on mobile)
	inline Dimension svw()         Dimension(this, SmallViewportWidth)
		
	// Percentage of the small viewport's height (without the address bar on mobile)
	inline Dimension svh()         Dimension(this, SmallViewportHeight)
		
struct Angle
	float value       // The value in the specified unit
	Unit unit = Turns // The unit of the value (Turns, Degrees, Gradians, or Radians)
	
	float toFloat()   return this.value
	string toString() return "{this.value}{this.unit}"
	
	// Returns true if the angle is not zero
	inline js bool toBool := this.value
	
	Angle assign Angle other: value = other.value; unit = other.unit; return this
	Angle assign float other: value = other; return this

	Angle + Angle other:   return {value + other.value, unit}
	Angle - Angle other:   return {value - other.value, unit}
	Angle * Angle other:   return {value * other.value, unit}
	Angle / Angle other:   return {value / other.value, unit}
	
	Angle + float other:   return {value + other, unit}
	Angle - float other:   return {value - other, unit}
	Angle * float other:   return {value * other, unit}
	Angle / float other:   return {value / other, unit}

	Angle += Angle other:  value += other.value; return this
	Angle -= Angle other:  value -= other.value; return this
		
	Angle += float other:  value += other; return this
	Angle -= float other:  value -= other; return this
		
	bool >  Angle other:   return value >  other.value
	bool >= Angle other:   return value >= other.value
	bool <  Angle other:   return value <  other.value
	bool <= Angle other:   return value <= other.value
	
	Angle operator - (Angle a) Angle(-a.value, a.unit)
	
	// inline js Angle rotateTowards: Angle value
	// 	                           Angle speed
	// 	(this = Angle.rotatedTowards(this, value, speed))
		
	// static Angle rotatedTowards: Angle value
	// 	                         Angle target
	// 	                         Angle speed
	// 	let delta = (((target - value + .5) % 1) + 1) % 1 - .5
	// 	let valuePlusDelta = value + delta
	// 	if delta > 0: value += speed; return value < valuePlusDelta ? value : target
	// 	else          value -= speed; return value > valuePlusDelta ? value : target
		
	// inline js Angle normalize
	// 	(((this + .5) % 1) + 1) % 1 - .5
	
	// inline js Angle % ensureSingleExecution Angle value
	// 	((this % value) + value) % value
		
	// inline js Angle operator -  (Angle a) -a
	
	// // The remainer after a division by the given value. The sign stays the same.
	// inline js Angle remainder: Angle value
	// 	(this % value)
	
immutable priority low struct float
	inline Dimension toAngle() Angle(this, Turns)

	inline Angle operator °(float value) Angle(value, Degrees)
	
	// One full rotation is 1
	inline Angle turns := Angle(this, Turns)
	
	// One full rotation is 2π (about 6.2832)
	inline Angle radians := Angle(this, Radians)
		
	// One full rotation is 360
	inline Angle degrees := Angle(this, Degrees)
		
	// One full rotation is 400
	inline Angle gradians := Angle(this, Gradians)

js Array
priority low class List<T>
	inline js T[] sort: Angle(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
		this.sort(comparer)
		
	T[] orderBy: Angle(T a) expression // First order by this expression
		return this.sort(expression(a) - expression(b))

global skipInit priority low unit math
	// Returns the absolute value
	inline js Angle abs: Angle value // The angle to return the absolute value of
		Math.abs(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline js Angle ceil: Angle value // The angle to round up
		Math.ceil(value)
		
	// Returns the largest integer less than or equal to the given value
	inline js Angle floor: Angle value // The angle to round down
		Math.floor(value)
		
	// Returns the given value rounded to the nearest integer
	inline js Angle round: Angle value // The angle to round
		Math.round(value)
		
	// Returns the smallest of the given values
	inline js Angle min: Angle a // The first angle
		                 Angle b // The second angle
		Math.min(a, b)
		
	// Returns the largest of the given values
	inline js Angle max: Angle a // The first angle
		                 Angle b // The second angle
		Math.max(a, b)
	// The ratio of a circle's circumference to its diameter
	const float PI = 3.141592653589793
	
	// The ratio of a circle's radius to its diameter
	const float TwoPI = 6.283185307179586
	
	moveTowards: Angle value
		         Angle targetValue
		         Angle speed = {.1 Turns}
		if targetValue > value: return math.min(value + speed, targetValue) else
		if targetValue < value: return math.max(value - speed, targetValue)
			
global skipInit unit math
	// Returns the arctangent of the quotient of the given values
	Angle getAngleForVector: Vector2 vector
		return math.atan2(vector.y, vector.x)
		
	Vector2 getVectorForAngle: Angle angle      // The angle in turns (0: straight up, 1: one full rotation clockwise)
		                       float radius = 1
		return new Vector2(math.sin(angle)*radius, -math.cos(angle)*radius)

enum FlexDirection
	Row = "row" // The flex container's main-axis will be the same as the text direction
	Column = "column" // The flex container's main-axis will be the same as the block-axis
	
	RowReverse = "row-reverse" // The flex container's main-axis will be the opposite direction of the text direction
	ColumnReverse = "column-reverse" // The flex container's main-axis will be the opposite direction of the block-axis
	
enum FlexWrap
	Wrap = "wrap" // The flex items break into multiple lines
	WrapReverse = "wrap-reverse" // Behaves the same as wrap but cross-start and cross-end are permuted
	NoWrap = "nowrap" // The flex items are laid out in a single line which may cause the flex container to overflow
	
enum AlignItems
	FlexStart = "flex-start" // The items are individually aligned toward the start edge of the container
	Center = "center" // The items are individuallycentered on the secondary axis
	FlexEnd = "flex-end" // The items are individuallyaligned toward the end edge of the container
	Stretch = "stretch" // The items are individually stretched along the secondary axis
	
	Normal = "normal" // For flex items, the keyword behaves as stretch
	SelfStart = "self-start" // The items are aligned toward the start edge of the container in the items writing mode
	SelfEnd = "self-end" // The items are aligned toward the end edge of the container in the items writing mode
	
	Baseline = "baseline" // All flex items are aligned such that their flex container baselines align
	FirstBaseline= "first baseline" // All flex items are aligned such that their flex container baselines align
	
	// Added in Chrome 93
	// Start = "start" // The items are individually aligned toward the start edge of the container
	// End = "end" // The items are individually aligned toward the end edge of the container

	// Only supported in Firefox
	// LastBaseline = "last baseline" // All flex items are aligned such that their flex container baselines align
	
enum AlignContent
	FlexStart = "flex-start" // When wrapping, the whole content is aligned toward the start edge on the cross axis
	Center = "center" // When wrapping, the whole content is centered on the cross axis
	FlexEnd = "flex-end" // When wrapping, the whole content is aligned toward the end edge on the cross axis
	
	SpaceEvenly = "space-evenly" // When wrapping, distribte the lines evenly with the same space around them
	SpaceBetween = "space-between" // When wrapping, distribte the lines evenly with no space at the top and bottom
	SpaceAround = "space-around" // When wrapping, distribte the lines with the same margins around them
	
	Normal = "normal" // The items are packed in their default position as if no align-content value was set
	Baseline = "baseline" // When wrapping, the whole content is aligned so the baseline match on the cross axis
	Stretch = "stretch" // When wrapping, stretch the whole content so the container is completely filled
	
	// Added in Chrome 93
	// Start = "start" // When wrapping, the whole content is aligned toward the start edge on the cross axis
	// End = "end" // When wrapping, the whole content is aligned toward the end edge on the cross axis
	
enum JustifyContent
	FlexStart = "flex-start" // The whole content is aligned toward the start edge on the main axis
	Center = "center" // The whole content is centered on the main axis
	FlexEnd = "flex-end" // The whole content is aligned toward the end edge on the main axis
	
	SpaceEvenly = "space-evenly" // Distribte the items evenly with the same space around them
	SpaceBetween = "space-between" // Distribte the items evenly with no space at the top and bottom
	SpaceAround = "space-around" // Distribte the items with the same margins around them
	
	Normal = "normal" // The items are packed in their default position as if no justify-content value was set
	Baseline = "baseline" // The whole content is aligned so the baseline match on the cross axis
	
	// Added in Chrome 93
	// Start = "start" // The items are packed flush to each other toward the start edge of the alignment container in the main axis.
	// End = "end" // The items are packed flush to each other toward the end edge of the alignment container in the main axis.
	// Left = "left" // The items are packed flush to each other toward the left edge of the alignment container. If the property's axis is not parallel with the inline axis, this value behaves like start.
	// Right = "right" // The items are packed flush to each other toward the right edge of the alignment container in the appropriate axis. If the property's axis is not parallel with the inline axis, this value behaves like start.
	
	// Only supported in Firefox
	// Safe = "safe" // Used alongside an alignment keyword. If the chosen keyword means that the item overflows the alignment container causing data loss, the item is instead aligned as if the alignment mode were start.
	// Unsafe = "unsafe" // Used alongside an alignment keyword. Regardless of the relative sizes of the item and alignment container, and regardless of whether overflow which causes data loss might happen, the given alignment value is honored.

	// Not supported for flexbox
	// Stretch = "stretch" // Stretch the whole content so the container is completely filled
	
enum Display
	Flex = "flex" // A block element that lays out its content according to the flexbox model
	Grid = "grid" // A block element that lays out its content according to the grid model
	Table = "table" // A block element that  behave like HTML <table> element
	
	Block = "block" // A block element, generates line breaks before and after the element when in the normal flow
	Inline = "inline" // An inline element, will be on the same line without line breaks in the normal flow
	
	InlineBlock = "inline-block" // A block element that will be flowed with surrounding content (like an image)
	InlineFlex = "inline-flex" // An inline element that lays out its content according to the flexbox model
	InlineGrid = "inline-grid" // An inline element that lays out its content according to the grid model
	InlineTable = "inline-table" // An inline element that  behave like HTML <table> element
	
	Contents = "contents" // These elements don't produce a specific box by themselves
	FlowRoot = "flow-root" // A block element that establishes a new block formatting context
	
	None = "none" // Turns off the display of an element so that it has no effect on layout

class Padding
	implicit Dimension top    // The padding on the top of the element
	implicit Dimension right  // The padding on the right side of the element
	implicit Dimension bottom // The padding on the bottom of the element
	implicit Dimension left   // The padding on the left side of the element
	string toString := "{top} {right} {bottom} {left}"
	
class Margin
	implicit Dimension top    // The margin on the top of the element
	implicit Dimension right  // The margin on the right side of the element
	implicit Dimension bottom // The margin on the bottom of the element
	implicit Dimension left   // The margin on the left side of the element
	string toString := "{top} {right} {bottom} {left}"
	
enum Cursor
	Pointer = "pointer" // The cursor is a pointer that indicates a link, typically an image of a pointing hand
	Default = "default" // The platform-dependent default cursor, typically an arrow
	Grab = "grab" // Something can be grabbed (dragged to be moved)
	Grabbing = "grabbing" // Something is being grabbed (dragged to be moved)
	NoDrop = "no-drop" // An item may not be dropped at the current location
	NotAllowed = "not-allowed" // The requested action will not be carried out
	Move = "move" // Something is to be moved
	Copy = "copy" // Something is to be copied
	ContextMenu = "context-menu" // A context menu is available
	Help = "help" // Help information is available
	Progress = "progress" // The program is busy in the background, but the user can still interact with the interface
	Wait = "wait" // The program is busy, and the user can't interact with the interface
	Cell = "cell" // The table cell or set of cells can be selected
	Crosshair = "crosshair" // Cross cursor, often used to indicate selection in a bitmap
	Text = "text" // The text can be selected Typically the shape of an I-beam
	VerticalText = "vertical-text" // The vertical text can be selected, typically the shape of a sideways I-beam
	Alias = "alias" // An alias or shortcut is to be created
	AllScroll = "all-scroll" // Something can be scrolled in any direction (on Windows, all-scroll is the same as move)
		
	ResizeCol = "col-resize" // The column can be resized horizontally, typically an left-right arrow with a vertial line
	ResizeRow = "row-resize" // The row can be resized vertically, typically an up-down arrow with a horizontal line
	ResizeN = "n-resize" // The top of of box can be moved
	ResizeE = "e-resize" // The right of of box can be moved
	ResizeS = "s-resize" // The bottom of of box can be moved
	ResizeW = "w-resize" // The left of of box can be moved
	ResizeNE = "ne-resize" // The top right corner of a box can be moved
	ResizeNW = "nw-resize" // The top left corner of a box can be moved
	ResizeSE = "se-resize" // The bottom right corner of a box can be moved
	ResizeSW = "sw-resize" // The bottom left corner of a box can be moved
	ResizeEW = "ew-resize" // Something can be moved left and right
	ResizeNS = "ns-resize" // Something can be moved up and down
	ResizeNESW = "nesw-resize" // Something can be moved diagonally from the bottom left to the top right
	ResizeNWSE = "nwse-resize" // Something can be moved diagonally from the top left to the bottom right
	
	ZoomIn = "zoom-in" // Something can be zoomed in
	ZoomOut = "zoom-out" // Something can be zoomed out	
	
	Auto = "auto" // The cursor will be based on the current context, for example "text" when hovering text
	None = "none" // No cursor is rendered
	
enum Position
	Absolute = "absolute" // Remove the element from the normal flow, it can be moved with top, right, bottom and left
	Relative = "relative" // Position the element in the normal flow, it can be moved with top, right, bottom and left
	Fixed = "fixed" // Remove from the element from the normal flow and fix its position
	Sticky = "sticky" // Position the element in the normal flow and fix its position
	Static = "static" // Position the element in the normal flow of the document
	
enum TextAlign
	Left = "left" // The inline contents are aligned to the left edge of the line box
	Center = "center" // The inline contents are centered within the line box
	Right = "right" // The inline contents are aligned to the right edge of the line box
	Justify = "justify" // The inline contents are justified
	
	Start = "start" // The same as left if direction is left-to-right and right if direction is right-to-left
	End = "end" // The same as right if direction is left-to-right and left if direction is right-to-left
	
	MatchParent = "match-parent" // Similar to inherit, but the values are calculated according to the parent's direction
	
enum TextOverflow
	Ellipsis = "ellipsis" // Use this to show "..." when text is too long
	Clip = "clip" // Use the default behavior
	
enum Overflow: 
	Hidden = "hidden" // Content is clipped if necessary to fit the padding box.
	Scroll = "scroll" // Content is clipped if necessary to fit the padding box and a scrollbar is shown.
	Visible = "visible" // Content is not clipped, it may be rendered outside the padding box.
	Auto = "auto" // Use the default behavior, which is visible.

enum WhiteSpace
	NoWrap = "nowrap" // Collapses white space as for normal and suppresses line breaks (text wrapping).
	Pre = "pre" // Sequences of white space are preserved. Lines are only broken at newline characters and at <br>.
	PreWrap = "pre-wrap" // Sequences of white space are preserved. Lines are broken as necessary to fill line boxes.
	PreLine = "pre-line" // Sequences of white space are collapsed. Lines are broken as necessary to fill line boxes.
	BreakSpaces = "break-spaces" // Sequences of white space are preserved. Lines can be broken at arbitrary points.
	Normal = "normal" // Sequences of white space are collapsed. Lines are broken as necessary to fill line boxes.
	
enum BorderStyle
	Solid = "solid" // Displays a single, straight, solid line
	Dotted = "dotted" // Displays a series of rounded dots
	Dashed = "dashed" // Displays a series of short square-ended dashes or line segments
	Double = "double" // Displays two straight lines that add up to the pixel size defined by border-width
	Groove = "groove" // Displays a border with a carved appearance (the opposite of ridge)
	Ridge = "ridge" // Displays a border with an extruded appearance (the opposite of groove)
	Inset = "inset" // Displays a border that makes the element appear embedded (the opposite of outset)
	Outset = "outset" // Displays a border that makes the element appear embossed (the opposite of inset)
	Hidden = "hidden" // Displays no border
	None = "none" // Displays no border
	
class Border
	global const Border None = {0} // Display no border
		
	implicit Dimension width = 1px // The thickness of the border
	BorderStyle style = Solid // The style of the border
	Color color = Black // The color of the border
	
	toString := width ? "{width} {style} {color}" : "none" 
	
class BoxShadow
	Vector2 offset // How far should the shadow be away from the element?
	implicit Dimension blur = 8px // How blurry should the shadow be?
	implicit Dimension spread = 8px // Positive values will make the shadow bigger, negative values make it smaller
	Color color = Black // The color of the showow
	bool inset // Changes the shadow to one inside the frame (as if the content was debossed inside the box)
	
	toString := "{inset ? "inset ":""}{offset.x}{offset.unit} {offset.y}{offset.unit} {blur} {spread} {color}"
	
enum lowercase string PointerEvents
	None // On its own, it doesn't trigger pointer event, but its subtree could by setting pointerEvents 
	Auto // The element behaves as it would if the pointerEvents property were not specified
	
dynamic Style
	AlignItems alignItems // Align the individual items along the cross axis
	AlignContent alignContent // When wrapping, align the whole content along the cross axis
	string alignSelf // The alignment for selected items inside a flexible container
	string animation // A shorthand property for all the animation properties, except the animationPlayState
	string animationDelay // When the animation will start
	string animationDirection // Whether or not the animation should play in reverse on alternate cycles
	string animationDuration // How many seconds or milliseconds an animation takes to complete one cycle
	string animationFillMode // What values are applied by the animation outside the time it is executing
	string animationIterationCount // The number of times an animation should be played
	string animationName // A name for the @keyframes animation
	string animationTimingFunction // The speed curve of the animation
	string animationPlayState // Whether the animation is running or paused
	string background // All the background properties in one declaration
	string backgroundAttachment // Whether a background-image is fixed or scrolls with the page
	Color backgroundColor // The background-color of an element
	Image backgroundImage // The background-image for an element
	string backgroundPosition // The starting position of a background-image
	string backgroundRepeat // How to repeat (tile) a background-image
	string backgroundClip // The painting area of the background
	string backgroundOrigin // The positioning area of the background images
	string backgroundSize // The size of the background image
	string backfaceVisibility // Whether or not an element should be visible when not facing the screen
	Border border // BorderWidth, borderStyle, and borderColor in one declaration
	Border borderBottom // All the borderBottom properties in one declaration
	Color borderBottomColor // The color of the bottom border
	implicit Dimension borderBottomLeftRadius // The shape of the border of the bottom-left corner
	implicit Dimension borderBottomRightRadius // The shape of the border of the bottom-right corner
	BorderStyle borderBottomStyle // The style of the bottom border
	implicit Dimension borderBottomWidth // The width of the bottom border
	string borderCollapse // Whether the table border should be collapsed into a single border, or not
	Color borderColor // The color of an element's border (can have up to four values)
	string borderImage // A shorthand property for setting or returning all the borderImage properties
	implicit Dimension borderImageOutset // The amount by which the border image area extends beyond the border box
	string borderImageRepeat // Whether the image-border should be repeated, rounded or stretched
	string borderImageSlice // The inward offsets of the image-border
	string borderImageSource // The image to be used as a border
	implicit Dimension borderImageWidth // The widths of the image-border
	Border borderLeft // All the borderLeft properties in one declaration
	Color borderLeftColor // The color of the left border
	BorderStyle borderLeftStyle // The style of the left border
	implicit Dimension borderLeftWidth // The width of the left border
	implicit Dimension borderRadius // A shorthand property for setting or returning all the four borderRadius properties
	Border borderRight // All the borderRight properties in one declaration
	Color borderRightColor // The color of the right border
	BorderStyle borderRightStyle // The style of the right border
	implicit Dimension borderRightWidth // The width of the right border
	implicit Dimension borderSpacing // The space between cells in a table
	BorderStyle borderStyle // The style of an element's border (can have up to four values)
	Border borderTop // All the borderTop properties in one declaration
	Color borderTopColor // The color of the top border
	implicit Dimension borderTopLeftRadius // The shape of the border of the top-left corner
	implicit Dimension borderTopRightRadius // The shape of the border of the top-right corner
	BorderStyle borderTopStyle // The style of the top border
	implicit Dimension borderTopWidth // The width of the top border
	implicit Dimension borderWidth // The width of an element's border (can have up to four values)
	implicit Dimension bottom // The bottom position of a positioned element
	string boxDecorationBreak // The behaviour of the background and border at page-break or line-break
	BoxShadow boxShadow // Attaches one or more drop-shadows to the box
	string boxSizing // Allows you to define certain elements to fit an area in a certain way
	string captionSide // The position of the table caption
	Color caretColor // The caret/cursor color of an element
	string clear // The position of the element relative to floating objects
	string clip // Which part of a positioned element is visible
	Color color // The color of the text
	string columnCount // The number of columns an element should be divided into
	string columnFill // How to fill columns
	implicit Dimension columnGap // The gap between the columns
	string columnRule // A shorthand property for setting or returning all the columnRule properties
	Color columnRuleColor // The color of the rule between columns
	string columnRuleStyle // The style of the rule between columns
	implicit Dimension columnRuleWidth // The width of the rule between columns
	string columns // A shorthand property for setting or returning columnWidth and columnCount
	int columnSpan // How many columns an element should span across
	implicit Dimension columnWidth // The width of the columns
	string content // Used with the :before and :after pseudo-elements, to insert generated content
	string counterIncrement // Increments one or more counters
	string counterReset // Creates or resets one or more counters
	Cursor cursor // The type of cursor to display for the mouse pointer
	string direction // The text direction
	Display display // An element's display type
	string emptyCells // Whether to show the border and background of empty cells, or not
	string filter // Image filters (visual effects, like blur and saturation)
	string flex // The length of the item, relative to the rest
	implicit Dimension flexBasis // The initial length of a flexible item
	FlexDirection flexDirection // The direction of the flexible items
	string flexFlow // A shorthand property for the flexDirection and the flexWrap properties
	float flexGrow // How much the item will grow relative to the rest
	float flexShrink // How the item will shrink relative to the rest
	FlexWrap flexWrap // Whether the flexible items should wrap or not
	string cssFloat // The horizontal alignment of an element
	string font // FontStyle, fontVariant, fontWeight, fontSize, lineHeight, and fontFamily in one declaration
	string fontFamily // The font family for text
	implicit Dimension fontSize // The font size of the text
	string fontStyle // Whether the style of the font is normal, italic or oblique
	string fontVariant // Whether the font should be displayed in small capital letters
	float fontWeight // The boldness of the font
	string fontSizeAdjust // Preserves the readability of text when font fallback occurs
	string fontStretch // Selects a normal, condensed, or expanded face from a font family
	implicit Dimension gap // The gap between rows or columns
	string hangingPunctuation // Specifies whether a punctuation character may be placed outside the line box
	implicit Dimension height // The height of an element
	string hyphens // Sets how to split words to improve the layout of paragraphs
	string icon // Provides the author the ability to style an element with an iconic equivalent
	string imageOrientation // Specifies a rotation in clockwise direction appied to an image
	string isolation // Defines whether an element must create a new stacking content
	JustifyContent justifyContent // Justify the whole content along the main axis (as in "justified text")
	implicit Dimension left // The left position of a positioned element
	implicit Dimension letterSpacing // The space between characters in a text
	string lineHeight // The distance between lines in a text
	string listStyle // ListStyleImage, listStylePosition, and listStyleType in one declaration
	string listStyleImage // An image as the list-item marker
	string listStylePosition // The position of the list-item marker
	string listStyleType // The list-item marker type
	Margin margin // The margins of an element (can have up to four values)
	Margin inset // A shorthand for the top, right, bottom, left properties
	implicit Dimension marginBottom // The bottom margin of an element
	implicit Dimension marginLeft // The left margin of an element
	implicit Dimension marginRight // The right margin of an element
	implicit Dimension marginTop // The top margin of an element
	implicit Dimension maxHeight // The maximum height of an element
	implicit Dimension maxWidth // The maximum width of an element
	implicit Dimension minHeight // The minimum height of an element
	implicit Dimension minWidth // The minimum width of an element
	string navDown // Where to navigate when using the arrow-down navigation key
	string navIndex // The tabbing order for an element
	string navLeft // Where to navigate when using the arrow-left navigation key
	string navRight // Where to navigate when using the arrow-right navigation key
	string navUp // Where to navigate when using the arrow-up navigation key
	string objectFit // Specifies how the contents of a replaced element should be fitted its box
	string objectPosition // Specifies the alignment of the replaced element inside its box
	float opacity // The opacity level for an element
	string order // The order of the flexible item, relative to the rest
	string orphans // The minimum number of lines that must be left at the bottom before a page-break
	Border outline // All the outline properties in one declaration
	Color outlineColor // The color of the outline around a element
	string outlineOffset // Offsets an outline, and draws it beyond the border edge
	string outlineStyle // The style of the outline around an element
	implicit Dimension outlineWidth // The width of the outline around an element
	Overflow overflow // What to do with content that renders outside the element box
	Overflow overflowX // Specifies what to do with the left/right edges of content rendering outside the element box
	Overflow overflowY // Specifies what to do with the top/bottom edges of content rendering outside the element box
	Padding padding // The padding of an element (can have up to four values)
	implicit Dimension paddingBottom // The bottom padding of an element
	implicit Dimension paddingLeft // The left padding of an element
	implicit Dimension paddingRight // The right padding of an element
	implicit Dimension paddingTop // The top padding of an element
	string pageBreakAfter // The page-break behavior after an element
	string pageBreakBefore // The page-break behavior before an element
	string pageBreakInside // The page-break behavior inside an element
	string perspective // The perspective on how 3D elements are viewed
	string perspectiveOrigin // The bottom position of 3D elements
	Position position // The type of positioning method used for an element (static, relative, absolute or fixed)
	string quotes // The type of quotation marks for embedded quotations
	string resize // Whether or not an element is resizable by the user
	implicit Dimension right // The right position of a positioned element
	string scrollBehavior // Specifies whether to smoothly animate the scroll position when a link is clicked
	string tableLayout // The way to lay out table cells, rows, and columns
	string tabSize // The length of the tab-character
	TextAlign textAlign // The horizontal alignment of text
	string textAlignLast // How the last line of a block is aligned when text-align is "justify"
	string textDecoration // The decoration of a text
	Color textDecorationColor // The color of the text-decoration
	string textDecorationLine // The type of line in a text-decoration
	string textDecorationStyle // The style of the line in a text decoration
	string textIndent // The indentation of the first line of text
	string textJustify // The justification method used when text-align is "justify"
	TextOverflow textOverflow // What should happen when text overflows the containing element
	string textShadow // The shadow effect of a text
	string textTransform // The capitalization of a text
	implicit Dimension top // The top position of a positioned element
	string transform // Applies a 2D or 3D transformation to an element
	string transformOrigin // The position of transformed elements
	string transformStyle // How nested elements are rendered in 3D space
	string transition // A shorthand property for setting or returning the four transition properties
	string transitionProperty // The CSS property that the transition effect is for
	string transitionDuration // How many seconds or milliseconds a transition effect takes to complete
	string transitionTimingFunction // The speed curve of the transition effect
	string transitionDelay // When the transition effect will start
	string unicodeBidi // Whether the text should be overridden to support multiple languages in the same document
	string userSelect // Whether the text of an element can be selected or not
	string verticalAlign // The vertical alignment of the content in an element
	string visibility // Whether an element should be visible
	WhiteSpace whiteSpace // How to handle tabs, line breaks and whitespace in a text
	implicit Dimension width // The width of an element
	string wordBreak // Line breaking rules for non-CJK scripts
	string wordSpacing // The spacing between words in a text
	string wordWrap // Allows long, unbreakable words to be broken and wrap to the next line
	string widows // The minimum number of lines for an element that must be visible at the top of a page
	int zIndex // The stack order of a positioned element
	string gridTemplateColumns // The line names and track sizing functions of the grid columns
	PointerEvents pointerEvents
	
	Vector2 translate // Move the element by this vector
	implicit Angle rotate // Rotate the element by this angle
	
	Vector2 size
	bool overlay
	
dynamic Attributes
	string id    // A unique string to indentify a specic element, often used to style a single element
	string class // A string to assign a class to one or more elements, often used to style several elements
	string key   // A unique identifier used to find the node that should be reused
	string title
	
	native void() onClick = null                       // Execute this code when the user clicks the HTML element
	native void(HtmlEvent ev) onLeftClick = null       // Execute this code when the user clicks the HTML element
	native void(HtmlEvent ev) onRightClick = null      // Execute this code when the user clicks the HTML element with the right mouse button
	native void(HtmlKeyboardEvent ev) onKeyDown = null // Execute this code when the user presses a key on the keyboard
	native void(HtmlKeyboardEvent ev) onKeyUp = null   // Execute this code when the user releases a key on the keyboard
	
	// native void(PointerEvent ev) onTouchDown = null  // Execute this code when a touch or click starts
	// native void(PointerEvent ev) onTouchMove = null  // Execute this code when a touch or clicks moves
	// native void(PointerEvent ev) onTouchUp = null    // Execute this code when a touch or click ends
	// native void(PointerEvent ev) onTouchCancel= null // Execute this code when a touch or click is canceled
	
	int tabIndex = 0
		

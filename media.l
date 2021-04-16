// A 2D vector comprised of an x and y coordinate
struct Vector2
	static Vector2 none = new Vector2(float.infinity, float.infinity)

	float x // The x-coordinate of the vector
	float y // The y-coordinate of the vector
	
	// Returns a string representation of the vector
	string toString := "("+x+" "+y+")"
	
	// Returns true if the vector is not equal to Vector2.none
	bool toBool := (x != float.infinity || y != float.infinity)
	
	// Creates a copy of the vector with the same values
	Vector2 clone := Vector2(x, y)
		
	Vector2 operator = (Vector2 a, Vector2 b) a.x = b.x; a.y = b.y; return a
	
	Vector2 operator + (Vector2 a, Vector2 b) return Vector2(a.x+b.x, a.y+b.y)
	Vector2 operator - (Vector2 a, Vector2 b) return Vector2(a.x-b.x, a.y-b.y)
	Vector2 operator * (Vector2 a, Vector2 b) return Vector2(a.x*b.x, a.y*b.y)
	Vector2 operator / (Vector2 a, Vector2 b) return Vector2(a.x/b.x, a.y/b.y)
	
	Vector2 operator * (Vector2 a, float b) return Vector2(a.x*b, a.y*b)
	Vector2 operator * (float a, Vector2 b) return Vector2(a*b.x, a*b.y)
	Vector2 operator / (Vector2 a, float b) return Vector2(a.x/b, a.y/b)
		
	Vector2 operator * (Vector2 vector, Matrix2D matrix)
		var m = matrix.matrix
		return Vector2(
			m[0] * vector.x + m[2] * vector.y + m[4],
			m[1] * vector.x + m[3] * vector.y + m[5]
		)
		
	Vector2 operator / (Vector2 vector, Matrix2D matrix)
		var a = matrix.matrix
		var aa = a[0], ab = a[1], ac = a[2], ad = a[3], atx = a[4], aty = a[5]

		var det = aa * ad - ab * ac
		if(det == 0) return Vector2()
		det = 1.0 / det
		
		return Vector2(
			( ad * det) * vector.x + (-ac * det) * vector.y + ((ac * aty - ad * atx) * det),
			(-ab * det) * vector.x + ( aa * det) * vector.y + ((ab * atx - aa * aty) * det)
		)			
	
	Vector2 operator += (Vector2 a, Vector2 b) a.x += b.x; a.y += b.y; return a
	Vector2 operator -= (Vector2 a, Vector2 b) a.x -= b.x; a.y -= b.y; return a
	Vector2 operator *= (Vector2 a, Vector2 b) a.x *= b.x; a.y *= b.y; return a
	Vector2 operator /= (Vector2 a, Vector2 b) a.x /= b.x; a.y /= b.y; return a
	
	bool operator == (Vector2 a, Vector2 b) return a.x == b.x && a.y == b.y
	bool operator != (Vector2 a, Vector2 b) return a.x != b.x || a.y != b.y
	bool operator >  (Vector2 a, Vector2 b) return a.x >  b.x && a.y >  b.y
	bool operator >= (Vector2 a, Vector2 b) return a.x >= b.x && a.y >= b.y
	bool operator <  (Vector2 a, Vector2 b) return a.x <  b.x && a.y <  b.y
	bool operator <= (Vector2 a, Vector2 b) return a.x <= b.x && a.y <= b.y
	
	// Returns the length of the vector
	length := Math.sqrt(x * x + y * y)
		
	// Returns a vector that is orthogonal to the existing vector
	orthogonal := Vector2(-y, x)
		
	// Returns a vector with the sign of each coordinate flipped
	inverse := Vector2(-x, -y)
		
	// Returns a vector with each coordinate rounded to the closest integer value
	rounded := IntVector2(Math.round(x), Math.round(y))
	
	// Returns a vector with each coordinate rounded down to an integer value
	floor := IntVector2(Math.floor(x), Math.floor(y))
		
	ceil := IntVector2(Math.ceil(x), Math.ceil(y))
		
	abs := Vector2(Math.abs(x), Math.abs(y))
		
	max := x > y ? x : y
	
	min := x < y ? x : y
		
	// Returns the distance between two vectors
	static distanceBetween: Vector2 a // The first vector 
		                    Vector2 b // The second vector
		var x = a.x - b.x
		var y = a.y - b.y
		return Math.sqrt(x*x + y*y)

	// Returns the angle between two vectors in radians
	static angleBetween: Vector2 a // The first vector
		                 Vector2 b // The second vector
		return Math.atan2(b-a)

	// Interpolates linearly between two given vectors
	static lerp: Vector2 a   // The first vector
		         Vector2 b   // The second vector
		         float value // The interpolation value, 0 returns the first vector, 1 returns the second vector
		var ivalue = 1 - value
		return new Vector2(a.x * ivalue + b.x * value, a.y * ivalue + b.y * value)

	// Returns a vector that points in the same direction, but has a length of 1
	normalized
		let len = Math.sqrt(x * x + y * y)
		return len != 0 ? Vector2(x / len, y / len) : Vector2(0, 0)
		
	moveTowards: Vector2 targetPosition
		         float speed = 1
		let delta = targetPosition - this
		if delta.x != 0 || delta.y != 0
			delta = delta.normalized * speed
			if delta.x > 0: x = Math.min(x + delta.x, targetPosition.x)
			else            x = Math.max(x + delta.x, targetPosition.x)
			if delta.y > 0: y = Math.min(y + delta.y, targetPosition.y)
			else            y = Math.max(y + delta.y, targetPosition.y)
		
	// Transforms the vector by a given matrix
	transform: Matrix2D matrix // The matrix to transform the vector by
		var m = matrix.matrix
		x = m[0] * x + m[2] * y + m[4]
		y = m[1] * x + m[3] * y + m[5]
		return this
		
	// Returns a vector that is transformed by a given matrix
	getTransformed: Matrix2D matrix // The matrix to transform the vector by
		var m = matrix.matrix
		return Vector2(
			m[0] * x + m[2] * y + m[4],
			m[1] * x + m[3] * y + m[5]
		)

	// Returns a vector that is transformed by the inverse of the given matrix
	getRelativeTo: Matrix2D matrix // The vector will be transformed by the inverse of this matrix
		var a = matrix.matrix
		var aa = a[0], ab = a[1], ac = a[2], ad = a[3], atx = a[4], aty = a[5]

		var det = aa * ad - ab * ac
		if(det == 0) return Vector2()
		det = 1.0 / det
		
		return Vector2(
			( ad * det) * x + (-ac * det) * y + ((ac * aty - ad * atx) * det),
			(-ab * det) * x + ( aa * det) * y + ((ab * atx - aa * aty) * det)
		)
		
	// Returns whether the vector is within a given rectangle
	isWithinRectangle: Vector2 center, // The center of the rectangle
		               Vector2 size,   // The size of the rectangle
		return x >= center.x - size.x && x < center.x + size.x
		    && y >= center.y - size.y && y < center.y + size.y
		
	// Returns whether the vector is within a given polygon
	isInsidePoygon: Vector2[] poly // A list of points that make up the polygon
		let c = false, i = -1, l = poly.length, j = l - 1
		while ++i < l
			((poly[i].y <= this.y && this.y < poly[j].y) || (poly[j].y <= this.y && this.y < poly[i].y))
			&& (this.x < (poly[j].x - poly[i].x) * (this.y - poly[i].y) / (poly[j].y - poly[i].y) + poly[i].x)
			&& (c = !c)
			j = i
		return c
		
	dot: Vector2 value
		return x * value.x + y * value.y
		
	cross: Vector2 value
		return x*value.y - y*value.x
		
// A 2D vector comprised of an integer x and y coordinate
struct IntVector2
	static IntVector2 none = new IntVector2(int.minValue, int.minValue)
		
	int x // The x-coordinate of the vector
	int y // The y-coordinate of the vector
	
	// Creates a copy of the vector with the same values
	IntVector2 clone := IntVector2(x, y)
		
	// Returns a string representation of the vector
	string toString := "("+x+", "+y+")" 
	
	// Returns true if any coordinates is not zero
	bool toBool := (x != int.minValue || y != int.minValue)
	
	implicit Vector2 toVector2 := Vector2(x,y)
	
	IntVector2 operator = (IntVector2 a, IntVector2 b) a.x = b.x; a.y = b.y; return a
	
	IntVector2 operator +  (IntVector2 a, IntVector2 b) return IntVector2(a.x+b.x, a.y+b.y)
	IntVector2 operator -  (IntVector2 a, IntVector2 b) return IntVector2(a.x-b.x, a.y-b.y)
	IntVector2 operator *  (IntVector2 a, IntVector2 b) return IntVector2(a.x*b.x, a.y*b.y)
	IntVector2 operator /  (IntVector2 a, IntVector2 b) return IntVector2(a.x/b.x, a.y/b.y)
	
	IntVector2 operator *  (IntVector2 a, int b) return IntVector2(a.x*b, a.y*b)
	Vector2 operator /  (IntVector2 a, float b) return Vector2(a.x/b, a.y/b)
	
	IntVector2 operator += (IntVector2 a, IntVector2 b) a.x += b.x; a.y += b.y; return a
	IntVector2 operator -= (IntVector2 a, IntVector2 b) a.x -= b.x; a.y -= b.y; return a
	IntVector2 operator *= (IntVector2 a, IntVector2 b) a.x *= b.x; a.y *= b.y; return a
	IntVector2 operator /= (IntVector2 a, IntVector2 b) a.x /= b.x; a.y /= b.y; return a
	
	bool operator == (IntVector2 a, IntVector2 b) return a.x == b.x && a.y == b.y
	bool operator != (IntVector2 a, IntVector2 b) return a.x != b.x || a.y != b.y
	bool operator >  (IntVector2 a, IntVector2 b) return a.x >  b.x && a.y >  b.y
	bool operator >= (IntVector2 a, IntVector2 b) return a.x >= b.x && a.y >= b.y
	bool operator <  (IntVector2 a, IntVector2 b) return a.x <  b.x && a.y <  b.y
	bool operator <= (IntVector2 a, IntVector2 b) return a.x <= b.x && a.y <= b.y
	
	// Returns the length of the vector
	length := Math.sqrt(x * x + y * y)
		
	// Returns a vector that is orthogonal to the existing vector
	orthogonal := IntVector2(-y, x)
		
	// Returns a vector with the sign of each coordinate flipped
	inverse := IntVector2(-x, -y)
		
	max := x > y ? x : y
	
	min := x < y ? x : y
		
	// Returns the distance between two vectors
	static distanceBetween: IntVector2 a // The first vector 
		                    IntVector2 b // The second vector
		var x = a.x - b.x
		var y = a.y - b.y
		return Math.sqrt(x*x + y*y)

	// Returns the angle between two vectors in radians
	static angleBetween: IntVector2 a // The first vector
		                 IntVector2 b // The second vector
		return Math.atan2(b-a)
	
// A 3x2 matrix used to transform vectors in 2D space
struct Matrix2D
	float[] matrix = [1, 0, 0, 1, 0, 0] // The values of the 3x2 matrix
	
	clear
		matrix[0] = 1
		matrix[1] = 0
		matrix[2] = 0
		matrix[3] = 1
		matrix[4] = 0
		matrix[5] = 0
	
	set: float a, float b, float c, float d, float e, float f, 
		matrix[0] = a
		matrix[1] = b
		matrix[2] = c
		matrix[3] = d
		matrix[4] = e
		matrix[5] = f
	
	// Returns a copy of the matrix with the same values
	Matrix2D clone
		return Matrix2D([matrix[0], matrix[1], matrix[2], matrix[3], matrix[4], matrix[5]])

	Matrix2D operator = (Matrix2D a, Matrix2D b)
		a.matrix[0] = b.matrix[0]
		a.matrix[1] = b.matrix[1]
		a.matrix[2] = b.matrix[2]
		a.matrix[3] = b.matrix[3]
		a.matrix[4] = b.matrix[4]
		a.matrix[5] = b.matrix[5]
		return this
		
	Vector2 position := {matrix[4], matrix[5]}
	Vector2 scale := {matrix[0], matrix[3]}

	Matrix2D operator * (Matrix2D a, Matrix2D b) Matrix2D c; return multiply(a, b, c)
	Matrix2D operator *= (Matrix2D a, Matrix2D b) return multiply(a, b, a)
		
	// Returns a string representation of the matrix
	string toString := "("+matrix[0]+" "+matrix[1]+" "+matrix[2]+" "+matrix[3]+" "+matrix[4]+" "+matrix[5]+")" 
	
	// Returns true if the matrix isn't the identity matrix
	bool toBool := (matrix[0] != 1 || matrix[1] != 0 || matrix[2] != 0 || matrix[3] != 1 || matrix[4] != 0 || matrix[5] != 0)
		
	Vector2 scaleVector := { matrix[0], matrix[3] }
	
	// Moves the matrix by a given vector
	move: Vector2 vector // The matrix will be moved by this vector
		var a0 = matrix[0], a1 = matrix[1], a2 = matrix[2], a3 = matrix[3], a4 = matrix[4], a5 = matrix[5]
		var v0 = vector.x, v1 = vector.y
		
		matrix[0] = a0;
		matrix[1] = a1;
		matrix[2] = a2;
		matrix[3] = a3;
		matrix[4] = a0 * v0 + a2 * v1 + a4;
		matrix[5] = a1 * v0 + a3 * v1 + a5;		
		return this	
		
	// Rotates the matrix by a given angle	
	rotate: float angle // The angle in radians to rotate by
		var a0 = matrix[0], a1 = matrix[1], a2 = matrix[2], a3 = matrix[3], a4 = matrix[4], a5 = matrix[5]
		var s = Math.sin(angle), c = Math.cos(angle)
		
		matrix[0] = a0 *  c + a2 * s;
		matrix[1] = a1 *  c + a3 * s;
		matrix[2] = a0 * -s + a2 * c;
		matrix[3] = a1 * -s + a3 * c;
		matrix[4] = a4;
		matrix[5] = a5;
		return this	

	// Scales the matrix by a given vector
	scale: Vector2 vector // The vector to scale by
		var a0 = matrix[0], a1 = matrix[1], a2 = matrix[2], a3 = matrix[3], a4 = matrix[4], a5 = matrix[5]
		var v0 = vector.x, v1 = vector.y
		
		matrix[0] = a0 * v0;
		matrix[1] = a1 * v0;
		matrix[2] = a2 * v1;
		matrix[3] = a3 * v1;
		matrix[4] = a4;
		matrix[5] = a5;	
		return this
	
	multiplyRight(Matrix2D value) return multiply(this, value, this)
	multiplyLeft(Matrix2D value)  return multiply(value, this, this)
		
	static multiply(Matrix2D left, Matrix2D right, Matrix2D result)
		let a = left.matrix
		let a00 = a[0], a01 = a[2], a02 = a[4]
		let a10 = a[1], a11 = a[3], a12 = a[5]
		
		let b = right.matrix
		let b00 = b[0], b01 = b[2], b02 = b[4]
		let b10 = b[1], b11 = b[3], b12 = b[5]
		
		let c = result.matrix
		c[0] = b00 * a00 + b01 * a10
		c[2] = b00 * a01 + b01 * a11
		c[4] = b00 * a02 + b01 * a12 + b02
		
		c[1] = b10 * a00 + b11 * a10
		c[3] = b10 * a01 + b11 * a11
		c[5] = b10 * a02 + b11 * a12 + b12
		return result

// Helper class for converting positions within an isomatic grid
class IsometicGrid
	IntVector2 size
	Vector2 cellSize, topFaceOffset
	
	visible Vector2 xOffset = cellSize / 2
	visible Vector2 yOffset = {xOffset.x, -xOffset.y}
	visible Vector2 basePos = {-xOffset.x*(size.x-1)}
	
	// Convert from grid position to logical position
	getPosition: IntVector2 gridPos // The grid position specifies which cell we want to get the position of
		return basePos + xOffset*gridPos.x + yOffset*gridPos.y
		
	// Convert from locgical position to grid position
	getGridPosition: Vector2 pos // The logical position
		Vector2 t = pos - basePos + topFaceOffset
		let x = Math.round((xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
		let y = Math.round((xOffset.y*t.x - xOffset.x*t.y) / (2*xOffset.x*xOffset.y))
		if x >= 0 and x < size.x and y >= 0 and y < size.y: return IntVector2(x,y)
		else                                                return IntVector2.none
		
// A texture that can be loaded into video memory
struct Sound
	string file
	Sound() open
	
	js void open
		if(!window._audioCache) _audioCache = {}
		this._sound = _audioCache[this.file]
		if(!this.audio) {
			this.audio = window._audioCache[this.file] = new Audio()
			this.audio.src = this.file
		}


// A color comprised of a red, green, blue and alpha component
class Color
	global Color White   = {"ffffff"}
	global Color Black   = {"000000"}
	global Color Red     = {"ef476f"}
	global Color Yellow  = {"ffd166"}
	global Color Green   = {"06d6a0"}
	global Color Blue    = {"118ab2"}
	global Color Gray    = {"073b4c"}
	global Color TransparentRed   = {"ef476f80"}
	string hex
	
	Color: string hex = ""
		   int red = 0
		   int green = 0
		   int blue = 0
		   int alpha = 255
		if hex: this.hex = "#" + hex
		else    this.hex = "#" + componentToHex(red) + componentToHex(green) 
		                       + componentToHex(blue) + componentToHex(alpha)
			
	static js string componentToHex: int c
		var hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
	
// A texture that can be loaded into video memory
class Texture
	string file
	Vector2 size
	Texture() open
	
	js void open
		if(!window._htmlImageCache) _htmlImageCache = {}
		let image = _htmlImageCache[this.file]
		if(!image) {
			image = new HTMLImage()
			image.src = this.file
			image.onload = e => {
				this._htmlImage = image
				window._htmlImageCache[this.file] = image
				this.size = new Vector2(image.width, image.height)
				if(Platform_mode == 0) Network_tickFrame();
			}
		} else {
			this._htmlImage = image
			this.size = new Vector2(image.width, image.height)
		}

// A single frame of an animated image
struct ImageFrame
	float x1, y1, x2, y2, w, h

// An image that can be drawn on the screen and can have several frames of animation
class Image
	Texture texture
	Vector2 size
	ImageFrame[] frames
	string file
	
enum HorizontalAlignment: Left, Center, Right
enum VerticalAlignment: Top, Middle, Bottom
enum FontStyle: Normal, Bold
		
unit audio
	js void playSound: Sound sound
		sound.audio.play()
	
// A collection of methods for drawing on the screen
global unit graphics
	internal Matrix2D matrix, appMatrix
		
	internal js void clearScreen
		if(Platform_fastForward) return
		Platform_context.setTransform(1,0,0,1,0,0)
		Platform_context.clearRect(0,0,Platform_pixelSize.x, Platform_pixelSize.y)
		graphics_currentlyVisibleFor = -1
		
	internal js void drawSafeArea
		Platform_context.fillStyle = "#404040"
		Platform_context.setTransform(1,0,0,1,0,0)
		if(Platform_showSafeArea) {
			if(Platform_effectiveScaleMode == 1) {
				// Fixed width
				let ratio = Platform_pixelSize.x / Platform_referenceSize.x
				let margin = (Platform_pixelSize.y-Platform_referenceSize.y*ratio)/2
				Platform_context.fillRect(0,0,Platform_pixelSize.x, margin)
				Platform_context.fillRect(0,Platform_pixelSize.y-margin,Platform_pixelSize.x, margin)
			} else if(Platform_effectiveScaleMode == 2) {
				// Fixed height
				let ratio = Platform_pixelSize.y / Platform_referenceSize.y
				let margin = (Platform_pixelSize.x-Platform_referenceSize.x*ratio)/2
				Platform_context.fillRect(0, 0, margin, Platform_pixelSize.y)
				Platform_context.fillRect(Platform_pixelSize.x-margin, 0, margin, Platform_pixelSize.y)
			}
		}
		
	// Moves all subsequent operations by a given vector						
	move: Vector2 distance // The distance to move
		appMatrix.move distance
		matrix.move distance
							
	// Moves all operations in a block by a given vector						
	move: Vector2 distance // The distance to move
		  void() block     // All operations in this block will be moved
		let a = appMatrix.matrix, b = matrix.matrix
		let a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], a4 = a[4], a5 = a[5]
		let b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3], b4 = b[4], b5 = b[5]
		appMatrix.move distance
		matrix.move distance
		block
		a[0] = a0; a[1] = a1; a[2] = a2; a[3] = a3; a[4] = a4; a[5] = a5 
		b[0] = b0; b[1] = b1; b[2] = b2; b[3] = b3; b[4] = b4; b[5] = b5 
							
	// Rotates all subsequent operations by a given angle	
	rotate: float angle // The angle in radians
		appMatrix.rotate angle
		matrix.rotate angle
		
	// Rotates all operation in a block by a given angle				
	rotate: float angle  // The angle in radians
		    void() block // All operations in this block will be rotated
		if angle == 0: block; return
		let a = appMatrix.matrix, b = matrix.matrix
		let a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], a4 = a[4], a5 = a[5]
		let b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3], b4 = b[4], b5 = b[5]
		appMatrix.rotate angle
		matrix.rotate angle
		block
		a[0] = a0; a[1] = a1; a[2] = a2; a[3] = a3; a[4] = a4; a[5] = a5 
		b[0] = b0; b[1] = b1; b[2] = b2; b[3] = b3; b[4] = b4; b[5] = b5 
	
	// Scales all subsequent operations by a given factor
	scale: float factor // The factor to scale by
		appMatrix.scale {factor, factor}
		matrix.scale {factor, factor}
		
	// Scales all operation in a block by a given factor					
	scale: float factor // The factor to scale by
		   void() block // All operations in this block will be scaled
		let a = appMatrix.matrix, b = matrix.matrix
		let a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], a4 = a[4], a5 = a[5]
		let b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3], b4 = b[4], b5 = b[5]
		appMatrix.scale {factor, factor}
		matrix.scale {factor, factor}
		block
		a[0] = a0; a[1] = a1; a[2] = a2; a[3] = a3; a[4] = a4; a[5] = a5 
		b[0] = b0; b[1] = b1; b[2] = b2; b[3] = b3; b[4] = b4; b[5] = b5 
	
	multiply: Matrix2D matrix
		appMatrix.multiplyRight matrix
		matrix.multiplyRight matrix
	
	multiply: Matrix2D matrix
		      void() block // All operations in this block will be scaled
		let a = this.appMatrix.matrix, b = this.matrix.matrix
		let a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], a4 = a[4], a5 = a[5]
		let b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3], b4 = b[4], b5 = b[5]
		this.appMatrix.multiplyLeft matrix
		this.matrix.multiplyLeft matrix
		block
		a[0] = a0; a[1] = a1; a[2] = a2; a[3] = a3; a[4] = a4; a[5] = a5 
		b[0] = b0; b[1] = b1; b[2] = b2; b[3] = b3; b[4] = b4; b[5] = b5
	
	js int[] manipulate: void(int[] pixels) code
		let imageData = Platform_context.getImageData(0,0,Platform_pixelSize.x, Platform_pixelSize.y)
		code(imageData.data)
		Platform_context.putImageData(imageData, 0, 0)
		
	js void createImage: Vector2 size
		                 void() code
		let prevCanvas = Platform_canvas
		let prevContext = Platform_context
		let prevPixelSizeX = Platform_pixelSize.x
		let prevPixelSizeY = Platform_pixelSize.y
		Platform_canvas = document.createElement("canvas")
		Platform_canvas.width = size.x
		Platform_canvas.height = size.y
		Platform_context = Platform_canvas.getContext("2d")
		Platform_pixelSize.x = size.x
		Platform_pixelSize.y = size.y
		let a = graphics_appMatrix.matrix, b = graphics_matrix.matrix
		let a0 = a[0], a1 = a[1], a2 = a[2], a3 = a[3], a4 = a[4], a5 = a[5]
		let b0 = b[0], b1 = b[1], b2 = b[2], b3 = b[3], b4 = b[4], b5 = b[5]
		graphics_appMatrix.set(1, 0, 0, 1, -size.x/2, -size.y/2)
		graphics_matrix.set(1, 0, 0, 1, size.x/2, size.y/2)
		code()
		a[0] = a0; a[1] = a1; a[2] = a2; a[3] = a3; a[4] = a4; a[5] = a5
		b[0] = b0; b[1] = b1; b[2] = b2; b[3] = b3; b[4] = b4; b[5] = b5
		Platform_context = prevContext
		Platform_canvas = prevCanvas
		Platform_pixelSize.x = prevPixelSizeX
		Platform_pixelSize.y = prevPixelSizeY

	// Color
	private Color currentColor = White
	color
		return currentColor
	
	color: Color color
		currentColor = color
		return currentColor
		
	color: Color color
		   void() code
		let prev = currentColor
		currentColor = color
		code()
		currentColor = prev
		return currentColor
	
	// Font
	private currentFont = "Arial"
	font
		return currentFont
	
	font: string font
		currentFont = font
		return currentFont
		
	font: string font
		  void() code
		let prev = currentFont
		currentFont = font
		code()
		currentFont = prev
		return currentFont
	
	// Font size
	private currentFontSize = 30
	fontSize
		return currentFontSize
	
	fontSize: int fontSize
		currentFontSize = fontSize
		return currentFontSize
		
	fontSize: int fontSize
		      void() code
		let prev = currentFontSize
		currentFontSize = fontSize
		code()
		currentFontSize = prev
		return currentFontSize
	
	// Font size
	private currentLineWidth = 8
	lineWidth
		return currentLineWidth
	
	lineWidth: int lineWidth
		currentLineWidth = lineWidth
		return currentLineWidth
		
	lineWidth: int lineWidth
		      void() code
		let prev = currentLineWidth
		currentLineWidth = lineWidth
		code()
		currentLineWidth = prev
		return currentLineWidth
	
	// User
	private currentlyVisibleFor = -1
	visibleFor
		return currentlyVisibleFor
	
	visibleFor: int user
		currentlyVisibleFor = user
		return currentlyVisibleFor
		
	visibleFor: int user
		        void() code
		let prev = currentlyVisibleFor
		currentlyVisibleFor = user
		code()
		currentlyVisibleFor = prev
		return currentlyVisibleFor
		
	// Draws a text on the screen
	global js int getTextWidth: string text              // The text
		                        size = 18                // The size of the text in pixels
		                        FontStyle style = Normal
		                        font = ""
		if(Platform_fastForward) return
		Platform_context.font = (style ? "bold ":"")+(size || graphics_currentFontSize)+"px "+(font || graphics_currentFont)
		let textSize = Platform_context.measureText(text)
		return textSize.width
		
	// Draws an image on the screen
	global void drawImage: Image image           // The image to draw
		                   Vector2 position = {} // The position where to draw the image
		                   framesPerSecond = 0   // Animate the image with this animation speed
		                   scale = 1.0           // Scale the image by this factor
		                   visibleFor = -1
		var frame = Math.floor(Network.logicFrame * Math.max(framesPerSecond, 0) / Network.targetFps) % image.frames.length;
		drawImage image, position, frame, scale, visibleFor
		
	// Draws an image on the screen
	global js void drawImage: Image image           // The image to draw
		                      Vector2 position = {} // The position where to draw the image
		                      frame = 0             // The frame to draw
		                      scale = 1.0           // Scale the image by this factor
		                      visibleFor = -1
		if(Platform_fastForward || !image.texture || !image.texture._htmlImage) return
		if(visibleFor == -1) visibleFor = graphics_currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network_userId) return
			
		let f = image.frames[frame % image.frames.length]
		let m = graphics_matrix.matrix
		Platform_context.setTransform(m[0], -m[1], -m[2], m[3], m[4], m[5])
		try{ Platform_context.drawImage(image.texture._htmlImage, f.x1, f.y1, f.w, f.h, position.x-f.w/2*scale, position.y-f.h/2*scale, f.w*scale, f.h*scale) }
		catch(e) { log(image.file+": "+e.message) }
	
	// Draws an image on the screen
	global js void drawTextureRegion: Texture texture
		                              Vector2 sourcePosition = {}
		                              Vector2 sourceSize = {}
		                              Vector2 position = {}       // The position where to draw the image
		                              scale = 1.0                 // Scale the image by this factor
		                              visibleFor = -1
		if(Platform_fastForward || !texture || !texture._htmlImage) return
		if(visibleFor == -1) visibleFor = graphics_currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network_userId) return
			
		let m = graphics_matrix.matrix
		Platform_context.setTransform(m[0], -m[1], -m[2], m[3], m[4], m[5])
		// Platform_context.setTransform(1, 0, 0, 1, 0, 0)
		
		try { 
			Platform_context.drawImage(texture._htmlImage, 
				sourcePosition.x+texture.size.x/2-sourceSize.x/2,
				sourcePosition.y+texture.size.y/2-sourceSize.y/2,
				sourceSize.x, 
				sourceSize.y, 
				
				position.x-sourceSize.x/2*scale,
				position.y-sourceSize.y/2*scale, 
				sourceSize.x*scale, 
				sourceSize.y*scale,
			)
			log()
		}
		catch(e) { log(texture.file+": "+e.message) }
		
		// try{ Platform_context.drawImage(texture._htmlImage, sourcePosition.x-sourceSize.x/2, sourcePosition.y-sourceSize.y/2, sourceSize.x, sourceSize.y, position.x, position.y, sourceSize.x*scale, sourceSize.y*scale) }
	
	// Draws an image on the screen
	global js void drawTexture: Texture texture       // The image to draw
		                        Vector2 position = {} // The position where to draw the image
		                        scale = 1.0           // Scale the image by this factor
		                        visibleFor = -1
		if(Platform_fastForward || !texture || !texture._htmlImage) return
		if(visibleFor == -1) visibleFor = graphics_currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network_userId) return
			
		let m = graphics_matrix.matrix
		Platform_context.setTransform(m[0], -m[1], -m[2], m[3], m[4], m[5])
		
		try{ Platform_context.drawImage(texture._htmlImage, position.x-texture.size.x/2*scale, position.y-texture.size.y/2*scale, texture.size.x*scale, texture.size.y*scale) }
		catch(e) { log(texture.file+": "+e.message) }
	
	// Draws an image on the screen
	global void drawButton: Image image            // The image to draw
		                    text = ""
		                    Vector2 position = {}  // The position where to draw the image
		                    Color textColor = null // The color of the text
		                    frame = 0              // The frame to draw
		                    scale = 1.0            // Scale the image by this factor
		                    fontSize = 18
		                    visibleFor = -1
		if(Platform.fastForward) return
		if(visibleFor == -1) visibleFor = currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network.userId) return
		
		drawImage(image, position, frame, scale, visibleFor)
		if text: drawText(text, position, fontSize, textColor, visibleFor)
			
	// Draws an image on the screen
	global void drawButton: Image image             // The image to draw
		                    text = ""
		                    Vector2 position = {}   // The position where to draw the image
		                    Color textColor = null  // The color of the text
		                    frame = 0               // The frame to draw
		                    scale = 1.0             // Scale the image by this vector
		                    fontSize = 18
		                    owner = -1
		                    touchMargin = Vector2(16,16)
		                    showTouchArea = false
		                    clickableBy = -1
		                    visibleFor = -1
		                    void(Touch touch) onClick = null
		if(Platform.fastForward) return
		if(visibleFor == -1) visibleFor = currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network.userId) return
			
		drawImage(image, position, frame, scale, visibleFor)
		if text: drawText(text, position, fontSize, textColor, visibleFor)
		// drawImage image, position, scale:image.size*scale
		// if showTouchArea: drawRectangle position, size:image.size*scale + touchMargin, visibleFor, fill:TransparentRed
			
		Input.onTouchDownWithin position, image.size*scale + touchMargin, userId:clickableBy, visualize:showTouchArea
			onClick touch
			
	// Draws a text on the screen
	global js void drawText: string text                        // The text to draw
		                     position = Vector2()               // The position where to draw the text
		                     size = 0                           // The size of the text in pixels
		                     Color color = null                 // The color of the text
		                     HorizontalAlignment align = Center // The horizontal alignment of the text
		                     VerticalAlignment valign = Middle  // The vertical alignment of the text
		                     FontStyle style = Normal
		                     font = ""
		                     visibleFor = -1
		if(Platform_fastForward) return
		if(visibleFor == -1) visibleFor = graphics_currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network_userId) return
		
		let m = graphics_matrix.matrix
		Platform_context.setTransform(m[0], -m[1], -m[2], m[3], m[4], m[5])
		Platform_context.fillStyle = (color || graphics_currentColor).hex
		Platform_context.font = (style ? "bold ":"")+(size || graphics_currentFontSize)+"px "+(font || graphics_currentFont)
		Platform_context.textBaseline = valign==0 ? "top" : valign ==1 ? "middle" : "alphabetic"
		Platform_context.textAlign = align==0 ? "start" : align ==1 ? "center" : "end"
		Platform_context.fillText(text, position.x, position.y+(valign==1 ? size*0.07 : 0))
		
	// Draws a text on the screen
	global js void drawRectangle: position = Vector2()
		                          size = Vector2()
		                          Color fill = null
		                          Color stroke = null
		                          lineWidth = 0
		                          visibleFor = -1
		if(Platform_fastForward) return
		if(visibleFor == -1) visibleFor = graphics_currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network_userId) return
			
		let m = graphics_matrix.matrix
		Platform_context.setTransform(m[0], -m[1], -m[2], m[3], m[4], m[5])
		if(fill || !stroke) {
			Platform_context.fillStyle = (fill || graphics_currentColor).hex
			Platform_context.fillRect(position.x-size.x/2, position.y-size.y/2, size.x, size.y)
		}
		if(stroke) {
			Platform_context.lineWidth = lineWidth || graphics_currentLineWidth
			Platform_context.strokeStyle = stroke.hex
			Platform_context.strokeRect(position.x-size.x/2, position.y-size.y/2, size.x, size.y)
		}
		
	// Draws a text on the screen
	global js void clearRectangle: position = Vector2()
		                           size = Vector2()
		                           visibleFor = -1
		if(Platform_fastForward) return
		if(visibleFor == -1) visibleFor = graphics_currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network_userId) return
			
		let m = graphics_matrix.matrix
		Platform_context.setTransform(m[0], -m[1], -m[2], m[3], m[4], m[5])
		Platform_context.clearRect(position.x-size.x/2, position.y-size.y/2, size.x, size.y)
		
	// Draws a text on the screen
	global js void drawPolygon: Vector2[] positions
		                        Color color = null
		                        visibleFor = -1
		if(Platform_fastForward) return
		if(visibleFor == -1) visibleFor = graphics_currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network_userId) return
		let m = graphics_matrix.matrix
		Platform_context.setTransform(m[0], -m[1], -m[2], m[3], m[4], m[5])
		
		Platform_context.fillStyle = (color || graphics_currentColor).hex
		let firstPos = positions[positions.length-1]
		Platform_context.moveTo(firstPos.x, firstPos.y)
		for(let p of positions)
			Platform_context.lineTo(p.x, p.y)
		Platform_context.fill()

	global js void drawRoundedRectangle: position = Vector2()
		                                 size = Vector2()
		                                 radius = 32
		                                 Color fill = null
		                                 Color stroke = null
		                                 lineWidth = 0
		                                 visibleFor = -1
		if(Platform_fastForward) return
		if(visibleFor == -1) visibleFor = graphics_currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network_userId) return
		let m = graphics_matrix.matrix
		Platform_context.setTransform(m[0], m[1], m[2], m[3], m[4], m[5])
		let sizeX = size.x, sizeY = size.y
		let x = position.x - sizeX/2
		let y = position.y - sizeY/2
		Platform_context.beginPath();
		Platform_context.moveTo(x + radius, y);
		Platform_context.lineTo(x + sizeX - radius, y);
		Platform_context.quadraticCurveTo(x + sizeX, y, x + sizeX, y + radius);
		Platform_context.lineTo(x + sizeX, y + sizeY - radius);
		Platform_context.quadraticCurveTo(x + sizeX, y + sizeY, x + sizeX - radius, y + sizeY);
		Platform_context.lineTo(x + radius, y + sizeY);
		Platform_context.quadraticCurveTo(x, y + sizeY, x, y + sizeY - radius);
		Platform_context.lineTo(x, y + radius);
		Platform_context.quadraticCurveTo(x, y, x + radius, y);
		Platform_context.closePath();
		if(fill || !stroke) {
			Platform_context.fillStyle = (fill || graphics_currentColor).hex
			Platform_context.fill()
		}
		if(stroke) {
			Platform_context.lineWidth = lineWidth || graphics_currentLineWidth
			Platform_context.strokeStyle = stroke.hex
			Platform_context.stroke()
		}
		
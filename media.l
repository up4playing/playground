// A 2D vector comprised of an x and y coordinate
struct float2
	float x // The x-coordinate of the vector
	float y // The y-coordinate of the vector
	SourceCodeLocation location
	
	static float2 none = new float2(float.infinity, float.infinity)
	
	// Returns a string representation of the vector
	string toString := "("+x+" "+y+")"
	
	// Returns true if the vector is not equal to float2.none
	bool toBool := (x != float.infinity || y != float.infinity)
	
	// Creates a copy of the vector with the same values
	js float2 clone
		return new float2(this.x, this.y, this.location ? this.location.clone() : null)
		
	float2 operator = (float2 a, float2 b)
		a.x = b.x
		a.y = b.y
		a.location = b.location ? b.location.clone : null
		return a
	
	js float2 operator + (float2 a, float2 b)
		let l = b.location || a.location
		return new float2(a.x+b.x, a.y+b.y, l ? new SourceCodeLocation(l.row, l.column, l.file, l.generation+1, a.location, l) : null)
		
	js float2 operator - (float2 a, float2 b)
		let l = b.location || a.location
		return new float2(a.x-b.x, a.y-b.y, l ? new SourceCodeLocation(l.row, l.column, l.file, l.generation+1, a.location, l) : null)
	
	js float2 operator * (float2 a, float2 b) return new float2(a.x*b.x, a.y*b.y, null)
	js float2 operator * (float2 a, float b) return new float2(a.x*b, a.y*b, null)
	js float2 operator * (float a, float2 b) return new float2(a*b.x, a*b.y, null)
	js float2 operator * (float2 vector, Matrix2D matrix)
		return new float2(
			matrix.m0 * vector.x + matrix.m2 * vector.y + matrix.m4,
			matrix.m1 * vector.x + matrix.m3 * vector.y + matrix.m5,
			null
		)
		
	js float2 operator / (float2 a, float2 b) return new float2(a.x/b.x, a.y/b.y, null)
	js float2 operator / (float2 a, float b) return new float2(a.x/b, a.y/b, null)
	js float2 operator / (float2 vector, Matrix2D matrix)
		var aa = matrix.m0, ab = matrix.m1, ac = matrix.m2, ad = matrix.m3, atx = matrix.m4, aty = matrix.m5

		var det = aa * ad - ab * ac
		if(det == 0) return new float2(0,0,null)
		det = 1.0 / det
		
		return new float2(
			( ad * det) * vector.x + (-ac * det) * vector.y + ((ac * aty - ad * atx) * det),
			(-ab * det) * vector.x + ( aa * det) * vector.y + ((ab * atx - aa * aty) * det),
			null
		)			
	
	float2 operator += (float2 a, float2 b) a.x += b.x; a.y += b.y; return a
	float2 operator -= (float2 a, float2 b) a.x -= b.x; a.y -= b.y; return a
	float2 operator *= (float2 a, float2 b) a.x *= b.x; a.y *= b.y; return a
	float2 operator /= (float2 a, float2 b) a.x /= b.x; a.y /= b.y; return a
	
	bool operator == (float2 a, float2 b) return a.x == b.x && a.y == b.y
	bool operator != (float2 a, float2 b) return a.x != b.x || a.y != b.y
	bool operator >  (float2 a, float2 b) return a.x >  b.x && a.y >  b.y
	bool operator >= (float2 a, float2 b) return a.x >= b.x && a.y >= b.y
	bool operator <  (float2 a, float2 b) return a.x <  b.x && a.y <  b.y
	bool operator <= (float2 a, float2 b) return a.x <= b.x && a.y <= b.y
	
	// Returns the length of the vector
	length := Math.sqrt(x * x + y * y)
		
	// Returns a vector that is orthogonal to the existing vector
	orthogonal := float2(-y, x)
		
	// Returns a vector with the sign of each coordinate flipped
	inverse := float2(-x, -y)
		
	// Returns a vector with each coordinate rounded to the closest integer value
	rounded := int2(Math.round(x), Math.round(y))
	
	// Returns a vector with each coordinate rounded down to an integer value
	floor := int2(Math.floor(x), Math.floor(y))
		
	ceil := int2(Math.ceil(x), Math.ceil(y))
		
	abs := float2(Math.abs(x), Math.abs(y))
		
	max := x > y ? x : y
	
	min := x < y ? x : y
		
	// Returns the distance between two vectors
	static distanceBetween: float2 a // The first vector 
		                    float2 b // The second vector
		var x = a.x - b.x
		var y = a.y - b.y
		return Math.sqrt(x*x + y*y)

	// Returns the angle between two vectors in radians
	static angleBetween: float2 a // The first vector
		                 float2 b // The second vector
		return Math.atan2(b-a)

	// Interpolates linearly between two given vectors
	static lerp: float2 a   // The first vector
		         float2 b   // The second vector
		         float value // The interpolation value, 0 returns the first vector, 1 returns the second vector
		var ivalue = 1 - value
		return new float2(a.x * ivalue + b.x * value, a.y * ivalue + b.y * value)

	// Returns a vector that points in the same direction, but has a length of 1
	normalized
		let len = Math.sqrt(x * x + y * y)
		return len != 0 ? float2(x / len, y / len) : float2(0, 0)
		
	moveTowards: float2 targetPosition
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
		x = matrix.m0 * x + matrix.m2 * y + matrix.m4
		y = matrix.m1 * x + matrix.m3 * y + matrix.m5
		return this
		
	// Returns a vector that is transformed by a given matrix
	getTransformed: Matrix2D matrix // The matrix to transform the vector by
		return float2(
			matrix.m0 * x + matrix.m2 * y + matrix.m4,
			matrix.m1 * x + matrix.m3 * y + matrix.m5
		)

	// Returns a vector that is transformed by the inverse of the given matrix
	getRelativeTo: Matrix2D matrix // The vector will be transformed by the inverse of this matrix
		var aa = matrix.m0, ab = matrix.m1, ac = matrix.m2, ad = matrix.m3, atx = matrix.m4, aty = matrix.m5

		var det = aa * ad - ab * ac
		if(det == 0) return float2()
		det = 1.0 / det
		
		return float2(
			( ad * det) * x + (-ac * det) * y + ((ac * aty - ad * atx) * det),
			(-ab * det) * x + ( aa * det) * y + ((ab * atx - aa * aty) * det)
		)
		
	// Returns whether the vector is within a given rectangle
	isWithinRectangle: float2 center, // The center of the rectangle
		               float2 size,   // The size of the rectangle
		return x >= center.x - size.x && x < center.x + size.x
		    && y >= center.y - size.y && y < center.y + size.y
		
	// Returns whether the vector is within a given polygon
	isInsidePoygon: float2[] poly // A list of points that make up the polygon
		let c = false, i = -1, l = poly.length, j = l - 1
		while ++i < l
			((poly[i].y <= this.y && this.y < poly[j].y) || (poly[j].y <= this.y && this.y < poly[i].y))
			&& (this.x < (poly[j].x - poly[i].x) * (this.y - poly[i].y) / (poly[j].y - poly[i].y) + poly[i].x)
			&& (c = !c)
			j = i
		return c
		
	dot: float2 value
		return x * value.x + y * value.y
		
	cross: float2 value
		return x*value.y - y*value.x
		
// A 2D vector comprised of an integer x and y coordinate
struct int2
	static int2 none = new int2(int.minValue, int.minValue)
		
	int x // The x-coordinate of the vector
	int y // The y-coordinate of the vector
	
	// Creates a copy of the vector with the same values
	int2 clone := int2(x, y)
		
	// Returns a string representation of the vector
	string toString := "("+x+", "+y+")" 
	
	// Returns true if any coordinates is not zero
	bool toBool := (x != int.minValue || y != int.minValue)
	
	implicit float2 toFloat2 := float2(x,y)
	
	int2 operator = (int2 a, int2 b) a.x = b.x; a.y = b.y; return a
	
	int2 operator +  (int2 a, int2 b) return int2(a.x+b.x, a.y+b.y)
	int2 operator -  (int2 a, int2 b) return int2(a.x-b.x, a.y-b.y)
	int2 operator *  (int2 a, int2 b) return int2(a.x*b.x, a.y*b.y)
	int2 operator /  (int2 a, int2 b) return int2(a.x/b.x, a.y/b.y)
	
	int2 operator *  (int2 a, int b) return int2(a.x*b, a.y*b)
	float2 operator /  (int2 a, float b) return float2(a.x/b, a.y/b)
	
	int2 operator += (int2 a, int2 b) a.x += b.x; a.y += b.y; return a
	int2 operator -= (int2 a, int2 b) a.x -= b.x; a.y -= b.y; return a
	int2 operator *= (int2 a, int2 b) a.x *= b.x; a.y *= b.y; return a
	int2 operator /= (int2 a, int2 b) a.x /= b.x; a.y /= b.y; return a
	
	bool operator == (int2 a, int2 b) return a.x == b.x && a.y == b.y
	bool operator != (int2 a, int2 b) return a.x != b.x || a.y != b.y
	bool operator >  (int2 a, int2 b) return a.x >  b.x && a.y >  b.y
	bool operator >= (int2 a, int2 b) return a.x >= b.x && a.y >= b.y
	bool operator <  (int2 a, int2 b) return a.x <  b.x && a.y <  b.y
	bool operator <= (int2 a, int2 b) return a.x <= b.x && a.y <= b.y
	
	// Returns the length of the vector
	length := Math.sqrt(x * x + y * y)
		
	// Returns a vector that is orthogonal to the existing vector
	orthogonal := int2(-y, x)
		
	// Returns a vector with the sign of each coordinate flipped
	inverse := int2(-x, -y)
		
	max := x > y ? x : y
	
	min := x < y ? x : y
		
	// Returns the distance between two vectors
	static distanceBetween: int2 a // The first vector 
		                    int2 b // The second vector
		var x = a.x - b.x
		var y = a.y - b.y
		return Math.sqrt(x*x + y*y)

	// Returns the angle between two vectors in radians
	static angleBetween: int2 a // The first vector
		                 int2 b // The second vector
		return Math.atan2(b-a)
	
// A 3x2 matrix used to transform vectors in 2D space
struct Matrix2D
	m0 = 1.0 // X Scaling
	m1 = 0.0 // Y Skewing
	m2 = 0.0 // X Skewing
	m3 = 1.0 // Y Scaling
	m4 = 0.0 // X Translation
	m5 = 0.0 // Y Translation
	
	clear
		m0 = 1.0
		m1 = 0.0
		m2 = 0.0
		m3 = 1.0
		m4 = 0.0
		m5 = 0.0
	
	set: float m0, float m1, float m2, float m3, float m4, float m5
		this.m0 = m0
		this.m1 = m1
		this.m2 = m2
		this.m3 = m3
		this.m4 = m4
		this.m5 = m5
	
	// Returns a copy of the matrix with the same values
	Matrix2D clone
		return Matrix2D(m0, m1, m2, m3, m4, m5)

	Matrix2D operator = (Matrix2D a, Matrix2D b)
		a.m0 = b.m0
		a.m1 = b.m1
		a.m2 = b.m2
		a.m3 = b.m3
		a.m4 = b.m4
		a.m5 = b.m5
		return this
		
	float2 position := {m4, m5}
	float2 scale := {m0, m3}

	Matrix2D operator * (Matrix2D a, Matrix2D b) Matrix2D c; return multiply(a, b, c)
	Matrix2D operator *= (Matrix2D a, Matrix2D b) return multiply(a, b, a)
		
	// Returns a string representation of the matrix
	string toString := "("+m0+" "+m1+" "+m2+" "+m3+" "+m4+" "+m5+")" 
	
	// Returns true if the matrix isn't the identity matrix
	bool toBool := (m0 != 1 || m1 != 0 || m2 != 0 || m3 != 1 || m4 != 0 || m5 != 0)
		
	float2 scaleVector := { m0, m3 }
	
	// Moves the matrix by a given vector
	move: float2 vector // The matrix will be moved by this vector
		var a0 = m0, a1 = m1, a2 = m2, a3 = m3, a4 = m4, a5 = m5
		var v0 = vector.x, v1 = vector.y
		
		m0 = a0;
		m1 = a1;
		m2 = a2;
		m3 = a3;
		m4 = a0 * v0 + a2 * v1 + a4;
		m5 = a1 * v0 + a3 * v1 + a5;		
		return this	
		
	// Rotates the matrix by a given angle	
	rotate: float angle // The angle in radians to rotate by
		var a0 = m0, a1 = m1, a2 = m2, a3 = m3, a4 = m4, a5 = m5
		var s = Math.sin(angle), c = Math.cos(angle)
		
		m0 = a0 *  c + a2 * s;
		m1 = a1 *  c + a3 * s;
		m2 = a0 * -s + a2 * c;
		m3 = a1 * -s + a3 * c;
		m4 = a4;
		m5 = a5;
		return this	

	// Scales the matrix by a given vector
	scale: float2 vector // The vector to scale by
		var a0 = m0, a1 = m1, a2 = m2, a3 = m3, a4 = m4, a5 = m5
		var v0 = vector.x, v1 = vector.y
		
		m0 = a0 * v0;
		m1 = a1 * v0;
		m2 = a2 * v1;
		m3 = a3 * v1;
		m4 = a4;
		m5 = a5;	
		return this
	
	multiplyRight(Matrix2D value) return multiply(this, value, this)
	multiplyLeft(Matrix2D value)  return multiply(value, this, this)
		
	static multiply(Matrix2D left, Matrix2D right, Matrix2D result)
		let a00 = left.m0, a01 = left.m2, a02 = left.m4
		let a10 = left.m1, a11 = left.m3, a12 = left.m5
		
		let b00 = right.m0, b01 = right.m2, b02 = right.m4
		let b10 = right.m1, b11 = right.m3, b12 = right.m5
		
		result.m0 = b00 * a00 + b01 * a10
		result.m2 = b00 * a01 + b01 * a11
		result.m4 = b00 * a02 + b01 * a12 + b02
		result.m1 = b10 * a00 + b11 * a10
		result.m3 = b10 * a01 + b11 * a11
		result.m5 = b10 * a02 + b11 * a12 + b12
		return result

// Helper class for converting positions within an isomatic grid
class IsometicGrid
	int2 size            // The amount of cells in the grid
	float2 cellSize      // The size of each cell
	float2 topFaceOffset // The position of the top face within the cell
	
	visible float2 xOffset = cellSize / 2
	visible float2 yOffset = {xOffset.x, -xOffset.y}
	visible float2 basePos = {-xOffset.x*(size.x-1)}
	
	// Convert from grid position to logical position
	getPosition: int2 gridPos // The grid position specifies which cell we want to get the position of
		return basePos + xOffset*gridPos.x + yOffset*gridPos.y
		
	// Convert from locgical position to grid position
	getGridPosition: float2 pos // The logical position
		float2 t = pos - basePos + topFaceOffset
		let x = Math.round((xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
		let y = Math.round((xOffset.y*t.x - xOffset.x*t.y) / (2*xOffset.x*xOffset.y))
		if x >= 0 and x < size.x and y >= 0 and y < size.y: return int2(x,y)
		else                                                return int2.none
		
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
	float2 size
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
				this.size = new float2(image.width, image.height, null)
				if(Platform_mode == 0) Network_tickFrame();
			}
		} else {
			this._htmlImage = image
			this.size = new float2(image.width, image.height, null)
		}

// A single frame of an animated image
struct ImageFrame
	float x1, y1, x2, y2, w, h

// An image that can be drawn on the screen and can have several frames of animation
class Image
	Texture texture
	float2 size
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
	internal Matrix2D totalMatrix, localMatrix
	DisplayItem[] items
		
	internal js void startFrame
		if(Platform_fastForward) return
		Matrix2D_assign_Matrix2D(graphics_totalMatrix, Platform_baseMatrix);
		graphics_localMatrix.clear();
		Platform_context.setTransform(1,0,0,1,0,0)
		Platform_context.clearRect(0,0,Platform_pixelSize.x, Platform_pixelSize.y)
		Platform_context.textBaseline = "hanging"
		graphics_currentlyVisibleFor = -1
		graphics_items.length = 0

	finishFrame
		items.sort b.layer - a.layer
		for <- items: draw
		drawSafeArea
			
	add: int visibleFor, DisplayImage item
		if(Platform.fastForward) return
		if(visibleFor == -1) visibleFor = currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network.userId) return
		items.add item
		
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
	move: float2 distance // The distance to move
		localMatrix.move distance
		totalMatrix.move distance
							
	// Moves all operations in a block by a given vector						
	move: float2 distance // The distance to move
		  void() block     // All operations in this block will be moved
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.move distance
		totalMatrix.move distance
		block
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
							
	// Rotates all subsequent operations by a given angle	
	rotate: float angle // The angle in radians
		localMatrix.rotate angle
		totalMatrix.rotate angle
		
	// Rotates all operation in a block by a given angle				
	rotate: float angle  // The angle in radians
		    void() block // All operations in this block will be rotated
		if angle == 0: block; return
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.rotate angle
		totalMatrix.rotate angle
		block
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
	
	// Scales all subsequent operations by a given factor
	scale: float factor // The factor to scale by
		localMatrix.scale {factor, factor}
		totalMatrix.scale {factor, factor}
		
	// Scales all operation in a block by a given factor					
	scale: float factor // The factor to scale by
		   void() block // All operations in this block will be scaled
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		localMatrix.scale {factor, factor}
		totalMatrix.scale {factor, factor}
		block
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5 
	
	multiply: Matrix2D matrix
		localMatrix.multiplyRight matrix
		matrix.multiplyRight matrix
	
	multiply: Matrix2D matrix
		      void() block // All operations in this block will be scaled
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = totalMatrix.m0, b1 = totalMatrix.m1, b2 = totalMatrix.m2, b3 = totalMatrix.m3, b4 = totalMatrix.m4, b5 = totalMatrix.m5
		this.localMatrix.multiplyLeft matrix
		this.totalMatrix.multiplyLeft matrix
		block
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5 
		totalMatrix.m0 = b0; totalMatrix.m1 = b1; totalMatrix.m2 = b2; totalMatrix.m3 = b3; totalMatrix.m4 = b4; totalMatrix.m5 = b5
	
	js int[] manipulate: void(int[] pixels) code
		let imageData = Platform_context.getImageData(0,0,Platform_pixelSize.x, Platform_pixelSize.y)
		code(imageData.data)
		Platform_context.putImageData(imageData, 0, 0)
		
	js void createImage: float2 size
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
		let a = graphics_localMatrix.matrix, b = graphics_totalMatrix.matrix
		let a0 = localMatrix.m0, a1 = localMatrix.m1, a2 = localMatrix.m2, a3 = localMatrix.m3, a4 = localMatrix.m4, a5 = localMatrix.m5
		let b0 = matrix.m0, b1 = matrix.m1, b2 = matrix.m2, b3 = matrix.m3, b4 = matrix.m4, b5 = matrix.m5
		graphics_localMatrix.set(1, 0, 0, 1, -size.x/2, -size.y/2)
		graphics_totalMatrix.set(1, 0, 0, 1, size.x/2, size.y/2)
		code()
		localMatrix.m0 = a0; localMatrix.m1 = a1; localMatrix.m2 = a2; localMatrix.m3 = a3; localMatrix.m4 = a4; localMatrix.m5 = a5
		matrix.m0 = b0; matrix.m1 = b1; matrix.m2 = b2; matrix.m3 = b3; matrix.m4 = b4; matrix.m5 = b5
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
	private currentFontSize = 20
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
		                   float2 position = {} // The position where to draw the image
		                   framesPerSecond = 0   // Animate the image with this animation speed
		                   scale = 1.0           // Scale the image by this factor
		                   visibleFor = -1
		                   implicit int layer = 0
		var frame = Math.floor(Network.logicFrame * Math.max(framesPerSecond, 0) / Network.targetFps) % image.frames.length;
		drawImage image, position, frame, scale, visibleFor, layer
	
	// Draws an image on the screen
	global js void drawImage: Image image           // The image to draw
		                      float2 position = {} // The position where to draw the image
		                      frame = 0             // The frame to draw
		                      scale = 1.0           // Scale the image by this factor
		                      visibleFor = -1
		                      implicit layer = 0
		if(!image.texture || !image.texture._htmlImage) return
		let f = image.frames[frame % image.frames.length]
		graphics_add(visibleFor, new DisplayImage(
			graphics_totalMatrix,
			position.x-f.w/2*scale,
			position.y-f.h/2*scale,
			f.w*scale,
			f.h*scale,
			layer, image.file, position.location,
			image.texture._htmlImage,
			f.x1, f.y1, f.w, f.h
		))
	
	// Draws an image on the screen
	global js void drawImage: Image image           // The image to draw
		                      float2 position = {} // The position where to draw the image
		                      frame = 0             // The frame to draw
		                      scale = 1.0           // Scale the image by this factor
		                      angle = 0.0
		                      visibleFor = -1
		                      implicit layer = 0
		if(!image.texture || !image.texture._htmlImage) return
		let f = image.frames[frame % image.frames.length]
		let matrix = graphics_totalMatrix.clone()
		matrix.move(position)
		matrix.rotate(angle)
		graphics_add(visibleFor, new DisplayImage(
			matrix,
			-f.w/2*scale,
			-f.h/2*scale,
			f.w*scale,
			f.h*scale,
			layer, image.file, position.location, 
			image.texture._htmlImage,
			f.x1, f.y1, f.w, f.h
		))
	
	// Draws an image on the screen
	global js void drawTextureRegion: Texture texture
		                              float2 sourcePosition = {}
		                              float2 sourceSize = {}
		                              float2 position = {}       // The position where to draw the image
		                              scale = 1.0                 // Scale the image by this factor
		                              visibleFor = -1
		                              implicit int layer = 0
		if(!texture || !texture._htmlImage) return
		graphics_add(visibleFor, new DisplayImage(
			graphics_totalMatrix,
			position.x-texture.size.x/2*scale,
			position.y-texture.size.y/2*scale,
			texture.size.x*scale,
			texture.size.y*scale,
			
			layer, texture.file, position.location, 
			texture._htmlImage,
			
			sourcePosition.x+texture.size.x/2-sourceSize.x/2,
			sourcePosition.y+texture.size.y/2-sourceSize.y/2,
			sourceSize.x, 
			sourceSize.y, 
		))
		
		// try{ Platform_context.drawImage(texture._htmlImage, sourcePosition.x-sourceSize.x/2, sourcePosition.y-sourceSize.y/2, sourceSize.x, sourceSize.y, position.x, position.y, sourceSize.x*scale, sourceSize.y*scale) }
	
	// Draws an image on the screen
	global js void drawTexture: Texture texture       // The image to draw
		                        float2 position = {} // The position where to draw the image
		                        scale = 1.0           // Scale the image by this factor
		                        visibleFor = -1
		                        implicit int layer = 0
		if(!texture || !texture._htmlImage) return
		graphics_add(visibleFor, new DisplayImage(
			graphics_totalMatrix,
			position.x-texture.size.x/2*scale,
			position.y-texture.size.y/2*scale,
			texture.size.x*scale,
			texture.size.y*scale,
			
			layer, texture.file, position.location,
			texture._htmlImage,
			0, 0, texture.size.x, texture.size.y
		))

	// Draws an image on the screen
	global void drawButton: Image image = null      // The image to draw
		                    text = ""               // The text to draw
		                    float2 position = {}    // The position where to draw the image
		                    Color textColor = null  // The color of the text
		                    frame = 0               // The frame to draw
		                    scale = 1.0             // Scale the image by this factor
		                    fontSize = 18
		                    owner = -1
		                    touchMargin = float2(16,16)
		                    showTouchArea = false
		                    visibleFor = -1
		                    implicit layer = 0
		if(Platform.fastForward) return
		if(visibleFor == -1) visibleFor = currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network.userId) return
			
		if image: drawImage image, position, frame, scale, visibleFor, layer
		if text:  drawText text, position, fontSize, textColor, visibleFor, layer
			
	// Draws an image on the screen
	global void drawButton: Image image = null      // The image to draw
		                    text = ""               // The text to draw
		                    float2 position = {}    // The position where to draw the image
		                    Color textColor = null  // The color of the text
		                    frame = 0               // The frame to draw
		                    scale = 1.0             // Scale the image by this factor
		                    fontSize = 18
		                    owner = -1
		                    touchMargin = float2(16,16)
		                    showTouchArea = false
		                    clickableBy = -1
		                    visibleFor = -1
		                    implicit layer = 0
		                    void(Touch touch) onClick = null
		if(Platform.fastForward) return
		if(visibleFor == -1) visibleFor = currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network.userId) return
			
		if image: drawImage image, position, frame, scale, visibleFor, layer
		if text:  drawText text, position, fontSize, textColor, visibleFor, layer
			
		Input.onTouchDownWithin position, image.size*scale + touchMargin, userId:clickableBy, visualize:showTouchArea
			onClick touch
			
	// Draws a text on the screen
	global js void drawText: string text                        // The text to draw
		                     position = float2()               // The position where to draw the text
		                     size = 0                           // The size of the text in pixels
		                     Color color = null                 // The color of the text
		                     HorizontalAlignment align = Center // The horizontal alignment of the text
		                     VerticalAlignment valign = Middle  // The vertical alignment of the text
		                     FontStyle style = Normal
		                     font = ""
		                     visibleFor = -1
		                     implicit layer = 0
		let contextFont = (style ? "bold ":"")+(size || graphics_currentFontSize)+"px "+(font || graphics_currentFont);
		Platform_context.font = contextFont
		let textSize = Platform_context.measureText(text)
		let fillStyle = (color || graphics_currentColor).hex
		let w = textSize.width
		let h = size || graphics_currentFontSize
		let x = align  == 0 ? position.x : align  == 1 ? position.x-w*.5 : position.x-w
		let y = valign == 0 ? position.y : valign == 1 ? position.y-h*.365 : position.y-h
		graphics_add(visibleFor, new DisplayText(graphics_totalMatrix, x, y, w, h, layer, text, position.location, fillStyle, contextFont))
		
	// Draws a text on the screen
	global js void drawRectangle: position = float2()
		                          size = float2()
		                          Color fill = null
		                          Color stroke = null
		                          lineWidth = 0
		                          visibleFor = -1
		                          implicit layer = 0
		graphics_add(visibleFor, new DisplayRectangle(
			graphics_totalMatrix, 
			position.x-size.x/2, position.y-size.y/2, size.x, size.y,
			layer, "Rectangle", position.location,
			fill || !stroke ? (fill || graphics_currentColor).hex : null,
			stroke ? stroke.hex : null,
			lineWidth || graphics_currentLineWidth
		))
		
	// Draws a text on the screen
	global js void clearRectangle: position = float2()
		                           size = float2()
		                           visibleFor = -1
		                           implicit layer = 0
		graphics_add(visibleFor, new DisplayRectangle(
			graphics_totalMatrix, position.x-size.x/2, position.y-size.y/2, size.x, size.y, layer, "Rectangle", position.location, "clear", null, 0
		))
		
	// Draws a text on the screen
	global js void drawPolygon: float2[] positions
		                        Color color = null
		                        visibleFor = -1
		if(Platform_fastForward) return
		if(visibleFor == -1) visibleFor = graphics_currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network_userId) return
		let m = graphics_totalMatrix.matrix
		Platform_context.setTransform(m0, -m[1], -m[2], m[3], m[4], m[5])
		
		Platform_context.fillStyle = (color || graphics_currentColor).hex
		let firstPos = positions[positions.length-1]
		Platform_context.moveTo(firstPos.x, firstPos.y)
		for(let p of positions)
			Platform_context.lineTo(p.x, p.y)
		Platform_context.fill()

	global js void drawRoundedRectangle: position = float2()
		                                 size = float2()
		                                 radius = 32
		                                 Color fill = null
		                                 Color stroke = null
		                                 lineWidth = 0
		                                 visibleFor = -1
		if(Platform_fastForward) return
		if(visibleFor == -1) visibleFor = graphics_currentlyVisibleFor
		if(visibleFor != -1 && visibleFor != Network_userId) return
		let m = graphics_totalMatrix.matrix
		Platform_context.setTransform(m0, m[1], m[2], m[3], m[4], m[5])
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

class DisplayItem
	float x, y, w, h
	int layer
	string name
	SourceCodeLocation location
	
	visible float m0, m1, m2, m3, m4, m5
	visible float2[] poly
	
	DisplayItem: Matrix2D m
		m0 = m.m0; m1 = m.m1; m2 = m.m2; m3 = m.m3; m4 = m.m4; m5 = m.m5
		if Platform.isDebug
			poly = [
				{ x,   y   }.transform(m),
				{ x+w, y   }.transform(m),
				{ x+w, y+h }.transform(m),
				{ x,   y+h }.transform(m),
			]
	draw
	
DisplayItem DisplayImage
	object htmlImage
	float sx, sy, sw, sh
	js void draw
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		try{ Platform_context.drawImage(this.htmlImage, this.sx, this.sy, this.sw, this.sh, this.x, this.y, this.w, this.h) }
		catch(e) { log("DisplayImage: "+e.message) }

DisplayItem DisplayText
	string fillStyle, font
	js void draw
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		// Platform_context.fillStyle = "#ff000080"
		// Platform_context.fillRect(this.x, this.y, this.w, this.h)
		Platform_context.font = this.font
		Platform_context.fillStyle = this.fillStyle
		Platform_context.fillText(this.name, this.x, this.y/*(this.textAlign=="center" ? size*0.07 : 0)*/)
		
DisplayItem DisplayRectangle
	string fill, stroke, lineWidth
	js void draw
		Platform_context.setTransform(this.m0, this.m1, this.m2, this.m3, this.m4, this.m5)
		if(this.fill == "clear") {
			Platform_context.clearRect(this.x, this.y, this.w, this.h)
		}
		else
		if(this.fill) {
			Platform_context.fillStyle = this.fill
			Platform_context.fillRect(this.x, this.y, this.w, this.h)
		}
		if(this.stroke) {
			Platform_context.lineWidth = this.lineWidth
			Platform_context.strokeStyle = this.stroke
			Platform_context.strokeRect(this.x, this.y, this.w, this.h)
		}

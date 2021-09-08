// A 2D vector comprised of an x and y coordinate
struct float2
	float x // The x-coordinate of the vector
	float y // The y-coordinate of the vector
	SourceCodeLocation location
	
	// Used to specify that the vector is not set or invalid
	const float2 none = new float2(float.infinity, float.infinity)
	
	// A string representation of the vector
	string toString := "({x} {y})"
	
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
		return new float2(a.x+b.x, a.y+b.y, a.location || b.location ? new SourceCodeLocation(0, 0, null, a.location, b.location) : null)
		
	js float2 operator - (float2 a, float2 b)
		return new float2(a.x-b.x, a.y-b.y, a.location || b.location ? new SourceCodeLocation(0, 0, null, a.location, b.location) : null)
	
	js float2 operator * (float2 a, float2 b) return new float2(a.x*b.x, a.y*b.y, a.location || b.location ? new SourceCodeLocation(0, 0, null, a.location, b.location) : null)
	js float2 operator * (float2 a, float b) return new float2(a.x*b, a.y*b, a.location || b.location ? new SourceCodeLocation(0, 0, null, a.location, b.location) : null)
	js float2 operator * (float a, float2 b) return new float2(a*b.x, a*b.y, a.location || b.location ? new SourceCodeLocation(0, 0, null, a.location, b.location) : null)
	js float2 operator * (float2 vector, Matrix2D matrix)
		return new float2(
			matrix.m0 * vector.x + matrix.m2 * vector.y + matrix.m4,
			matrix.m1 * vector.x + matrix.m3 * vector.y + matrix.m5,
			vector.location
		)
		
	js float2 operator / (float2 a, float2 b) return new float2(a.x/b.x, a.y/b.y, a.location || b.location ? new SourceCodeLocation(0, 0, null, a.location, b.location) : null)
	js float2 operator / (float2 a, float b) return new float2(a.x/b, a.y/b, a.location || b.location ? new SourceCodeLocation(0, 0, null, a.location, b.location) : null)
	js float2 operator / (float2 vector, Matrix2D matrix)
		var aa = matrix.m0, ab = matrix.m1, ac = matrix.m2, ad = matrix.m3, atx = matrix.m4, aty = matrix.m5

		var det = aa * ad - ab * ac
		if(det == 0) return new float2(0,0,null)
		det = 1.0 / det
		
		return new float2(
			( ad * det) * vector.x + (-ac * det) * vector.y + ((ac * aty - ad * atx) * det),
			(-ab * det) * vector.x + ( aa * det) * vector.y + ((ab * atx - aa * aty) * det),
			vector.location
		)			
	
	js float2 operator % (float2 a, float2 b) return new float2(((a.x % b.x) + b.x) % b.x, ((a.y % b.y) + b.y) % b.y, a.location || b.location ? new SourceCodeLocation(0, 0, null, a.location, b.location) : null)
	js float2 operator % (float2 a, float b) return new float2(((a.x % b) + b) % b, ((a.y % b) + b) % b, a.location || b.location ? new SourceCodeLocation(0, 0, null, a.location, b.location) : null)
	
	float2 operator += (float2 a, float2 b) a.x += b.x; a.y += b.y; return a
	float2 operator -= (float2 a, float2 b) a.x -= b.x; a.y -= b.y; return a
	float2 operator *= (float2 a, float2 b) a.x *= b.x; a.y *= b.y; return a
	float2 operator /= (float2 a, float2 b) a.x /= b.x; a.y /= b.y; return a
	
	bool operator == (float2 a, float2 b) return a.x == b.x && a.y == b.y
	bool operator != (float2 a, float2 b) return a.x != b.x || a.y != b.y
	
	bool operator == (float2 a, int2 b) return a.x == b.x && a.y == b.y
	bool operator != (float2 a, int2 b) return a.x != b.x || a.y != b.y
	
	bool operator == (int2 a, float2 b) return b.x == a.x && b.y == a.y
	bool operator != (int2 a, float2 b) return b.x != a.x || b.y != a.y
	
	bool operator >  (float2 a, float2 b) return a.x >  b.x && a.y >  b.y
	bool operator >= (float2 a, float2 b) return a.x >= b.x && a.y >= b.y
	bool operator <  (float2 a, float2 b) return a.x <  b.x && a.y <  b.y
	bool operator <= (float2 a, float2 b) return a.x <= b.x && a.y <= b.y
	
	bool operator == (float2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) == length
	bool operator != (float2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) != length
	bool operator >  (float2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) >  length
	bool operator >= (float2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) >= length
	bool operator <  (float2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) <  length
	bool operator <= (float2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) <= length
	
	// The length of the vector
	length := Math.sqrt(x * x + y * y)
		
	// A vector that is orthogonal to the existing vector
	orthogonal := float2(-y, x)
		
	// A vector with the sign of each coordinate flipped
	inverse := float2(-x, -y)
		
	// A vector with each coordinate rounded to the closest integer value
	rounded := int2(Math.round(x), Math.round(y))
	
	// A vector with each coordinate rounded down to an integer value
	floor := int2(Math.floor(x), Math.floor(y))
		
	// A vector with each coordinate rounded up to an integer value
	ceil := int2(Math.ceil(x), Math.ceil(y))
		
	// A vector with the absolute value of each coordinate
	abs := float2(Math.abs(x), Math.abs(y))
		
	// The larger of the two coordinates
	max := x > y ? x : y
	
	// The smaller of the two coordinates
	min := x < y ? x : y
	
	rotate: float angle
		let x = this.x, y = this.y
		let sn = Math.sin(angle)
		let cs = Math.cos(angle)
		this.x = x * cs - y * sn;
		this.y = x * sn + y * cs;
		return this
		
	// The distance to another vector
	distanceTo: float2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return Math.sqrt(x*x + y*y)

	// The distance to another vector along axes at right angles
	manhattanDistanceTo: float2 value // The second vector
		return Math.abs(x - value.x) + Math.abs(y - value.y)

	// The angle to another vector in radians
	angleTo: float2 value // The second vector
		return Math.atan2(value - this)

	// Interpolates linearly to another vector
	interpolateTo: float2 target  // The target vector to interpolate to
		           float value    // The interpolation value, 0 returns the original vector, 1 returns the target vector
		let ivalue = 1 - value
		return new float2(x * ivalue + target.x * value, y * ivalue + target.y * value)

	// A vector that points in the same direction, but has a length of 1
	normalized
		let len = Math.sqrt(x * x + y * y)
		return len != 0 ? float2(x / len, y / len) : float2(0, 0)
	
	// Moves the vector towards the given target by the given distance	
	moveTowards: float2 targetPosition // The target to move towards
		         float distance = 1    // The distance to move by
		let delta = targetPosition - this
		if delta.x != 0 || delta.y != 0
			delta = delta.normalized * distance
			if delta.x > 0: x = Math.min(x + delta.x, targetPosition.x)
			else            x = Math.max(x + delta.x, targetPosition.x)
			if delta.y > 0: y = Math.min(y + delta.y, targetPosition.y)
			else            y = Math.max(y + delta.y, targetPosition.y)
		
	// Transforms the vector by a given matrix
	transform: Matrix2D matrix // The matrix to transform the vector by
		let ax = x, ay = y
		x = matrix.m0 * ax + matrix.m2 * ay + matrix.m4
		y = matrix.m1 * ax + matrix.m3 * ay + matrix.m5
		return this
		
	// A vector that is transformed by a given matrix
	getTransformed: Matrix2D matrix // The matrix to transform the vector by
		return float2(
			matrix.m0 * x + matrix.m2 * y + matrix.m4,
			matrix.m1 * x + matrix.m3 * y + matrix.m5
		)

	// A vector that is transformed by the inverse of the given matrix
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
	isInsideRectangle: float2 center, // The center of the rectangle
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
	
	// The dot product
	dot: float2 value // The value to calculate the dot procut with
		return x * value.x + y * value.y
		
	// The cross product
	cross: float2 value // The value to calculate the cross procut with
		return x*value.y - y*value.x
		
	serialize: Buffer buffer
		buffer.writeFloat64(x)
		buffer.writeFloat64(y)
		
	deserialize: Buffer buffer
		x = buffer.readFloat64
		y = buffer.readFloat64
		
// A 2D vector comprised of an integer x and y coordinate
struct int2
	int x // The x-coordinate of the vector
	int y // The y-coordinate of the vector
	
	// Used to specify that the vector is not set or invalid
	const int2 none = new int2(int.minValue, int.minValue)
	
	// Creates a copy of the vector with the same values
	int2 clone := int2(x, y)
		
	// A string representation of the vector
	string toString := "({x} {y})"
	
	// Returns true if the vector is not equal to int2.none
	bool toBool := (x != int.minValue || y != int.minValue)
	
	implicit float2 toFloat2 := float2(x,y)
	
	int2 operator = (int2 a, int2 b) a.x = b.x; a.y = b.y; return a
	
	int2 operator +  (int2 a, int2 b) return int2(a.x+b.x, a.y+b.y)
	int2 operator -  (int2 a, int2 b) return int2(a.x-b.x, a.y-b.y)
		
	int2 operator * (int2 a, int2 b) return int2(a.x*b.x, a.y*b.y)
	int2 operator * (int2 a, int b) return int2(a.x*b, a.y*b)
	int2 operator * (int a, int2 b) return int2(a*b.x, a*b.y)
		
	float2 operator * (int2 a, float b) return float2(a.x*b, a.y*b)
	float2 operator * (float a, int2 b) return float2(a*b.x, a*b.y)
		
	float2 operator / (int2 a, int2 b) return float2(a.x/b.x, a.y/b.y)
	float2 operator / (int2 a, float b) return float2(a.x/b, a.y/b)
	
	int2 operator % (int2 a, int b) return int2(a.x%b, a.y%b)
	int2 operator % (int2 a, int2 b) return int2(a.x%b.x, a.y%b.y)
	float2 operator % (int2 a, float b) return float2(a.x%b, a.y%b)
	float2 operator % (int2 a, float2 b) return float2(a.x%b.x, a.y%b.y)
	
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
	
	// The length of the vector
	length := Math.sqrt(x * x + y * y)
		
	// A vector that is orthogonal to the existing vector
	orthogonal := int2(-y, x)
		
	// A vector with the sign of each coordinate flipped
	inverse := int2(-x, -y)
		
	// A vector with the absolute value of each coordinate
	abs := int2(Math.abs(x), Math.abs(y))
		
	// The larger of the two coordinates
	max := x > y ? x : y
	
	// The smaller of the two coordinates
	min := x < y ? x : y
	
	limit: int2 min
		return int2(
			Math.limit x, min:min.x
			Math.limit y, min:min.y
		)
		
	limit: int2 max
		return int2(
			Math.limit x, max:max.x
			Math.limit y, max:max.y
		)
		
	limit: int2 min, int2 max
		return int2(
			Math.limit x, min:min.x, max:max.x
			Math.limit y, min:min.y, max:max.y
		)
		
	// Interpolates linearly to another vector
	interpolateTo: int2 target  // The target vector to interpolate to
		           float value    // The interpolation value, 0 returns the original vector, 1 returns the target vector
		let ivalue = 1 - value
		return new float2(x * ivalue + target.x * value, y * ivalue + target.y * value)
	
	// The distance to another vector
	distanceTo: int2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return Math.sqrt(x*x + y*y)

	// The distance to another vector along axes at right angles
	manhattanDistanceTo: int2 value // The second vector
		return Math.abs(x - value.x) + Math.abs(y - value.y)

	// The angle to another vector in radians
	angleTo: int2 value // The second vector
		return Math.atan2(value - this)
		
	// A float vector that points in the same direction, but has a length of 1
	normalized
		let len = Math.sqrt(x * x + y * y)
		return len != 0 ? float2(x / len, y / len) : float2(0, 0)
	
// A 3x2 matrix used to transform vectors in 2D space
struct Matrix2D
	m0 = 1.0 // X Scaling
	m1 = 0.0 // Y Skewing
	m2 = 0.0 // X Skewing
	m3 = 1.0 // Y Scaling
	m4 = 0.0 // X Translation
	m5 = 0.0 // Y Translation
	
	// Set the matrix to the identity matrix
	clear
		m0 = 1.0
		m1 = 0.0
		m2 = 0.0
		m3 = 1.0
		m4 = 0.0
		m5 = 0.0
	
	// Set the matrix to the given values
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
		
	Matrix2D operator * (Matrix2D a, Matrix2D b) Matrix2D c; return multiply(a, b, c)
	Matrix2D operator *= (Matrix2D a, Matrix2D b) return multiply(a, b, a)
		
	// Returns the translation component of the matrix
	float2 translationVector := {m4, m5}
	
	// Return the scale component of the matrix
	float2 scaleVector := {m0, m3}

	// Returns a string representation of the matrix
	string toString := "("+m0+" "+m1+" "+m2+" "+m3+" "+m4+" "+m5+")" 
	
	// Returns true if the matrix isn't the identity matrix
	bool toBool := (m0 != 1 || m1 != 0 || m2 != 0 || m3 != 1 || m4 != 0 || m5 != 0)
		
	// Moves the matrix by a given vector
	move: float2 vector // The matrix will be moved by this vector
		let x = vector.x, y = vector.y
		m4 += m0 * x + m2 * y
		m5 += m1 * x + m3 * y		
		return this	
		
	// Rotates the matrix by a given angle	
	rotate: float angle // The angle in radians to rotate by
		let a0 = m0, a1 = m1, a2 = m2, a3 = m3
		let sin = Math.sin(angle), cos = Math.cos(angle)
		m0 = a0 *  cos + a2 * sin
		m1 = a1 *  cos + a3 * sin
		m2 = a0 * -sin + a2 * cos
		m3 = a1 * -sin + a3 * cos
		return this	

	// Scales the matrix by a given vector
	scale: float2 vector // The vector to scale by
		let x = vector.x, y = vector.y
		m0 *= x
		m1 *= x
		m2 *= y
		m3 *= y
		return this
	
	// Return the current matrix multipied with the given matrix
	multiplyRight(Matrix2D value) return multiply(this, value, this)
		
	// Returns the given matrix multiplied with the current matrix
	multiplyLeft(Matrix2D value)  return multiply(value, this, this)
		
	// Multipies two matrices
	static multiply(Matrix2D left, Matrix2D right, Matrix2D result)
		let a0 = left.m0, a2 = left.m2, a4 = left.m4
		let a1 = left.m1, a3 = left.m3, a5 = left.m5
		
		let b0 = right.m0, b2 = right.m2, b4 = right.m4
		let b1 = right.m1, b3 = right.m3, b5 = right.m5
		
		result.m0 = b0 * a0 + b2 * a1
		result.m2 = b0 * a2 + b2 * a3
		result.m4 = b0 * a4 + b2 * a5 + b4
		result.m1 = b1 * a0 + b3 * a1
		result.m3 = b1 * a2 + b3 * a3
		result.m5 = b1 * a4 + b3 * a5 + b5
		return result

unit Math
	// Returns the arctangent of the quotient of the given values
	inline js float atan2: float2 vector
		Math.atan2(vector.y, vector.x)

// Converts positions within an isomatic grid with the origin in the north
// Tilt your head slighly to the right to visualize the directions
// World space (northwest is up)
//
//      Left   Top             
//           x               🡷 🡶
//    Bottom   Right        y     x
//
// Screen space (north is up)
//
//          Top              🡺 x
//     Left  +  Right      🡻 
//        Bottom            y
//
class IsometicGrid
	int2 size            // The amount of cells in the grid
	float2 cellSize      // The size of each cell
	float2 topFaceOffset // The position of the top face within the cell
	
	visible float2 xOffset = cellSize / 2
	visible float2 yOffset = {-xOffset.x, xOffset.y}
	visible float2 basePos = {0,-yOffset.y*(size.y-1)}
	
	// Convert world position (northwest is up) to screen position (north is up)
	getScreenPosition: float2 worldPos // The world position
		return basePos + xOffset*worldPos.x + yOffset*worldPos.y
		
	// Convert screen position (north is up) to world position (northwest is up)
	getWorldPosition: float2 screenPos // The screen position
		              bool allowOutside = false
		float2 t = screenPos - basePos + topFaceOffset
		let x = (xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y)
		let y = (xOffset.x*t.y - xOffset.y*t.x) / (2*xOffset.x*xOffset.y)
		if allowOutside or (x >= 0 and x < size.x and y >= 0 and y < size.y): return float2(x,y)
		else                                                                  return float2.none
		
	// Convert screen pos (north is up) to rounded world pos (northwest is up)
	getGridPosition: float2 screenPos // The screen position
		             bool allowOutside = false
		float2 t = screenPos - basePos + topFaceOffset
		let x = Math.round((xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
		let y = Math.round((xOffset.x*t.y - xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
		if allowOutside or (x >= 0 and x < size.x and y >= 0 and y < size.y): return int2(x,y)
		else                                                                  return int2.none
		
	isValid: int2 pos
		return pos >= {0,0} and pos < size
		
	limitToInside: int2 position
		return int2(
			Math.limit position.x, min:0, max:size.x-1
			Math.limit position.y, min:0, max:size.y-1
		)
		
	getScreenVector: float2 worldVector
		return xOffset*worldVector.x + yOffset*worldVector.y
		
class Direction
	global const Direction Right = {"Right", 0, { 1, 0},   0°, 330°} // positive x direction (1,0)
	global const Direction Down  = {"Down",  1, { 0, 1},  90°,  30°} // positive y direction (0,1)
	global const Direction Left  = {"Left",  2, {-1, 0}, 180°, 150°} // negative x direction (-1,0)
	global const Direction Up    = {"Up",    3,  {0,-1}, 270°, 210°} // negative y direction (0,-1)
	
	const Direction UpLeft    = {"UpLeft",    0, {-1,-1}} // negative x, negative y direction (-1,-1)
	const Direction UpRight   = {"UpRight",   1, { 1,-1}} // positive x, negative y direction (1,-1)
	const Direction DownLeft  = {"DownLeft",  2, {-1, 1}} // negative x, positive y direction (-1,1)
	const Direction DownRight = {"DownRight", 3, { 1, 1}} // positive x, positive y direction (1,1)
	
	// List of the four primary direction: Right, Down, Left, Up
	const Direction[] allFourDirections = [Right, Down, Left, Up]
	
	// List of the primary direction and the diagonals
	const Direction[] allEightDirections = [Right, DownRight, Down, DownLeft, Left, UpLeft, Up, UpRight]
	
	// List of the four diagonals: UpLeft, UpRight, DownLeft, DownRight
	const Direction[] allDiagonals = [DownLeft, DownRight, UpLeft, UpRight]

	string name
	int index
	int2 vector
	float angle
	float isoAngle
	
	toString := name
	
	rotated: RotationDirection direction = Clockwise
		return allFourDirections[(index+(direction == Clockwise ? 1:3))%4]
		
	inverted
		return allFourDirections[(index+2)%4]
		
	isOrthogonalTo: Direction value
		return index%2 != value.index%2
		
	isParallelTo: Direction value
		return index%2 == value.index%2
		
	
	

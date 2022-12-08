// A 2D vector comprised of an x and y coordinate
struct Vector2
	float x // The x-coordinate of the vector
	float y // The y-coordinate of the vector
	SourceCodeLocation location
	
	// Used to specify that the vector is not set or invalid
	const Vector2 none = {float.infinity, float.infinity, null}
	
	// {float.minValue, float.minValue}
	const Vector2 minValue = {float.minValue, float.minValue, null}
	
	// {float.maxValue, float.maxValue}
	const Vector2 maxValue = {float.maxValue, float.maxValue, null}
	
	// {0,0}
	const Vector2 zero = {0, 0, null}
		
	// A string representation of the vector
	string toString := "({x} {y})"
	
	// Returns true if the vector is not equal to Vector2.none
	bool toBool := (x != float.infinity || y != float.infinity)
	
	// Creates a copy of the vector with the same values
	Vector2 clone() := {x, y, location}
		
	Vector2 operator = (Vector2 a, Vector2 b) a.x = b.x; a.y = b.y; a.location = b.location; return a
	
	Vector2 operator + (Vector2 a, Vector2 b) return {a.x+b.x, a.y+b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	Vector2 operator - (Vector2 a, Vector2 b) return {a.x-b.x, a.y-b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	
	Vector2 operator * (Vector2 a, Vector2 b) return {a.x*b.x, a.y*b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	Vector2 operator * (Vector2 a, float b)   return {a.x*b, a.y*b, a.location}
	Vector2 operator * (Vector2 a, Time b)    return {cast a.x*b, cast a.y*b, a.location}
	Vector2 operator * (float a, Vector2 b)   return {a*b.x, a*b.y, b.location}
	Vector2 operator * (Vector2 vector, Matrix2D matrix)
		return {
			matrix.m0 * vector.x + matrix.m2 * vector.y + matrix.m4,
			matrix.m1 * vector.x + matrix.m3 * vector.y + matrix.m5,
			vector.location
		}
		
	Vector2 operator / (Vector2 a, Vector2 b) return {a.x/b.x, a.y/b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	Vector2 operator / (Vector2 a, float b)   return {a.x/b, a.y/b, a.location}
	Vector2 operator / (Vector2 vector, Matrix2D matrix)
		var aa = matrix.m0, ab = matrix.m1, ac = matrix.m2, ad = matrix.m3, atx = matrix.m4, aty = matrix.m5

		var det = aa * ad - ab * ac
		if(det == 0) return {0,0,null}
		det = 1.0 / det
		
		return {
			( ad * det) * vector.x + (-ac * det) * vector.y + ((ac * aty - ad * atx) * det),
			(-ab * det) * vector.x + ( aa * det) * vector.y + ((ab * atx - aa * aty) * det),
			vector.location
		}			
	
	Vector2 operator % (Vector2 a, Vector2 b) return {((a.x % b.x) + b.x) % b.x, ((a.y % b.y) + b.y) % b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	Vector2 operator % (Vector2 a, float b)   return {((a.x % b) + b) % b, ((a.y % b) + b) % b, a.location}
	
	Vector2 operator += (Vector2 a, Vector2 b) a.x += b.x; a.y += b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	Vector2 operator -= (Vector2 a, Vector2 b) a.x -= b.x; a.y -= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	Vector2 operator *= (Vector2 a, Vector2 b) a.x *= b.x; a.y *= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	Vector2 operator /= (Vector2 a, Vector2 b) a.x /= b.x; a.y /= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	
	bool operator == (Vector2 a, Vector2 b) return a.x == b.x && a.y == b.y
	bool operator != (Vector2 a, Vector2 b) return a.x != b.x || a.y != b.y
	
	bool operator == (Vector2 a, IntVector2 b) return a.x == b.x && a.y == b.y
	bool operator != (Vector2 a, IntVector2 b) return a.x != b.x || a.y != b.y
	
	bool operator == (IntVector2 a, Vector2 b) return b.x == a.x && b.y == a.y
	bool operator != (IntVector2 a, Vector2 b) return b.x != a.x || b.y != a.y
	
	bool operator >  (Vector2 a, Vector2 b) return a.x >  b.x && a.y >  b.y
	bool operator >= (Vector2 a, Vector2 b) return a.x >= b.x && a.y >= b.y
	bool operator <  (Vector2 a, Vector2 b) return a.x <  b.x && a.y <  b.y
	bool operator <= (Vector2 a, Vector2 b) return a.x <= b.x && a.y <= b.y
	
	bool operator == (Vector2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) == length
	bool operator != (Vector2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) != length
	bool operator >  (Vector2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) >  length
	bool operator >= (Vector2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) >= length
	bool operator <  (Vector2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) <  length
	bool operator <= (Vector2 a, float length) let x = a.x, y = a.y; return Math.sqrt(x*x + y*y) <= length
	
	// The length of the vector
	length := Math.sqrt(x * x + y * y)
		
	// A vector that is orthogonal to the existing vector
	orthogonal := Vector2(x:-y, y:x)
		
	// A vector with the sign of each coordinate flipped
	inverse := Vector2(-x, -y)
		
	// A vector with each coordinate rounded to the closest integer value
	rounded := IntVector2(Math.round(x), Math.round(y))
	
	// A vector with each coordinate rounded down to an integer value
	floor := IntVector2(Math.floor(x), Math.floor(y))
		
	// A vector with each coordinate rounded up to an integer value
	ceil := IntVector2(Math.ceil(x), Math.ceil(y))
		
	// A vector with the absolute value of each coordinate
	abs := Vector2(Math.abs(x), Math.abs(y))
		
	// The larger of the two coordinates
	max := x > y ? x : y
	
	// The smaller of the two coordinates
	min := x < y ? x : y
	
	rotate: Angle angle // The angle in turns (one full rotation is 1)
		let x = this.x, y = this.y
		let sn = Math.sin(angle)
		let cs = Math.cos(angle)
		this.x = x * cs - y * sn;
		this.y = x * sn + y * cs;
		return this
		
	// The distance to another vector
	distanceTo: Vector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return Math.sqrt(x*x + y*y)

	// The distance to another vector along axes at right angles
	manhattanDistanceTo: Vector2 value // The second vector
		return Math.abs(x - value.x) + Math.abs(y - value.y)

	// The angle to another vector in turns (one full rotation is 1)
	angleTo: Vector2 value // The second vector
		return Math.getAngleForVector(value - this)

	// Interpolates to another vector
	interpolateTo: Vector2 target  // The target vector to interpolate to
		           float value    // The interpolation value, 0 returns the original vector, 1 returns the target vector
		let ivalue = 1 - value
		return new Vector2(x * ivalue + target.x * value, y * ivalue + target.y * value)

	// Interpolates to another vector
	interpolateTo: Vector2 target  // The target vector to interpolate to
		           float value    // The interpolation value, 0 returns the original vector, 1 returns the target vector
		           EaseFunction ease
		value = ease.function(value)
		let ivalue = 1 - value
		return new Vector2(x * ivalue + target.x * value, y * ivalue + target.y * value)

	// A vector that points in the same direction, but has a length of 1
	normalized
		let len = Math.sqrt(x * x + y * y)
		return len != 0 ? Vector2(x / len, y / len) : Vector2(0, 0)
	
	// Moves the vector towards the given target by the given distance	
	moveTowards: Vector2 targetPosition // The target to move towards
		         float speed = 1        // The distance to move by
		let delta = targetPosition - this
		if delta.x != 0 || delta.y != 0
			delta = delta.normalized * speed
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
		return Vector2(
			matrix.m0 * x + matrix.m2 * y + matrix.m4,
			matrix.m1 * x + matrix.m3 * y + matrix.m5
		)

	// A vector that is transformed by the inverse of the given matrix
	getRelativeTo: Matrix2D matrix // The vector will be transformed by the inverse of this matrix
		var aa = matrix.m0, ab = matrix.m1, ac = matrix.m2, ad = matrix.m3, atx = matrix.m4, aty = matrix.m5

		var det = aa * ad - ab * ac
		if(det == 0) return Vector2()
		det = 1.0 / det
		
		return Vector2(
			( ad * det) * x + (-ac * det) * y + ((ac * aty - ad * atx) * det),
			(-ab * det) * x + ( aa * det) * y + ((ab * atx - aa * aty) * det)
		)
		
	// Returns whether the vector is within a given rectangle
	isInsideRectangle: Vector2 center, // The center of the rectangle
		               Vector2 size,   // The size of the rectangle
		return x >= center.x - size.x/2 && x < center.x + size.x/2
		    && y >= center.y - size.y/2 && y < center.y + size.y/2
		
	// Returns whether the vector is within a given polygon
	isInsidePoygon: Vector2[] poly // A list of points that make up the polygon
		let c = false, i = -1, l = poly.length, j = l - 1
		while ++i < l
			((poly[i].y <= this.y && this.y < poly[j].y) || (poly[j].y <= this.y && this.y < poly[i].y))
			&& (this.x < (poly[j].x - poly[i].x) * (this.y - poly[i].y) / (poly[j].y - poly[i].y) + poly[i].x)
			&& (c = !c)
			j = i
		return c
	
	// The dot product
	dot: Vector2 value // The value to calculate the dot procut with
		return x * value.x + y * value.y
		
	// The cross product
	cross: Vector2 value // The value to calculate the cross procut with
		return x*value.y - y*value.x
		
	serialize: Buffer buffer
		buffer.writeFloat64(x)
		buffer.writeFloat64(y)
		
	deserialize: Buffer buffer
		x = buffer.readFloat64
		y = buffer.readFloat64
		
// A 2D vector comprised of an integer x and y coordinate
struct IntVector2
	int x // The x-coordinate of the vector
	int y // The y-coordinate of the vector
	SourceCodeLocation location
	
	// Used to specify that the vector is not set or invalid
	const IntVector2 none = {int.minValue, int.minValue, null}
		
	// {0,0}
	const IntVector2 zero = {0, 0, null}
	
	// Creates a copy of the vector with the same values
	IntVector2 clone := {x, y, location}
		
	// A string representation of the vector
	string toString := "({x} {y})"
	
	// Returns true if the vector is not equal to IntVector2.none
	bool toBool := (x != int.minValue || y != int.minValue)
	
	implicit Vector2 toVector2 := {x, y, location}
	
	// IntVector2 operator = (IntVector2 a, IntVector2 b) a.x = b.x; a.y = b.y; return a
	
	// IntVector2 operator +  (IntVector2 a, IntVector2 b) return IntVector2(a.x+b.x, a.y+b.y)
	// IntVector2 operator -  (IntVector2 a, IntVector2 b) return IntVector2(a.x-b.x, a.y-b.y)
		
	// IntVector2 operator * (IntVector2 a, IntVector2 b) return IntVector2(a.x*b.x, a.y*b.y)
	// IntVector2 operator * (IntVector2 a, int b) return IntVector2(a.x*b, a.y*b)
	// IntVector2 operator * (int a, IntVector2 b) return IntVector2(a*b.x, a*b.y)
		
	// Vector2 operator * (IntVector2 a, float b) return Vector2(a.x*b, a.y*b)
	// Vector2 operator * (float a, IntVector2 b) return Vector2(a*b.x, a*b.y)
		
	// Vector2 operator / (IntVector2 a, IntVector2 b) return Vector2(a.x/b.x, a.y/b.y)
	// Vector2 operator / (IntVector2 a, float b) return Vector2(a.x/b, a.y/b)
	
	// IntVector2 operator % (IntVector2 a, int b) return IntVector2(a.x%b, a.y%b)
	// IntVector2 operator % (IntVector2 a, IntVector2 b) return IntVector2(a.x%b.x, a.y%b.y)
	// Vector2 operator % (IntVector2 a, float b) return Vector2(a.x%b, a.y%b)
	// Vector2 operator % (IntVector2 a, Vector2 b) return Vector2(a.x%b.x, a.y%b.y)
	
	// IntVector2 operator += (IntVector2 a, IntVector2 b) a.x += b.x; a.y += b.y; return a
	// IntVector2 operator -= (IntVector2 a, IntVector2 b) a.x -= b.x; a.y -= b.y; return a
	// IntVector2 operator *= (IntVector2 a, IntVector2 b) a.x *= b.x; a.y *= b.y; return a
	// IntVector2 operator /= (IntVector2 a, IntVector2 b) a.x /= b.x; a.y /= b.y; return a
	
	IntVector2 operator = (IntVector2 a, IntVector2 b) a.x = b.x; a.y = b.y; a.location = b.location; return a
	
	IntVector2 operator + (IntVector2 a, IntVector2 b) return {a.x+b.x, a.y+b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	IntVector2 operator - (IntVector2 a, IntVector2 b) return {a.x-b.x, a.y-b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	
	IntVector2 operator * (IntVector2 a, IntVector2 b) return {a.x*b.x, a.y*b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	IntVector2 operator * (IntVector2 a, int b)   return {a.x*b, a.y*b, a.location}
	IntVector2 operator * (int a, IntVector2 b)   return {a*b.x, a*b.y, b.location}
		
	Vector2 operator / (IntVector2 a, IntVector2 b) return {a.x/b.x, a.y/b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	Vector2 operator / (IntVector2 a, float b)   return {a.x/b, a.y/b, a.location}
	
	IntVector2 operator % (IntVector2 a, IntVector2 b) return {((a.x % b.x) + b.x) % b.x, ((a.y % b.y) + b.y) % b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	IntVector2 operator % (IntVector2 a, int b)   return {((a.x % b) + b) % b, ((a.y % b) + b) % b, a.location}
	
	IntVector2 operator += (IntVector2 a, IntVector2 b) a.x += b.x; a.y += b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	IntVector2 operator -= (IntVector2 a, IntVector2 b) a.x -= b.x; a.y -= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	IntVector2 operator *= (IntVector2 a, IntVector2 b) a.x *= b.x; a.y *= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	IntVector2 operator /= (IntVector2 a, IntVector2 b) a.x /= b.x; a.y /= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	
	bool operator == (IntVector2 a, IntVector2 b) return a.x == b.x && a.y == b.y
	bool operator != (IntVector2 a, IntVector2 b) return a.x != b.x || a.y != b.y
	bool operator >  (IntVector2 a, IntVector2 b) return a.x >  b.x && a.y >  b.y
	bool operator >= (IntVector2 a, IntVector2 b) return a.x >= b.x && a.y >= b.y
	bool operator <  (IntVector2 a, IntVector2 b) return a.x <  b.x && a.y <  b.y
	bool operator <= (IntVector2 a, IntVector2 b) return a.x <= b.x && a.y <= b.y
	
	// The length of the vector
	length := Math.sqrt(x * x + y * y)
		
	// A vector that is orthogonal to the existing vector
	orthogonal := IntVector2(x:-y, y:x)
		
	// A vector with the sign of each coordinate flipped
	inverse := IntVector2(-x, -y)
		
	// A vector with the absolute value of each coordinate
	abs := IntVector2(Math.abs(x), Math.abs(y))
		
	// The larger of the two coordinates
	max := x > y ? x : y
	
	// The smaller of the two coordinates
	min := x < y ? x : y
	
	limit: IntVector2 min
		   IntVector2 max
		return IntVector2(
			Math.limit x, min:min.x, max:max.x
			Math.limit y, min:min.y, max:max.y
		)
		
	limit: IntVector2 max
		return IntVector2(
			Math.limit x, max:max.x
			Math.limit y, max:max.y
		)
		
	limit: IntVector2 min
		return IntVector2(
			Math.limit x, min:min.x
			Math.limit y, min:min.y
		)
		
	// Interpolates linearly to another vector
	interpolateTo: IntVector2 target  // The target vector to interpolate to
		           float value    // The interpolation value, 0 returns the original vector, 1 returns the target vector
		let ivalue = 1 - value
		return new Vector2(x * ivalue + target.x * value, y * ivalue + target.y * value)
	
	// The distance to another vector
	distanceTo: IntVector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return Math.sqrt(x*x + y*y)
		
	// The distance to another vector
	distanceTo: Vector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return Math.sqrt(x*x + y*y)

	// The distance to another vector along axes at right angles
	manhattanDistanceTo: IntVector2 value // The second vector
		return Math.abs(x - value.x) + Math.abs(y - value.y)

	// The angle to another vector in turns (one full rotation is 1)
	angleTo: IntVector2 value // The second vector
		return Math.getAngleForVector(value - this)
		
	// A float vector that points in the same direction, but has a length of 1
	normalized
		let len = Math.sqrt(x * x + y * y)
		return len != 0 ? Vector2(x / len, y / len) : Vector2(0, 0)
	
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
	Vector2 translationVector := {m4, m5}
	
	// Return the scale component of the matrix
	Vector2 scaleVector := {m0, m3}

	// Returns a string representation of the matrix
	string toString := "("+m0.format(1)+" "+m1.format(1)+" "+m2.format(1)+" "+m3.format(1)+" "+m4.format(1)+" "+m5.format(1)+")" 
	
	// Returns true if the matrix isn't the identity matrix
	bool toBool := (m0 != 1 || m1 != 0 || m2 != 0 || m3 != 1 || m4 != 0 || m5 != 0)
		
	// Moves the matrix by a given vector
	move: Vector2 vector // The matrix will be moved by this vector
		let x = vector.x, y = vector.y
		m4 += m0 * x + m2 * y
		m5 += m1 * x + m3 * y		
		return this	
		
	// Rotates the matrix by a given angle
	rotate: Angle angle // The angle in turns (one full rotation is 1)
		let a0 = m0, a1 = m1, a2 = m2, a3 = m3
		let sin = Math.sin(angle), cos = Math.cos(angle)
		m0 = a0 *  cos + a2 * sin
		m1 = a1 *  cos + a3 * sin
		m2 = a0 * -sin + a2 * cos
		m3 = a1 * -sin + a3 * cos
		return this	

	// Scales the matrix by a given vector
	scale: Vector2 vector // The vector to scale by
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
	Angle getAngleForVector: Vector2 vector
		return Math.atan2(vector.y, vector.x)
		
	Vector2 getVectorForAngle: Angle angle      // The angle in turns (one full rotation is 1)
		                       float radius = 1
		return new Vector2(Math.cos(angle)*radius, Math.sin(angle)*radius)
	
global transient unit System
	global inline js void forPositions: T[] subject               // The list to iterate over
		                                Vector2 start = {0,0}     // Left or top align items at this position
		                                Vector2 delta = {300,0}   // Distance between items
		                                -> void(
		                                    T it,                 // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,          // The position of the current item
		                                    int i                 // The index of the current item of the list we are iterating over with forCentered
		                                ) do                      // Do this for each item in a list
		for(let i=0, _subject=subject, _start = start, _delta = delta, _len=_subject.length, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) { let it = _subject[i], pos = new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null); do()}

	global inline js void forPositions: int to                    // The exclusive upper bound to iterate towards
		                                Vector2 start = {0,0}     // Left or top align items at this position
		                                Vector2 delta = {300,0}   // Distance between items
		                                -> void(
		                                    int i,                // The index of the current item of the list we are iterating over with forCentered
		                                    Vector2 pos,          // The position of the current item
		                                ) do                      // Do this for each item in a list
		for(let i=0, _start = start, _delta = delta, _len=to, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) { let pos = new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null); do()}

	global inline js void forPositions: T[] subject               // The list to iterate over
		                                Vector2 start = {0,0}     // Left or top align items at this position
		                                Vector2 delta = {100,100} // Distance between items
		                                float width               // Wrap to the next row when we reach this width
		                                -> void(
		                                    T it,                 // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,          // The position of the current item
		                                    int i                 // The index of the current item of the list we are iterating over with forCentered
		                                ) do                      // Do this for each item in a list
		for(let i=0, _subject=subject, _start = start, _delta = delta, _width = width, _len=_subject.length, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x) { if(_x >= _start.x+_width) {_x = _start.x; _y += _delta.y} let it = _subject[i], pos = new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null); do()}

	global inline js void forPositions: T[] subject               // The list to iterate over
		                                Vector2 center = {0,0}    // Center items at this position
		                                Vector2 delta = {300,0}   // Distance between items
		                                -> void(
		                                    T it,                 // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,          // The position of the current item
		                                    int i                 // The index of the current item of the list we are iterating over with forCentered
		                                ) do                      // Do this for each item in a list
		for(let i=0, _subject=subject, _center = center, _delta = delta, _len=_subject.length, _x = _center.x-(_len-1)*_delta.x/2, _y=_center.y-(_len-1)*_delta.y/2; i<_len; ++i, _x += _delta.x, _y += _delta.y) { let it = _subject[i], pos = new Vector2(_x, _y, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null); do()}

	global inline js void forPositions: int to                    // The exclusive upper bound to iterate towards
		                                Vector2 center = {0,0}    // Center items at this position
		                                Vector2 delta = {300,0}   // Distance between items
		                                -> void(
		                                    int i,                // The index of the current item of the list we are iterating over with forCentered
		                                    Vector2 pos           // The position of the current item
		                                ) do                      // Do this for each item in a list
		for(let i=0, _center = center, _delta = delta, _len=to, _x = _center.x-(_len-1)*_delta.x/2, _y=_center.y-(_len-1)*_delta.y/2; i<_len; ++i, _x += _delta.x, _y += _delta.y) { let pos = new Vector2(_x, _y, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null); do()}

	global inline js void forPositions: T[] subject               // The list to iterate over
		                                Vector2 end = {0,0}       // Right or bottom align items at this position
		                                Vector2 delta = {300,0}   // Distance between items
		                                -> void(
		                                    T it,                 // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,          // The position of the current item
		                                    int i                 // The index of the current item of the list we are iterating over with forCentered
		                                ) do                      // Do this for each item in a list
		for(let i=0, _subject=subject, _end = end, _delta = delta, _len=_subject.length, _x = _end.x-(_len-1)*_delta.x, _y=_end.y-(_len-1)*_delta.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) { let it = _subject[i], pos = new Vector2(_x, _y, _end.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _end.location, _delta.location) : null); do()}

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
	IntVector2 size            // The amount of cells in the grid
	Vector2 cellSize      // The size of each cell
	Vector2 topFaceOffset // The position of the top face within the cell
	
	visible Vector2 xOffset = cellSize / 2
	visible Vector2 yOffset = {-xOffset.x, xOffset.y}
	visible Vector2 basePos = {0,-yOffset.y*(size.y-1)}
	
	// Convert world position (northwest is up) to screen position (north is up)
	getScreenPosition: Vector2 worldPos // The world position
		return basePos + xOffset*worldPos.x + yOffset*worldPos.y
		
	// Convert screen position (north is up) to world position (northwest is up)
	getWorldPosition: Vector2 screenPos // The screen position
		              bool allowOutside = false
		Vector2 t = screenPos - basePos + topFaceOffset
		let x = (xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y)
		let y = (xOffset.x*t.y - xOffset.y*t.x) / (2*xOffset.x*xOffset.y)
		if allowOutside or (x >= 0 and x < size.x and y >= 0 and y < size.y): return Vector2(x,y)
		else                                                                  return Vector2.none
		
	// Convert screen pos (north is up) to rounded world pos (northwest is up)
	getGridPosition: Vector2 screenPos // The screen position
		             bool allowOutside = false
		Vector2 t = screenPos - basePos + topFaceOffset
		let x = Math.round((xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
		let y = Math.round((xOffset.x*t.y - xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
		if allowOutside or (x >= 0 and x < size.x and y >= 0 and y < size.y): return IntVector2(x,y)
		else                                                                  return IntVector2.none
		
	isValid: IntVector2 pos
		return pos >= {0,0} and pos < size
		
	limitToInside: IntVector2 position
		return IntVector2(
			Math.limit position.x, min:0, max:size.x-1
			Math.limit position.y, min:0, max:size.y-1
		)
		
	getScreenVector: Vector2 worldVector
		return xOffset*worldVector.x + yOffset*worldVector.y
		
class Direction
	global const Direction Right = {"Right", 0, { 1, 0},   0°, 330°} // positive x direction (1,0)
	global const Direction Down  = {"Down",  1, { 0, 1},  90°,  30°} // positive y direction (0,1)
	global const Direction Left  = {"Left",  2, {-1, 0}, 180°, 150°} // negative x direction (-1,0)
	global const Direction Up    = {"Up",    3,  {0,-1}, 270°, 210°} // negative y direction (0,-1)
	
	const Direction DownRight = {"DownRight", 0, { 1, 1},  45°} // positive x, positive y direction (1,1)
	const Direction DownLeft  = {"DownLeft",  1, {-1, 1}, 135°} // negative x, positive y direction (-1,1)
	const Direction UpLeft    = {"UpLeft",    2, {-1,-1}, 225°} // negative x, negative y direction (-1,-1)
	const Direction UpRight   = {"UpRight",   3, { 1,-1}, 315°} // positive x, negative y direction (1,-1)
	
	// List of the four primary direction: Right, Down, Left, Up
	const Direction[] allFourDirections = [Right, Down, Left, Up]
	
	// List of the primary direction and the diagonals
	const Direction[] allEightDirections = [Right, DownRight, Down, DownLeft, Left, UpLeft, Up, UpRight]
	
	// List of the four diagonals: UpLeft, UpRight, DownLeft, DownRight
	const Direction[] allDiagonals = [DownRight, DownLeft, UpLeft, UpRight]

	string name
	int index
	IntVector2 vector
	Angle angle
	Angle isoAngle
	
	toString := name
	
	rotated: RotationDirection direction = Clockwise
		return allFourDirections[(index+(direction == Clockwise ? 1:3))%4]
		
	inverted
		return allFourDirections[(index+2)%4]
		
	isOrthogonalTo: Direction value
		return index%2 != value.index%2
		
	isParallelTo: Direction value
		return index%2 == value.index%2
		
enum LineType: Line, Ray, Segment
	
class Line
	Vector2 start, end
	LineType type
	
	length
		return type == Segment ? (start distanceTo end) : float.infinity
	
	Vector2 intersectionWith: Line other
		let x1    = start.x,       y1 = start.y
		let x2    = end.x,         y2 = end.y
		let typeA = type
		let x3    = other.start.x, y3 = other.start.y
		let x4    = other.end.x,   y4 = other.end.y
		let typeB = other.type
		
		// Check if none of the lines are of length 0
		if (x1 == x2 && y1 == y2) || (x3 == x4 && y3 == y4) return Vector2.none

		// compute line params
		let denominator = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
		if (denominator == 0) return Vector2.none // lines are parallel
		let ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator
		let ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator

		// is the intersection along the segments
		if (typeA >= Ray && ua < 0) || (typeA == Segment && ua > 1)
		|| (typeB >= Ray && ub < 0) || (typeB == Segment && ub > 1)
			return Vector2.none
			
		// Return a object with the x and y coordinates of the intersection
		return new Vector2(x1 + ua * (x2 - x1), y1 + ua * (y2 - y1))
		
	toString := "{start.x.format(fractionDigits:2)} {start.y.format(fractionDigits:2)} -> {end.x.format(fractionDigits:2)} {end.y.format(fractionDigits:2)}"

class Rect
	Vector2 position, size
	
class Grid<T>
	IntVector2 size
	T[] items
	
	get: int x // The column to get the value from
		 int y // The row to get the value from
		return items[y*size.x + x]
	
	get: IntVector2 position // The vector to get the value from
		return items[position.y*size.x + position.x]
	
	set: int x   // The column of the value to set
		 int y   // The row of the value to set
		 T value // The value to set
		items[y*size.x + x] = value
	
	set: IntVector2 position // The grid position of the value to set
		 T value             // The value to set
		items[position.y*size.x + position.x] = value
			
global transient unit System
	global inline js void for: IntVector2 subject    // The exclusive upper bound to iterate towards
		                       -> void(
		                           IntVector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do           // Do this the given number of times
		for(let _size=subject, y=0; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) { let pos = new IntVector2(x,y); do()}
			
	global inline js void for: IntVector2 subject    // The exclusive upper bound to iterate towards
		                       <- void(
		                           IntVector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do           // Do this the given number of times
		for(let _size=subject, y=_size.y-1; y>=0; --y) for(let x=_size.x-1; x>=0; --x) { let pos = new IntVector2(x,y); do()}
			
	global inline js void for: Grid<T> subject    // The grid to iterate over
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           IntVector2 pos,
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let i=0, _subject=subject.items, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; if(it) { let pos = new IntVector2(i%subject.size.x, Math.floor(i/subject.size.x)); do()}}
			
	global inline js void for: Grid<T> subject    // The grid to iterate over
		                       includeEmpty = false
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           IntVector2 pos,
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _size=subject.size, y=0, _items=subject.items; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) { let it = _items[y*_size.x + x]; let pos = new IntVector2(x,y); do()}

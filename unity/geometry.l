// A 3D vector comprised of an x, y and z coordinate
cs(UnityEngine) struct Vector3
	float x // The x-coordinate of the vector
	float y // The y-coordinate of the vector
	float z // The y-coordinate of the vector
	
	// Used to specify that the vector is not set or invalid
	static inline cs(UnityEngine) Vector3 none() new Vector3(float.PositiveInfinity, float.PositiveInfinity, float.PositiveInfinity)
	
	// {float.minValue, float.minValue}
	static inline cs(UnityEngine) Vector3 minValue() new Vector3(float.MinValue, float.MinValue, float.MinValue)
	
	// {float.maxValue, float.maxValue}
	static inline cs(UnityEngine) Vector3 maxValue() new Vector3(float.MaxValue, float.MaxValue, float.MaxValue)
	
	// {0,0}
	static inline cs(UnityEngine) Vector3 zero() Vector3.zero
		
	// A string representation of the vector
	string toString := "({x} {y} {z})"
	
	// Returns true if the vector is not equal to Vector2.none
	bool toBool := (x != float.infinity || y != float.infinity)
	
	// Creates a copy of the vector with the same values
	// Vector2 clone() := {x, y, location}
		
	// Vector2 operator = (Vector2 a, Vector2 b) a.x = b.x; a.y = b.y; a.location = b.location; return a
	
	inline cs Vector3 operator + (Vector3 a, Vector3 b) a + b
	inline cs Vector3 operator - (Vector3 a, Vector3 b) a - b
	
	inline cs Vector3 operator * (Vector3 a, Vector3 b) a * b
	inline cs Vector3 operator * (Vector3 a, float b) a * b
	inline cs Vector3 operator * (Vector3 a, Time b) a * b
	// Vector2 operator * (float a, Vector2 b)   return {a*b.x, a*b.y, b.location}
	// Vector2 operator * (Vector2 vector, Matrix2D matrix)
	// 	return {
	// 		matrix.m0 * vector.x + matrix.m2 * vector.y + matrix.m4,
	// 		matrix.m1 * vector.x + matrix.m3 * vector.y + matrix.m5,
	// 		vector.location
	// 	}
		
	// Vector2 operator / (Vector2 a, Vector2 b) return {a.x/b.x, a.y/b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	// Vector2 operator / (Vector2 a, float b)   return {a.x/b, a.y/b, a.location}
	// Vector2 operator / (Vector2 vector, Matrix2D matrix)
	// 	var aa = matrix.m0, ab = matrix.m1, ac = matrix.m2, ad = matrix.m3, atx = matrix.m4, aty = matrix.m5

	// 	var det = aa * ad - ab * ac
	// 	if(det == 0) return {0,0,null}
	// 	det = 1.0 / det
		
	// 	return {
	// 		( ad * det) * vector.x + (-ac * det) * vector.y + ((ac * aty - ad * atx) * det),
	// 		(-ab * det) * vector.x + ( aa * det) * vector.y + ((ab * atx - aa * aty) * det),
	// 		vector.location
	// 	}			
	
	// Vector2 operator % (Vector2 a, Vector2 b) return {((a.x % b.x) + b.x) % b.x, ((a.y % b.y) + b.y) % b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	// Vector2 operator % (Vector2 a, float b)   return {((a.x % b) + b) % b, ((a.y % b) + b) % b, a.location}
	
	// Vector2 operator += (Vector2 a, Vector2 b) a.x += b.x; a.y += b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	// Vector2 operator -= (Vector2 a, Vector2 b) a.x -= b.x; a.y -= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	// Vector2 operator *= (Vector2 a, Vector2 b) a.x *= b.x; a.y *= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	// Vector2 operator /= (Vector2 a, Vector2 b) a.x /= b.x; a.y /= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	
	// bool operator == (Vector2 a, Vector2 b) return a.x == b.x && a.y == b.y
	// bool operator != (Vector2 a, Vector2 b) return a.x != b.x || a.y != b.y
	
	// bool operator == (Vector2 a, IntVector2 b) return a.x == b.x && a.y == b.y
	// bool operator != (Vector2 a, IntVector2 b) return a.x != b.x || a.y != b.y
	
	// bool operator == (IntVector2 a, Vector2 b) return b.x == a.x && b.y == a.y
	// bool operator != (IntVector2 a, Vector2 b) return b.x != a.x || b.y != a.y
	
	// bool operator >  (Vector2 a, Vector2 b) return a.x >  b.x && a.y >  b.y
	// bool operator >= (Vector2 a, Vector2 b) return a.x >= b.x && a.y >= b.y
	// bool operator <  (Vector2 a, Vector2 b) return a.x <  b.x && a.y <  b.y
	// bool operator <= (Vector2 a, Vector2 b) return a.x <= b.x && a.y <= b.y
	
	// bool operator == (Vector2 a, float length) var x = a.x, y = a.y; return Math.sqrt(x*x + y*y) == length
	// bool operator != (Vector2 a, float length) var x = a.x, y = a.y; return Math.sqrt(x*x + y*y) != length
	// bool operator >  (Vector2 a, float length) var x = a.x, y = a.y; return Math.sqrt(x*x + y*y) >  length
	// bool operator >= (Vector2 a, float length) var x = a.x, y = a.y; return Math.sqrt(x*x + y*y) >= length
	// bool operator <  (Vector2 a, float length) var x = a.x, y = a.y; return Math.sqrt(x*x + y*y) <  length
	// bool operator <= (Vector2 a, float length) var x = a.x, y = a.y; return Math.sqrt(x*x + y*y) <= length
	
	// // The length of the vector
	// length := Math.sqrt(x * x + y * y)
		
	// // A vector that is orthogonal to the existing vector
	// orthogonal := Vector2(x:-y, y:x)
		
	// // A vector with the sign of each coordinate flipped
	// inverse := Vector2(-x, -y)
		
	// A vector with each coordinate rounded to the closest integer value
	Vector3 rounded := {Math.round(x), Math.round(y), Math.round(z)}
	
	// // A vector with each coordinate rounded down to an integer value
	// floor := IntVector2(Math.floor(x), Math.floor(y))
		
	// // A vector with each coordinate rounded up to an integer value
	// ceil := IntVector2(Math.ceil(x), Math.ceil(y))
		
	// // A vector with the absolute value of each coordinate
	// abs := Vector2(Math.abs(x), Math.abs(y))
		
	// // The larger of the two coordinates
	// max := x > y ? x : y
	
	// // The smaller of the two coordinates
	// min := x < y ? x : y
	
	// rotate: Angle angle // The angle in turns (one full rotation is 1)
	// 	var x = this.x, y = this.y
	// 	var sn = Math.sin(angle)
	// 	var cs = Math.cos(angle)
	// 	this.x = x * cs - y * sn;
	// 	this.y = x * sn + y * cs;
	// 	return this
		
	// The distance to another vector
	inline cs float distanceTo: Vector3 value // The second vector
		Vector3.Distance(this, value)

	// // The distance to another vector along axes at right angles
	// manhattanDistanceTo: Vector2 value // The second vector
	// 	return Math.abs(x - value.x) + Math.abs(y - value.y)

	// // The angle to another vector in turns (one full rotation is 1)
	// angleTo: Vector2 value // The second vector
	// 	return Math.getAngleForVector(value - this)

	// // Interpolates to another vector
	// interpolateTo: Vector2 target  // The target position to interpolate to
	// 	           float value     // The input value
	// 	var ivalue = 1 - value
	// 	return new Vector2(x * ivalue + target.x * value, y * ivalue + target.y * value)

	// // Interpolates to another vector
	// interpolateTo: Vector2 target  // The target position to interpolate to
	// 	           float value     // The input value
	// 	           EaseFunction ease
	// 	value = ease.function(value)
	// 	var ivalue = 1 - value
	// 	return new Vector2(x * ivalue + target.x * value, y * ivalue + target.y * value)

	// // Interpolates to another vector
	// interpolateTo: Vector2 target // The target position to interpolate to
	// 	           float value    // The input value
	// 	           float from     // The beginning of the input range
	// 	           float to       // The end of the input range
	// 	if value <= from: return this
	// 	if value >= to: return target
	// 	var factor = (value-from) / (to-from)
	// 	return new Vector2(x + (target.x-x)*factor, y + (target.y-y)*factor)

	// // Interpolates to another vector
	// interpolateTo: Vector2 target    // The target position to interpolate to
	// 	           float value       // The input value
	// 	           float from        // The beginning of the input range
	// 	           float to          // The end of the input range
	// 	           EaseFunction ease // The easing function to apply
	// 	if value <= from: return this
	// 	if value >= to: return target
	// 	var factor = ease.function((value-from) / (to-from))
	// 	return new Vector2(x + (target.x-x)*factor, y + (target.y-y)*factor)

	// A vector that points in the same direction, but has a length of 1
	inline cs Vector3 normalized() this.normalized
	
	// Moves the vector towards the given target by the given distance	
	moveTowards: Vector3 targetPosition // The target to move towards
		         float speed = 1        // The distance to move by
		var delta = targetPosition - this
		if delta.x != 0 || delta.y != 0 || delta.z != 0
			delta = delta.normalized * (speed * Time.deltaTime)
			if delta.x > 0: x = Math.min(x + delta.x, targetPosition.x)
			else            x = Math.max(x + delta.x, targetPosition.x)
			if delta.y > 0: y = Math.min(y + delta.y, targetPosition.y)
			else            y = Math.max(y + delta.y, targetPosition.y)
			if delta.z > 0: z = Math.min(z + delta.z, targetPosition.z)
			else            z = Math.max(z + delta.z, targetPosition.z)
		
	// // Transforms the vector by a given matrix
	// transform: Matrix2D matrix // The matrix to transform the vector by
	// 	var ax = x, ay = y
	// 	x = matrix.m0 * ax + matrix.m2 * ay + matrix.m4
	// 	y = matrix.m1 * ax + matrix.m3 * ay + matrix.m5
	// 	return this
		
	// // A vector that is transformed by a given matrix
	// getTransformed: Matrix2D matrix // The matrix to transform the vector by
	// 	return Vector2(
	// 		matrix.m0 * x + matrix.m2 * y + matrix.m4,
	// 		matrix.m1 * x + matrix.m3 * y + matrix.m5
	// 	)

	// // A vector that is transformed by the inverse of the given matrix
	// getRelativeTo: Matrix2D matrix // The vector will be transformed by the inverse of this matrix
	// 	var aa = matrix.m0, ab = matrix.m1, ac = matrix.m2, ad = matrix.m3, atx = matrix.m4, aty = matrix.m5

	// 	var det = aa * ad - ab * ac
	// 	if(det == 0) return Vector2()
	// 	det = 1.0 / det
		
	// 	return Vector2(
	// 		( ad * det) * x + (-ac * det) * y + ((ac * aty - ad * atx) * det),
	// 		(-ab * det) * x + ( aa * det) * y + ((ab * atx - aa * aty) * det)
	// 	)
		
	// Returns whether the vector is within a given rectangle
	isInside: Vector3 center // The center of the rectangle
		      Vector3 size   // The size of the rectangle
		return x >= center.x - size.x/2 && x < center.x + size.x/2
		    && y >= center.y - size.y/2 && y < center.y + size.y/2
		    && z >= center.z - size.z/2 && z < center.z + size.z/2
		
	// // Returns whether the vector is within a given polygon
	// isInsidePoygon: Vector2[] poly // A list of points that make up the polygon
	// 	var c = false, i = -1, l = poly.length, j = l - 1
	// 	while ++i < l
	// 		((poly[i].y <= this.y && this.y < poly[j].y) || (poly[j].y <= this.y && this.y < poly[i].y))
	// 		&& (this.x < (poly[j].x - poly[i].x) * (this.y - poly[i].y) / (poly[j].y - poly[i].y) + poly[i].x)
	// 		&& (c = !c)
	// 		j = i
	// 	return c
		
	// in: Rect rectangle
	// 	return x >= rectangle.position.x - rectangle.size.x/2 && x < rectangle.position.x + rectangle.size.x/2
	// 	    && y >= rectangle.position.y - rectangle.size.y/2 && y < rectangle.position.y + rectangle.size.y/2
	
	// // The dot product
	// dot: Vector2 value // The value to calculate the dot procut with
	// 	return x * value.x + y * value.y
		
	// // The cross product
	// cross: Vector2 value // The value to calculate the cross procut with
	// 	return x*value.y - y*value.x
		
	// serialize: Buffer buffer
	// 	buffer.writeFloat64(x)
	// 	buffer.writeFloat64(y)
		
	// deserialize: Buffer buffer
	// 	x = buffer.readFloat64
	// 	y = buffer.readFloat64
		
// A 2D vector comprised of an integer x and y coordinate
cs(UnityEngine Vector2Int) struct IntVector2
	int x // The x-coordinate of the vector
	int y // The y-coordinate of the vector
	
	// Used to specify that the vector is not set or invalid
	static inline cs(UnityEngine) IntVector2 none() new Vector2Int(int.MinValue, int.MinValue, int.MinValue)
	
	// {float.minValue, float.minValue}
	static inline cs(UnityEngine) IntVector2 minValue() new Vector2Int(int.MinValue, int.MinValue, int.MinValue)
	
	// {float.maxValue, float.maxValue}
	static inline cs(UnityEngine) IntVector2 maxValue() new Vector2Int(int.MaxValue, int.MaxValue, int.MaxValue)
	
	// {0,0}
	static inline cs(UnityEngine) IntVector2 zero() Vector2Int.zero
		
	// A string representation of the vector
	string toString := "({x} {y})"
	
	// Returns true if the vector is not equal to IntVector2.none
	bool toBool := (x != int.minValue || y != int.minValue)
	
	implicit Vector2 toVector2 := {x, y}
	implicit Vector3 toVector3 := {x, y:0, z:y}
	
	inline cs IntVector2 operator + (IntVector2 a, IntVector2 b) a + b
	inline cs IntVector2 operator - (IntVector2 a, IntVector2 b) a - b
	
	inline cs IntVector2 operator * (IntVector2 a, IntVector2 b) a * b
	inline cs IntVector2 operator * (IntVector2 a, float b) a * b
	inline cs IntVector2 operator * (IntVector2 a, Time b) a * b
	
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
	
	// bool operator == (IntVector2 a, IntVector2 b) return a.x == b.x && a.y == b.y
	// bool operator != (IntVector2 a, IntVector2 b) return a.x != b.x || a.y != b.y
	// bool operator >  (IntVector2 a, IntVector2 b) return a.x >  b.x && a.y >  b.y
	// bool operator >= (IntVector2 a, IntVector2 b) return a.x >= b.x && a.y >= b.y
	// bool operator <  (IntVector2 a, IntVector2 b) return a.x <  b.x && a.y <  b.y
	// bool operator <= (IntVector2 a, IntVector2 b) return a.x <= b.x && a.y <= b.y
	
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
		var ivalue = 1 - value
		return new Vector2(x * ivalue + target.x * value, y * ivalue + target.y * value)
	
	// The distance to another vector
	distanceTo: IntVector2 value // The second vector
		var x = x - value.x
		var y = y - value.y
		return Math.sqrt(x*x + y*y)
		
	// The distance to another vector
	distanceTo: Vector2 value // The second vector
		var x = x - value.x
		var y = y - value.y
		return Math.sqrt(x*x + y*y)

	// The distance to another vector along axes at right angles
	manhattanDistanceTo: IntVector2 value // The second vector
		return Math.abs(x - value.x) + Math.abs(y - value.y)

	// The angle to another vector in turns (one full rotation is 1)
	angleTo: IntVector2 value // The second vector
		return Math.getAngleForVector(value - this)
		
	// A float vector that points in the same direction, but has a length of 1
	normalized
		var len = Math.sqrt(x * x + y * y)
		return len != 0 ? Vector2(x / len, y / len) : Vector2(0, 0)

// A 2D vector comprised of an integer x and y coordinate
cs(UnityEngine Vector3Int) struct IntVector3
	int x // The x-coordinate of the vector
	int y // The y-coordinate of the vector
	int z // The y-coordinate of the vector
	
// 	// Used to specify that the vector is not set or invalid
// 	const IntVector2 none = {int.minValue, int.minValue, null}
		
// 	// {0,0}
// 	const IntVector2 zero = {0, 0, null}
	
// 	// Creates a copy of the vector with the same values
// 	IntVector2 clone := {x, y, location}
		
// 	// A string representation of the vector
// 	string toString := "({x} {y})"
	
// 	// Returns true if the vector is not equal to IntVector2.none
// 	bool toBool := (x != int.minValue || y != int.minValue)
	
// 	implicit Vector2 toVector2 := {x, y, location}
	
	inline cs IntVector3 operator + (IntVector3 a, IntVector3 b) a + b
	inline cs IntVector3 operator - (IntVector3 a, IntVector3 b) a - b
	
	inline cs IntVector3 operator * (IntVector3 a, IntVector3 b) a * b
	inline cs IntVector3 operator * (IntVector3 a, float b) a * b
	inline cs IntVector3 operator * (IntVector3 a, Time b) a * b
	
// 	// IntVector2 operator = (IntVector2 a, IntVector2 b) a.x = b.x; a.y = b.y; return a
	
// 	// IntVector2 operator +  (IntVector2 a, IntVector2 b) return IntVector2(a.x+b.x, a.y+b.y)
// 	// IntVector2 operator -  (IntVector2 a, IntVector2 b) return IntVector2(a.x-b.x, a.y-b.y)
		
// 	// IntVector2 operator * (IntVector2 a, IntVector2 b) return IntVector2(a.x*b.x, a.y*b.y)
// 	// IntVector2 operator * (IntVector2 a, int b) return IntVector2(a.x*b, a.y*b)
// 	// IntVector2 operator * (int a, IntVector2 b) return IntVector2(a*b.x, a*b.y)
		
// 	// Vector2 operator * (IntVector2 a, float b) return Vector2(a.x*b, a.y*b)
// 	// Vector2 operator * (float a, IntVector2 b) return Vector2(a*b.x, a*b.y)
		
// 	// Vector2 operator / (IntVector2 a, IntVector2 b) return Vector2(a.x/b.x, a.y/b.y)
// 	// Vector2 operator / (IntVector2 a, float b) return Vector2(a.x/b, a.y/b)
	
// 	// IntVector2 operator % (IntVector2 a, int b) return IntVector2(a.x%b, a.y%b)
// 	// IntVector2 operator % (IntVector2 a, IntVector2 b) return IntVector2(a.x%b.x, a.y%b.y)
// 	// Vector2 operator % (IntVector2 a, float b) return Vector2(a.x%b, a.y%b)
// 	// Vector2 operator % (IntVector2 a, Vector2 b) return Vector2(a.x%b.x, a.y%b.y)
	
// 	// IntVector2 operator += (IntVector2 a, IntVector2 b) a.x += b.x; a.y += b.y; return a
// 	// IntVector2 operator -= (IntVector2 a, IntVector2 b) a.x -= b.x; a.y -= b.y; return a
// 	// IntVector2 operator *= (IntVector2 a, IntVector2 b) a.x *= b.x; a.y *= b.y; return a
// 	// IntVector2 operator /= (IntVector2 a, IntVector2 b) a.x /= b.x; a.y /= b.y; return a
	
// 	IntVector2 operator = (IntVector2 a, IntVector2 b) a.x = b.x; a.y = b.y; a.location = b.location; return a
	
// 	IntVector2 operator + (IntVector2 a, IntVector2 b) return {a.x+b.x, a.y+b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
// 	IntVector2 operator - (IntVector2 a, IntVector2 b) return {a.x-b.x, a.y-b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	
// 	IntVector2 operator * (IntVector2 a, IntVector2 b) return {a.x*b.x, a.y*b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
// 	IntVector2 operator * (IntVector2 a, int b)   return {a.x*b, a.y*b, a.location}
// 	IntVector2 operator * (int a, IntVector2 b)   return {a*b.x, a*b.y, b.location}
		
// 	Vector2 operator / (IntVector2 a, IntVector2 b) return {a.x/b.x, a.y/b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
// 	Vector2 operator / (IntVector2 a, float b)   return {a.x/b, a.y/b, a.location}
	
// 	IntVector2 operator % (IntVector2 a, IntVector2 b) return {((a.x % b.x) + b.x) % b.x, ((a.y % b.y) + b.y) % b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
// 	IntVector2 operator % (IntVector2 a, int b)   return {((a.x % b) + b) % b, ((a.y % b) + b) % b, a.location}
	
// 	IntVector2 operator += (IntVector2 a, IntVector2 b) a.x += b.x; a.y += b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
// 	IntVector2 operator -= (IntVector2 a, IntVector2 b) a.x -= b.x; a.y -= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
// 	IntVector2 operator *= (IntVector2 a, IntVector2 b) a.x *= b.x; a.y *= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
// 	IntVector2 operator /= (IntVector2 a, IntVector2 b) a.x /= b.x; a.y /= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	
// 	bool operator == (IntVector2 a, IntVector2 b) return a.x == b.x && a.y == b.y
// 	bool operator != (IntVector2 a, IntVector2 b) return a.x != b.x || a.y != b.y
// 	bool operator >  (IntVector2 a, IntVector2 b) return a.x >  b.x && a.y >  b.y
// 	bool operator >= (IntVector2 a, IntVector2 b) return a.x >= b.x && a.y >= b.y
// 	bool operator <  (IntVector2 a, IntVector2 b) return a.x <  b.x && a.y <  b.y
// 	bool operator <= (IntVector2 a, IntVector2 b) return a.x <= b.x && a.y <= b.y
	
// 	// The length of the vector
// 	length := Math.sqrt(x * x + y * y)
		
// 	// A vector that is orthogonal to the existing vector
// 	orthogonal := IntVector2(x:-y, y:x)
		
// 	// A vector with the sign of each coordinate flipped
// 	inverse := IntVector2(-x, -y)
		
// 	// A vector with the absolute value of each coordinate
// 	abs := IntVector2(Math.abs(x), Math.abs(y))
		
// 	// The larger of the two coordinates
// 	max := x > y ? x : y
	
// 	// The smaller of the two coordinates
// 	min := x < y ? x : y
	
// 	limit: IntVector2 min
// 		   IntVector2 max
// 		return IntVector2(
// 			Math.limit x, min:min.x, max:max.x
// 			Math.limit y, min:min.y, max:max.y
// 		)
		
// 	limit: IntVector2 max
// 		return IntVector2(
// 			Math.limit x, max:max.x
// 			Math.limit y, max:max.y
// 		)
		
// 	limit: IntVector2 min
// 		return IntVector2(
// 			Math.limit x, min:min.x
// 			Math.limit y, min:min.y
// 		)
		
// 	// Interpolates linearly to another vector
// 	interpolateTo: IntVector2 target  // The target vector to interpolate to
// 		           float value    // The interpolation value, 0 returns the original vector, 1 returns the target vector
// 		var ivalue = 1 - value
// 		return new Vector2(x * ivalue + target.x * value, y * ivalue + target.y * value)
	
// 	// The distance to another vector
// 	distanceTo: IntVector2 value // The second vector
// 		var x = x - value.x
// 		var y = y - value.y
// 		return Math.sqrt(x*x + y*y)
		
// 	// The distance to another vector
// 	distanceTo: Vector2 value // The second vector
// 		var x = x - value.x
// 		var y = y - value.y
// 		return Math.sqrt(x*x + y*y)

// 	// The distance to another vector along axes at right angles
// 	manhattanDistanceTo: IntVector2 value // The second vector
// 		return Math.abs(x - value.x) + Math.abs(y - value.y)

// 	// The angle to another vector in turns (one full rotation is 1)
// 	angleTo: IntVector2 value // The second vector
// 		return Math.getAngleForVector(value - this)
		
// 	// A float vector that points in the same direction, but has a length of 1
// 	normalized
// 		var len = Math.sqrt(x * x + y * y)
// 		return len != 0 ? Vector2(x / len, y / len) : Vector2(0, 0)
class List<T>
	Vector2 total: Vector2(T it) selector
		Vector2 sum = {0,0}
		for this: sum += selector(.)
		return sum	

unit Math
	// Returns the arctangent of the quotient of the given values
	Angle getAngleForVector: Vector2 vector
		return Math.atan2(vector.y, vector.x)
		
	Vector2 getVectorForAngle: Angle angle      // The angle in turns (one full rotation is 1)
		                       float radius = 1
		return new Vector2(Math.cos(angle)*radius, Math.sin(angle)*radius)
		
	// Vector2 intersectLines: Vector2 startA
	// 	                    Vector2 endA
	// 	                    Vector2 startB
	// 	                    Vector2 endB
	// 	                    LineType typeA = Segment
	// 	                    LineType typeB = Segment
		
	// 	var x1    = startA.x, y1 = startA.y
	// 	var x2    = endA.x,   y2 = endA.y
	// 	var x3    = startB.x, y3 = startB.y
	// 	var x4    = endB.x,   y4 = endB.y
		
	// 	// Check if none of the lines are of length 0
	// 	if (x1 == x2 && y1 == y2) || (x3 == x4 && y3 == y4) return Vector2.none

	// 	// compute line params
	// 	var denominator = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
	// 	if (denominator == 0) return Vector2.none // lines are parallel
	// 	var ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator
	// 	var ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator

	// 	// is the intersection along the segments
	// 	if (typeA >= Ray && ua < 0) || (typeA == Segment && ua > 1)
	// 	|| (typeB >= Ray && ub < 0) || (typeB == Segment && ub > 1)
	// 		return Vector2.none
			
	// 	// Return a object with the x and y coordinates of the intersection
	// 	return new Vector2(x1 + ua * (x2 - x1), y1 + ua * (y2 - y1))
	
	// // Maps a value from an input range to an output range
	// map: float value    // The input value 
	// 	 float from = 0 // The beginning of the input range
	// 	 float to = 1   // The end of the input range
	// 	 Vector2 start  // The start output position, will be returned for values smaller than "from".
	// 	 Vector2 target // The target output position, will be returned for values larger than "to".
	// 	if value <= from: return start
	// 	if value >= to:   return target
	// 	var factor = (value-from) / (to-from)
	// 	return start + (target-start) * factor
			
	// // Maps a value from an input range to an output range
	// map: float value       // The input value 
	// 	 float from = 0    // The beginning of the input range
	// 	 float to = 1      // The end of the input range
	// 	 Vector2 start     // The start output position, will be returned for values smaller than "from".
	// 	 Vector2 target    // The target output position, will be returned for values larger than "to".
	// 	 EaseFunction ease // The easing function to apply
	// 	if value <= from: return start
	// 	if value >= to:   return target
	// 	var factor = (value-from) / (to-from)
	// 	return start + (target-start) * ease.function(factor)
	
global transient unit System
	// global inline js void forPositions: T[] subject                       // The list to iterate over
	// 	                                Vector2 start = {0,0}             // Left or top align items at this position
	// 	                                implicit Vector2 delta = {300,0}  // Distance between items
	// 	                                -> void(
	// 	                                    T it,                         // The current item of the list we are iterating over with forCentered
	// 	                                    Vector2 pos,                  // The position of the current item
	// 	                                    int i                         // The index of the current item of the list we are iterating over with forCentered
	// 	                                ) do                              // Do this for each item in a list
	// 	for(var i=0, _subject=subject, _start = start, _delta = delta, _len=_subject.Count, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) { var it = _subject[i], pos = new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null); do()}

	// global inline js void forPositions: int to                            // The exclusive upper bound to iterate towards
	// 	                                Vector2 start = {0,0}             // Left or top align items at this position
	// 	                                implicit Vector2 delta = {300,0}  // Distance between items
	// 	                                -> void(
	// 	                                    int i,                        // The index of the current item of the list we are iterating over with forCentered
	// 	                                    Vector2 pos,                  // The position of the current item
	// 	                                ) do                              // Do this for each item in a list
	// 	for(var i=0, _start = start, _delta = delta, _len=to, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) { var pos = new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null); do()}

	// global inline js void forPositions: T[] subject                       // The list to iterate over
	// 	                                Vector2 start = {0,0}             // Left or top align items at this position
	// 	                                implicit Vector2 elta = {300,300} // Distance between items
	// 	                                float width                       // Wrap to the next row when we reach this width
	// 	                                -> void(
	// 	                                    T it,                         // The current item of the list we are iterating over with forCentered
	// 	                                    Vector2 pos,                  // The position of the current item
	// 	                                    int i                         // The index of the current item of the list we are iterating over with forCentered
	// 	                                ) do                              // Do this for each item in a list
	// 	for(var i=0, _subject=subject, _start = start, _delta = delta, _width = width, _len=_subject.Count, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x) { if(_x >= _start.x+_width) {_x = _start.x; _y += _delta.y} var it = _subject[i], pos = new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null); do()}

	// global inline js void forPositions: T[] subject                       // The list to iterate over
	// 	                                Vector2 center = {0,0}            // Center items at this position
	// 	                                implicit Vector2 delta = {300,0}  // Distance between items
	// 	                                -> void(
	// 	                                    T it,                         // The current item of the list we are iterating over with forCentered
	// 	                                    Vector2 pos,                  // The position of the current item
	// 	                                    int i                         // The index of the current item of the list we are iterating over with forCentered
	// 	                                ) do                              // Do this for each item in a list
	// 	for(var i=0, _subject=subject, _center = center, _delta = delta, _len=_subject.Count, _x = _center.x-(_len-1)*_delta.x/2, _y=_center.y-(_len-1)*_delta.y/2; i<_len; ++i, _x += _delta.x, _y += _delta.y) { var it = _subject[i], pos = new Vector2(_x, _y, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null); do()}

	// global inline js void forPositions: int to                            // The exclusive upper bound to iterate towards
	// 	                                Vector2 center = {0,0}            // Center items at this position
	// 	                                implicit Vector2 delta = {300,0}  // Distance between items
	// 	                                -> void(
	// 	                                    int i,                        // The index of the current item of the list we are iterating over with forCentered
	// 	                                    Vector2 pos                   // The position of the current item
	// 	                                ) do                              // Do this for each item in a list
	// 	for(var i=0, _center = center, _delta = delta, _len=to, _x = _center.x-(_len-1)*_delta.x/2, _y=_center.y-(_len-1)*_delta.y/2; i<_len; ++i, _x += _delta.x, _y += _delta.y) { var pos = new Vector2(_x, _y, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null); do()}

	// global inline js void forPositions: T[] subject                       // The list to iterate over
	// 	                                Vector2 end = {0,0}               // Right or bottom align items at this position
	// 	                                implicit Vector2 delta = {300,0}  // Distance between items
	// 	                                -> void(
	// 	                                    T it,                         // The current item of the list we are iterating over with forCentered
	// 	                                    Vector2 pos,                  // The position of the current item
	// 	                                    int i                         // The index of the current item of the list we are iterating over with forCentered
	// 	                                ) do                              // Do this for each item in a list
	// 	for(var i=0, _subject=subject, _end = end, _delta = delta, _len=_subject.Count, _x = _end.x-(_len-1)*_delta.x, _y=_end.y-(_len-1)*_delta.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) { var it = _subject[i], pos = new Vector2(_x, _y, _end.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _end.location, _delta.location) : null); do()}

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
// class IsometicGrid
// 	IntVector2 size            // The amount of cells in the grid
// 	Vector2 cellSize      // The size of each cell
// 	Vector2 topFaceOffset // The position of the top face within the cell
	
// 	visible Vector2 xOffset = cellSize / 2
// 	visible Vector2 yOffset = {-xOffset.x, xOffset.y}
// 	visible Vector2 basePos = {0,-yOffset.y*(size.y-1)}
	
// 	// Convert world position (northwest is up) to screen position (north is up)
// 	getScreenPosition: Vector2 worldPos // The world position
// 		return basePos + xOffset*worldPos.x + yOffset*worldPos.y
		
// 	// Convert screen position (north is up) to world position (northwest is up)
// 	getWorldPosition: Vector2 screenPos // The screen position
// 		              bool allowOutside = false
// 		Vector2 t = screenPos - basePos + topFaceOffset
// 		var x = (xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y)
// 		var y = (xOffset.x*t.y - xOffset.y*t.x) / (2*xOffset.x*xOffset.y)
// 		if allowOutside or (x >= 0 and x < size.x and y >= 0 and y < size.y): return Vector2(x,y)
// 		else                                                                  return Vector2.none
		
// 	// Convert screen pos (north is up) to rounded world pos (northwest is up)
// 	getGridPosition: Vector2 screenPos // The screen position
// 		             bool allowOutside = false
// 		Vector2 t = screenPos - basePos + topFaceOffset
// 		var x = Math.round((xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
// 		var y = Math.round((xOffset.x*t.y - xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
// 		if allowOutside or (x >= 0 and x < size.x and y >= 0 and y < size.y): return IntVector2(x,y)
// 		else                                                                  return IntVector2.none
		
// 	isValid: IntVector2 pos
// 		return pos >= {0,0} and pos < size
		
// 	limitToInside: IntVector2 position
// 		return IntVector2(
// 			Math.limit position.x, min:0, max:size.x-1
// 			Math.limit position.y, min:0, max:size.y-1
// 		)
		
// 	getScreenVector: Vector2 worldVector
// 		return xOffset*worldVector.x + yOffset*worldVector.y
	
struct Direction
	global const Direction Front = {"Front", 3, { 0, 1}, { 0, 0, 1},    0, Quaternion.identity          } // positive z direction (0,0,1)
	global const Direction Right = {"Right", 0, { 1, 0}, { 1, 0, 0},  .25, Quaternion.Euler(  0,  90, 0)} // positive x direction (1,0,0)
	global const Direction Back  = {"Back",  1, { 0,-1}, { 0, 0,-1},  .50, Quaternion.Euler(  0, 180, 0)} // negative z direction (0,0,-1)
	global const Direction Left  = {"Left",  2, {-1, 0}, {-1, 0, 0},  .75, Quaternion.Euler(  0, 270, 0)} // negative x direction (-1,0,0)
	global const Direction Up    = {"Up",    4, { 0, 0}, { 0, 1, 0},    0, Quaternion.Euler( 90,   0, 0)} // positive y direction (0,1,0)
	global const Direction Down  = {"Down",  5, { 0, 0}, { 0,-1, 0},    0, Quaternion.Euler(-90,   0, 0)} // negative y direction (0,-1,0)
	
	global const Direction FrontRight = {"FrontRight", 0, { 1, 1}, { 1, 0, 1},  .125, Quaternion.Euler(  0,  45, 0)}
	global const Direction BackRight  = {"BackRight",  1, { 1,-1}, { 1, 0,-1},  .375, Quaternion.Euler(  0, 135, 0)}
	global const Direction BackLeft   = {"BackLeft",   2, {-1,-1}, {-1, 0,-1},  .625, Quaternion.Euler(  0, 225, 0)}
	global const Direction FrontLeft  = {"FrontLeft",  3, {-1, 1}, {-1, 0, 1},  .875, Quaternion.Euler(  0, 315, 0)}
	
	// List of the four primary direction: Right, Down, Left, Up
	const Direction[] primaryDirections = [Front, Right, Back, Left]
	
	// List of the four diagonals: UpLeft, UpRight, DownLeft, DownRight
	const Direction[] diagonalDirections = [FrontRight, BackRight, BackLeft, FrontLeft]
	
	// List of the primary direction and the diagonals
	const Direction[] allDirections = [Front, FrontRight, Right, BackRight, Back, BackLeft, Left, FrontLeft]

	string name
	int index
	IntVector2 vector
	IntVector3 vector3
	Angle angle
	Quaternion quaternion
	
	override toString := name
	implicit toQuaternion := quaternion
		
// enum LineType: Line, Ray, Segment
	
// class Line
// 	Vector2 start, end
// 	LineType type
	
// 	length
// 		return type == Segment ? (start distanceTo end) : float.infinity
	
// 	Vector2 intersectionWith: Line other
// 		var x1    = start.x,       y1 = start.y
// 		var x2    = end.x,         y2 = end.y
// 		var typeA = type
// 		var x3    = other.start.x, y3 = other.start.y
// 		var x4    = other.end.x,   y4 = other.end.y
// 		var typeB = other.type
		
// 		// Check if none of the lines are of length 0
// 		if (x1 == x2 && y1 == y2) || (x3 == x4 && y3 == y4) return Vector2.none

// 		// compute line params
// 		var denominator = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
// 		if (denominator == 0) return Vector2.none // lines are parallel
// 		var ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denominator
// 		var ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denominator

// 		// is the intersection along the segments
// 		if (typeA >= Ray && ua < 0) || (typeA == Segment && ua > 1)
// 		|| (typeB >= Ray && ub < 0) || (typeB == Segment && ub > 1)
// 			return Vector2.none
			
// 		// Return a object with the x and y coordinates of the intersection
// 		return new Vector2(x1 + ua * (x2 - x1), y1 + ua * (y2 - y1))
		
// 	toString := "{start.x.format(fractionDigits:2)} {start.y.format(fractionDigits:2)} -> {end.x.format(fractionDigits:2)} {end.y.format(fractionDigits:2)}"

// class Rect
// 	Vector2 position, size
// 	bool contains: Vector2 position
// 		return this.position-this.size/2 <=  position < this.position+this.size/2
	
class Grid<T>
	IntVector2 size
	visible T[] items
	
	get: int x // The column to get the value from
		 int y // The row to get the value from
		return items[y*size.x + x]
	
	get: IntVector2 position // The vector to get the value from
		return items[position.y*size.x + position.x]
	
	T set: int x   // The column of the value to set
		   int y   // The row of the value to set
		   T value // The value to set
		return items[y*size.x + x] = value
		
	T set: IntVector2 position // The grid position of the value to set
		   T value             // The value to set
		return items[position.y*size.x + position.x] = value
		
	isValid: int x, int y
		return 0 <= x < size.x 
		   and 0 <= y < size.y
		
	isValid: IntVector2 position
		return 0 <= position.x < size.x 
		   and 0 <= position.y < size.y
		
	inline cs(UnityEngine, System) void each: -> void(
		                     T it,      // The current item of the list we are iterating over with the for-loop
		                     IntVector2 pos,
		                     int i      // The index of the current item of the list we are iterating over with the for-loop
		                 ) do           // Do this for each item in a list
		var _subject=this.items; 
		for(int _i=0, _len=_subject.Count; _i<_len; ++_i) { var _it = _subject[_i]; if(_it != null) { var _pos = new Vector2Int(_i%this.size.x, (int)MathF.Floor(_i/this.size.x)); do(_it, _pos, _i)}}
			
	inline cs(UnityEngine) void each: includeEmpty = false
		                 -> void(
		                     T it,      // The current item of the list we are iterating over with the for-loop
		                     IntVector2 pos
		                 ) do           // Do this for each item in a list
		var _subject=this.items;
		for(int _size=this.size, _y=0; _y<_size.y; ++_y) for(int _x=0; _x<_size.x; ++_x) { var _it = _subject[y*_size.x + x]; var _pos = new Vector2Int(x,y); do(_it, _pos)}
			
global transient unit System
	global inline cs void for: ensureSingleExecution IntVector2 size // Iterate over all dimensions of this vector
		                       -> void(
		                           IntVector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do           // Do this the given number of times
		for(int _y=0; _y<size.y; ++_y) for(int _x=0; _x<size.x; ++_x) { var _pos = new Vector2Int(_x,_y); do(_pos, _x, _y)}
			
	global inline cs void for: ensureSingleExecution IntVector2 size // Iterate over all dimensions of this vector
		                       <- void(
		                           IntVector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do           // Do this the given number of times
		for(int _y=size.y-1; _y>=0; --_y) for(int _x=size.x-1; _x>=0; --_x) { var pos = new Vector2Int(x,y); do(_pos, _x, _y)}
			
	global inline cs(UnityEngine, System) void for: Grid<T> subject    // The grid to iterate over
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           IntVector2 pos,
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		{var _subject=subject.items; for(int i=0, _len=_subject.Count; i<_len; ++i) { var it = _subject[i]; if(it != null) { var pos = new Vector2Int(i%subject.size.x, (int)MathF.Floor(i/subject.size.x)); do()}}}
			
	global inline cs(UnityEngine) void for: ensureSingleExecution Grid<T> subject    // The grid to iterate over
		                       includeEmpty = false
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           IntVector2 pos
		                       ) do           // Do this for each item in a list
		var _size=this.size;
		for(int _y=0; _y<_size.y; ++_y) for(int _x=0; _x<_size.x; ++_x) { var _it = _subject[y*_size.x + x]; var _pos = new Vector2Int(x,y); do(_it, _pos)}}

// A 2D vector comprised of an x and y coordinate
struct Vector2
	float x // The x-coordinate of the vector
	float y // The y-coordinate of the vector
	SourceCodeLocation location
	
	// Used to specify that the vector is not set or invalid
	static inline Vector2 none() Vector2(float.infinity, float.infinity, null)
	
	// {float.minValue, float.minValue}
	static inline Vector2 minValue() Vector2(float.minValue, float.minValue, null)
	
	// {float.maxValue, float.maxValue}
	static inline Vector2 maxValue() Vector2(float.maxValue, float.maxValue, null)
	
	// {0,0}
	static inline Vector2 zero() Vector2(0, 0, null)
		
	// A string representation of the vector
	string toString() := "{x} {y}"
	
	// Returns true if the vector is not equal to Vector2.none
	bool toBool := (x != float.infinity || y != float.infinity)
	
	// Creates a copy of the vector with the same values
	Vector2 clone() := {x, y, location}
		
	// Create a new instance. Useful for data imported from json where the vector might be undefined
	inline js Vector2 create: float x // The x-coordinate of the vector to create
		                      float y // The y-coordinate of the vector to create
		                      SourceCodeLocation location
		(this = new Vector2(x, y, location))
		
	// Create a new instance. Useful for data imported from json where the vector might be undefined
	inline js Vector2 create: Vector2 value  // Create a new instance with the coordinated of this vector
		(this = new Vector2(value.x, value.y, value.location))
		
	Vector2 assign Vector2 other: x = other.x; y = other.y; location = other.location; return this
		
	// Vector2 operator = (Vector2 a, Vector2 b) a.x = b.x; a.y = b.y; a.location = b.location; return a
	
	Vector2 + Vector2 other:   return {x + other.x, y + other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 - Vector2 other:   return {x - other.x, y - other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	
	Vector2 * Vector2 other:   return {x * other.x, y * other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 * float other:     return {x * other,   y * other,   location}
	Vector2 * Matrix2D matrix: return {matrix.m0 * x + matrix.m2 * y + matrix.m4, matrix.m1 * x + matrix.m3 * y + matrix.m5, location}
	
	Vector2 / Vector2 other:   return {x / other.x, y / other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 / float other:     return {x / other,   y / other,   location}
	Vector2 / Matrix2D matrix
		var aa = matrix.m0, ab = matrix.m1, ac = matrix.m2, ad = matrix.m3, atx = matrix.m4, aty = matrix.m5

		var det = aa * ad - ab * ac
		if(det == 0) return {0,0,null}
		det = 1.0 / det
		
		return {
			( ad * det) * x + (-ac * det) * y + ((ac * aty - ad * atx) * det),
			(-ab * det) * x + ( aa * det) * y + ((ab * atx - aa * aty) * det),
			location
		}	
				
	Vector2 % Vector2 other:   return {x % other.x, y % other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 % float other:     return {x % other,   y % other,   location}
		
	Vector2 += Vector2 other: x += other.x; y += other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	Vector2 -= Vector2 other: x -= other.x; y -= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	
	Vector2 *= Vector2 other: x *= other.x; y *= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	Vector2 *= float other:   x *= other;   y *= other; return this
	
	Vector2 /= Vector2 other: x /= other.x; y /= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	Vector2 /= float other:   x /= other;   y /= other; return this
	
	// Vector2 operator + (Vector2 a, Vector2 b) return {a.x+b.x, a.y+b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	// Vector2 operator - (Vector2 a, Vector2 b) return {a.x-b.x, a.y-b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	
	// Vector2 operator * (Vector2 a, Vector2 b) return {a.x*b.x, a.y*b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	// Vector2 operator * (Vector2 a, float b)   return {a.x*b, a.y*b, a.location}
	// Vector2 operator * (Vector2 a, Time b)    return {cast a.x*b, cast a.y*b, a.location}
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
	// Vector2 operator *= (Vector2 a, float b) a.x *= b; a.y *= b; return a
	
	// Vector2 operator /= (Vector2 a, Vector2 b) a.x /= b.x; a.y /= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	// Vector2 operator /= (Vector2 a, float b) a.x /= b; a.y /= b; return a
	
	bool == Vector2 other: return x == other.x && y == other.y
	bool != Vector2 other: return x != other.x || y != other.y
		
	bool == IntVector2 other: return x == other.x && y == other.y
	bool != IntVector2 other: return x != other.x || y != other.y
		
	bool <  Vector2 other: return x <  other.x && y <  other.y
	bool <= Vector2 other: return x <= other.x && y <= other.y
	bool >  Vector2 other: return x >  other.x && y >  other.y
	bool >= Vector2 other: return x >= other.x && y >= other.y
	
	bool <  float length: return math.sqrt(x*x + y*y) <  length
	bool <= float length: return math.sqrt(x*x + y*y) <= length
	bool >  float length: return math.sqrt(x*x + y*y) >  length
	bool >= float length: return math.sqrt(x*x + y*y) >= length
		
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
	
	// bool operator == (Vector2 a, float length) let x = a.x, y = a.y; return math.sqrt(x*x + y*y) == length
	// bool operator != (Vector2 a, float length) let x = a.x, y = a.y; return math.sqrt(x*x + y*y) != length
	// bool operator >  (Vector2 a, float length) let x = a.x, y = a.y; return math.sqrt(x*x + y*y) >  length
	// bool operator >= (Vector2 a, float length) let x = a.x, y = a.y; return math.sqrt(x*x + y*y) >= length
	// bool operator <  (Vector2 a, float length) let x = a.x, y = a.y; return math.sqrt(x*x + y*y) <  length
	// bool operator <= (Vector2 a, float length) let x = a.x, y = a.y; return math.sqrt(x*x + y*y) <= length
	
	// The length of the vector
	length := math.sqrt(x * x + y * y)
		
	lengthSquared := x * x + y * y
		
	// A vector that is orthogonal to the existing vector
	orthogonal := Vector2(x:-y, y:x)
		
	// A vector with the sign of each coordinate flipped
	inverse := Vector2(-x, -y)
		
	// A vector with each coordinate rounded to the closest integer value
	rounded := IntVector2(math.round(x), math.round(y))
	
	// A vector with each coordinate rounded down to an integer value
	floor := IntVector2(math.floor(x), math.floor(y))
		
	// A vector with each coordinate rounded up to an integer value
	ceil := IntVector2(math.ceil(x), math.ceil(y))
		
	// A vector with the absolute value of each coordinate
	abs := Vector2(math.abs(x), math.abs(y))
		
	// The larger of the two coordinates
	max := x > y ? x : y
	
	// The smaller of the two coordinates
	min := x < y ? x : y
	
	// Move the vector
	move: Vector2 delta // The vector to move by
		this.x += delta.x
		this.y += delta.y
		return this
	
	// Move the vector	
	move: float x // Move horizontally by this value
		  float y // Move vertically by this value
		this.x += x
		this.y += y
		return this
		
	rotate: Angle angle // The angle in turns (one full rotation is 1)
		let x = this.x, y = this.y
		let sn = math.sin(angle)
		let cs = math.cos(angle)
		this.x = x * cs - y * sn;
		this.y = x * sn + y * cs;
		return this
		
	// The distance to another vector
	distanceTo: Vector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return math.sqrt(x*x + y*y)

	// The distance to another vector along axes at right angles
	manhattanDistanceTo: Vector2 value // The second vector
		return math.abs(x - value.x) + math.abs(y - value.y)

	// The angle to another vector in turns (one full rotation is 1)
	angleTo: Vector2 value // The second vector
		return math.getAngleForVector(value - this)

	// A vector that points in the same direction, but has a length of 1
	normalized
		let len = math.sqrt(x * x + y * y)
		return len != 0 ? Vector2(x / len, y / len) : Vector2(0, 0)
	
	// Moves the vector towards the given target by the given distance	
	moveTowards: Vector2 targetPosition // The target to move towards
		         float speed = 30       // The distance to move by
		let delta = targetPosition - this
		if delta.x != 0 || delta.y != 0
			delta = delta.normalized * speed
			if delta.x > 0: x = math.min(x + delta.x, targetPosition.x)
			else            x = math.max(x + delta.x, targetPosition.x)
			if delta.y > 0: y = math.min(y + delta.y, targetPosition.y)
			else            y = math.max(y + delta.y, targetPosition.y)
		
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
		
	in: Rect rectangle
		return x >= rectangle.position.x - rectangle.size.x/2 && x < rectangle.position.x + rectangle.size.x/2
		    && y >= rectangle.position.y - rectangle.size.y/2 && y < rectangle.position.y + rectangle.size.y/2
	
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
	
	static getPathLength: Vector2[] path
		float length
		forPairs path: length += .distanceTo next
		return length
		
	static Vector2 getPositionAlongPath: Vector2[] path, float distance
		float traveledSoFar
		forPairs path
			let segmentLength = .distanceTo next
			let traveledAfterSegment = traveledSoFar + segmentLength
			if  traveledAfterSegment > distance
				return .interpolateTo next progress:distance traveledSoFar..traveledAfterSegment
			traveledSoFar = traveledAfterSegment
		return path.last
		
	static PositionAndVector getPositionAndVectorAlongPath: Vector2[] path, float distance
		float traveledSoFar
		forPairs path
			let segmentLength = .distanceTo next
			let traveledAfterSegment = traveledSoFar + segmentLength
			if  traveledAfterSegment > distance
				return {
					position: .interpolateTo next progress:distance traveledSoFar..traveledAfterSegment
					vector:   next - .
				}
			traveledSoFar = traveledAfterSegment
			
		let lastPos = path.last
		return {position:lastPos, vector:lastPos - path[path.length-2]}
		
js String
immutable class string
	Vector2 toVector2
		let mid = this.indexOf " "
		return Vector2(cast this[..mid], cast this[mid+1..]) 
		
PositionAndVector
	Vector2 position
	Vector2 vector
	
Path
	Vector2[] nodes
	float[] segmentLengths
	float length
	
	Vector2 first := nodes ? nodes.first : Vector2.none
	Vector2 last :=  nodes ? nodes.last  : Vector2.none
	int count := nodes.length
	inline Vector2 get(int index) this.nodes[index]
	
	Path
		update
		
	update
		length = 0
		forPairs nodes
			let x = next.x - .x
			let y = next.y - .y
			length += segmentLengths[i] = math.sqrt(x*x + y*y)
		
	Vector2 getPosition: float distance
		if nodes.length == 0: return Vector2.none
		if nodes.length == 1: return nodes[0]
			
		float travelledSoFar
		forPairs nodes
			let segmentLength = segmentLengths[i]
			let travelledAfterSegment = travelledSoFar + segmentLength
			if  travelledAfterSegment >= distance
				let factor = (distance - travelledSoFar) / segmentLength
				return {.x + (next.x - .x)*factor, .y + (next.y - .y)*factor}
				// return .interpolateTo next progress:distance travelledSoFar..travelledAfterSegment
			travelledSoFar = travelledAfterSegment
		return nodes.last
		
	PositionAndVector getPositionAndVector: float distance
		if nodes.length == 0: return { position:Vector2.none }
		if nodes.length == 1: return { position:nodes[0] }
			
		float travelledSoFar
		forPairs nodes
			let segmentLength = segmentLengths[i]
			let travelledAfterSegment = travelledSoFar + segmentLength
			if  travelledAfterSegment >= distance
				let factor = (distance - travelledSoFar) / segmentLength
				return {
					position:{.x + (next.x - .x)*factor, .y + (next.y - .y)*factor}
					vector: next - .
				}
				// return .interpolateTo next progress:distance travelledSoFar..travelledAfterSegment
			travelledSoFar = travelledAfterSegment
			
		let lastPos = nodes.last
		return {position:lastPos, vector:lastPos - nodes[nodes.length-2]}
		
// A 2D vector comprised of an integer x and y coordinate
struct IntVector2
	int x // The x-coordinate of the vector
	int y // The y-coordinate of the vector
	SourceCodeLocation location
	
	// Used to specify that the vector is not set or invalid
	static inline IntVector2 none() IntVector2(int.minValue, int.minValue, null)
		
	// {0,0}
	static inline IntVector2 zero() IntVector2(0, 0, null)
	
	// Creates a copy of the vector with the same values
	IntVector2 clone := {x, y, location}
		
	// A string representation of the vector
	string toString := "({x} {y})"
	
	// Returns true if the vector is not equal to IntVector2.none
	bool toBool := (x != int.minValue || y != int.minValue)
	
	implicit Vector2 toVector2 := {x, y, location}
	
	IntVector2 assign IntVector2 other: x = other.x; y = other.y; location = other.location; return this
		
	IntVector2 + IntVector2 other:   return {x + other.x, y + other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 + Vector2 other:         return {x + other.x, y + other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	
	IntVector2 - IntVector2 other:   return {x - other.x, y - other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 - Vector2 other:         return {x - other.x, y - other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	
	IntVector2 * IntVector2 other:   return {x * other.x, y * other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2    * Vector2 other:      return {x * other.x, y * other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	IntVector2 * int other:          return {x * other,   y * other, location}
	Vector2    * float other:        return {x * other,   y * other, location}
	
	Vector2 / IntVector2 other:      return {x / other.x, y / other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	Vector2 / float other:           return {x / other,   y / other, location}

	IntVector2 % IntVector2 other:   return {x % other.x, y % other.y, location || other.location ? new SourceCodeLocation(null, 0, 0, location, other.location) : null}
	IntVector2 % int other:          return {x % other,   y % other, location}
		
	IntVector2 += IntVector2 other: x += other.x; y += other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	IntVector2 -= IntVector2 other: x -= other.x; y -= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	
	IntVector2 *= IntVector2 other: x *= other.x; y *= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	IntVector2 *= int other:        x *= other;   y *= other; return this
	
	Vector2    /= IntVector2 other: x /= other.x; y /= other.y; if(location || other.location) {location = new SourceCodeLocation(null, 0, 0, location, other.location)} return this
	Vector2    /= float other:      x /= other;   y /= other; return this
	
	// IntVector2 operator = (IntVector2 a, IntVector2 b) a.x = b.x; a.y = b.y; a.location = b.location; return a
	
	// IntVector2 operator + (IntVector2 a, IntVector2 b) return {a.x+b.x, a.y+b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	// IntVector2 operator - (IntVector2 a, IntVector2 b) return {a.x-b.x, a.y-b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	
	// IntVector2 operator * (IntVector2 a, IntVector2 b) return {a.x*b.x, a.y*b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	// IntVector2 operator * (IntVector2 a, int b)   return {a.x*b, a.y*b, a.location}
	// IntVector2 operator * (int a, IntVector2 b)   return {a*b.x, a*b.y, b.location}
		
	// Vector2 operator / (IntVector2 a, IntVector2 b) return {a.x/b.x, a.y/b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	// Vector2 operator / (IntVector2 a, float b)   return {a.x/b, a.y/b, a.location}
	
	// IntVector2 operator % (IntVector2 a, IntVector2 b) return {((a.x % b.x) + b.x) % b.x, ((a.y % b.y) + b.y) % b.y, a.location || b.location ? new SourceCodeLocation(null, 0, 0, a.location, b.location) : null}
	// IntVector2 operator % (IntVector2 a, int b)   return {((a.x % b) + b) % b, ((a.y % b) + b) % b, a.location}
	
	// IntVector2 operator += (IntVector2 a, IntVector2 b) a.x += b.x; a.y += b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	// IntVector2 operator -= (IntVector2 a, IntVector2 b) a.x -= b.x; a.y -= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	// IntVector2 operator *= (IntVector2 a, IntVector2 b) a.x *= b.x; a.y *= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	// IntVector2 operator /= (IntVector2 a, IntVector2 b) a.x /= b.x; a.y /= b.y; if(a.location || b.location) {a.location = new SourceCodeLocation(null, 0, 0, a.location, b.location)} return a
	
	bool == IntVector2 other: return x == other.x && y == other.y
	bool != IntVector2 other: return x != other.x || y != other.y
		
	bool <  IntVector2 other: return x <  other.x && y <  other.y
	bool <= IntVector2 other: return x <= other.x && y <= other.y
	bool >  IntVector2 other: return x >  other.x && y >  other.y
	bool >= IntVector2 other: return x >= other.x && y >= other.y
	
	bool <  float length: return math.sqrt(x*x + y*y) <  length
	bool <= float length: return math.sqrt(x*x + y*y) <= length
	bool >  float length: return math.sqrt(x*x + y*y) >  length
	bool >= float length: return math.sqrt(x*x + y*y) >= length
		
	// bool operator == (IntVector2 a, IntVector2 b) return a.x == b.x && a.y == b.y
	// bool operator != (IntVector2 a, IntVector2 b) return a.x != b.x || a.y != b.y
	// bool operator >  (IntVector2 a, IntVector2 b) return a.x >  b.x && a.y >  b.y
	// bool operator >= (IntVector2 a, IntVector2 b) return a.x >= b.x && a.y >= b.y
	// bool operator <  (IntVector2 a, IntVector2 b) return a.x <  b.x && a.y <  b.y
	// bool operator <= (IntVector2 a, IntVector2 b) return a.x <= b.x && a.y <= b.y
	
	// The length of the vector
	length := math.sqrt(x * x + y * y)
		
	// A vector that is orthogonal to the existing vector
	orthogonal := IntVector2(x:-y, y:x)
		
	// A vector with the sign of each coordinate flipped
	inverse := IntVector2(-x, -y)
		
	// A vector with the absolute value of each coordinate
	abs := IntVector2(math.abs(x), math.abs(y))
		
	// The larger of the two coordinates
	max := x > y ? x : y
	
	// The smaller of the two coordinates
	min := x < y ? x : y
	
	limit: IntVector2 min
		   IntVector2 max
		return IntVector2(
			math.limit x, min:min.x, max:max.x
			math.limit y, min:min.y, max:max.y
		)
		
	limit: IntVector2 max
		return IntVector2(
			math.limit x, max:max.x
			math.limit y, max:max.y
		)
		
	limit: IntVector2 min
		return IntVector2(
			math.limit x, min:min.x
			math.limit y, min:min.y
		)
		
	// The distance to another vector
	distanceTo: IntVector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return math.sqrt(x*x + y*y)
		
	// The distance to another vector
	distanceTo: Vector2 value // The second vector
		let x = x - value.x
		let y = y - value.y
		return math.sqrt(x*x + y*y)

	// The distance to another vector along axes at right angles
	manhattanDistanceTo: IntVector2 value // The second vector
		return math.abs(x - value.x) + math.abs(y - value.y)
		
	// Returns whether the vector is within a given rectangle
	isInsideRectangle: IntVector2 center, // The center of the rectangle
		               IntVector2 size,   // The size of the rectangle
		return x >= center.x - size.x/2 && x < center.x + size.x/2
		    && y >= center.y - size.y/2 && y < center.y + size.y/2		

	// The angle to another vector in turns (one full rotation is 1)
	angleTo: IntVector2 value // The second vector
		return math.getAngleForVector(value - this)
		
	// A float vector that points in the same direction, but has a length of 1
	normalized
		let len = math.sqrt(x * x + y * y)
		return len != 0 ? Vector2(x / len, y / len) : Vector2(0, 0)
		
	static js TResult[] enumerate: IntVector2 from
	                               IntVector2 to
	                               TResult(IntVector2 it) selector
		let result = []
		for(let y=from.y; y < to.y; ++y)
			for(let x=from.x; x < to.x; ++x)
				result.push(selector(new IntVector2(x,y)))
		return result
		
	inline js TResult[] times: TResult(IntVector2 it) selector
		Vector2.enumerate(new IntVector2(0,0), this, selector)
	
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

	Matrix2D assign Matrix2D other
		m0 = other.m0
		m1 = other.m1
		m2 = other.m2
		m3 = other.m3
		m4 = other.m4
		m5 = other.m5
		return this
		
	Matrix2D * Matrix2D other
		Matrix2D c
		return multiply(this, other, c)
		
	Matrix2D *= Matrix2D other
		return multiply(this, other, this)
		
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
		let sin = math.sin(angle), cos = math.cos(angle)
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
		
struct float
	inline Vector2 * Vector2 other: Vector2(this * other.x, this * other.y, other.location)

struct int
	inline Vector2 * Vector2 other: Vector2(this * other.x, this * other.y, other.location)
	inline IntVector2 * IntVector2 other: IntVector2(this * other.x, this * other.y, other.location)
		
class List<T>
	Vector2 total: Vector2(T it) selector
		Vector2 sum = {0,0}
		for this: sum += selector(.)
		return sum	
		
	Vector2 average: Vector2(T it) selector
		int count
		Vector2 sum = {0,0}
		for this
			sum += selector(.)
			count++
		return sum/count
		
	Vector2 average: Vector2(T it) selector
		             bool(T it) where
		int count
		Vector2 sum = {0,0}
		for this
			if where(.)
				sum += selector(.)
				count++
		return sum/count
		
// ------------------------------------------- Angle -------------------------------------------
		
transient immutable float Angle
	inline js float toFloat() this
	inline js string toString() this.toString()
		
	// Returns true if the angle is not zero
	inline js bool toBool := this
	
	inline js float in: AngleUnit unit
		(unit==1 ? this*math.TwoPI : unit==2 ? this*360 : unit==3 ? this*400 : this)
		
	inline js Angle rotateTowards: Angle value
		                           Angle speed
		(this = Angle.rotatedTowards(this, value, speed))
		
	static Angle rotatedTowards: Angle value
		                         Angle target
		                         Angle speed
		target = target % 1
		let delta = (target - value) % 1
		if delta < .5: value = (value + speed) % 1; return value < target ? value : target
		else           value = (value - speed) % 1; return value > target ? value : target
		
	inline Angle + Angle value
	inline Angle - Angle value
	inline float / Angle value
	inline float * Angle value
	
	inline Angle += Angle value
	inline Angle -= Angle value
	inline Angle /= Angle value
	inline Angle *= Angle value
	
	inline bool == Angle value
	inline bool != Angle value
	inline bool < Angle value
	inline bool <= Angle value
	inline bool > Angle value
	inline bool >= Angle value
	
	inline js Angle normalize
		(((this + .5) % 1) + 1) % 1 - .5
	
	inline js Angle % ensureSingleExecution Angle value
		((this % value) + value) % value
		
	inline js Angle operator -  (Angle a) -a

		
enum AngleUnit
	turns    // One full rotation is 1
	radians  // One full rotation is 2π (about 6.2832)
	degrees  // One full rotation is 360
	gradians // One full rotation is 400
	
	
immutable priority low struct float
	implicit inline js Angle toAngle() this
	
	inline js Angle operator °(float angle) (angle/360)
	
	// One full rotation is 1
	inline js Angle turns := this
	
	// One full rotation is 2π (about 6.2832)
	inline js Angle radians := (this/math.TwoPI)
		
	// One full rotation is 360
	inline js Angle degrees := (this/360)
		
	// One full rotation is 400
	inline js Angle gradians := (this/400)

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
	
	internal inline js float nativeSin: float angle // The angle in radians
		Math.sin(angle)
		
	internal inline js float nativeCos: float angle // The angle in radians
		Math.cos(angle)
		
	internal inline js float nativeTan: float angle // The angle in radians
		Math.tan(angle)
		
	// Returns the sine of an angle in turns
	sin: Angle angle // The angle in turns (one full rotation is 1)
	    float result = cast(angle - .5 - math.floor(angle))
	    result *= 16 * (math.abs(result) - .5)
	    result += .225 * result * (math.abs(result) - 1)
	    return result

	// Returns the cosine of an angle in turns
	cos: Angle angle // The angle in turns (one full rotation is 1)
	    float result = cast(angle - .25 - math.floor(angle + .25))
	    result *= 16 * (math.abs(result) - .5)
	    result += .225 * result * (math.abs(result) - 1)
	    return result
	
	// Returns the tangent of an angle in turns
	tan: Angle angle
		return sin(angle) / cos(angle)
		
	// Returns the inverse tangent in turns
	Angle atan2: float y, float x
		float r, angle;
		float absx = math.abs(x) + .00000000001
		if y > 0.0
			r = (-y + absx) / (+y + absx);
			angle = .375;
		else
			r = (-y - absx) / (-y + absx);
			angle = .125;
		angle += (.03124211533 * r * r - .1562424076) * r;
		if x < 0.0: return cast -angle
		else        return cast angle
		
	moveTowards: Angle value
		         Angle targetValue
		         Angle speed = 10
		if targetValue > value: return math.min(value + speed, targetValue) else
		if targetValue < value: return math.max(value - speed, targetValue)
			
global skipInit unit math
	// Returns the arctangent of the quotient of the given values
	Angle getAngleForVector: Vector2 vector
		return math.atan2(vector.y, vector.x)
		
	Vector2 getVectorForAngle: Angle angle      // The angle in turns (0: straight up, 1: one full rotation clockwise)
		                       float radius = 1
		return new Vector2(math.sin(angle)*radius, -math.cos(angle)*radius)
		
	Vector2 intersectLines: Vector2 startA
		                    Vector2 endA
		                    Vector2 startB
		                    Vector2 endB
		                    LineType typeA = Segment
		                    LineType typeB = Segment
		
		let x1    = startA.x, y1 = startA.y
		let x2    = endA.x,   y2 = endA.y
		let x3    = startB.x, y3 = startB.y
		let x4    = endB.x,   y4 = endB.y
		
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
		
	projectPointOnLine: Vector2 from, Vector2 to, LineType type = Segment, Vector2 point
		let lineVector = to - from
		let pointVector = point - from
		let scalar = (pointVector dot lineVector) / lineVector.lengthSquared
		if type >= Ray     and scalar < 0: return Vector2.none
		if type == Segment and scalar > 1: return Vector2.none
		return from + lineVector * scalar
	
	closestPointOnLine: Vector2 from, Vector2 to, LineType type = Segment, Vector2 point
		let lineVector = to - from
		let pointVector = point - from
		let scalar = (pointVector dot lineVector) / lineVector.lengthSquared
		if type >= Ray     and scalar < 0: scalar = 0
		if type == Segment and scalar > 1: scalar = 1
		return from + lineVector * scalar
	
global transient unit System
	global inline js void forPositions: int to                            // The exclusive upper bound to iterate towards
		                                Vector2 start = {0,0}             // Left or top align items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    Vector2 pos,                  // The position of the current item
		                                    int i                         // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _start = start, _delta = delta, _len=to, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null), i)

	global inline js void forPositions: int to                            // The exclusive upper bound to iterate towards
		                                Vector2 center = {0,0}            // Center items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    Vector2 pos,                  // The position of the current item
		                                    int i,                        // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _center = center, _delta = delta, _len=to, _x = _center.x-(_len-1)*_delta.x/2, _y=_center.y-(_len-1)*_delta.y/2; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(new Vector2(_x, _y, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null), i)

	global inline js void forPositions: T[] subject                       // The list to iterate over
		                                Vector2 start = {0,0}             // Left or top align items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    T it,                         // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                  // The position of the current item
		                                    int i                         // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _subject=subject, _start = start, _delta = delta, _len=_subject.length, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(_subject[i], new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null), i)

	global inline js void forPositions: T[] subject                       // The list to iterate over
		                                Vector2 start = {0,0}             // Left or top align items at this position
		                                implicit Vector2 delta = {300,300} // Distance between items
		                                float width                       // Wrap to the next row when we reach this width
		                                inline -> void(
		                                    T it,                         // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                  // The position of the current item
		                                    int i                         // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _subject=subject, _start = start, _delta = delta, _width = width, _len=_subject.length, _x = _start.x, _y= _start.y; i<_len; ++i, _x += _delta.x) { if(_x >= _start.x+_width) {_x = _start.x; _y += _delta.y} do(_subject[i], new Vector2(_x, _y, _start.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _start.location, _delta.location) : null), i)}

	global inline js void forPositions: T[] subject                       // The list to iterate over
		                                Vector2 center = {0,0}            // Center items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    T it,                         // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                  // The position of the current item
		                                    int i                         // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _subject=subject, _center = center, _delta = delta, _len=_subject.length, _x = _center.x-(_len-1)*_delta.x/2, _y=_center.y-(_len-1)*_delta.y/2; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(_subject[i], new Vector2(_x, _y, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null), i)

	global inline js void forPositions: T[] subject                       // The list to iterate over
		                                Vector2 end = {0,0}               // Right or bottom align items at this position
		                                implicit Vector2 delta = {300,0}  // Distance between items
		                                inline -> void(
		                                    T it,                         // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                  // The position of the current item
		                                    int i                         // The index of the current item of the list we are iterating over with forCentered
		                                ) do                              // Do this for each item in a list
		for(let i=0, _subject=subject, _end = end, _delta = delta, _len=_subject.length, _x = _end.x-(_len-1)*_delta.x, _y=_end.y-(_len-1)*_delta.y; i<_len; ++i, _x += _delta.x, _y += _delta.y) do(_subject[i], new Vector2(_x, _y, _end.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _end.location, _delta.location) : null), i)
	
	global inline js void forPositions: T[] subject                        // The list to iterate over
		                                IntVector2 grid                    // Align items in a grid with this size
		                                Vector2 center = {0,0}             // Center items at this position
		                                implicit Vector2 delta = {300,300} // Distance between items
		                                inline -> void(
		                                    T it,                          // The current item of the list we are iterating over with forCentered
		                                    Vector2 pos,                   // The position of the current item
		                                    int i                          // The index of the current item of the list we are iterating over with forCentered
		                                ) do                               // Do this for each item in a list
		for(let _subject=subject, _center = center, _delta = delta, _grid=grid, _y=0, _yPos=_center.y-(_grid.y-1)*_delta.y/2; _y<_grid.y; ++_y, _yPos += _delta.y) for(let _x=0, _xPos = _center.x-(_grid.x-1)*_delta.x/2; _x < _grid.x; ++_x, _xPos += _delta.x) {let i = _y*_grid.x+_x; do(_subject[i], new Vector2(_xPos, _yPos, _center.location || _delta.location ? new SourceCodeLocation(null, 0, 0, _center.location, _delta.location) : null), i)}


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
		let x = math.round((xOffset.x*t.y + xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
		let y = math.round((xOffset.x*t.y - xOffset.y*t.x) / (2*xOffset.x*xOffset.y))
		if allowOutside or (x >= 0 and x < size.x and y >= 0 and y < size.y): return IntVector2(x,y)
		else                                                                  return IntVector2.none
		
	isValid: IntVector2 pos
		return pos >= {0,0} and pos < size
		
	limitToInside: IntVector2 position
		return IntVector2(
			math.limit position.x, min:0, max:size.x-1
			math.limit position.y, min:0, max:size.y-1
		)
		
	getScreenVector: Vector2 worldVector
		return xOffset*worldVector.x + yOffset*worldVector.y
		
enum RotationDirection: Clockwise, CounterClockwise
		
immutable Direction
	global const Direction Up     = {"Up",      0, { 0,-1, location:null},   0, 210°} // negative y direction (0,-1)
	global const Direction Right  = {"Right",   1, { 1, 0, location:null}, .25, 330°} // positive x direction (1,0)
	global const Direction Down   = {"Down",    2, { 0, 1, location:null}, .50,  30°} // positive y direction (0,1)
	global const Direction Left   = {"Left",    3, {-1, 0, location:null}, .75, 150°} // negative x direction (-1,0)
	global const Direction None   = {"None",   -1, { 0, 0, location:null},   0,   0°} // no direction (0,0)
		
	const Direction UpLeft    = {"UpLeft",    0, {-1,-1, location:null},-.125} // negative x, negative y direction (-1,-1)
	const Direction UpRight   = {"UpRight",   1, { 1,-1, location:null}, .125} // positive x, negative y direction (1,-1)
	const Direction DownRight = {"DownRight", 2, { 1, 1, location:null}, .375} // positive x, positive y direction (1,1)
	const Direction DownLeft  = {"DownLeft",  3, {-1, 1, location:null}, .625} // negative x, positive y direction (-1,1)
		
	
	// List of the four primary direction: Right, Down, Left, Up
	const Direction[] primaryDirections = [Up, Right, Down, Left]
	
	// List of the four diagonals: UpLeft, UpRight, DownLeft, DownRight
	const Direction[] diagonalDirections = [UpLeft, UpRight, DownRight, DownLeft]
	
	// The two horitontal directions: Left and Right
	const Direction[] horizontalDirections = [Left, Right]
	
	// The two vertical directions: Up and Down
	const Direction[] verticalDirections = [Up, Down]
	
	// Directions that form a triangle pointing up: Up, DownRight, DownLeft
	const Direction[] trianglePointingUp = [Up, DownRight, DownLeft]
	
	// Directions that form a triangle pointing right: UpLeft, Right, DownLeft
	const Direction[] trianglePointingRight = [UpLeft, Right, DownLeft]
	
	// Directions that form a triangle pointing down: UpLeft, UpRight, Down
	const Direction[] trianglePointingDown = [UpLeft, UpRight, Down]
	
	// Directions that form a triangle pointing left: Left, UpRight, DownRight
	const Direction[] trianglePointingLeft = [Left, UpRight, DownRight]
	
	// List of the primary direction and the diagonals
	const Direction[] allDirections = [Up, UpRight, Right, DownRight, Down, DownLeft, Left, UpLeft]

	// The center and all surrounding directions (a 3 x 3 around the center)
	const Direction[] centerAndAllDirections = [None, Up, UpRight, Right, DownRight, Down, DownLeft, Left, UpLeft]

	// The center and all horizontal and vertical directions (a cross)
	const Direction[] centerAndPrimaryDirections = [None, Up, Right, Down, Left]

	string name       // The name of the direction (e.g. "Left", "Right", "Up", "Down", "UpLeft", "DownRight", ...)
	int index         // The index starting with "Right" and going around clockwise (0: Right, 1: Down, 2: Left, 3: Up)
	IntVector2 vector // The vector of the direction (Right: {1,0}, Down:{0,1}, Left:{-1,0}, Up:{0,-1})
	Angle angle       // The angle in turns starting with "Right" and going around clockwise
	Angle isoAngle    // The angle in turns within an isometric grid
	
	toString := name
	
	bool == Direction value 
		this.angle == value.angle
	
	rotated: RotationDirection direction = Clockwise
		return primaryDirections[(index+(direction == Clockwise ? 1:3))%4]
		
	inverted
		return primaryDirections[(index+2)%4]
		
	isOrthogonalTo: Direction value
		return index%2 != value.index%2
		
	isParallelTo: Direction value
		return index%2 == value.index%2
		
enum LineType: Line, Ray, Segment
	
immutable Line
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

immutable Rect
	Vector2 position, size
	
	float left := position.x - size.x/2
	float right := position.x + size.x/2
	float top := position.y - size.y/2
	float bottom := position.y + size.y/2
	
	bool contains: Vector2 position
		return this.position - this.size/2 <=  position < this.position + this.size/2
	
	bool intersectsWith: Vector2 position
		                 Vector2 size
		return this.position - this.size/2 - size/2 <=  position < this.position + this.size/2 + size/2

class Grid<T>
	IntVector2 size
	T[] items
	
	Grid
		for size.x * size.y: items.add null
	
	get: int x // The column to get the value from
		 int y // The row to get the value from
		return items[y*size.x + x]
	
	get: IntVector2 position // The vector to get the value from
		return {0,0} <= position < size ? items[position.y*size.x + position.x] : null
	
	set: int x   // The column of the value to set
		 int y   // The row of the value to set
		 T value // The value to set
		items[y*size.x + x] = value
	
	set: IntVector2 position // The grid position of the value to set
		 T value             // The value to set
		items[position.y*size.x + position.x] = value
		
	// Do something for each item in the grid
	inline js void each: inline -> void(
		                     T it,      // The current item of the list we are iterating over with the for-loop
		                     IntVector2 pos,
		                     int i      // The index of the current item of the list we are iterating over with the for-loop
		                 ) do           // Do this for each item in a list
		for(let i=0, _subject=this.items, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; if(it) do(it, new IntVector2(i%this.size.x, Math.floor(i/this.size.x)), i)}
			
	inline js void each: includeEmpty = false // Include items that are null
		                 inline -> void(
		                     T it,      // The current item of the list we are iterating over with the for-loop
		                     IntVector2 pos,
		                     int i      // The index of the current item of the list we are iterating over with the for-loop
		                 ) do           // Do this for each item in a list
		for(let _size=this.size, y=0, _items=this.items; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) do(_items[y*_size.x + x], new IntVector2(x,y), i)}
		
	// Return a list that contains the selected field or expression for each item
	inline js TValue[] select: TValue(T it) selector
		this.items.map(selector)
		
	// Get the selected field or expression for each item and flattens the result
	inline js TValue[] flatten: TValue[](T it) selector
		this.items.flatMap(selector)
		
	// Returns true if the given condition is true for any item in the list
	inline js bool any
		this.items.some(a => a)
		
	// Returns true if the given condition is true for any item in the list
	inline js bool any: bool(T a) predicate // The condition to check
		this.items.some(predicate)
		
	inline js T[] where: bool(T a) predicate // The condition to check
		this.items.filter(predicate)
		
	int count: bool(T a) predicate // The condition to check
		int count = 0
		for items
			if predicate(.)
				count++
		return count
		
	// Returns true if the given condition is true for all items in the list
	inline js bool all
		this.items.every(a => a)
		
	// Returns true if the given condition is true for all items in the list
	inline js bool all: bool(T a) predicate // The condition to check
		this.items.every(predicate)
		
	bool isValid: IntVector2 pos
		return {0,0} <= pos < size
			
global transient unit System
	global inline js void for: IntVector2 subject  // The exclusive upper bound to iterate towards
		                       -> inline void(
		                           IntVector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do                // Do this the given number of times
		for(let _size=subject, y=0; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) do(new IntVector2(x,y), x, y)
			
	global inline js void for: IntVector2 subject  // The exclusive upper bound to iterate towards
		                       <- inline void(
		                           IntVector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do                // Do this the given number of times
		for(let _size=subject, y=_size.y-1; y>=0; --y) for(let x=_size.x-1; x>=0; --x) do(new IntVector2(x,y), x, y)
			
	global inline js void for: Grid<T> subject    // The grid to iterate over
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           IntVector2 pos,
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let i=0, _subject=subject.items, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; if(it) do(it, new IntVector2(i%subject.size.x, Math.floor(i/subject.size.x)), i)}
			
	global inline js void for: Grid<T> subject      // The grid to iterate over
		                       includeEmpty = false // Include items that are null
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           IntVector2 pos,
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _size=subject.size, y=0, _items=subject.items; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) do(_items[y*_size.x + x], new IntVector2(x,y), i)

	global inline js TResult[] for: IntVector2 to     // Iterator over both dimensions of the vector towards this exclusive upper bound
		                            TResult(
		                                IntVector2 it // The current position of the vector we are iterating over with the for-loop
		                            ) do              // Select the field or expression to be included in the result
		IntVector2.enumerate(new IntVector2(0,0), to, do)

	global inline js TResult[] for: IntVector2 from     // Iterator over both dimensions of the vector starting from this vector
		                            TResult(
		                                IntVector2 it   // The current position of the vector we are iterating over with the for-loop
		                            ) do                // Select the field or expression to be included in the result
		                            label IntVector2 to // Iterator over both dimensions of the vector towards this exclusive upper bound
		IntVector2.enumerate(from, to, do)
		
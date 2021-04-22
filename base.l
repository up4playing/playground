// A number stored as a 32-bit integer
struct int
	// The  largest possible value of an integer
	static maxValue = 2147483647
	
	// The  smallest possible value of an integer
	static minValue = -2147483648
	
	// Returns true if the integer is not zero
	inline js bool toBool := this
	
	inline js string toString := this.toString()

// A number stored as a double precision 64-bit floating point value
struct float
	static inline js float infinity := Number.POSITIVE_INFINITY
	
	// Returns true if the floot is not zero
	inline js bool toBool := this != 0
	
	inline js string toString := this.toString()
		
	js float operator **(float a, float b) return Math.pow(a,b)

// A sequence of characters
struct string
	// Returns the number of characters in the string
	inline js int length := this.length
	
	// Returns a string with each character converted to uppercase
	inline js string toUpperCase := this.toUpperCase()
		
	// Returns a string with each character converted to lowercase
	inline js string toLowerCase := this.toLowerCase()
	
	// Returns true if the string is not null and not empty	
	inline js bool toBool := this
	
	inline js int toInt := parseInt(this)
	
	inline js string[] split: string character = " "
		this.split(character)
		
	inline js bool startsWith(string str) (this.indexOf(str) == 0)
		
	inline js int indexOf(string str) this.indexOf(str)
		
	inline js int getCharCodeAt(int index) this.charCodeAt(index)
		
	static inline js string fromCharCode(int charCode) String.fromCharCode(charCode)
		
	inline js string substring: int start
		                        int end
		this.substring(start, end)

// A logical data type that can have the value true or false
enum bool: false, true
		
enum SortingOrder: Ascending, Descending
	
// A data container that grows in size as needed
class List<T>
	// Gets an item from the list
	inline js T get: int index // The index of the item to get
		this[index]
	
	// Sets an item at a given index
	inline js T set: int index // The index of the item to set
	                 T value   // The new value to set
		this[index] = value
	
	inline js T getOrSet: int index      
		                  T initalValue
		this[index] || (this[index] = initalValue)
		
	// Adds an item to the end of the list
	inline js void add: T item // The item to add
		this.push(item)
		
	inline js void setList: T[] list
		this.splice(0, this.length, ...list)
		
	inline js T pop := this.pop()
		
	// Gets the number of items in the list
	inline js int length() this.length
	
	js int setLength: int value
		this.length = value
	
	// Removes all items from the list
	inline js void clear := this.length = 0
		
	// Gets a random item from the list
	T random() := get(Math.randomInteger(length))
		
		
	// Removes an item from the list
	js T remove: T item // The item to remove
		var index = this.indexOf(item);
		if(index > -1) this.splice(index, 1);
			
	// Removes the item at the given index from the list
	js T removeAt: int index // The index of the item to remove
		this.splice(index, 1);
			
	removeWhere: bool(T a) condition // The condition to check
		for i, item -> this
			if condition(item)
				removeAt i
				return item
		return null
		
	// Returns true if the list is not null and not empty	
	inline js bool toBool := (this != null && this.length != 0) 
	
	// Moves an item to the end of the list
	js T moveToEnd: T item // The item to move to the end of the list
		var index = this.indexOf(item);
		if(index > -1) {
			this.splice(index,1);
			this.push(item);
		}
		
	// Sort the list
	inline js void sort
		this.sort()
	
	inline js void sort: float(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
		this.sort(comparer)
	
	// Sort the list by a given expression
	orderBy: float(T a) expression // The expression to order by
		this.sort(expression(a) - expression(b))
		
	// Sort the list by a given expression
	orderBy: float(T a) expression // The expression to order by
		     SortingOrder order    // Specifies if you want to sort in ascending or descending order
		if order == Ascending: this.sort(expression(a) - expression(b))
		else                   this.sort(expression(b) - expression(a))
		
	// Returns true if the given condition is true for any item in the list
	inline js bool any: bool(T a) predicate // The condition to check
		this.some(predicate)
		
	// Returns true if the given condition is true for all items in the list
	inline js bool all: bool(T a) predicate // The condition to check
		this.every(predicate)
		
	inline js T find: bool(T a) condition // The condition to check
		this.find(condition)
		
	inline js T[] filter: bool(T a) condition // The condition to check
		this.filter(condition)
		
	js int sum: int(T a) selector
		let sum = 0
		for(let i=0; i<this.length; i++)
			sum += selector(this[i])
		return sum
		
	shuffle
		for i = 1 <- length
			var j = Math.floor(Math.randomFloat * (i + 1))
			var temp = this.get(i)
			this.set(i, this.get(j))
			this.set(j, temp)
		return this
		
	min: int(T a) selector 
		int resultValue = int.maxValue
		for item -> this
			let value = selector(item)
			if value < resultValue: resultValue = value
		return resultValue
		
	min: int(T a) selector 
		 bool(T a) where
		int resultValue = int.maxValue
		for item -> this if where(item)
			let value = selector(item)
			if value < resultValue: resultValue = value
		return resultValue
		
	max: int(T a) selector
		int resultValue = int.minValue
		for item -> this
			let value = selector(item)
			if value > resultValue: resultValue = value
		return resultValue
		
	max: int(T a) selector
		 bool(T a) where
		int resultValue = int.minValue
		for item -> this if where(item)
			let value = selector(item)
			if value > resultValue: resultValue = value
		return resultValue
		
	withMin: int(T a) selector, int threshold = int.maxValue
		int resultValue = threshold
		T resultItem
		for item -> this
			let value = selector(item)
			if value < resultValue
				resultValue = value
				resultItem = item
		return resultItem
		
	withMin: float(T a) selector, float threshold = float.infinity
		float resultValue = threshold
		T resultItem
		for item -> this
			let value = selector(item)
			if value < resultValue
				resultValue = value
				resultItem = item
		return resultItem
		
	withMax: int(T a) selector 
		int resultValue = int.minValue
		T resultItem
		for item -> this
			let value = selector(item)
			if value > resultValue
				resultValue = value
				resultItem = item
		return resultItem
		
	addRolling: T value
		        int maxValues
		add value
		if length > maxValues: removeAt 0
	
// A data container that stores key-value pairs
class Map<T>

// Specifies that a function doesn't return a value
struct void

// Classes derived from this type can be iterated over
struct iterable	
	
// Denotes a type that can be null
struct Nullable<T>
	
interface object
	inline js bool toBool() (this != null)
	inline js string toString() JSON.stringify(this)
		
// This struct is automatically filled with the source code location
struct SourceCodeLocation
	int row     // The row of the source code
	int column  // The column of the source code
	string file // The filename of the source code
	SourceCodeLocation left, right
	
// A collection of basic system functions
global unit System
	// Executes code depending on whether a given condition is true or false
	global inline js void if: implicit bool condition // The condition to check
	                   void() then             // The code to execute if the condition is true
		if(condition) then()
			
	// Executes code depending on whether a given condition is true or false
	global inline js void if: implicit bool condition // The condition to check
		               void() then                    // The code to execute if the condition is true
		               void() else                    // The code to execute if the condition is false
		if(condition) then() @else else()
			
	// Executes code as long as a given condition is true
	global inline js void while: bool condition // The condition to check
	                      void() block   // The code to execute while to condition is true
		while(condition) block()
	
	// Prints a message to the console
	global js void print: logstring text // The text, variables or expressions to print
		                  SourceCodeLocation location
		log(text, location.row, location.column, location.file)
	
	// Shows a dialog box with a given message
	global inline js void alert: implicit string message // The message to show
		alert(message)
		
	global inline js void break() break
	global inline js void continue() continue
		
// A collection of mathematical functions and constants
unit Math
	// Returns the absolute value
	inline js float abs: float value // The value to return the absolute value of
		Math.abs(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline js int ceil: float value // The value to round up
		Math.ceil(value)
		
	// Returns the largest integer less than or equal to the given value
	inline js int floor: float value // The value to round down
		Math.floor(value)
		
	// Returns the given value rounded to the nearest integer
	inline js int round: float value // The value to round
		Math.round(value)
		
	inline js int min: int a // The first value
		               int b // The second value
		Math.min(a, b)
		
	// Returns the smallest of the given values
	inline js float min: float a // The first value
		                 float b // The second value
		Math.min(a, b)
		
	// Returns the largest of the given values
	inline js int max: int a // The first value
		               int b // The second value
		Math.max(a, b)
		
	// Returns the largest of the given values
	inline js float max: float a // The first value
		                 float b // The second value
		Math.max(a, b)
		
	// Returns the positive square root of the given value
	inline js float sqrt: float value // The value to return the square root of
		Math.sqrt(value)
		
	// The ratio of a circle's circumference to its diameter
	inline js float PI := Math.PI
	
	// Returns the sine of an angle in radians
	inline js float sin: float angle // The angle in radians
		Math.sin(angle)
		
	// Returns the cosine of an angle in radians
	inline js float cos: float angle // The angle in radians
		Math.cos(angle)
		
	// Returns the tangent of an angle in radians
	inline js float tan: float angle // The angle in radians
		Math.tan(angle)
	
	// Returns the arctangent of the quotient of the given values
	inline js float atan2: float2 vector
		Math.atan2(vector.y, vector.x)
		
	js void init
		Math_randomGenerator = Math.random
		
	js string generateRandomSeed:
		if(window.crypto) {
			let out = new Uint8Array(256);
			crypto.getRandomValues(out);
			return out.toString();
		}
		else {
			return Date.now().toString()
		}
		
	js void setRandomSeed: string seed
		// Ported from an algorithm by Johannes Baagøe <baagoe@baagoe.com>
		// https://github.com/nquinlan/better-random-numbers-for-javascript-mirror
		function Alea(seed) {
			var me = this, mash = Mash();
			var count = 0
			me.next = function() {
				var t = 2091639 * me.s0 + me.c * 2.3283064365386963e-10; // 2^-32
				me.s0 = me.s1;
				me.s1 = me.s2;
				var value = me.s2 = t - (me.c = t | 0);
				
				// TEMP: Log every random number
				Network_eventLog += " ["+count+"] "+value;
				count++
				return value
			}
			
			// Apply the seeding algorithm from Baagoe.
			me.c = 1;
			me.s0 = mash(' ');
			me.s1 = mash(' ');
			me.s2 = mash(' ');
			me.s0 -= mash(seed);
			if (me.s0 < 0) { me.s0 += 1; }
			me.s1 -= mash(seed);
			if (me.s1 < 0) { me.s1 += 1; }
			me.s2 -= mash(seed);
			if (me.s2 < 0) { me.s2 += 1; }
			mash = null;
		}
		
		function copy(f, t) {
			t.c = f.c;
			t.s0 = f.s0;
			t.s1 = f.s1;
			t.s2 = f.s2;
			return t;
		}
		
		function Mash() {
			var n = 0xefc8249d;
			var mash = function(data) {
				data = String(data);
				for (var i = 0; i < data.length; i++) {
					n += data.charCodeAt(i);
					var h = 0.02519603282416938 * n;
					n = h >>> 0;
					h -= n;
					h *= n;
					n = h >>> 0;
					h -= n;
					n += h * 0x100000000; // 2^32
				}
				return (n >>> 0) * 2.3283064365386963e-10; // 2^-32
			};
			return mash;
		}
		Math_randomGenerator = new Alea(seed).next
	
	// Generates a random integer
	inline js int randomInteger: int max // The exclusive upper bound of the random integer to generate
		((Math_randomGenerator() * max) | 0)
	
	// Generates a random float
	inline js int randomFloat
		Math_randomGenerator()
	
	float operator °(float angle) return angle*PI/180
	
	inline js int shiftLeft: int value
		                     int count
		(value << count)
	
	inline js int shiftRight: int value
		                      int count
		(value >> count)
		
	moveTowards: float value
		         float targetValue
		         float speed = 1
		if targetValue > value: return Math.min(value + speed, targetValue) else
		if targetValue < value: return Math.max(value - speed, targetValue)
			
	limit: int value
		   int min
		if value < min: return min
			            return value
	
	limit: int value
		   int max
		if value > max: return max
			            return value
	
	limit: int value
		   int min
		   int max
		if value < min: return min
		if value > max: return max
			            return value
	
	limit: float value
		   float min
		if value < min: return min
			            return value
	
	limit: float value
		   float max
		if value > max: return max
			            return value
	
	limit: float value
		   float min
		   float max
		if value < min: return min
		if value > max: return max
			            return value
	
struct RollingList
	public int maxValues = 50
	
	int[] list

	add: int value
		list.add value
		if list.length > maxValues: list.removeAt 0
	
	sum
		let result = 0
		for list: result += l
		return result
	
	average
		return list.length > 0 ? sum / list.length : 0
		
	// Returns true if the rolling list is not empty
	toBool := list.length > 0

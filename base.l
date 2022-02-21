// A number stored as a 32-bit integer
struct int
	// The  largest possible value of an integer
	const maxValue = 2147483647
	
	// The  smallest possible value of an integer
	const minValue = -2147483648
	
	inline js int operator ** (int a, int b) 
		Math.pow(a,b)
		
	js int operator % (int a, int b)
		return ((a % b) + b) % b
		
	// The remainer after a division by the given value. The sign stays the same.
	inline js int remainder: int value
		(this % value)
		
	// Returns true if the integer is not zero
	inline js bool toBool := this
	
	inline js string toString := this.toString()
		
	inline js string formatWithSpaces := this.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
		
	inline js string format: int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString('en-US', {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	// Returns the absolute value
	inline js int abs
		Math.abs(this)
		
	inline js int shiftLeft: int count
		(this << count)
	
	inline js int shiftRight: int count
		(this >> count)
		
	inline js int bitwiseOr: int value
		(this | value)
	
	inline js int bitwiseAnd: int value
		(this & value)
	
	inline js int limit: int min
		(this < min ? min : this)
	
	inline js int limit: int max
		(this > max ? max : this)
	
	inline js int limit: int min
		                 int max
		(this < min ? min : this > max ? max : this)
		
	inline js int setIfLarger: int newValue
		(this = Math.max(newValue, this))
		
	inline js int incrementAndWrap: int max // When the integer reaches this value, it wraps around to zero
		(this = (((this+1) % max) + max) % max)
	
	inline js int incrementUpTo: int max // When the integer reaches this value, it wraps around to zero
		(this < max ? this++ : max)
		
	// inline js int[] to: int max
	// 	(() => {let list=[]; for(let _i=this; _i<max; _i++) list.push(_i); return list})()
	
// A number stored as a double precision 64-bit floating point value
struct float
	const inline js float minValue := Number.MIN_VALUE
	
	const inline js float maxValue := Number.MAX_VALUE
	
	const inline js float infinity := Number.POSITIVE_INFINITY
	
	inline js float operator ** (float a, float b) 
		Math.pow(a,b)
		
	js float operator % (float a, float b)
		return ((a % b) + b) % b
		
	// The remainer after a division by the given value. The sign stays the same.
	inline js float remainder: float value
		(this % value)
		
	// Returns true if the floot is not zero
	inline js bool toBool := this
	
	inline js string toString := this.toString()
		
	inline js string format: int fractionDigits, int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString('en-US', {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	inline js string format: int fractionDigits, bool grouping = false
		this.toLocaleString('en-US', {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, useGrouping:grouping})
		
	inline js string format: int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString('en-US', {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	// Returns the absolute value
	inline js float abs
		Math.abs(this)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline js int ceil
		Math.ceil(this)
		
	// Returns the largest integer less than or equal to the given value
	inline js int floor
		Math.floor(this)
		
	// Returns the given value rounded to the nearest integer
	inline js int round
		Math.round(this)
		
	inline js float limit: float min
		(this < min ? min : this)
	
	inline js float limit: float max
		(this > max ? max : this)
	
	inline js float limit: float min
		                   float max
		(this < min ? min : this > max ? max : this)
		
	inline js bool isApproximately: float value
		                            float epsilon = 0.00001
		(Math.abs(this - value) < epsilon)
		
	inline js bool isAngleApproximately: float value
		                                 float epsilon = 0.0175
		(Math.abs((((this % Math_TwoPI) + Math_TwoPI) % Math_TwoPI) - (((value % Math_TwoPI) + Math_TwoPI) % Math_TwoPI)) < epsilon)
		
// A sequence of characters
js String
class string
	// Returns the number of characters in the string
	inline js int length := this.length
	
	inline js string get(int index) this[index]
	
	// Returns a string with each character converted to uppercase
	inline js string toUpperCase := this.toUpperCase()
		
	// Returns a string with each character converted to lowercase
	inline js string toLowerCase := this.toLowerCase()
	
	// Returns true if the string is not null and not empty	
	inline js bool toBool := this
	
	inline js string toString() this
	
	inline js int toInt := parseInt(this)
		
	inline js int toFloat := parseFloat(this)
	
	inline js string[] split: string character = " "
		this.split(character)
		
	inline js bool startsWith(string str) (this.indexOf(str) == 0)
		
	inline js int indexOf(string str) this.indexOf(str)
		
	inline js bool contains(string str) (this.indexOf(str) != -1)
		
	inline js int getCharCodeAt(int index) this.charCodeAt(index)
		
	static inline js string fromCharCode(int charCode) String.fromCharCode(charCode)
		
	inline js string substring: int start
		this.substring(start)
		
	inline js string substring: int start = 0
		                        int end
		this.substring(start, end)
		
	// Returns 0 for an exact match, 1 if first is larger, -1 if second is larger
	inline js int compareTo: string value // The string to compare to
		this.localeCompare(value)
		
	inline js string trim
		this.trim()
		
	js string getExtension
		let dot = this.lastIndexOf(".")
		if(dot != -1) return this.substring(dot+1)
		else          return ""
		
	inline js string capitalizeFirstCharacter
		(this.length > 0 ? this[0].toUpperCase() + this.substring(1) : this)
		
// A logical data type that can have the value true or false
enum bool: false, true
		
enum SortingOrder: Ascending, Descending
	
// A data container that grows in size as needed
js Array
class List<T>
	// Execute code for each item in a list
	inline js void each -> void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // The code to execute for each item in a list
		for(let i=0, _subject=this, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	inline js void each <- void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // The code to execute for each item in a list
		for(let _subject=this, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
		
	// Adds an item to the end of the list
	inline js void add: T item // The item to add
		this.push(item)
		
	inline js void add: T item
		      int maxLength
		this.push(item)
		if(this.length > maxLength) this.splice(0, 1)
			
	inline js void insert: T item // The item to add
		                   int index
		this.splice(index, 0, item)
		
	// Removes an item from the list
	js void remove: T item // The item to remove
		var index = this.indexOf(item);
		if(index > -1) this.splice(index, 1);
			
	// Removes the item at the given index from the list
	inline js void removeAt: int index // The index of the item to remove
		this.splice(index, 1)
			
	// Removes the item at the given index from the list
	inline js void removeRange: int index // The index of the first item to remove
		                        int count // The number of items to remove
		this.splice(index, count)
			
	T removeFirstWhere: bool(T a) condition // The condition to check
		for this
			if condition(.)
				removeAt i
				return .
		return null
		
	removeAllWhere: bool(T a) condition // The condition to check
		for this <-
			if condition(.)
				removeAt i
		return null
		
	// Adds an item to the list if it isn't already in there
	inline js void ensure: T item // The item to add
		if(this.indexOf(item) == -1) this.push(item)
		
	inline js void addRange: T[] items
		this.push(...items)
			
	inline js bool contains: T item
		(this.indexOf(item) != -1)
		
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
		
	inline js int indexOf: T item
		this.indexOf(item)
		
	inline js void setList: T[] list
		this.splice(0, this.length, ...list)
		
	void setFilteredList: T[] list
		                  bool(T a) condition
		clear
		for list: if condition(.): add .
		
	void setFilteredList: T[] list
		                  bool(T a) condition
		                  int maxCount
		clear
		int count = 0
		for list
			if condition .
				add .
				if ++count >= maxCount: break
		
	inline js T pop := this.pop()
		
	T popWhere: bool(T a) condition
		for length()
			let item = get(i)
			if condition(item)
				removeAt i
				return item
		return null
	
	js T popFront
		if(this.length == 0) return null
		let firstItem = this[0]
		this.splice(0, 1)
		return firstItem
	
	// Gets the number of items in the list
	inline js int length() this.length
	
	js int setLength: int value
		this.length = value
	
	// Removes all items from the list
	inline js void clear := this.length = 0
	
	js string toString()
		let result = "";
		for(let item of this) {
			if(result) result += ", ";
			result += item;
		}
		return "["+result+"]"
		
	// Gets a random item from the list
	T random() := get(Math.randomInteger(length))
		
	T popRandom()
		int index = Math.randomInteger(length)
		T item = get(index)
		this.removeAt(index)
		return item
		
		
	T next: T currentItem
		int index = indexOf(currentItem)
		return this.get((index+1)%length)
		
	T prev: T currentItem
		int index = indexOf(currentItem)
		return index != -1 ? this.get((index-1)%length) : this.get(length-1)
		
	T pickWithinRangeOrClosest: float(T a) selector
		                        float min = -float.infinity
		                        float max = float.infinity
		float closestDistance = float.infinity
		int closestIndex = -1
		T closestItem = null
		for this
			let value = selector(.)
			float distance
			if value > max: distance = value - max; else
			if value < min: distance = min - value; else
				            this.removeAt(i); return .
				
			if distance < closestDistance
				closestDistance = distance
				closestIndex = i
				closestItem = .
		
		if(closestIndex != -1) this.removeAt(closestIndex)
		return closestItem
			
	// Returns true if the list is not null and not empty	
	inline js bool toBool := (this != null && this.length != 0) 
		
	
	// Reverses the order of the items of the list
	inline js T[] reverse() this.reverse()
	
	// Moves an item to the end of the list
	js T moveToBack: T item // The item to move to the end of the list
		var index = this.indexOf(item);
		if(index != -1) {
			let endIndex = this.length-1;
			for(let i=index; i<endIndex; ++i) {
				this[i] = this[i+1]
			}
			this[endIndex] = item
		}
		
	// Moves an item to the end of the list
	js T moveToFront: T item // The item to move to the end of the list
		var index = this.indexOf(item);
		if(index != -1) {
			for(let i=index; i>0; --i) {
				this[i] = this[i-1]
			}
			this[0] = item
		}
		
	// Sort the list
	inline js T[] sort
		this.sort()
	
	inline js T[] sort: float(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
		this.sort(comparer)
	
	// Sort the list by a given expression
	T[] orderBy: float(T a) expression // The expression to order by
		return this.sort(expression(a) - expression(b))
		
	T[] orderBy: string(T a) expression // The expression to order by
		return this.sort(expression(a) compareTo expression(b))
		
	// Sort the list by a given expression
	T[] orderBy: float(T a) expression // The expression to order by
		     SortingOrder order    // Specifies if you want to sort in ascending or descending order
		if order == Ascending: return this.sort(expression(a) - expression(b))
		else                   return this.sort(expression(b) - expression(a))
		
	// Returns true if the given condition is true for any item in the list
	inline js bool any: bool(T a) predicate // The condition to check
		this.some(predicate)
		
	inline js bool none: bool(T a) predicate // The condition to check
		!this.some(predicate)
		
	// Returns true if the given condition is true for all items in the list
	inline js bool all: bool(T a) predicate // The condition to check
		this.every(predicate)
		
	inline js TValue[] select: TValue(T a) selector
		this.map(selector)
		
	inline js T find: bool(T a) condition // The condition to check
		this.find(condition)
		
	int findIndex: bool(T a) condition // The condition to check
		for this
			if condition(.)
				return i
		return -1
		
	inline js T[] where: bool(T a) condition // The condition to check
		this.filter(condition)
		
	inline js T[] take: int count
		this.slice(0, count)
		
	// js int sum: int(T a) selector
	// 	let sum = 0
	// 	for(let i=0; i<this.length; i++)
	// 		sum += selector(this[i])
	// 	return sum
		
	js int sum
		let sum = 0;
		for(let i=0; i<this.length; i++)
			sum += this[i];
		return sum;
	
	js float average
		return this.length > 0 ? this.sum() / this.length : 0
		
	shuffle
		for 1 to length <- i
			var j = Math.floor(Math.randomFloat * (i + 1))
			var temp = this.get(i)
			this.set(i, this.get(j))
			this.set(j, temp)
		return this
		
	private static transient T[] temporaryCopy = null
		
	js T percentile: int value
		if(this.length == 0) return 0
		if(this.length == 1) return this[0]
		if(!List_temporaryCopy) List_temporaryCopy = []
		const len = List_temporaryCopy.length = this.length
		for(let i=0; i<len; ++i) List_temporaryCopy[i] = this[i] 
		List_temporaryCopy.sort((a,b) => a - b)
		return List_temporaryCopy[Math.round((List_temporaryCopy.length-1) * value / 100)]
		
	min: int(T a) selector 
		 int threshold = int.maxValue
		 int default = 0
		int resultValue = threshold
		for this
			let value = selector(.)
			if value < resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	min: float(T a) selector 
		 float threshold = float.maxValue
		 float default = 0
		float resultValue = threshold
		for this
			let value = selector(.)
			if value < resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	min: int(T a) selector 
		 int threshold = int.maxValue
		 int default = 0
		 bool(T a) where
		int resultValue = threshold
		for this
			if where(.)
				let value = selector(.)
				if value < resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	min: float(T a) selector 
		 float threshold = float.maxValue
		 float default = 0
		 bool(T a) where
		float resultValue = threshold
		for this
			if where(.)
				let value = selector(.)
				if value < resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	max: int(T a) selector
		 int threshold = int.minValue
		 int default = 0
		int resultValue = threshold
		for this
			let value = selector(.)
			if value > resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	max: float(T a) selector
		 float threshold = float.minValue
		 float default = 0
		float resultValue = threshold
		for this
			let value = selector(.)
			if value > resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	max: int(T a) selector
		 int threshold = int.minValue
		 int default = 0
		 bool(T a) where
		int resultValue = threshold
		for this 
			if where(.)
				let value = selector(.)
				if value > resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	max: float(T a) selector
		 float threshold = float.minValue
		 float default = 0
		 bool(T a) where
		float resultValue = threshold
		for this
			if where(.)
				let value = selector(.)
				if value > resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	minIndex: int(T a) selector
		      int threshold = int.maxValue
		int resultValue = threshold
		int index = -1
		for this
			let value = selector(.)
			if value < resultValue
				resultValue = value
				index = i
		return index
		
	maxIndex: int(T a) selector
		      int threshold = int.minValue
		int resultValue = threshold
		int index = -1
		for this
			let value = selector(.)
			if value > resultValue
				resultValue = value
				index = i
		return index
		
	withMin: int(T a) selector
		     int threshold = int.maxValue
		int resultValue = threshold
		T resultItem
		for this
			let value = selector(.)
			if value < resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMin: float(T a) selector
		     float threshold = float.maxValue
		float resultValue = threshold
		T resultItem
		for this
			let value = selector(.)
			if value < resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMin: int(T a) selector
		     int threshold = int.maxValue
		     bool(T a) where
		int resultValue = threshold
		T resultItem
		for this
			if where(.)
				let value = selector(.)
				if value < resultValue
					resultValue = value
					resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMin: float(T a) selector
		     float threshold = float.maxValue
		     bool(T a) where
		float resultValue = threshold
		T resultItem
		for this
			if where(.)
				let value = selector(.)
				if value < resultValue
					resultValue = value
					resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMax: int(T a) selector
		     int threshold = int.minValue
		int resultValue = threshold
		T resultItem
		for this
			let value = selector(.)
			if value > resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null
		
		
	withMax: float(T a) selector
		     float threshold = float.minValue
		float resultValue = threshold
		T resultItem
		for this
			let value = selector(.)
			if value > resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMax: int(T a) selector
		     int threshold = int.minValue
		     bool(T a) where
		int resultValue = threshold
		T resultItem
		for this
			if where(.)
				let value = selector(.)
				if value > resultValue
					resultValue = value
					resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMax: float(T a) selector
		     float threshold = float.minValue
		     bool(T a) where
		float resultValue = threshold
		T resultItem
		for this
			if where(.)
				let value = selector(.)
				if value > resultValue
					resultValue = value
					resultItem = .
		return resultValue != threshold ? resultItem : null
		
	count: bool(T a) predicate
		int count = 0
		for this
			if predicate(.)
				count++
		return count
		
	countNot: bool(T a) predicate
		int count = 0
		for this
			if !predicate(.)
				count++
		return count
		
// A data container that stores key-value pairs
js Map
class Map<T>

// Specifies that a function doesn't return a value
struct void

// Classes derived from this type can be iterated over
struct iterable	
	
// Denotes a type that can be null
struct Nullable<T>
	
interface object
	inline js bool toBool() (this != null)
	inline js string toString() object_stringify(this, 3)
		
	static internal js string stringify: object subject, int depth = 0 
		switch(typeof subject)
		{
			case "object":
				if(subject === null) return "null"
				let result = "\{_type:" + subject.constructor.name
				if(depth > 0)
					for(let name in subject)
					{
						let item = object_stringify(subject[name], depth-1)
						if(item != "") result += "," + name + ":" + item
					}
				return result + "\}"
				
			case "string":
				return "\"" + subject + "\""
				
			case "undefined":
				return "\"undefined\""
				
			case "function":
				return ""
				
			default:
				return subject.toString()
		}

		
// This struct is automatically filled with the source code location
transient class SourceCodeLocation
	int row     // The row of the source code
	int column  // The column of the source code
	string file // The filename of the source code
	
	SourceCodeLocation left
	SourceCodeLocation right
	
	js SourceCodeLocation clone 
		return new SourceCodeLocation(this.row, this.column, this.file, this.left, this.right)
		
	void flatten: SourceCodeLocation[] result
		if file:          result.add this
		if left != null:  left.flatten result
		if right != null: right.flatten result
	
js Error
class Error
	string message
	implicit inline js string toString := this.stack
	
// A collection of basic system functions
global transient unit System
	// Executes code depending on whether a given condition is true or false
	global inline js void if: implicit bool condition // The condition to check
		                      void() then             // The code to execute if the condition is true
		if(condition) then()
			
	// Executes code depending on whether a given condition is true or false
	global inline js void if: implicit bool condition // The condition to check
		                      void() then             // The code to execute if the condition is true
		                      void() else             // The code to execute if the condition is false
		if(condition) then() @else else()
			
	// Executes code as long as a given condition is true
	global inline js void while: implicit bool condition // The condition to check
		                         void() do               // The code to execute while to condition is true
		while(condition) do()
	
	// Execute code a given number of times or for each item in a list
	global inline js void for: void subject    // The list to iterate over or the exclusive upper bound to iterate towards
		                       void do         // The code to execute for each item in a list or a given number of times
		
	// Execute code a given number of times or for each item in a list
	global inline js void for: T[] subject    // The list to iterate over
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // The code to execute for each item in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	// Execute code a given number of times or for each item in a list
	global inline js void for: T[] subject    // The list to iterate over
		                       <- void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // The code to execute for each item in a list
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
		
	global inline js void for: int subject    // The exclusive upper bound to iterate towards
		                       -> void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // The code to execute the given number of times
		for(let i=0; i<subject; ++i) do()
		
	global inline js void for: int subject    // The exclusive upper bound to iterate towards
		                       <- void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // The code to execute hte  given number of times
		for(let i=subject-1; i>=0; --i) do()
		
	global inline js void for: int subject
		                       -> void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // The code to execute for each value in the given range
		                       int to         // If specified, we iterate from given start value to this exclusive upper bound 
		for(let i=subject; i<to; ++i) do()
		
	global inline js void for: int subject
		                       <- void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // The code to execute for each value in the given range
		                       int to         // If specified, we iterate from given start value to this exclusive upper bound 
		for(let i=to-1; i>=subject; --i) do()
		
	global inline js void for: string subject
		                       -> void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // The code to execute for each character in the given string
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
	
	global inline js void for: string subject
		                       <- void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // The code to execute for each character in the given string
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
				
	global inline js void for: IntVector2 subject    // The exclusive upper bound to iterate towards
		                       -> void(
		                           IntVector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do           // The code to execute the given number of times
		for(let _size=subject, y=0; y<_size.y; ++y) for(let x=0; x<_size.x; ++x) { let pos = new IntVector2(x,y); do()}
			
	global inline js void for: IntVector2 subject    // The exclusive upper bound to iterate towards
		                       <- void(
		                           IntVector2 pos, // The current position of the vector we are iterating over with the for-loop
		                           int x,          // The x component of the current position we are iterating over with the for-loop
		                           int y           // The y component of the current position we are iterating over with the for-loop
		                       ) do           // The code to execute the given number of times
		for(let _size=subject, y=_size.y-1; y>=0; --y) for(let x=_size.x-1; x>=0; --x) { let pos = new IntVector2(x,y); do()}
			
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:null)
	global inline js void forLookAhead: T[] subject    // The list to iterate over
		                                    -> void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // The code to execute for each consecutive pair in a list
		for(let _subject=subject, _len=_subject.length, i=0; i<_len; ++i) { let it = _subject[i], next = i+1<_len ? _subject[i+1] : null; do()}
		
	global inline js void forLookAhead: T[] subject    // The list to iterate over
		                                    <- void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // The code to execute for each consecutive pair in a list
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) { let it = _subject[i], next = i>0 ? _subject[i-1] : null; do()}
		
	// [a,b,c] -> (prev:null, a), (prev:a, b), (prev:b, c)
	global inline js void forLookBack: T[] subject    // The list to iterate over
		                                    -> void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // The code to execute for each consecutive pair in a list
		for(let i=0, _len=subject.length; i<_len; ++i) { let it = subject[i], prev = i>0 ? subject[i-1] : null; do()}
		
	global inline js void forLookBack: T[] subject    // The list to iterate over
		                                    <- void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // The code to execute for each consecutive pair in a list
		for(let _subject=subject, _len=subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], prev = i+1<_len ? _subject[i+1] : null; do()}
		
	// [a,b,c] -> (prev:null, a, next:b), (prev:a, b, next:c), (prev:b, c, next:null)
	global inline js void forLookAheadAndBack: T[] subject  // The list to iterate over
		                              -> void(
		                                  T it,    // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,  // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,  // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i    // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do         // The code to execute for each triple in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i], next = i+1<_len ? _subject[i+1] : null, prev = i>0 ? _subject[i-1] : null; do()}
		
	global inline js void forLookAheadAndBack: T[] subject  // The list to iterate over
		                              <- void(
		                                  T it,    // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,  // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,  // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i    // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do         // The code to execute for each triple in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], next = i>0 ? _subject[i-1] : null, prev = i+1<_len ? _subject[i+1] : null; do()}
		
	// [a,b,c] -> (a, next:b), (b, next:c)
	global inline js void forPairs: T[] subject  // The list to iterate over
		                            -> void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // The code to execute for each consecutive pair in a list
		for(let i=0, _subject=subject, _len=_subject.length-1; i<_len; ++i) { let it = _subject[i], next = _subject[i+1]; do()}
		
	global inline js void forPairs: T[] subject  // The list to iterate over
		                            <- void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // The code to execute for each consecutive pair in a list
		for(let _subject=subject, i=_subject.length-1; i>0; --i) { let it = _subject[i], next = _subject[i-1]; do()}
		
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:a) 
	global inline js void forWrappingPairs: T[] subject    // The list to iterate over
		                                   -> void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // The code to execute for each consecutive pair in a list
		for(let _subject=subject, i=0, _len=_subject.length; i<_len; ++i) { let it = _subject[i], next = _subject[(i+1)%_len]; do()}
		
	global inline js void forWrappingPairs: T[] subject    // The list to iterate over
		                                   <- void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // The code to execute for each consecutive pair in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], next = _subject[(((i-1)%_len)+_len)%_len]; do()}
		
	// [a,b,c] -> (prev:a, b, next:c)
	global inline js void forTriples: T[] subject  // The list to iterate over
		                              -> void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // The code to execute for each triple in a list
		for(let i=1, _subject=subject, _len=_subject.length-1; i<_len; ++i) { let it = _subject[i], next = _subject[i+1], prev = _subject[i-1]; do()}
		
	global inline js void forTriples: T[] subject  // The list to iterate over
		                              <- void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // The code to execute for each triple in a list
		for(let _subject=subject, i=_subject.length-2; i>=1; --i) { let it = _subject[i], next = _subject[i-1], prev = _subject[i+1]; do()}
		
	// [a,b,c] -> (prev:c, a, next:b), (prev:a, b, next:c), (prev:b, c, next:a)
	global inline js void forWrappingTriples: T[] subject  // The list to iterate over
		                                     -> void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // The code to execute for each triple in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i], next = _subject[(i+1)%_len], prev = _subject[(((i-1)%_len)+_len)%_len]; do()}
		
	global inline js void forWrappingTriples: T[] subject  // The list to iterate over
		                                     <- void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // The code to execute for each triple in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], next = _subject[(((i-1)%_len)+_len)%_len], prev = _subject[(i+1)%_len]; do()}

	global inline js void forCentered: T[] subject  // The list to iterate over
		                               Vector2 center = {0,0}
		                               Vector2 delta = {100,0}
		                               -> void(
		                                   T it,    // The current item of the list we are iterating over with forCentered
		                                   Vector2 pos,
		                                   int i    // The index of the current item of the list we are iterating over with forCentered
		                               ) do         // The code to execute for each item in a list
		for(let i=0, _subject=subject, _center = center, _delta = delta, _len=_subject.length, _x = _center.x-(_len-1)*_delta.x/2, _y=_center.y-(_len-1)*_delta.y/2; i<_len; ++i, _x += _delta.x, _y += _delta.y) { let it = _subject[i], pos = new Vector2(_x, _y, _center.location || _delta.location ? new SourceCodeLocation(0, 0, null, _center.location, _delta.location) : null); do()}
		
	// Prints a message to the console
	global js void print: logstring text // The text, variables or expressions to print
		                  SourceCodeLocation location
		log(text, location.row, location.column, location.file, Network_frame)
	
	// Display a message in the timeline
	global js void watch: string text // The text to display
		                  SourceCodeLocation location
		if(Platform_isDebug && Network_frame >= Network_frameWithNewWatches) {
			Platform_sendWatch(Network_frame, text, location.row, location.column, location.file)
		}
	
	// Shows a dialog box with a given message
	global inline js void alert: implicit string message // The message to show
		alert(message)
		
	global inline js void break() break
	global inline js void continue() continue
		
	global inline js void try: void() code
		                       nocolon void(Error error) catch
		try code() @catch(error) catch()
		
		
// A collection of mathematical functions and constants
unit Math
	// Returns the absolute value
	inline js int abs: int value // The value to return the absolute value of
		Math.abs(value)
		
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
	float PI = 3.141592653589793
	
	// The ratio of a circle's radius to its diameter
	float TwoPI = 6.283185307179586
	
	// Returns the sine of an angle in radians
	inline js float sin: float angle // The angle in radians
		Math.sin(angle)
		
	// Returns the cosine of an angle in radians
	inline js float cos: float angle // The angle in radians
		Math.cos(angle)
		
	// Returns the tangent of an angle in radians
	inline js float tan: float angle // The angle in radians
		Math.tan(angle)
		
	init
		initDefaultRandomGenerator
		
	js void initDefaultRandomGenerator
		Math_randomGenerator = Math.random
		
	js string generateRandomSeed:
		let crypto = !window.crypto && typeof(require) != "undefined" ? require("crypto") : window.crypto
		if(crypto) {
			let out = new Uint8Array(256);
			crypto.getRandomValues(out);
			return out.toString();
		}
		
	internal string randomSeed
	internal int randomValueIndex
	transient internal float[] randomValues
	
	internal recreateRandomValues
		let targetRandomValueIndex = randomValueIndex
		setRandomSeed randomSeed
		for targetRandomValueIndex: randomFloat
	
	js void setRandomSeed: string seed
		Math_randomSeed = seed
		Math_randomValues.length = 0
		Math_randomValueIndex = 0
		
		// Ported from an algorithm by Johannes Baagøe <baagoe@baagoe.com>
		// https://github.com/nquinlan/better-random-numbers-for-javascript-mirror
		function Alea(seed) {
			var me = this, mash = Mash();
			var count = 0
			me.next = function() {
				if(Math_randomValueIndex < Math_randomValues.length) {
					var value = Math_randomValues[Math_randomValueIndex]
					
					// TEMP: Log every random number
					Network_eventLog += " ["+Math_randomValueIndex+"/"+Math_randomValues.length+"] replay "+value;
					
					Math_randomValueIndex++
				} else {
					var t = 2091639 * me.s0 + me.c * 2.3283064365386963e-10; // 2^-32
					me.s0 = me.s1;
					me.s1 = me.s2;
					var value = me.s2 = t - (me.c = t | 0);
					
					// TEMP: Log every random number
					Network_eventLog += " rnd("+Math_randomValueIndex+"/"+Math_randomValues.length+"):"+value;
					if(Math_randomValueIndex != Math_randomValues.length) {
						Network_eventLog += " INVALID rnd"
						alert("Random values out of sync. Please click 'Save Logs' and send me the log file that will be created.")
					}
					
					Math_randomValues[Math_randomValueIndex++] = value;
				}
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
			
	interpolate: float value
		         float fromStart = 0
		         float fromEnd = 1
		         float toStart = 0
		         float toEnd = 1
		if value < fromStart: return toStart
		if value > fromEnd:   return toEnd
			                  return toStart + (toEnd-toStart) * (value-fromStart)/(fromEnd-fromStart)
	
transient class Time
	inline js int year := this.getFullYear()
	inline js int month := (this.getMonth()+1)
	inline js int date := this.getDate()
	inline js int day := this.getDay()
		
	inline js int hour := this.getHours()
	inline js int minute := this.getMinutes()
	inline js int second := this.getSeconds()
		
	inline js string twoDigitMonth := (this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitDate := this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitDay := this.getDay().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitHour := this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitMinute := this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitSecond := this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	inline js string dayMonthYearString := (this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear())
	inline js string dayLongMonthNameYearString := (this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+" "+this.toLocaleString('en-US', {month: 'long'})+" "+this.getFullYear())
	inline js string dayShortMonthNameYearString := (this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+" "+this.toLocaleString('en-US', {month: 'short'})+" "+this.getFullYear())
	inline js string hourMinuteSecondString := (this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2}))+"-"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string dayMonthYearHourMinuteSecondString := (this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2}))+"-"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	inline js int time := this.getTime()
		
	static inline js Time current := new Date()
		
	static inline js Time fromTicks(int ticks) new Date(ticks)
	
	// The current frame	
	static inline js int frame := Network_frame
		
	// The number of milliseconds elapsed since January 1, 1970
	static int now
	
	static inline js float preciseTime := performance.now()
		
	static measure: void() code
		let startTime = preciseTime
		code
		return preciseTime - startTime
		
	static js string dateAndTimeString
		let d = new Date()
		let min = d.getMinutes()
		return d.getDate()+"."+(d.getMonth()+1)+"."+d.getFullYear()+" "+d.getHours()+":"+(min < 10 ? "0"+min : min)


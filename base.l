// A number stored as a 32-bit integer
struct int
	// The largest possible integer value
	const maxValue = 2147483647
	
	// The smallest possible integer value
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
		                 int max
		(this < min ? min : this > max ? max : this)
		
	inline js int limit: int max
		(this > max ? max : this)
	
	inline js int limit: int min
		(this < min ? min : this)
	
	inline js int setIfLarger: int newValue
		(this = Math.max(newValue, this))
		
	inline js int incrementAndWrap: int max // When the integer reaches this value, it wraps around to zero
		(this = (((this+1) % max) + max) % max)
	
	inline js int decrementAndWrap: int max // When the integer reaches this value, it wraps around to zero
		(this = (((this-1) % max) + max) % max)
	
	inline js int incrementUpTo: int max
		(this < max ? ++this : max)
		
	inline js int incrementUpToExclusive: int max
		(this < max-1 ? ++this : max-1)
		
	inline js int decrementDownTo: int min
		(this > min ? --this : min)
		
	inline js int decrementDownToExclusive: int min
		(this > min+1 ? --this : min+1)
		
	inline js bool within: Range range
		(this >= range.from && this < range.to)
		
	inline js bool withinInclusively: Range range
		(this >= range.from && this <= range.to)
	
// A number stored as a double precision 64-bit floating point value
struct float
	// The largest possible floating point value
	const inline js float maxValue := Number.MAX_VALUE
	
	// The smallest possible floating point value
	const inline js float minValue := -Number.MAX_VALUE
	
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
		                   float max
		(this < min ? min : this > max ? max : this)
		
	inline js float limit: float max
		(this > max ? max : this)
	
	inline js float limit: float min
		(this < min ? min : this)
	
	inline js bool isApproximately: float value
		                            float epsilon = 0.00001
		(Math.abs(this - value) < epsilon)
		
	inline js bool isAngleApproximately: float value
		                                 float epsilon = 0.0175
		(Math.abs((((this % Math_TwoPI) + Math_TwoPI) % Math_TwoPI) - (((value % Math_TwoPI) + Math_TwoPI) % Math_TwoPI)) < epsilon)
		
	inline js float moveTowards: float value
		                         float speed
		(this < value ? (this + speed < value ? (this += speed) : (this = value)) : (this - speed > value ? (this -= speed) : (this = value)))
		
	inline js float interpolateTo: float target
		                           float value
		(this + (target - this)*value)
		
	inline js float interpolateTo: float target
		                           float value
		                           EaseFunction ease
		(this + (target - this)*ease.function.invoke(value))
		
	// ------------------------------------------- Time -------------------------------------------
	
	implicit inline js Time toTime() this
	
	// Milliseconds
	inline js Time ms := this
	
	// Seconds
	inline js Time s := (this*1000)
		
	// Minutes
	inline js Time min := (this*60000)
		
	// Hours
	inline js Time h := (this*3600000)
	
	// Days
	inline js Time days := (this*86400000)
	
	// Weeks	
	inline js Time weeks := (this*604800000)
		
	// ------------------------------------------- Angle -------------------------------------------
	
	implicit inline js Angle toAngle() this
	
	inline js Angle operator °(float angle) (angle/360)
	
	// Turns (one full rotation is 1)
	inline js Angle turns() this
	
	// Radians (one full rotation is 1π) 
	inline js Angle rad() (this/Math_TwoPI)
		
	// Degrees (one full rotation is 360)
	inline js Angle deg() (this/360)
		
	// Gradians (one full rotation is 360)
	inline js Angle grad() (this/400)
		
class EaseFunction
	float(float value) function
	
	global const EaseFunction None    = { . }
	global const EaseFunction InQuad  = { . * . }
	global const EaseFunction OutBack = { 1 + 2.70158 * Math.pow(. - 1, 3) + 1.70158 * Math.pow(. - 1, 2) }
	
// A sequence of characters
js String
class string
	// Returns the number of characters in the string
	inline js int length := this.length
	
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
	inline js int indexOf(string str, int startPos) this.indexOf(str, startPos)
		
	inline js bool contains(string str) (this.indexOf(str) != -1)
		
	inline js int getCharCodeAt(int index) this.charCodeAt(index)
		
	static inline js string fromCharCode(int charCode) String.fromCharCode(charCode)
		
	inline js string substring: int start
		this.substring(start)
		
	inline js string substring: int start = 0
		                        int end
		this.substring(start, end)
		
	js string getUntil: string value
		                int start = 0
		let index = this.indexOf(value)
		if(index != -1) return this.substring(start, index)
		else            return this
		
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
		
	inline js string interleaveWith: int charCode
		this.split("").join(String.fromCharCode(charCode))
		
	inline js string replace: string source
		                      string target
		this.replace(new RegExp(source, "g"), target)
		
	js string get: int index
		return index >= 0 ? this[index] : this[this.length+index]
	
	js string get: int from = 0
		           int to
		return this.substring(from >= 0 ? from : this.length+from, to >= 0 ? to : this.length+to)
		
	js string get: int from = 0
		return this.substring(from >= 0 ? from : this.length+from)	
	
		
// A logical data type that can have the value true or false
enum bool: false, true
		
enum SortingOrder: Ascending, Descending
	
// A data container that grows in size as needed
js Array
class List<T>
	// Do something for each item in a list
	inline js void each -> void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let i=0, _subject=this, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	inline js void each <- void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let _subject=this, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	inline js void eachChangable -> void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let i=0, _subject=[...this], _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	inline js void eachChangable <- void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let _subject=[...this], i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
		
	// Adds an item to the end of the list
	inline js void add: T item // The item to add
		this.push(item)
		
	inline js void add: T item
		      int maxLength
		this.push(item)
		if(this.length > maxLength) this.splice(0, 1)
			
	inline js void insert: T item // The item to add
		                   index = 0
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
		
	removeWhere: bool(T a) condition // The condition to check
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
		
	inline js T popAt: int index
		this.splice(index, 1)[0]
		
	inline js T[] popRange: int index
		                    int count
		this.splice(index, count)
		
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
	
	inline js T[] clone() [...this]
	
	js string toString()
		let result = "";
		for(let item of this) {
			if(result) result += ", ";
			result += item;
		}
		return "["+result+"]"
		
	// Gets a random item from the list
	T random()
		let randomInteger = Math.randomInteger(length)
		// print randomInteger, length
		return get(randomInteger)
		
	T popRandom()
		int index = Math.randomInteger(length)
		T item = get(index)
		this.removeAt(index)
		return item
		
		
	T next: T currentItem
		int index = indexOf(currentItem)
		return this.get((index+1)%length)
		
	T next: T currentItem
		    bool(T item) where
		int baseIndex = indexOf(currentItem)
		for this.length
			let item = this.get((baseIndex+i+1)%length)
			if(where(item)) return item
		return null
		
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
	
	// Reverses the order of the items of the list in place
	inline js T[] reverse() this.reverse()
		
	// Return a list with all unique items of the original list
	inline js T[] distinct() [...new Set(this)]
	
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
		this.sort((a,b) => a - b)
	
	inline js T[] sort: float(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
		this.sort(comparer)
	
	inline js T[] sort: Time(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
		this.sort(comparer)
	
	// Sort the list by a given expression
	T[] orderBy: float(T a) expression // The expression to order by
		return this.sort(expression(a) - expression(b))
		
	T[] orderBy: Time(T a) expression // The expression to order by
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
		
	int indexWhere: bool(T a) condition // The condition to check
		for this
			if condition(.)
				return i
		return -1
		
	int indexWhere: <- bool(T a) condition // The condition to check
		for this <-
			if condition(.)
				return i
		return -1
		
	inline js T[] where: bool(T a) condition // The condition to check
		this.filter(condition)
		
	inline js T[] take: int count
		this.slice(0, count)
		
	inline js T[] subList: int start, int count
		this.slice(start, count)
		
	js int total: int(T a) selector
		let sum = 0
		for(let i=0; i<this.length; i++)
			sum += selector(this[i])
		return sum
		
	js int sum
		let sum = 0;
		for(let i=0; i<this.length; i++)
			sum += this[i];
		return sum;
	
	js float average
		return this.length > 0 ? this.sum() / this.length : 0
		
	string concat: string(T a) selector
		           string separator = ", "
		let result = ""
		for this
			if result: result += separator
			result += selector(.)
		return result
		
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
		
	max: Time(T a) selector
		 Time threshold = float.minValue
		 Time default = 0
		Time resultValue = threshold
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
		
	max: Time(T a) selector
		 Time threshold = float.minValue
		 Time default = 0
		 bool(T a) where
		Time resultValue = threshold
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
		
	withMin: Time(T a) selector
		     Time threshold = float.maxValue
		Time resultValue = threshold
		T resultItem
		for this
			let value = selector(.)
			if value < resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMin: int(T a) selector
		     int threshold = int.maxValue
		     label bool(T a) where
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
		     label bool(T a) where
		float resultValue = threshold
		T resultItem
		for this
			if where(.)
				let value = selector(.)
				if value < resultValue
					resultValue = value
					resultItem = .
		return resultValue != threshold ? resultItem : null
		
	withMin: Time(T a) selector
		     Time threshold = float.maxValue
		     bool(T a) where
		Time resultValue = threshold
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
		
	withMax: Time(T a) selector
		     Time threshold = float.minValue
		Time resultValue = threshold
		T resultItem
		for this
			let value = selector(.)
			if value > resultValue
				resultValue = value
				resultItem = .
		return resultValue != threshold ? resultItem : null
		
	popMax: int(T a) selector
		    int threshold = int.minValue
		int resultValue = threshold
		T resultItem = null
		int resultIndex = -1
		for this
			let value = selector(.)
			if value > resultValue
				resultValue = value
				resultItem = .
				resultIndex = i
				
		if resultIndex != -1: removeAt resultIndex
		return resultItem
		
	popMax: int(T a) selector
		    float threshold = float.minValue
		float resultValue = threshold
		T resultItem = null
		int resultIndex = -1
		for this
			let value = selector(.)
			if value > resultValue
				resultValue = value
				resultItem = .
				resultIndex = i
				
		if resultIndex != -1: removeAt resultIndex
		return resultItem
		
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
		
	rotate
		insert pop
		
	js T[] intersectWith: T[] other
		const a = this || []
		const b = other || []
		const result = [];
		const map = {};
		for (let i = 0, length = b.length; i < length; ++i) {
			map[b[i]] = true;
		}
		for (let i = 0, length = a.length; i < length; ++i) {
			if (a[i] in map) result.push(a[i]);
		}
		return result;
		
	// Gets an item from the list
	js T get: implicit int index // The index of the item to get
		return index >= 0 ? this[index] : this[this.length+index]
		
	js T get: int from = 0
		             int to
		return this.slice(from, to)
	
	js T get: int from = 0
		return this.slice(from)
	
	js T set: int index // The index of the item to set
		      T value   // The new value to set
		return index >= 0 ? this[index] = value : this[this.length+index] = value
		
	// Tries to get an item from the list. If it doesn't exist, it sets it.
	// TODO: Support index with side effect (e.g. list[index++] ?= 0)
	inline js T getOrSet: int index
		                  T value
		(this.hasOwnProperty(index) ? this[index] : this[index] = value)
		
	// Add a value to an item of the list
	js T addToItem: int index // The index of the item to change
		            T value   // The value to add to the item
		return index >= 0 ? this[index] += value : this[this.length+index] += value
		
	// Subtract a value from an item of the list
	js T subtractFromItem: int index // The index of the item to change
		                   T value   // The value to subtract from the item
		return index >= 0 ? this[index] -= value : this[this.length+index] -= value
		
	// Multiply an item of the list by a value
	js T multiplyItem: int index // The index of the item to change
		               T value   // The value to multiply the item by
		return index >= 0 ? this[index] *= value : this[this.length+index] *= value
		
	// Divide an item of the list by a value
	js T divideItem: int index // The index of the item to change
		             T value   // The value to divide the item by
		return index >= 0 ? this[index] /= value : this[this.length+index] /= value
		
	// Add 1 to item of the list
	js T incrementItem: int index // The index of the item to change
		return index >= 0 ? this[index]++ : this[this.length+index]++
	
	// Subtract 1 from an item of the list
	js T decrementItem: int index // The index of the item to change
		return index >= 0 ? this[index]-- : this[this.length+index]--
		
// A data container that stores key-value pairs
js Map
class Map<TKey, TValue>
	inline js TValue get: TKey key
		this.get(key)
	inline js void set: TKey key
		                TValue value
		this.set(key, value)

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
	string file
	int start
	int end
	SourceCodeLocation left
	SourceCodeLocation right
	
	inline js bool toBool() (this != null)
	
	SourceCodeLocation clone := {file, start, end, left, right}
			
	SourceCodeLocation find: string file, int pos
		if this.file and this.file == file and pos >= this.start and pos <= this.end
			return this
		if left != null
			let result = left.find file, pos
			if result != null: return result
		if right != null
			let result = right.find file, pos
			if result != null: return result
		return null
			
	SourceCodeLocation find: SourceCodeLocation location
		if file == location.file and start == location.start and end == location.end
			return this
		if left != null
			let result = left.find location
			if result != null: return result
		if right != null
			let result = right.find location
			if result != null: return result
		return null
		
	SourceCodeLocation leaf
		if file: return this
		if right
			let result = right.leaf
			if result: return result
		if left
			let result = left.leaf
			if result: return result
		return null
		
js Error
class Error
	string message
	string stack
	implicit inline js string toString := this.stack
	
// A collection of basic system functions
global transient unit System
	// Executes code depending on whether a given condition is true or false
	global inline js void if: implicit bool condition // The condition to check
		                      void() then             // Do this if the condition is true
		if(condition) then()
			
	// Executes code depending on whether a given condition is true or false
	global inline js void if: implicit bool condition // The condition to check
		                      void() then             // Do this if the condition is true
		                      void() else             // Do this if the condition is false
		if(condition) then() @else else()
			
	// Executes code as long as a given condition is true
	global inline js void while: implicit bool condition // The condition to check
		                         void() do               // Do this while to condition is true
		while(condition) do()
			
	global inline js void loop: void() do
		for(;;) do()
	
	global inline js void do: void() do                   // Do this while to condition is true
		                      nolabel implicit bool while // The condition to check
		@do do() 
		@while(while)
	
	// Do something a given number of times or for each item in a list
	global inline js void for: void subject    // The list to iterate over or the exclusive upper bound to iterate towards
		                       void do         // Do this for each item in a list or a given number of times
		
	// Do something a given number of times or for each item in a list
	global inline js void for: T[] subject    // The list to iterate over
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	// Do something a given number of times or for each item in a list
	global inline js void for: T[] subject    // The list to iterate over
		                       <- void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	global inline js void forChangeable: T[] subject    // The list to iterate over
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let i=0, _subject=[...subject], _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	global inline js void forChangeable: T[] subject    // The list to iterate over
		                       <- void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _subject=[...subject], i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
		
	global inline js void for: int subject    // The exclusive upper bound to iterate towards
		                       -> void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this the given number of times
		for(let i=0; i<subject; ++i) do()
		
	global inline js void for: int subject    // The exclusive upper bound to iterate towards
		                       <- void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this the given number of times
		for(let i=subject-1; i>=0; --i) do()
		
	global inline js void for: int subject
		                       -> void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this for each value in the given range
		                       int to         // If specified, we iterate from given start value to this exclusive upper bound 
		for(let i=subject; i<to; ++i) do()
		
	global inline js void for: int subject
		                       <- void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this for each value in the given range
		                       int to         // If specified, we iterate from given start value to this exclusive upper bound 
		for(let i=to-1; i>=subject; --i) do()
		
	global inline js void for: string subject
		                       -> void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // Do this for each character in the given string
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
	
	global inline js void for: string subject
		                       <- void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // Do this for each character in the given string
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
				
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:null)
	global inline js void forLookAhead: T[] subject    // The list to iterate over
		                                    -> void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, _len=_subject.length, i=0; i<_len; ++i) { let it = _subject[i], next = i+1<_len ? _subject[i+1] : null; do()}
		
	global inline js void forLookAhead: T[] subject    // The list to iterate over
		                                    <- void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) { let it = _subject[i], next = i>0 ? _subject[i-1] : null; do()}
		
	// [a,b,c] -> (prev:null, a), (prev:a, b), (prev:b, c)
	global inline js void forLookBack: T[] subject    // The list to iterate over
		                                    -> void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // Do this for each consecutive pair in a list
		for(let i=0, _len=subject.length; i<_len; ++i) { let it = subject[i], prev = i>0 ? subject[i-1] : null; do()}
		
	global inline js void forLookBack: T[] subject    // The list to iterate over
		                                    <- void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, _len=subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], prev = i+1<_len ? _subject[i+1] : null; do()}
		
	// [a,b,c] -> (prev:null, a, next:b), (prev:a, b, next:c), (prev:b, c, next:null)
	global inline js void forLookAheadAndBack: T[] subject  // The list to iterate over
		                              -> void(
		                                  T it,    // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,  // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,  // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i    // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do         // Do this for each triple in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i], next = i+1<_len ? _subject[i+1] : null, prev = i>0 ? _subject[i-1] : null; do()}
		
	global inline js void forLookAheadAndBack: T[] subject  // The list to iterate over
		                              <- void(
		                                  T it,    // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,  // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,  // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i    // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do         // Do this for each triple in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], next = i>0 ? _subject[i-1] : null, prev = i+1<_len ? _subject[i+1] : null; do()}
		
	// [a,b,c] -> (a, next:b), (b, next:c)
	global inline js void forPairs: T[] subject  // The list to iterate over
		                            -> void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // Do this for each consecutive pair in a list
		for(let i=0, _subject=subject, _len=_subject.length-1; i<_len; ++i) { let it = _subject[i], next = _subject[i+1]; do()}
		
	global inline js void forPairs: T[] subject  // The list to iterate over
		                            <- void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // Do this for each consecutive pair in a list
		for(let _subject=subject, i=_subject.length-1; i>0; --i) { let it = _subject[i], next = _subject[i-1]; do()}
		
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:a) 
	global inline js void forWrappingPairs: T[] subject    // The list to iterate over
		                                   -> void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, i=0, _len=_subject.length; i<_len; ++i) { let it = _subject[i], next = _subject[(i+1)%_len]; do()}
		
	global inline js void forWrappingPairs: T[] subject    // The list to iterate over
		                                   <- void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], next = _subject[(((i-1)%_len)+_len)%_len]; do()}
		
	// [a,b,c] -> (prev:a, b, next:c)
	global inline js void forTriples: T[] subject  // The list to iterate over
		                              -> void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // Do this for each triple in a list
		for(let i=1, _subject=subject, _len=_subject.length-1; i<_len; ++i) { let it = _subject[i], next = _subject[i+1], prev = _subject[i-1]; do()}
		
	global inline js void forTriples: T[] subject  // The list to iterate over
		                              <- void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // Do this for each triple in a list
		for(let _subject=subject, i=_subject.length-2; i>=1; --i) { let it = _subject[i], next = _subject[i-1], prev = _subject[i+1]; do()}
		
	// [a,b,c] -> (prev:c, a, next:b), (prev:a, b, next:c), (prev:b, c, next:a)
	global inline js void forWrappingTriples: T[] subject  // The list to iterate over
		                                     -> void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // Do this for each triple in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i], next = _subject[(i+1)%_len], prev = _subject[(((i-1)%_len)+_len)%_len]; do()}
		
	global inline js void forWrappingTriples: T[] subject  // The list to iterate over
		                                     <- void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // Do this for each triple in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], next = _subject[(((i-1)%_len)+_len)%_len], prev = _subject[(i+1)%_len]; do()}

	// Prints a message to the console
	global js void print: logstring text // The text, variables or expressions to print
		                  SourceCodeLocation location
		log(text, location.row, location.column, location.file)
	
	// Display a message in the timeline
	global js void watch: logstring text // The text, variables or expressions to watch
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
global skipInit unit Math
	// Returns the absolute value
	global inline js int abs: int value // The value to return the absolute value of
		Math.abs(value)
		
	// Returns the absolute value
	global inline js float abs: float value // The value to return the absolute value of
		Math.abs(value)
		
	// Returns the absolute value
	global inline js Angle abs: Angle value // The angle to return the absolute value of
		Math.abs(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	global inline js int ceil: float value // The value to round up
		Math.ceil(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	global inline js Time ceil: Time value // The value to round up
		Math.ceil(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	global inline js Angle ceil: Angle value // The angle to round up
		Math.ceil(value)
		
	// Returns the largest integer less than or equal to the given value
	global inline js int floor: float value // The value to round down
		Math.floor(value)
		
	// Returns the largest integer less than or equal to the given value
	global inline js Time floor: Time value // The value to round down
		Math.floor(value)
		
	// Returns the largest integer less than or equal to the given value
	global inline js Angle floor: Angle value // The angle to round down
		Math.floor(value)
		
	// Returns the given value rounded to the nearest integer
	global inline js int round: float value // The value to round
		Math.round(value)
		
	// Returns the given value rounded to the nearest integer
	global inline js Angle round: Angle value // The angle to round
		Math.round(value)
		
	// Returns the given value rounded to the nearest integer
	global inline js Time round: Time value // The angle to round
		Math.round(value)
		
	global inline js int min: int a // The first value
		                      int b // The second value
		Math.min(a, b)
		
	// Returns the smallest of the given values
	global inline js float min: float a // The first value
		                        float b // The second value
		Math.min(a, b)
		
	// Returns the smallest of the given values
	global inline js Angle min: Angle a // The first angle
		                        Angle b // The second angle
		Math.min(a, b)
		
	// Returns the largest of the given values
	global inline js int max: int a // The first value
		                      int b // The second value
		Math.max(a, b)
		
	// Returns the largest of the given values
	global inline js float max: float a // The first value
		                        float b // The second value
		Math.max(a, b)
		
	// Returns the largest of the given values
	global inline js Angle max: Angle a // The first angle
		                        Angle b // The second angle
		Math.max(a, b)
		
	// Returns the positive square root of the given value
	inline js float sqrt: float value // The value to return the square root of
		Math.sqrt(value)
		
	inline js float pow: float base
		                 float exponent
		Math.pow(base, exponent)
		
	// The ratio of a circle's circumference to its diameter
	float PI = 3.141592653589793
	
	// The ratio of a circle's radius to its diameter
	float TwoPI = 6.283185307179586
	
	internal inline js float nativeSin: float angle // The angle in radians
		Math.sin(angle)
		
	internal inline js float nativeCos: float angle // The angle in radians
		Math.cos(angle)
		
	internal inline js float nativeTan: float angle // The angle in radians
		Math.tan(angle)
		
	// Returns the sine of an angle in turns
	sin: Angle angle // The angle in turns (one full rotation is 1)
	    float result = cast(angle - .5 - Math.floor(angle))
	    result *= 16 * (Math.abs(result) - .5)
	    result += .225 * result * (Math.abs(result) - 1)
	    return result

	// Returns the cosine of an angle in turns
	cos: Angle angle // The angle in turns (one full rotation is 1)
	    float result = cast(angle - .25 - Math.floor(angle + .25))
	    result *= 16 * (Math.abs(result) - .5)
	    result += .225 * result * (Math.abs(result) - 1)
	    return result
	
	// Returns the tangent of an angle in turns
	tan: Angle angle
		return sin(angle) / cos(angle)
		
	// Returns the inverse tangent in turns
	Angle atan2: float y, float x
		float r, angle;
		float abs_y = Math.abs(y) + .00000000001
		if x < 0.0
			r = (x + abs_y) / (abs_y - x);
			angle = .375;
		else
			r = (x - abs_y) / (x + abs_y);
			angle = .125;
		angle += (.03124211533 * r * r - .1562424076) * r;
		if y < 0.0: return cast -angle
		else        return cast angle
		
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
		
		// Seeding the random number generator in Javascript
		// https://stackoverflow.com/a/47593316
		function xmur3(str) {
		    for(var i = 0, h = 1779033703 ^ str.length; i < str.length; i++) {
		        h = Math.imul(h ^ str.charCodeAt(i), 3432918353);
		        h = h << 13 | h >>> 19;
		    } return function() {
		        h = Math.imul(h ^ (h >>> 16), 2246822507);
		        h = Math.imul(h ^ (h >>> 13), 3266489909);
		        return (h ^= h >>> 16) >>> 0;
		    }
		}
		
		function sfc32(a, b, c, d) {
		    return function() {
		      a >>>= 0; b >>>= 0; c >>>= 0; d >>>= 0; 
		      var t = (a + b) | 0;
		      a = b ^ b >>> 9;
		      b = c + (c << 3) | 0;
		      c = (c << 21 | c >>> 11);
		      d = d + 1 | 0;
		      t = t + d | 0;
		      c = c + t | 0;
		      return (t >>> 0) / 4294967296;
		    }
		}
		
		function mulberry32(a) {
		    return function() {
		      var t = a += 0x6D2B79F5;
		      t = Math.imul(t ^ t >>> 15, t | 1);
		      t ^= t + Math.imul(t ^ t >>> 7, t | 61);
		      return ((t ^ t >>> 14) >>> 0) / 4294967296;
		    }
		}
		
		var seed = xmur3(seed);
		var rand = sfc32(seed(), seed(), seed(), seed());
		var rand = mulberry32(seed());
		
		Math_randomGenerator = function() {
			let value
			if(Math_randomValueIndex < Math_randomValues.length) {
				value = Math_randomValues[Math_randomValueIndex]
				// Log random numbers for testing
				// Network_log("rnd("+Math_randomValueIndex+"/"+Math_randomValues.length+") replay "+value)
				Math_randomValueIndex++
			} else {
				value = rand()
				// Log random numbers for testing
				// Network_log("rnd("+Math_randomValueIndex+"/"+Math_randomValues.length+"):"+value)
				Math_randomValues[Math_randomValueIndex++] = value;
			}
			return value
		}

	// Generates a random integer
	global js int randomInteger: int min // The inclusive lower bound of the random integer
		                         int max // The exclusive upper bound of the random integer
		return min + Math.floor(Math_randomGenerator() * (max-min))
	
	global js int randomInteger: int max = 2147483647 // The exclusive upper bound of the random integer
		return Math.floor(Math_randomGenerator() * max)
	
	// Generates a random float
	global inline js int randomFloat
		Math_randomGenerator()
	
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
			
	moveTowards: Angle value
		         Angle targetValue
		         Angle speed = 1
		if targetValue > value: return Math.min(value + speed, targetValue) else
		if targetValue < value: return Math.max(value - speed, targetValue)
			
	limit: int value
		   int min
		   int max
		if value < min: return min
		if value > max: return max
			            return value
	
	limit: int value
		   int max
		if value > max: return max
			            return value
	
	limit: int value
		   int min
		if value < min: return min
			            return value
	
	limit: float value
		   float min
		   float max
		if value < min: return min
		if value > max: return max
			            return value
	
	limit: float value
		   float max
		if value > max: return max
			            return value
			
	limit: float value
		   float min
		if value < min: return min
			            return value
	
	interpolate: float value
		         float fromStart = 0
		         float fromEnd = 1
		         float toStart = 0
		         float toEnd = 1
		if value < fromStart: return toStart
		if value > fromEnd:   return toEnd
			                  return toStart + (toEnd-toStart) * (value-fromStart)/(fromEnd-fromStart)
		
enum AngleUnit
	turns // Turn (one full rotation is 1)
	rad   // Radians (one full rotation is 2π)
	deg   // Degrees (one full rotation is 360)
	grad  // Gradiants (one full rotation is 400)
	
transient float Angle
	inline js float toFloat() this
	inline js string toString() this.toString()
		
	// Returns true if the angle is not zero
	inline js bool toBool := this
	
	inline js Angle operator +  (Angle a, Angle b) a+b
	inline js Angle operator +  (Angle a, int b) a+b
	inline js Angle operator +  (Angle a, float b) a+b
	
	inline js Angle operator -  (Angle a, Angle b) a-b
	inline js Angle operator -  (Angle a, int b) a-b
	inline js Angle operator -  (Angle a, float b) a-b
	inline js Angle operator -  (Angle a) -a
	
	inline js float operator /  (Angle a, Angle b) a/b
	inline js Angle operator /  (Angle a, int b) a/b
	inline js Angle operator /  (Angle a, float b) a/b
	
	inline js Angle operator *  (Angle a, int b) a*b
	inline js Angle operator *  (Angle a, float b) a*b
	inline js Angle operator *  (int a, Angle b) a*b
	inline js Angle operator *  (float a, Angle b) a*b
	
	inline js Angle operator %  (Angle a, int b) a%b
	inline js Angle operator %  (Angle a, Angle b) a%b
	
	inline js bool  operator <  (Angle a, Angle b) a<b
	inline js bool  operator <= (Angle a, Angle b) a<=b
	inline js bool  operator >  (Angle a, Angle b) a>b
	inline js bool  operator >= (Angle a, Angle b) a>=b
	
	inline js bool  operator == (Angle a, Angle b) a==b
	inline js bool  operator == (Angle a, int b) a==b
	inline js bool  operator == (Angle a, float b) a==b
	
	inline js bool  operator != (Angle a, Angle b) a!=b
	inline js bool  operator != (Angle a, int b) a!=b
	inline js bool  operator != (Angle a, float b) a!=b
	
	inline js float in: AngleUnit unit
		(unit==1 ? this*Math_TwoPI : unit==2 ? this*360 : unit==3 ? this*400 : this)
		
enum TimeUnit
	ms   // Milliseconds
	s    // Seconds
	min  // Minutes
	h    // Hours
	days // Days
		
transient float Time
	// The largest possible time value
	const inline js Time maxValue := Number.MAX_VALUE
	
	// The smallest possible time value
	const inline js Time minValue := Number.MIN_VALUE
	
	// The number of milliseconds elapsed since January 1, 1970
	static Time now

	// The current frame
	static inline js int frame := Network_frame
	
	static Time fromTimeString(string timeString)
		Time value = 0
		int colon1 = timeString.indexOf(":")
		if(colon1 == -1)
			value += int(timeString)*3600000
		else
			value += int(timeString.substring(0, colon1))*3600000
			int colon2 = timeString.indexOf(":", colon1+1)
			if(colon2 == -1)
				value += int(timeString.substring(colon1+1))*60000
			else
				value += int(timeString.substring(colon1+1, colon2))*60000
				value += int(timeString.substring(colon2+1))*1000
		return value
		
	static inline js Time fromIsoString: string isoString
		new Date(isoString).getTime()
		
	inline js float toFloat() this
	inline js string toString() this.toString()
		
	// Returns true if the time is not zero
	inline js bool toBool := this
	
	inline js int milliseconds := Math.floor((this %    1000)          ) 
	inline js int seconds      := Math.floor((this %   60000) /    1000) 
	inline js int minutes      := Math.floor((this % 3600000) /   60000) 
	inline js int hours        := Math.floor((this          ) / 3600000)
		
	inline js string minutesAndSeconds := (Math.floor((this % 3600000) / 60000) + (this % 60000 < 10000 ? ":0":":") + Math.floor((this % 60000) / 1000))
	
	inline js string dayMonthYearHourMinuteString() new Date(this).dayMonthYearHourMinuteString()
			
	inline js Time  operator +  (Time a, Time b) a+b
	inline js Time  operator +  (Time a, int b) a+b
	inline js Time  operator +  (Time a, float b) a+b
	
	inline js Time  operator -  (Time a, Time b) a-b
	inline js Time  operator -  (Time a, int b) a-b
	inline js Time  operator -  (Time a, float b) a-b
	
	inline js float operator /  (Time a, Time b) a/b
	inline js Time  operator /  (Time a, int b) a/b
	inline js Time  operator /  (Time a, float b) a/b
	
	inline js Time  operator *  (Time a, int b) a*b
	inline js Time  operator *  (Time a, float b) a*b
	inline js Time  operator *  (int a, Time b) a*b
	inline js Time  operator *  (float a, Time b) a*b
	
	inline js Time  operator %  (Time a, int b) a%b
	inline js Time  operator %  (Time a, Time b) a%b
	
	inline js bool  operator <  (Time a, Time b) a<b
	inline js bool  operator <= (Time a, Time b) a<=b
	inline js bool  operator >  (Time a, Time b) a>b
	inline js bool  operator >= (Time a, Time b) a>=b
	
	static measure: void() do
		let startTime = preciseTime
		do
		return preciseTime - startTime
		
	inline js float in: TimeUnit unit // Convert the time to this unit
		(unit==1 ? this/1000 : unit==2 ? this/60000 : unit==3 ? this/3600000 : unit==4 ? this/86400000 : this)
		
	js static void startTimer() window._timerStart = performance.now()
	js static void printTimer(string text) log(text+": "+(performance.now()-window._timerStart))
	static inline js float preciseTime := performance.now()
	
js Date
transient struct Date
	const dayStrings = [
		["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Gameday", "Do not send"]
		["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"]
	]
		
	inline js Date() new Date(Time_now)
	
	inline js int year := this.getFullYear()
	inline js int month := (this.getMonth()+1)
	inline js int day := this.getDate()
	inline js int dayOfWeek := this.getDay()
		
	inline js int hour := this.getHours()
	inline js int minute := this.getMinutes()
	inline js int second := this.getSeconds()
		
	inline js string twoDigitMonth := (this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitDay := this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitHour := this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitMinute := this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	inline js string twoDigitSecond := this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
		
	inline js Time timeOfDay := this.getHours()*3600000 + this.getMinutes()*60000
	
	private static string toTwoDigitString: int value
		return value < 10 ? "0"+value.toString : value.toString
	
	// (31.12.2000)
	js string dayMonthYearString: language = Loca.language
		return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()
	
	// (31 December 2000)
	js string dayLongMonthNameYearString: language = Loca.language
		return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+" "+this.toLocaleString('en-US', {month: 'long'})+" "+this.getFullYear()
	
	// (31 Dec 2000)
	js string dayShortMonthNameYearString: language = Loca.language
		return this.getDate()+" "+this.toLocaleString('en-US', {month: 'short'})+" "+this.getFullYear()
	
	// (Monday)
	string weekdayString: language = Loca.language
		return dayStrings[language][dayOfWeek]
	
	// (23:59)
	string hourMinuteString: language = Loca.language
		if language == English
			let h = hour
			return ""+((h-1)%12+1)+":"+toTwoDigitString(minute)+(h < 12 ? " am":" pm")
		else
			return ""+hour+":"+toTwoDigitString(minute)
	
	// (23:59:59)
	string hourMinuteSecondString: language = Loca.language
		if language == English
			let h = hour
			return ""+((h-1)%12+1)+":"+toTwoDigitString(minute)+":"+toTwoDigitString(second)+(h < 12 ? " am":" pm")
		else
			return ""+hour+":"+toTwoDigitString(minute)+":"+toTwoDigitString(second)
	
	// (31.12.2000 23:59)
	js string dayMonthYearHourMinuteString: language = Loca.language
		if(language == 1000) return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
		else                 return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// (31.12.2000 23:59:59)
	js string dayMonthYearHourMinuteSecondString: language = Loca.language
		return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// (31-12-2000 23-59-59)
	js string invariantDayMonthYearHourMinuteSecondString: language = Loca.language
		return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// The number of milliseconds elapsed since January 1, 1970
	inline js Time time := this.getTime()
		
	// The data and time in ISO 8601 format, for example "2000-12-31T17:30:00.000Z"
	js string isoString()
		let tzo = -this.getTimezoneOffset()
		let dif = tzo >= 0 ? '+' : '-'
		
		function pad (num) {
			return (num < 10 ? '0' : '') + num;
		}
		
		return this.getFullYear() +
			'-' + pad(this.getMonth() + 1) +
			'-' + pad(this.getDate()) +
			'T' + pad(this.getHours()) +
			':' + pad(this.getMinutes()) +
			':' + pad(this.getSeconds()) +
			dif + pad(Math.floor(Math.abs(tzo) / 60)) +
			':' + pad(Math.abs(tzo) % 60);

	static inline js Date now := new Date(Time_now)
	static inline js Date fromTime(Time time) new Date(time)
	static inline js Date fromValues(int year, int month, int day, int hour = 0, int minute = 0, int second = 0) new Date(year, month-1, day, hour, minute, second)

class Range
	int from, to
	
	inline js bool contains: int value
		(value >= this.from && value < this.from)
	
	inline js bool containsInclusively: int value
		(value >= this.from && value <= this.from)

unit Json
	inline js dynamic parse(string str) JSON.parse(str)
	inline js string stringify(dynamic object) JSON.stringify(object)
		
enum Language: English, German, Spanish, Frensh, Italian, Portuguese, Japanese, Chinese, Korean, Dutch, Turkish, Polish, Russian, Hindi, Arabic, Bengali, Urdu, Indonesian, Invariant = 1000

unit Loca
	visible Language[] supportedLanguages = [English, German]
	visible string[] defaultLocaleForLanguage = ["en-001", "de-DE", "es-ES", "fr-FR", "it-IT", "pt-PT", "ja-JP", "zh-Hans-CN", "ko-KR", "nl-NL", "tr-TR", "pl-PL", "ru-RU", "hi-IN", "ar-001", "bn-BD", "ur-IN", "id-ID"]
	
	Language language = English
	string locale = defaultLocaleForLanguage[language]
	
	set: Language language, string locale = null
		this.language = language
		this.locale = locale or defaultLocaleForLanguage[language]
	
	
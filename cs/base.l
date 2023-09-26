// A number stored as a 32-bit integer
struct int
	// The largest possible integer value
	static inline cs int maxValue := int.MaxValue
	
	// The smallest possible integer value
	static inline cs int minValue := int.MinValue
	
	inline cs int operator ** (int a, int b) 
		Math.pow(a,b)
		
	inline cs int operator % (int a, int b)
		(((a % b) + b) % b)
		
	// The remainer after a division by the given value. The sign stays the same.
	inline cs int remainder: int value
		(this % value)
		
	// Returns true if the integer is not zero
	inline cs bool toBool := (this != 0)
	
	inline cs string toString := this.ToString()
		
	inline cs string formatWithSpaces := this.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
		
	inline cs string format: int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString('en-US', {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	// Returns the absolute value
	inline cs int abs
		Math.abs(this)
		
	inline cs int shiftLeft: int count
		(this << count)
	
	inline cs int shiftRight: int count
		(this >> count)
		
	inline cs int bitwiseOr: implicit int value
		(this | value)
	
	inline cs int bitwiseAnd: implicit int value
		(this & value)
	
	inline cs int setBit: implicit int value
		(this |= value)
	
	inline cs int unsetBit: implicit int value
		(this &= ~value)
	
	inline cs int limit: int from
		                 int to
		(this < from ? from : this > to ? to : this)
		
	inline cs int limit: int to
		(this > to ? to : this)
	
	inline cs int limit: int from
		(this < from ? from : this)
	
	inline cs int max: int value
		(this > value ? value : this)
	
	inline cs int min: int value
		(this < value ? value : this)
	
	inline cs int setIfLarger: int newValue
		(this = Math.Max(newValue, this))
		
	inline cs int incrementAndWrap: int max // When the integer reaches this value, it wraps around to zero
		(this = (((this+1) % max) + max) % max)
	
	inline cs int decrementAndWrap: int max // When the integer reaches this value, it wraps around to zero
		(this = (((this-1) % max) + max) % max)
	
	inline cs int incrementUpTo: int max
		(this < max ? ++this : max)
		
	inline cs int incrementUpToExclusive: int max
		(this < max-1 ? ++this : max-1)
		
	inline cs int incrementBy: int value
		                       int upTo
		(this+value < upTo ? (this += value) : upTo)
		
	inline cs int decrementDownTo: int min
		(this > min ? --this : min)
		
	inline cs int decrementDownToExclusive: int min
		(this > min+1 ? --this : min+1)
		
	inline cs bool within: Range range
		(this >= range.from && this < range.to)
		
	inline cs bool withinInclusively: Range range
		(this >= range.from && this <= range.to)
	
// A number stored as a double precision 64-bit floating point value
struct float
	// The largest possible floating point value
	static inline cs float maxValue := float.MaxValue
	
	// The smallest possible floating point value
	static inline cs float minValue := float.MinValue
	
	const inline cs float infinity := float.PositiveInfinity
	
	inline cs float operator ** (float a, float b) 
		Math.pow(a,b)
		
	inline cs float operator % (float a, float b)
		(((a % b) + b) % b)
		
	// The remainer after a division by the given value. The sign stays the same.
	inline cs float remainder: float value
		(this % value)
		
	inline cs(System) int toInt := (int)(this)
		
	// Returns true if the floot is not zero
	inline cs bool toBool := this
	
	inline cs string toString := this.ToString()
		
	inline cs string format: int fractionDigits, int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString('en-US', {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	inline cs string format: int fractionDigits, bool grouping = false
		this.toLocaleString('en-US', {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, useGrouping:grouping})
		
	inline cs string format: int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString('en-US', {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	// Returns the absolute value
	inline cs float abs
		Math.abs(this)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline cs int ceil
		Math.ceil(this)
		
	// Returns the largest integer less than or equal to the given value
	inline cs int floor
		Math.floor(this)
		
	// Returns the given value rounded to the nearest integer
	inline cs int round
		Math.round(this)
		
	inline cs float limit: float from
		                   float to
		(this < from ? from : this > to ? to : this)
		
	inline cs float limit: float to
		(this > to ? to : this)
	
	inline cs float limit: float from
		(this < from ? from : this)
	
	inline cs float max: float value
		(this > value ? value : this)
	
	inline cs float min: float value
		(this < value ? value : this)
	
	inline cs bool isApproximately: float value
		                            float epsilon = 0.00001
		(Math.abs(this - value) < epsilon)
		
	inline cs bool isAngleApproximately: float value
		                                 float epsilon = 0.0175
		(Math.abs((((this % Math_TwoPI) + Math_TwoPI) % Math_TwoPI) - (((value % Math_TwoPI) + Math_TwoPI) % Math_TwoPI)) < epsilon)
		
	inline cs void moveTowards: float value
		                        float speed
		if(this < value) { if(this + speed < value) this += speed; else this = value; }
		else             { if(this - speed > value) this -= speed; else this = value; }
		
	inline cs float interpolateTo: float target
		                           float value
		(this + (target - this)*value)
		
	inline cs float interpolateTo: float target
		                           float value
		                           EaseFunction ease
		(this + (target - this)*ease.function.invoke(value))
		
	inline cs float incrementBy: float value
		                         float max
		(this+value < max ? (this += value) : max)
		
	// ------------------------------------------- Time -------------------------------------------
	
	implicit inline cs Time toTime() this
	
	// Milliseconds
	inline cs Time ms := this
	
	// Seconds
	inline cs Time s := (this*1000)
		
	// Minutes
	inline cs Time min := (this*60000)
		
	// Hours
	inline cs Time h := (this*3600000)
	
	// Days
	inline cs Time days := (this*86400000)
	
	// Weeks	
	inline cs Time weeks := (this*604800000)
		
	// ------------------------------------------- Angle -------------------------------------------
	
	implicit inline cs Angle toAngle() this
	
	inline cs Angle operator °(float angle) (angle/360)
	
	// Turns (one full rotation is 1)
	inline cs Angle turns() this
	
	// Radians (one full rotation is 1π) 
	inline cs Angle rad() (this/Math.TwoPI)
		
	// Degrees (one full rotation is 360)
	inline cs Angle deg() (this/360)
		
	// Gradians (one full rotation is 360)
	inline cs Angle grad() (this/400)
		
class EaseFunction
	// float(float value) function
	
	// global const EaseFunction None    = { . }
	// global const EaseFunction InQuad  = { . * . }
	// global const EaseFunction OutBack = { 1 + 2.70158 * Math.pow(. - 1, 3) + 1.70158 * Math.pow(. - 1, 2) }
	
// A sequence of characters
cs ,string
class string
	// Returns the number of characters in the string
	inline cs int length := this.Length
	
	// Returns a string with each character converted to uppercase
	inline cs string toUpperCase := this.toUpperCase()
		
	// Returns a string with each character converted to lowercase
	inline cs string toLowerCase := this.toLowerCase()
	
	// Returns true if the string is not null and not empty	
	inline cs bool toBool := !string.IsNullOrEmpty(this)
	
	inline cs string toString() this
	
	inline cs int toInt := parseInt(this)
		
	inline cs int toFloat := parseFloat(this)
	
	inline cs string[] split: string character = " "
		this.split(character)
		
	inline cs bool startsWith(string str) (this.indexOf(str) == 0)
		
	inline cs int indexOf(string str) this.indexOf(str)
	inline cs int indexOf(string str, int startPos) this.indexOf(str, startPos)
		
	inline cs bool contains(string str) (this.indexOf(str) != -1)
		
	inline cs int getCharCodeAt(int index) this.charCodeAt(index)
		
	static inline cs string fromCharCode(int charCode) String.fromCharCode(charCode)
		
	inline cs string substring: int start
		this.substring(start)
		
	inline cs string substring: int start = 0
		                        int end
		this.substring(start, end)
		
	// string getUntil: string value
	// 	             int start = 0
	// 	let index = this.indexOf(value);
	// 	if(index != -1) return this.substring(start, index)
	// 	else            return this
		
	// Returns 0 for an exact match, 1 if first is larger, -1 if second is larger
	inline cs int compareTo: string value // The string to compare to
		this.localeCompare(value)
		
	inline cs string trim
		this.trim()
		
	// cs string getExtension
	// 	let dot = this.lastIndexOf(".")
	// 	if(dot != -1) return this.substring(dot+1)
	// 	else          return ""
		
	inline cs string capitalizeFirstCharacter
		(this.Length > 0 ? this[0].toUpperCase() + this.substring(1) : this)
		
	inline cs string interleaveWith: int charCode
		this.split("").join(String.fromCharCode(charCode))
		
	inline cs string replace: string source
		                      string target
		this.replace(new RegExp(source, "g"), target)
		
	cs string get: int index
		return index >= 0 ? this.Substring(index,1) : this.Substring(this.Length+index,1);
	
	cs string get: int from = 0
		           int to
		return this.Substring(from >= 0 ? from : this.Length+from, to >= 0 ? to : this.Length+to);
		
	cs string get: int from = 0
		return this.Substring(from >= 0 ? from : this.Length+from);
	
		
cs ,byte
struct byte

cs ,Array
struct Array
	
// A logical data type that can have the value true or false
enum bool: false, true
		
enum SortingOrder: Ascending, Descending
	
// A data container that grows in size as needed
cs System.Collections.Generic List
class List<T>
	// Do something for each item in a list
	inline cs void each -> void(
		                       T it // The current item of the list we are iterating over
		                   ) do     // Do this for each item in a list
		foreach(var _it in this) do(_it)
		
	// inline cs void each <- void(
	// 	                       T it,      // The current item of the list we are iterating over
	// 	                       int i      // The index of the current item of the list we are iterating over
	// 	                   ) do           // Do this for each item in a list
	// 	for(let _subject=this, i=_subject.Count-1; i>=0; --i) { let it = _subject[i]; do()}
		
	// // Do something for each item in a list. You can add or remove items inside the loop.
	// inline cs void eachChangable -> void(
	// 	                       T it,      // The current item of the list we are iterating over
	// 	                       int i      // The index of the current item of the list we are iterating over
	// 	                   ) do           // Do this for each item in a list
	// 	for(let i=0, _subject=[...this], _len=_subject.Count; i<_len; ++i) { let it = _subject[i]; do()}
		
	// inline cs void eachChangable <- void(
	// 	                       T it,      // The current item of the list we are iterating over
	// 	                       int i      // The index of the current item of the list we are iterating over
	// 	                   ) do           // Do this for each item in a list
	// 	for(let _subject=[...this], i=_subject.Count-1; i>=0; --i) { let it = _subject[i]; do()}
			
	// cs void eachDistinct: TKey(T it) selector
	// 	                         void(
	// 	                             TKey it,
	// 	                             T[] items,
	// 	                             int i
	// 	                         ) do
	// 	if(this.Count > 0) {
	// 		let _subject = this.sort((a,b) => selector(a) - selector(b))
	// 		for(let _nextIndex=1, it = selector(_subject[0]), i=0; _nextIndex<_subject.Count; ++_nextIndex) { 
	// 			let _nextIt = selector(_subject[_nextIndex]);
	// 			if(_nextIt != it) {
	// 				let items = _subject.slice(i, _nextIndex);
	// 				do(it, items, i)
	// 				it = _nextIt;
	// 				i = _nextIndex;
	// 			}
	// 		}
	// 	}
			
			
		
	// Adds an item to the end of the list
	inline cs void add: T item // The item to add
		this.Add(item)
		
	inline cs void add: T item
		      int maxLength
		this.Add(item);
		if(this.Count > maxLength) this.RemoveAt(0)
			
	inline cs void insert: T item // The item to add
		                   index = 0
		this.Insert(index, item)
		
	// Removes an item from the list
	inline cs void remove: T item // The item to remove
		this.Remove(item)
			
	// Removes the item at the given index from the list
	inline cs void removeAt: int index // The index of the item to remove
		this.RemoveAt(index)
			
	// // Removes the item at the given index from the list
	inline cs void removeRange: int index // The index of the first item to remove
		                        int count // The number of items to remove
		this.RemoveRange(index, count)
			
	// T removeFirstWhere: bool(T a) condition // The condition to check
	// 	for this
	// 		if condition(.)
	// 			removeAt i
	// 			return .
	// 	return null
		
	// removeWhere: bool(T a) condition // The condition to check
	// 	for this <-
	// 		if condition(.)
	// 			removeAt i
	// 	return null
		
	// Adds an item to the list if it isn't already in there
	inline cs void ensure: T item // The item to add
		if(!this.Contains(item)) this.Add(item)
		
	cs void exandIfNeeded: int index
		while(this.Count <= index) this.Add(default(T));
		
	inline cs void addRange: T[] items
		this.AddRange(items)
			
	inline cs bool contains: T item
		this.Contains(item)
		
	inline cs int indexOf: T item
		this.IndexOf(item)
		
	// inline cs void setList: T[] list
	// 	this.splice(0, this.Count, ...list)
		
	// void setFilteredList: T[] list
	// 	                  bool(T a) condition
	// 	clear
	// 	for list: if condition(.): add .
		
	// void setFilteredList: T[] list
	// 	                  bool(T a) condition
	// 	                  int maxCount
	// 	clear
	// 	int count = 0
	// 	for list
	// 		if condition .
	// 			add .
	// 			if ++count >= maxCount: break
		
	cs T pop
		if(this.Count == 0) return default(T);
		int lastIndex = this.Count - 1;
		T item = this[lastIndex];
		this.RemoveAt(lastIndex);
		return item;
		
	inline cs T popAt: int index
		if(index >= this.Count) return default(T);
		T item = this[index];
		this.RemoveAt(index);
		return item;
		
	// inline cs T[] popRange: int index
	// 	                    int count
	// 	this.splice(index, count)
		
	// T popWhere: bool(T a) condition
	// 	for length()
	// 		let item = get(i)
	// 		if condition(item)
	// 			removeAt i
	// 			return item
	// 	return null
	
	cs T popFront
		if(this.Count == 0) return default(T);
		T item = this[0];
		this.RemoveAt(0);
		return item;
	
	// Gets the number of items in the list
	inline cs int length() this.Count
	
	// cs int setLength: int value
	// 	this.length = value
	
	// Removes all items from the list
	inline cs void clear
		this.Clear()
	
	// inline cs T[] clone() [...this]
	
	// cs string toString()
	// 	let result = "";
	// 	for(let item of this) {
	// 		if(result) result += ", ";
	// 		result += item;
	// 	}
	// 	return "["+result+"]"
		
	// // Gets a random item from the list
	T random
		return get(Math.randomInteger(length))	
		
	// T popRandom()
	// 	int index = Math.randomInteger(length)
	// 	T item = get(index)
	// 	this.removeAt(index)
	// 	return item
		
		
	// T next: T currentItem
	// 	int index = indexOf(currentItem)
	// 	return this.get((index+1)%length)
		
	// T next: T currentItem
	// 	    label bool(T item) where
	// 	int baseIndex = indexOf(currentItem)
	// 	for this.length
	// 		let item = this.get((baseIndex+i+1)%length)
	// 		if(where(item)) return item
	// 	return null
		
	// T prev: T currentItem
	// 	int index = indexOf(currentItem)
	// 	return index != -1 ? this.get((index-1)%length) : this.get(length-1)
		
	// T pickWithinRangeOrClosest: float(T a) selector
	// 	                        float min = -float.infinity
	// 	                        float max = float.infinity
	// 	float closestDistance = float.infinity
	// 	int closestIndex = -1
	// 	T closestItem = null
	// 	for this
	// 		let value = selector(.)
	// 		float distance
	// 		if value > max: distance = value - max; else
	// 		if value < min: distance = min - value; else
	// 			            this.removeAt(i); return .
				
	// 		if distance < closestDistance
	// 			closestDistance = distance
	// 			closestIndex = i
	// 			closestItem = .
		
	// 	if(closestIndex != -1) this.removeAt(closestIndex)
	// 	return closestItem
			
	// // Returns true if the list is not null and not empty	
	// inline cs bool toBool := (this != null && this.Count != 0) 
	
	// // Reverses the order of the items of the list in place
	// inline cs T[] reverse() this.reverse()
		
	// // Return a list with all unique items of the original list
	// inline cs T[] distinct() [...new Set(this)]
	
	// // Moves an item to the end of the list
	// cs T moveToBack: T item // The item to move to the end of the list
	// 	var index = this.indexOf(item);
	// 	if(index != -1) {
	// 		let endIndex = this.Count-1;
	// 		for(let i=index; i<endIndex; ++i) {
	// 			this[i] = this[i+1]
	// 		}
	// 		this[endIndex] = item
	// 	}
		
	// // Moves an item to the end of the list
	// cs T moveToFront: T item // The item to move to the end of the list
	// 	var index = this.indexOf(item);
	// 	if(index != -1) {
	// 		for(let i=index; i>0; --i) {
	// 			this[i] = this[i-1]
	// 		}
	// 		this[0] = item
	// 	}
		
	// // Sort the list
	// inline cs T[] sort
	// 	this.sort((a,b) => a - b)
	
	// inline cs T[] sort: float(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
	// 	this.sort(comparer)
	
	// inline cs T[] sort: Time(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
	// 	this.sort(comparer)
	
	// inline cs T[] sort: Angle(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
	// 	this.sort(comparer)
	
	// // Sort the list by a given expression
	// T[] orderBy: float(T a) expression // First order by this expression
	// 	return this.sort(expression(a) - expression(b))
		
	// T[] orderBy: float(T it) expression           // First order by this expression
	// 	         label nocolon float(T it) thenBy // Then order by this expression
	// 	return this.sort(expression(a) - expression(b) || thenBy(a) - thenBy(b))
		
	// T[] orderBy: Time(T a) expression // First order by this expression
	// 	return this.sort(expression(a) - expression(b))
		
	// T[] orderBy: Angle(T a) expression // First order by this expression
	// 	return this.sort(expression(a) - expression(b))
		
	// T[] orderBy: string(T a) expression // First order by this expression
	// 	return this.sort(expression(a) compareTo expression(b))
		
	// // Sort the list by a given expression
	// T[] orderBy: float(T a) expression // First order by this expression
	// 	         SortingOrder order    // Specifies if you want to sort in ascending or descending order
	// 	if order == Ascending: return this.sort(expression(a) - expression(b))
	// 	else                   return this.sort(expression(b) - expression(a))
		
	// Returns true if the given condition is true for any item in the list
	inline cs(System.Linq) bool any: bool(T a) predicate // The condition to check
		this.Any(predicate)
		
	inline cs(System.Linq) bool none: bool(T a) predicate // The condition to check
		!this.Any(predicate)
		
	// Returns true if the given condition is true for all items in the list
	inline cs(System.Linq) bool all: bool(T a) predicate // The condition to check
		this.All(predicate)
		
	// inline cs(System.Linq) TValue[] select: TValue(T it) selector
	// 	this.Select(selector)
		
	inline cs(System.Linq) T find: bool(T a) condition // The condition to check
		this.FirstOrDefault(condition)
		
	// int indexWhere: bool(T a) condition // The condition to check
	// 	for this
	// 		if condition(.)
	// 			return i
	// 	return -1
		
	// int indexWhere: <- bool(T a) condition // The condition to check
	// 	for this <-
	// 		if condition(.)
	// 			return i
	// 	return -1
		
	// inline cs T[] where: bool(T a) condition // The condition to check
	// 	this.filter(condition)
		
	// inline cs T[] take: int count
	// 	this.slice(0, count)
		
	// inline cs T[] subList: int start, int count
	// 	this.slice(start, count)
		
	// int total: int(T it) selector
	// 	let sum = 0
	// 	for this: sum += selector(.)
	// 	return sum
		
	// cs int sum
	// 	let sum = 0;
	// 	for(let i=0; i<this.Count; i++)
	// 		sum += this[i];
	// 	return sum;
	
	// cs float average
	// 	return this.Count > 0 ? this.sum() / this.Count : 0
		
	// string joinToString: string(T a) selector
	// 	                 string separator = ", "
	// 	let result = ""
	// 	for this
	// 		if result: result += separator
	// 		result += selector(.)
	// 	return result
		
	shuffle
		for 1 to length <- i
			var j = Math.floor(Math.randomFloat * (i + 1))
			var temp = this.get(i)
			this.set(i, this.get(j))
			this.set(j, temp)
		return this
		
	// private static transient T[] temporaryCopy = null
		
	// cs T percentile: int value
	// 	if(this.Count == 0) return 0
	// 	if(this.Count == 1) return this[0]
	// 	if(!List_temporaryCopy) List_temporaryCopy = []
	// 	const len = List_temporaryCopy.Count = this.Count
	// 	for(let i=0; i<len; ++i) List_temporaryCopy[i] = this[i] 
	// 	List_temporaryCopy.sort((a,b) => a - b)
	// 	return List_temporaryCopy[Math.round((List_temporaryCopy.Count-1) * value / 100)]
		
	// min: int(T a) selector 
	// 	 int threshold = int.maxValue
	// 	 int default = 0
	// 	int resultValue = threshold
	// 	for this
	// 		let value = selector(.)
	// 		if value < resultValue: resultValue = value
	// 	return resultValue != threshold ? resultValue : default
		
	// min: float(T a) selector 
	// 	 float threshold = float.maxValue
	// 	 float default = 0
	// 	float resultValue = threshold
	// 	for this
	// 		let value = selector(.)
	// 		if value < resultValue: resultValue = value
	// 	return resultValue != threshold ? resultValue : default
		
	// min: int(T a) selector 
	// 	 int threshold = int.maxValue
	// 	 int default = 0
	// 	 label bool(T a) where
	// 	int resultValue = threshold
	// 	for this
	// 		if where(.)
	// 			let value = selector(.)
	// 			if value < resultValue: resultValue = value
	// 	return resultValue != threshold ? resultValue : default
		
	// min: float(T a) selector 
	// 	 float threshold = float.maxValue
	// 	 float default = 0
	// 	 label bool(T a) where
	// 	float resultValue = threshold
	// 	for this
	// 		if where(.)
	// 			let value = selector(.)
	// 			if value < resultValue: resultValue = value
	// 	return resultValue != threshold ? resultValue : default
		
	// max: int(T a) selector
	// 	 int threshold = int.minValue
	// 	 int default = 0
	// 	int resultValue = threshold
	// 	for this
	// 		let value = selector(.)
	// 		if value > resultValue: resultValue = value
	// 	return resultValue != threshold ? resultValue : default
		
	// max: float(T a) selector
	// 	 float threshold = float.minValue
	// 	 float default = 0
	// 	float resultValue = threshold
	// 	for this
	// 		let value = selector(.)
	// 		if value > resultValue: resultValue = value
	// 	return resultValue != threshold ? resultValue : default
		
	// max: Time(T a) selector
	// 	 Time threshold = float.minValue
	// 	 Time default = 0
	// 	Time resultValue = threshold
	// 	for this
	// 		let value = selector(.)
	// 		if value > resultValue: resultValue = value
	// 	return resultValue != threshold ? resultValue : default
		
	// max: int(T a) selector
	// 	 int threshold = int.minValue
	// 	 int default = 0
	// 	 label bool(T a) where
	// 	int resultValue = threshold
	// 	for this 
	// 		if where(.)
	// 			let value = selector(.)
	// 			if value > resultValue: resultValue = value
	// 	return resultValue != threshold ? resultValue : default
		
	// max: float(T a) selector
	// 	 float threshold = float.minValue
	// 	 float default = 0
	// 	 label bool(T a) where
	// 	float resultValue = threshold
	// 	for this
	// 		if where(.)
	// 			let value = selector(.)
	// 			if value > resultValue: resultValue = value
	// 	return resultValue != threshold ? resultValue : default
		
	// max: Time(T a) selector
	// 	 Time threshold = float.minValue
	// 	 Time default = 0
	// 	 label bool(T a) where
	// 	Time resultValue = threshold
	// 	for this
	// 		if where(.)
	// 			let value = selector(.)
	// 			if value > resultValue: resultValue = value
	// 	return resultValue != threshold ? resultValue : default
		
	// minIndex: int(T a) selector
	// 	      int threshold = int.maxValue
	// 	int resultValue = threshold
	// 	int index = -1
	// 	for this
	// 		let value = selector(.)
	// 		if value < resultValue
	// 			resultValue = value
	// 			index = i
	// 	return index
		
	// maxIndex: int(T a) selector
	// 	      int threshold = int.minValue
	// 	int resultValue = threshold
	// 	int index = -1
	// 	for this
	// 		let value = selector(.)
	// 		if value > resultValue
	// 			resultValue = value
	// 			index = i
	// 	return index
		
	// withMin: int(T a) selector
	// 	     int threshold = int.maxValue
	// 	int resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		let value = selector(.)
	// 		if value < resultValue
	// 			resultValue = value
	// 			resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// withMin: float(T a) selector
	// 	     float threshold = float.maxValue
	// 	float resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		let value = selector(.)
	// 		if value < resultValue
	// 			resultValue = value
	// 			resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// withMin: Time(T a) selector
	// 	     Time threshold = float.maxValue
	// 	Time resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		let value = selector(.)
	// 		if value < resultValue
	// 			resultValue = value
	// 			resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// withMin: int(T a) selector
	// 	     int threshold = int.maxValue
	// 	     label bool(T a) where
	// 	int resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		if where(.)
	// 			let value = selector(.)
	// 			if value < resultValue
	// 				resultValue = value
	// 				resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// withMin: float(T a) selector
	// 	     float threshold = float.maxValue
	// 	     label bool(T a) where
	// 	float resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		if where(.)
	// 			let value = selector(.)
	// 			if value < resultValue
	// 				resultValue = value
	// 				resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// withMin: Time(T a) selector
	// 	     Time threshold = float.maxValue
	// 	     label bool(T a) where
	// 	Time resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		if where(.)
	// 			let value = selector(.)
	// 			if value < resultValue
	// 				resultValue = value
	// 				resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// withMax: int(T a) selector
	// 	     int threshold = int.minValue
	// 	int resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		let value = selector(.)
	// 		if value > resultValue
	// 			resultValue = value
	// 			resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// withMax: float(T a) selector
	// 	     float threshold = float.minValue
	// 	float resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		let value = selector(.)
	// 		if value > resultValue
	// 			resultValue = value
	// 			resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// withMax: Time(T a) selector
	// 	     Time threshold = float.minValue
	// 	Time resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		let value = selector(.)
	// 		if value > resultValue
	// 			resultValue = value
	// 			resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// popMax: int(T a) selector
	// 	    int threshold = int.minValue
	// 	int resultValue = threshold
	// 	T resultItem = null
	// 	int resultIndex = -1
	// 	for this
	// 		let value = selector(.)
	// 		if value > resultValue
	// 			resultValue = value
	// 			resultItem = .
	// 			resultIndex = i
				
	// 	if resultIndex != -1: removeAt resultIndex
	// 	return resultItem
		
	// popMax: int(T a) selector
	// 	    float threshold = float.minValue
	// 	float resultValue = threshold
	// 	T resultItem = null
	// 	int resultIndex = -1
	// 	for this
	// 		let value = selector(.)
	// 		if value > resultValue
	// 			resultValue = value
	// 			resultItem = .
	// 			resultIndex = i
				
	// 	if resultIndex != -1: removeAt resultIndex
	// 	return resultItem
		
	// withMax: int(T a) selector
	// 	     int threshold = int.minValue
	// 	     label bool(T a) where
	// 	int resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		if where(.)
	// 			let value = selector(.)
	// 			if value > resultValue
	// 				resultValue = value
	// 				resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// withMax: float(T a) selector
	// 	     float threshold = float.minValue
	// 	     label bool(T a) where
	// 	float resultValue = threshold
	// 	T resultItem
	// 	for this
	// 		if where(.)
	// 			let value = selector(.)
	// 			if value > resultValue
	// 				resultValue = value
	// 				resultItem = .
	// 	return resultValue != threshold ? resultItem : null
		
	// count: bool(T a) predicate
	// 	int count = 0
	// 	for this
	// 		if predicate(.)
	// 			count++
	// 	return count
		
	// countNot: bool(T a) predicate
	// 	int count = 0
	// 	for this
	// 		if !predicate(.)
	// 			count++
	// 	return count
		
	// rotate
	// 	insert pop
		
	// cs T[] intersectWith: T[] other
	// 	const a = this || []
	// 	const b = other || []
	// 	const result = [];
	// 	const map = {};
	// 	for (let i = 0, length = b.Count; i < length; ++i) {
	// 		map[b[i]] = true;
	// 	}
	// 	for (let i = 0, length = a.Count; i < length; ++i) {
	// 		if (a[i] in map) result.push(a[i]);
	// 	}
	// 	return result;
		
	// // Gets an item from the list
	cs T get: implicit int index // The index of the item to get
		return index >= 0 ? this[index] : this[this.Count+index];
		
	// cs T get: int from = 0 // Return a new list starting from this index
	// 	      int to       // Return a new list up to (but not including) this index
	// 	return this.slice(from, to)
	
	// cs T get: int from // Return a new list starting from this index
	// 	return this.slice(from)
	
	cs T set: int index // The index of the item to set
		      T value   // The new value to set
		if(index < 0) index = this.Count+index;
		while(this.Count <= index) this.Add(default(T));
		return this[index] = value;
		
	// Tries to get an item from the list. If it doesn't exist, it sets it.
	// TODO: Support index with side effect (e.g. list[index++] ?= 0)
	inline cs T getOrSet: int index
		                  T value
		(index < this.Count ? this[index] : this.set(index, value))
		
	// // Add a value to an item of the list
	// cs T addToItem: int index // The index of the item to change
	// 	            T value   // The value to add to the item
	// 	return index >= 0 ? this[index] += value : this[this.Count+index] += value
		
	// // Subtract a value from an item of the list
	// cs T subtractFromItem: int index // The index of the item to change
	// 	                   T value   // The value to subtract from the item
	// 	return index >= 0 ? this[index] -= value : this[this.Count+index] -= value
		
	// // Multiply an item of the list by a value
	// cs T multiplyItem: int index // The index of the item to change
	// 	               T value   // The value to multiply the item by
	// 	return index >= 0 ? this[index] *= value : this[this.Count+index] *= value
		
	// // Divide an item of the list by a value
	// cs T divideItem: int index // The index of the item to change
	// 	             T value   // The value to divide the item by
	// 	return index >= 0 ? this[index] /= value : this[this.Count+index] /= value
		
	// // Add 1 to item of the list
	// cs T incrementItem: int index // The index of the item to change
	// 	return index >= 0 ? this[index]++ : this[this.Count+index]++
	
	// // Subtract 1 from an item of the list
	// cs T decrementItem: int index // The index of the item to change
	// 	return index >= 0 ? this[index]-- : this[this.Count+index]--
		
// A data container that stores key-value pairs
cs System.Collections.Generic Dictionary
class Map<TKey, TValue>
	cs TValue get: TKey key
		TValue value = default(TValue);
		this.TryGetValue(key, out value);
		return value;
		
	inline cs TValue set: TKey key
		                  TValue value
		this[key] = value
		
	inline cs TValue getOrSet: TKey key
		                       TValue value
		(this.ContainsKey(key) ? this[key] : this[key] = value)
		
	inline cs void each: -> void(
		                     TValue it, // The current value of the map we are iterating over with the for-loop
		                     TKey key   // The current key of the map we are iterating over with the for-loop
		                 ) do           // Do this for each item in a map
		foreach(var pair in this) { var it = pair.Value; var key = pair.Key; do()}
			
	cs TValue[] values
		var list = new List<TValue>();
		list.AddRange(this.Values);
		return list;
		
	inline cs void remove: TKey key
		this.Remove(key)
		
	inline cs void clear
		this.Clear()


// Specifies that a function doesn't return a value
struct void
	
// Denotes a type that can be null
struct Nullable<T>
	
interface object
	inline cs bool toBool() (this != null)
	inline cs string toString() object_stringify(this, 3)
		
	// static internal cs string stringify: object subject, int depth = 0 
	// 	switch(typeof subject)
	// 	{
	// 		case "object":
	// 			if(subject === null) return "null"
	// 			let result = "\{_type:" + subject.constructor.name
	// 			if(depth > 0)
	// 				for(let name in subject)
	// 				{
	// 					let item = object_stringify(subject[name], depth-1)
	// 					if(item != "") result += "," + name + ":" + item
	// 				}
	// 			return result + "\}"
				
	// 		case "string":
	// 			return "\"" + subject + "\""
				
	// 		case "undefined":
	// 			return "\"undefined\""
				
	// 		case "function":
	// 			return ""
				
	// 		default:
	// 			return subject.toString()
	// 	}

		
// This struct is automatically filled with the source code location
transient class SourceCodeLocation
	string file
	int start
	int end
	SourceCodeLocation left
	SourceCodeLocation right
	
	inline cs bool toBool() (this != null)
	inline cs string toString() (this.file+":"+this.start)
	
	// SourceCodeLocation clone := {file, start, end, left, right}
			
	// SourceCodeLocation find: string file, int pos
	// 	if this.file and this.file == file and pos >= this.start and pos <= this.end
	// 		return this
	// 	if left != null
	// 		let result = left.find file, pos
	// 		if result != null: return result
	// 	if right != null
	// 		let result = right.find file, pos
	// 		if result != null: return result
	// 	return null
			
	// SourceCodeLocation find: SourceCodeLocation location
	// 	if file == location.file and start == location.start and end == location.end
	// 		return this
	// 	if left != null
	// 		let result = left.find location
	// 		if result != null: return result
	// 	if right != null
	// 		let result = right.find location
	// 		if result != null: return result
	// 	return null
		
	// SourceCodeLocation leaf
	// 	if file: return this
	// 	if right
	// 		let result = right.leaf
	// 		if result: return result
	// 	if left
	// 		let result = left.leaf
	// 		if result: return result
	// 	return null
		
cs System Exception
class Error
	string message
	string stack
	implicit inline cs string toString := this.stack
	
// A collection of basic system functions
global transient unit System
	// Executes code depending on whether a given condition is true or false
	global inline cs void if: implicit bool condition // The condition to check
		                      void() then             // Do this if the condition is true
		if(condition) then()
			
	// Executes code depending on whether a given condition is true or false
	global inline cs void if: implicit bool condition   // The condition to check
		                      void() then               // Do this if the condition is true
		                      label nocolon void() else // Do this if the condition is false
		if(condition) then() @else else()
			
	// Executes code as long as a given condition is true
	global inline cs void while: implicit bool condition // The condition to check
		                         void() do               // Do this while to condition is true
		while(condition) do()
			
	global inline cs void loop: void() do
		for(;;) do()
	
	global inline cs void do: void() do                   // Do this while to condition is true
		                      nocolon implicit bool while // The condition to check
		@do do() 
		@while(while)
	
	// Do something a given number of times or for each item in a list
	// global inline cs void for: T[] subject    // The list to iterate over
	// 	                       -> void(
	// 	                           T it       // The current item of the list we are iterating over with the for-loop
	// 	                       ) do           // Do this for each item in a list
	// 	foreach(var it in subject) do()
		
	// Do something a given number of times or for each item in a list
	global inline cs void for: ensureSingleExecution T[] subject    // The list to iterate over
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		                       //bool withIndex
		for(int _i=0, _len=subject.Count; _i<_len; ++_i) { var _it = subject[_i]; do(_it, _i)}
		
	// Do something a given number of times or for each item in a list
	global inline cs void for: ensureSingleExecution T[] subject    // The list to iterate over
		                       <- void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(int _i=subject.Count-1; _i>=0; --_i) { var _it = subject[_i]; do(_it, _i)}
		
	global inline cs void for: TValue[TKey] subject    // The map to iterate over
		                       -> void(
		                           TValue it, // The current value of the map we are iterating over with the for-loop
		                           TKey key   // The current key of the map we are iterating over with the for-loop
		                       ) do           // Do this for each item in a map
		foreach(var _pair in subject) do(_pair.Value, _pair.Key)
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	global inline cs void forChangeable: T[] subject    // The list to iterate over
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		var _subject=new List<T>(subject);
		for(int _i=0, _len=_subject.Count; _i<_len; ++_i) { var _it = _subject[_i]; do(_it, _i)}
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	global inline cs void forChangeable: T[] subject    // The list to iterate over
		                       <- void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		var _subject=new List<T>(subject);
		for(int _i=_subject.Count-1; _i>=0; --_i) { var _it = _subject[_i]; do(_it, _i)}
		
	global inline cs void for: int to // The exclusive upper bound to iterate towards
		                       -> void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this the given number of times
		for(int _i=0, _to=to; _i<_to; ++_i) do(_i)
		
	global inline cs void for: int to // The exclusive upper bound to iterate towards
		                       <- void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this the given number of times
		for(int _i=to-1; _i>=0; --_i) do(_i)
		
	global inline cs void for: int from
		                       -> void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this for each value in the given range
		                       int to // The exclusive upper bound
		for(int _i=from, _to=to; _i<_to; ++_i) do(_i)
		
	global inline cs void for: int from
		                       <- void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this for each value in the given range
		                       int to         // The exclusive upper bound
		for(int _i=to-1, _from=from; _i>=_from; --_i) do(_i)
		
	global inline cs void for: string subject
		                       -> void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // Do this for each character in the given string
		for(int _i=0, _len=subject.Count; _i<_len; ++_i) { var _it = _subject[_i]; do(_it, _i)}
	
	global inline cs void for: string subject
		                       <- void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // Do this for each character in the given string
		for(int _i=_subject.Count-1; _i>=0; --_i) { var _it = _subject[_i]; do(_it, _i)}
				
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:null)
	global inline cs void forLookAhead: T[] subject    // The list to iterate over
		                                    -> void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // Do this for each consecutive pair in a list
		for(var _subject=subject, _len=_subject.Count, i=0; i<_len; ++i) { var it = _subject[i], next = i+1<_len ? _subject[i+1] : null; do()}
		
	global inline cs void forLookAhead: T[] subject    // The list to iterate over
		                                    <- void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // Do this for each consecutive pair in a list
		for(var _subject=subject, i=_subject.Count-1; i>=0; --i) { var it = _subject[i], next = i>0 ? _subject[i-1] : null; do()}
		
	// [a,b,c] -> (prev:null, a), (prev:a, b), (prev:b, c)
	global inline cs void forLookBack: T[] subject    // The list to iterate over
		                                    -> void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // Do this for each consecutive pair in a list
		for(var i=0, _len=subject.Count; i<_len; ++i) { var it = subject[i], prev = i>0 ? subject[i-1] : null; do()}
		
	global inline cs void forLookBack: T[] subject    // The list to iterate over
		                                    <- void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // Do this for each consecutive pair in a list
		for(var _subject=subject, _len=subject.Count, i=_len-1; i>=0; --i) { var it = _subject[i], prev = i+1<_len ? _subject[i+1] : null; do()}
		
	// [a,b,c] -> (prev:null, a, next:b), (prev:a, b, next:c), (prev:b, c, next:null)
	global inline cs void forLookAheadAndBack: T[] subject  // The list to iterate over
		                              -> void(
		                                  T it,    // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,  // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,  // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i    // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do         // Do this for each triple in a list
		for(var i=0, _subject=subject, _len=_subject.Count; i<_len; ++i) { var it = _subject[i], next = i+1<_len ? _subject[i+1] : null, prev = i>0 ? _subject[i-1] : null; do()}
		
	global inline cs void forLookAheadAndBack: T[] subject  // The list to iterate over
		                              <- void(
		                                  T it,    // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,  // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,  // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i    // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do         // Do this for each triple in a list
		for(var _subject=subject, _len=_subject.Count, i=_len-1; i>=0; --i) { var it = _subject[i], next = i>0 ? _subject[i-1] : null, prev = i+1<_len ? _subject[i+1] : null; do()}
		
	// [a,b,c] -> (a, next:b), (b, next:c)
	global inline cs void forPairs: T[] subject  // The list to iterate over
		                            -> void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // Do this for each consecutive pair in a list
		for(var i=0, _subject=subject, _len=_subject.Count-1; i<_len; ++i) { var it = _subject[i], next = _subject[i+1]; do()}
		
	global inline cs void forPairs: T[] subject  // The list to iterate over
		                            <- void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // Do this for each consecutive pair in a list
		for(var _subject=subject, i=_subject.Count-1; i>0; --i) { var it = _subject[i], next = _subject[i-1]; do()}
		
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:a) 
	global inline cs void forWrappingPairs: T[] subject    // The list to iterate over
		                                   -> void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // Do this for each consecutive pair in a list
		for(var _subject=subject, i=0, _len=_subject.Count; i<_len; ++i) { var it = _subject[i], next = _subject[(i+1)%_len]; do()}
		
	global inline cs void forWrappingPairs: T[] subject    // The list to iterate over
		                                   <- void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // Do this for each consecutive pair in a list
		for(var _subject=subject, _len=_subject.Count, i=_len-1; i>=0; --i) { var it = _subject[i], next = _subject[(((i-1)%_len)+_len)%_len]; do()}
		
	// [a,b,c] -> (prev:a, b, next:c)
	global inline cs void forTriples: T[] subject  // The list to iterate over
		                              -> void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // Do this for each triple in a list
		for(var i=1, _subject=subject, _len=_subject.Count-1; i<_len; ++i) { var it = _subject[i], next = _subject[i+1], prev = _subject[i-1]; do()}
		
	global inline cs void forTriples: T[] subject  // The list to iterate over
		                              <- void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // Do this for each triple in a list
		for(var _subject=subject, i=_subject.Count-2; i>=1; --i) { var it = _subject[i], next = _subject[i-1], prev = _subject[i+1]; do()}
		
	// [a,b,c] -> (prev:c, a, next:b), (prev:a, b, next:c), (prev:b, c, next:a)
	global inline cs void forWrappingTriples: T[] subject  // The list to iterate over
		                                     -> void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // Do this for each triple in a list
		for(var i=0, _subject=subject, _len=_subject.Count; i<_len; ++i) { var it = _subject[i], next = _subject[(i+1)%_len], prev = _subject[(((i-1)%_len)+_len)%_len]; do()}
		
	global inline cs void forWrappingTriples: T[] subject  // The list to iterate over
		                                     <- void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // Do this for each triple in a list
		for(var _subject=subject, _len=_subject.Count, i=_len-1; i>=0; --i) { var it = _subject[i], next = _subject[(((i-1)%_len)+_len)%_len], prev = _subject[(i+1)%_len]; do()}

	// Prints a message to the console
	global inline cs(UnityEngine) void print: logstring text // The text, variables or expressions to print
		                                      SourceCodeLocation location
		Debug.Log(text)
	
	// Display a message in the timeline
	global inline cs(UnityEngine) void watch: logstring text // The text, variables or expressions to watch
		                                      SourceCodeLocation location
		Debug.Log(text)

	
	// Shows a dialog box with a given message
	global inline cs void alert: implicit string message // The message to show
		alert(message)
		
	global inline cs void break() break
	global inline cs void continue() continue
		
	global inline cs void try: void() code
		                       nocolon void(Error error) catch
		try code() @catch(error) catch()
		
		
// A collection of mathematical functions and constants
global skipInit unit Math
	// Returns the absolute value
	inline cs(System) int abs: int value // The value to return the absolute value of
		Math.Abs(value)
		
	// Returns the absolute value
	inline cs(System) float abs: float value // The value to return the absolute value of
		Math.Abs(value)
		
	// Returns the absolute value
	inline cs(System) Angle abs: Angle value // The angle to return the absolute value of
		Math.Abs(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline cs(System) int ceil: float value // The value to round up
		(int)Math.Ceil(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline cs(System) Time ceil: Time value // The value to round up
		(int)Math.Ceil(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline cs(System) Angle ceil: Angle value // The angle to round up
		(int)Math.Ceil(value)
		
	// Returns the largest integer less than or equal to the given value
	inline cs(System) int floor: float value // The value to round down
		(int)Math.Floor(value)
		
	// Returns the largest integer less than or equal to the given value
	inline cs(System) Time floor: Time value // The value to round down
		(int)Math.Floor(value)
		
	// Returns the largest integer less than or equal to the given value
	inline cs(System) Angle floor: Angle value // The angle to round down
		(int)Math.Floor(value)
		
	// Returns the given value rounded to the nearest integer
	inline cs(System) int round: float value // The value to round
		(int)Math.Round(value)
		
	// Returns the given value rounded to the nearest integer
	inline cs(System) Angle round: Angle value // The angle to round
		(int)Math.Round(value)
		
	// Returns the given value rounded to the nearest integer
	inline cs(System) Time round: Time value // The angle to round
		(int)Math.Round(value)
		
	inline cs(System) int min: int a // The first value
		               int b // The second value
		Math.Min(a, b)
		
	// Returns the smallest of the given values
	inline cs(System) float min: float a // The first value
		                 float b // The second value
		Math.Min(a, b)
		
	// Returns the smallest of the given values
	inline cs(System) Angle min: Angle a // The first angle
		                 Angle b // The second angle
		Math.Min(a, b)
		
	// Returns the largest of the given values
	inline cs(System) int max: int a // The first value
		               int b // The second value
		Math.Max(a, b)
		
	// Returns the largest of the given values
	inline cs(System) float max: float a // The first value
		                 float b // The second value
		Math.Max(a, b)
		
	// Returns the largest of the given values
	inline cs(System) Angle max: Angle a // The first angle
		                 Angle b // The second angle
		Math.Max(a, b)
		
	// Returns the largest of the given values
	inline cs(System) Time max: Time a // The first time
		                Time b // The second time
		Math.Max(a, b)
		
	// Returns the positive square root of the given value
	inline cs(System) float sqrt: float value // The value to return the square root of
		MathF.Sqrt(value)
		
	inline cs(System) float pow: float base
		                 float exponent
		Math.Pow(base, exponent)
		
	// The ratio of a circle's circumference to its diameter
	inline cs float PI() 3.141592653589793f
	
	// The ratio of a circle's radius to its diameter
	inline cs float TwoPI() 6.283185307179586f
	
	internal inline cs(System) float nativeSin: float angle // The angle in radians
		Math.Sin(angle)
		
	internal inline cs(System) float nativeCos: float angle // The angle in radians
		Math.Cos(angle)
		
	internal inline cs(System) float nativeTan: float angle // The angle in radians
		Math.Tan(angle)
		
	// Returns the sine of an angle in turns
	sin: Angle angle // The angle in turns (one full rotation is 1)
	    float result = cast(angle - .5 - Math.floor(angle));
	    result *= 16 * (Math.abs(result) - .5);
	    result += .225 * result * (Math.abs(result) - 1);
	    return result;

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
		
	// init
	// 	initDefaultRandomGenerator
		
	// cs void initDefaultRandomGenerator
	// 	Math_randomGenerator = Math.random
		
	// cs string generateRandomSeed:
	// 	let crypto = !window.crypto && typeof(require) != "undefined" ? require("crypto") : window.crypto
	// 	if(crypto) {
	// 		let out = new Uint8Array(256);
	// 		crypto.getRandomValues(out);
	// 		return out.toString();
	// 	}
		
	// internal string randomSeed
	// internal int randomValueIndex
	// transient internal float[] randomValues
	
	// internal recreateRandomValues
	// 	let targetRandomValueIndex = randomValueIndex
	// 	setRandomSeed randomSeed
	// 	for targetRandomValueIndex: randomFloat
	
	// cs void setRandomSeed: string seed
	// 	Math_randomSeed = seed
	// 	Math_randomValues.length = 0
	// 	Math_randomValueIndex = 0
		
	// 	// Seeding the random number generator in Javascript
	// 	// https://stackoverflow.com/a/47593316
	// 	function xmur3(str) {
	// 	    for(var i = 0, h = 1779033703 ^ str.length; i < str.length; i++) {
	// 	        h = Math.imul(h ^ str.charCodeAt(i), 3432918353);
	// 	        h = h << 13 | h >>> 19;
	// 	    } return function() {
	// 	        h = Math.imul(h ^ (h >>> 16), 2246822507);
	// 	        h = Math.imul(h ^ (h >>> 13), 3266489909);
	// 	        return (h ^= h >>> 16) >>> 0;
	// 	    }
	// 	}
		
	// 	function sfc32(a, b, c, d) {
	// 	    return function() {
	// 	      a >>>= 0; b >>>= 0; c >>>= 0; d >>>= 0; 
	// 	      var t = (a + b) | 0;
	// 	      a = b ^ b >>> 9;
	// 	      b = c + (c << 3) | 0;
	// 	      c = (c << 21 | c >>> 11);
	// 	      d = d + 1 | 0;
	// 	      t = t + d | 0;
	// 	      c = c + t | 0;
	// 	      return (t >>> 0) / 4294967296;
	// 	    }
	// 	}
		
	// 	function mulberry32(a) {
	// 	    return function() {
	// 	      var t = a += 0x6D2B79F5;
	// 	      t = Math.imul(t ^ t >>> 15, t | 1);
	// 	      t ^= t + Math.imul(t ^ t >>> 7, t | 61);
	// 	      return ((t ^ t >>> 14) >>> 0) / 4294967296;
	// 	    }
	// 	}
		
	// 	var seed = xmur3(seed);
	// 	var rand = sfc32(seed(), seed(), seed(), seed());
	// 	var rand = mulberry32(seed());
		
	// 	Math_randomGenerator = function() {
	// 		let value
	// 		if(Math_randomValueIndex < Math_randomValues.length) {
	// 			value = Math_randomValues[Math_randomValueIndex]
	// 			// Log random numbers for testing
	// 			// Network_log("rnd("+Math_randomValueIndex+"/"+Math_randomValues.length+") replay "+value)
	// 			Math_randomValueIndex++
	// 		} else {
	// 			value = rand()
	// 			// Log random numbers for testing
	// 			// Network_log("rnd("+Math_randomValueIndex+"/"+Math_randomValues.length+"):"+value)
	// 			Math_randomValues[Math_randomValueIndex++] = value;
	// 		}
	// 		return value
	// 	}

	// Generates a random integer
	// global cs int randomInteger: int min // The inclusive lower bound of the random integer
	// 	                         int max // The exclusive upper bound of the random integer
	// 	return min + Math.floor(Math_randomGenerator() * (max-min))
	
	// global cs int randomInteger: int max = 2147483647 // The exclusive upper bound of the random integer
	// 	return Math.floor(Math_randomGenerator() * max)
	
	// // Generates a random float
	// global inline cs int randomFloat
	// 	Math_randomGenerator()
		
	// Generates a random float
	global inline cs int randomFloat
		UnityEngine.Random.value
		
	// Generates a random integer
	global inline cs int randomInteger: int min // The inclusive lower bound of the random integer
		                         int max // The exclusive upper bound of the random integer
		UnityEngine.Random.Range(min, max)
		
	// Generates a random integer
	global inline cs int randomInteger: int max // The exclusive upper bound of the random integer
		UnityEngine.Random.Range(0, max)
	
	inline cs int shiftLeft: int value
		                     int count
		(value << count)
	
	inline cs int shiftRight: int value
		                      int count
		(value >> count)
		
	moveTowards: float value
		         float targetValue
		         float speed = 1
		if targetValue > value: return Math.min(value + speed, targetValue)
		if targetValue < value: return Math.max(value - speed, targetValue)
			                    return value
			
	moveTowards: Angle value
		         Angle targetValue
		         Angle speed = 1
		if targetValue > value: return Math.min(value + speed, targetValue)
		if targetValue < value: return Math.max(value - speed, targetValue)
			                    return value
			
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
			
	// Maps a value from an input range to an output range
	map: Time value        // The input value 
		 Time from = 0     // The beginning of the input range
		 Time to = 1       // The end of the input range
		 float start = 0   // The lowest possible output value, will be returned for values smaller than "from".
		 float target = 1  // The highest possible output value, will be returned for values larger than "to".
		if value <= from: return start
		if value >= to:   return target
		let factor = (value-from) / (to-from)
		return start + (target-start) * factor
			
	// Maps a value from an input range to an output range
	map: float value       // The input value 
		 float from = 0    // The beginning of the input range
		 float to = 1      // The end of the input range
		 float start = 0   // The lowest possible output value, will be returned for values smaller than "from".
		 float target = 1  // The highest possible output value, will be returned for values larger than "to".
		if value <= from: return start
		if value >= to:   return target
		let factor = (value-from) / (to-from)
		return start + (target-start) * factor
			
	// Maps a value from an input range to an output range
	// map: float value       // The input value 
	// 	 float from = 0    // The beginning of the input range
	// 	 float to = 1      // The end of the input range
	// 	 float start = 0   // The lowest possible output value, will be returned for values smaller than "from".
	// 	 float target = 1  // The highest possible output value, will be returned for values larger than "to".
	// 	 EaseFunction ease // The easing function to apply
	// 	if value <= from: return start
	// 	if value >= to:   return target
	// 	let factor = ease.function((value-from) / (to-from))
	// 	return start + (target-start) * factor
		
// struct Average
// 	float total
// 	int count
// 	add: float value
// 		total += value
// 		count++
// 	average := total / count		

transient float Angle
	inline cs float toFloat() this
	inline cs string toString() this.toString()
		
	// Returns true if the angle is not zero
	inline cs bool toBool := this
	
	inline cs Angle operator +  (Angle a, Angle b) a+b
	inline cs Angle operator +  (Angle a, int b) a+b
	inline cs Angle operator +  (Angle a, float b) a+b
	
	inline cs Angle operator -  (Angle a, Angle b) a-b
	inline cs Angle operator -  (Angle a, int b) a-b
	inline cs Angle operator -  (Angle a, float b) a-b
	inline cs Angle operator -  (Angle a) -a
	
	inline cs float operator /  (Angle a, Angle b) a/b
	inline cs Angle operator /  (Angle a, int b) a/b
	inline cs Angle operator /  (Angle a, float b) a/b
	
	inline cs Angle operator *  (Angle a, int b) a*b
	inline cs Angle operator *  (Angle a, float b) a*b
	inline cs Angle operator *  (int a, Angle b) a*b
	inline cs Angle operator *  (float a, Angle b) a*b
	
	inline cs Angle operator %  (Angle a, int b) a%b
	inline cs Angle operator %  (Angle a, Angle b) a%b
	
	inline cs bool  operator <  (Angle a, Angle b) a<b
	inline cs bool  operator <= (Angle a, Angle b) a<=b
	inline cs bool  operator >  (Angle a, Angle b) a>b
	inline cs bool  operator >= (Angle a, Angle b) a>=b
	
	inline cs bool  operator == (Angle a, Angle b) a==b
	inline cs bool  operator == (Angle a, int b) a==b
	inline cs bool  operator == (Angle a, float b) a==b
	
	inline cs bool  operator != (Angle a, Angle b) a!=b
	inline cs bool  operator != (Angle a, int b) a!=b
	inline cs bool  operator != (Angle a, float b) a!=b
	
	inline cs float in: AngleUnit unit
		(unit==1 ? this*Math_TwoPI : unit==2 ? this*360 : unit==3 ? this*400 : this)
		
enum AngleUnit
	turns // Turn (one full rotation is 1)
	rad   // Radians (one full rotation is 2π)
	deg   // Degrees (one full rotation is 360)
	grad  // Gradiants (one full rotation is 400)
		
skipInit transient float Time
	// // The largest possible time value
	// const inline cs Time maxValue := Number.MAX_VALUE
	
	// // The smallest possible time value
	// const inline cs Time minValue := Number.MIN_VALUE
	
	static inline cs(UnityEngine) float deltaTime() UnityEngine.Time.deltaTime
	
	// // The number of milliseconds elapsed since January 1, 1970
	static float now
	
	static internal inline cs(System) float realTime := (float)(DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond)

	// // The current frame
	static int frame
	
	// static Time fromTimeString(string timeString)
	// 	Time value = 0
	// 	int colon1 = timeString.indexOf(":")
	// 	if(colon1 == -1)
	// 		value += int(timeString)*3600000
	// 	else
	// 		value += int(timeString.substring(0, colon1))*3600000
	// 		int colon2 = timeString.indexOf(":", colon1+1)
	// 		if(colon2 == -1)
	// 			value += int(timeString.substring(colon1+1))*60000
	// 		else
	// 			value += int(timeString.substring(colon1+1, colon2))*60000
	// 			value += int(timeString.substring(colon2+1))*1000
	// 	return value
		
	// static inline cs Time fromIsoString: string isoString
	// 	new Date(isoString).getTime()
		
	// inline cs float toFloat() this
	// inline cs int toInt() Math.floor(this)
	// inline cs string toString() this.toString()
		
	// // Returns true if the time is not zero
	// inline cs bool toBool := this
	
	// inline cs int milliseconds := Math.floor((this %    1000)          ) 
	// inline cs int seconds      := Math.floor((this %   60000) /    1000) 
	// inline cs int minutes      := Math.floor((this % 3600000) /   60000) 
	// inline cs int hours        := Math.floor((this          ) / 3600000)
		
	// // (31.12.)
	// inline cs string dayMonthString(language = Loca.language) new Date(this).dayMonthString(language)
		
	// // (31.12.2000)
	// inline cs string dayMonthYearString(language = Loca.language) new Date(this).dayMonthYearString(language)
	
	// // (31 December 2000)
	// inline cs string dayLongMonthNameYearString(language = Loca.language) new Date(this).dayLongMonthNameYearString(language)
	
	// // (31 Dec 2000)
	// inline cs string dayShortMonthNameYearString(language = Loca.language) new Date(this).dayShortMonthNameYearString(language)
	
	// // (Monday)
	// inline cs string weekdayString(language = Loca.language) new Date(this).weekdayString(language)
	
	// // (23:59)
	// inline cs string hourMinuteString(language = Loca.language) new Date(this).hourMinuteString(language)
	
	// // (59:59)
	// inline cs string minuteSecondString() (Math.floor((this % 3600000) / 60000) + (this % 60000 < 10000 ? ":0":":") + Math.floor((this % 60000) / 1000))
	
	// // (23:59:59)
	// inline cs string hourMinuteSecondString(language = Loca.language) new Date(this).hourMinuteSecondString(language)
	
	// // (31.12.2000 23:59)
	// inline cs string dayMonthYearHourMinuteString(language = Loca.language) new Date(this).dayMonthYearHourMinuteString(language)
	
	// // (31.12.2000 23:59:59)
	// inline cs string dayMonthYearHourMinuteSecondString(language = Loca.language) new Date(this).dayMonthYearHourMinuteSecondString(language)
	
	// // (31-12-2000 23-59-59)
	// inline cs string invariantDayMonthYearHourMinuteSecondString() new Date(this).invariantDayMonthYearHourMinuteSecondString()
			
	inline cs Time  operator +  (Time a, Time b) a+b
	inline cs Time  operator +  (Time a, int b) a+b
	inline cs Time  operator +  (Time a, float b) a+b
	
	inline cs Time  operator -  (Time a, Time b) a-b
	inline cs Time  operator -  (Time a, int b) a-b
	inline cs Time  operator -  (Time a, float b) a-b
	
	inline cs float operator /  (Time a, Time b) a/b
	inline cs Time  operator /  (Time a, int b) a/b
	inline cs Time  operator /  (Time a, float b) a/b
	
	inline cs Time  operator *  (Time a, int b) a*b
	inline cs Time  operator *  (Time a, float b) a*b
	inline cs Time  operator *  (int a, Time b) a*b
	inline cs Time  operator *  (float a, Time b) a*b
	
	inline cs Time  operator %  (Time a, int b) a%b
	inline cs Time  operator %  (Time a, Time b) a%b
	
	inline cs bool  operator <  (Time a, Time b) a<b
	inline cs bool  operator <= (Time a, Time b) a<=b
	inline cs bool  operator >  (Time a, Time b) a>b
	inline cs bool  operator >= (Time a, Time b) a>=b
	
	// static measure: void() do
	// 	let startTime = preciseTime
	// 	do
	// 	return preciseTime - startTime
		
	// inline cs float in: TimeUnit unit // Convert the time to this unit
	// 	(unit==1 ? this/1000 : unit==2 ? this/60000 : unit==3 ? this/3600000 : unit==4 ? this/86400000 : this)
		
	// cs static void startTimer() window._timerStart = performance.now()
	// cs static void printTimer(string text) log(text+": "+(performance.now()-window._timerStart))
	// static inline cs float preciseTime := performance.now()
		
enum TimeUnit
	ms   // Milliseconds
	s    // Seconds
	min  // Minutes
	h    // Hours
	days // Days
		

// transient struct Date
	// const dayStrings = [
	// 	["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	// 	["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
	// ]
		
	// const shortDayStrings = [
	// 	["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	// 	["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
	// ]
		
	// inline cs Date() new Date(Time_now)
	
	// inline cs int year := this.getFullYear()
	// inline cs int month := (this.getMonth()+1)
	// inline cs int day := this.getDate()
	// inline cs int dayOfWeek := this.getDay()
		
	// inline cs int hour := this.getHours()
	// inline cs int minute := this.getMinutes()
	// inline cs int second := this.getSeconds()
		
	// inline cs string twoDigitMonth := (this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})
	// inline cs string twoDigitDay := this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})
	// inline cs string twoDigitHour := this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})
	// inline cs string twoDigitMinute := this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	// inline cs string twoDigitSecond := this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
		
	// inline cs Time timeOfDay := this.getHours()*3600000 + this.getMinutes()*60000
	
	// private static string toTwoDigitString: int value
	// 	return value < 10 ? "0"+value.toString : value.toString
	
	// (31.12.)
	// cs string dayMonthString: language = Loca.language
	// 	return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."
	
	// // (31.12.2000)
	// cs string dayMonthYearString: language = Loca.language
	// 	return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()
	
	// // (31 December 2000)
	// cs string dayLongMonthNameYearString: language = Loca.language
	// 	return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+" "+this.toLocaleString('en-US', {month: 'long'})+" "+this.getFullYear()
	
	// // (31 Dec 2000)
	// cs string dayShortMonthNameYearString: language = Loca.language
	// 	return this.getDate()+" "+this.toLocaleString('en-US', {month: 'short'})+" "+this.getFullYear()
	
	// // (Monday)
	// string weekdayString: language = Loca.language
	// 	return dayStrings[language][dayOfWeek]
	
	// // (Mon)
	// string shortWeekdayString: language = Loca.language
	// 	return shortDayStrings[language][dayOfWeek]
	
	// // (23:59)
	// string hourMinuteString: language = Loca.language
	// 	if language == English
	// 		let h = hour
	// 		return ""+((h-1)%12+1)+":"+toTwoDigitString(minute)+(h < 12 ? " am":" pm")
	// 	else
	// 		return ""+hour+":"+toTwoDigitString(minute)
	
	// // (23:59:59)
	// string hourMinuteSecondString: language = Loca.language
	// 	if language == English
	// 		let h = hour
	// 		return ""+((h-1)%12+1)+":"+toTwoDigitString(minute)+":"+toTwoDigitString(second)+(h < 12 ? " am":" pm")
	// 	else
	// 		return ""+hour+":"+toTwoDigitString(minute)+":"+toTwoDigitString(second)
	
	// // (31.12.2000 23:59)
	// cs string dayMonthYearHourMinuteString: language = Loca.language
	// 	if(language == 1000) return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	// 	else                 return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// // (31.12.2000 23:59:59)
	// cs string dayMonthYearHourMinuteSecondString: language = Loca.language
	// 	return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// // (31-12-2000 23-59-59)
	// cs string invariantDayMonthYearHourMinuteSecondString: language = Loca.language
	// 	return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// // The number of milliseconds elapsed since January 1, 1970
	// inline cs Time time := this.getTime()
		
	// // The data and time in ISO 8601 format, for example "2000-12-31T17:30:00.000Z"
	// cs string isoString()
	// 	let tzo = -this.getTimezoneOffset()
	// 	let dif = tzo >= 0 ? '+' : '-'
		
	// 	function pad (num) {
	// 		return (num < 10 ? '0' : '') + num;
	// 	}
		
	// 	return this.getFullYear() +
	// 		'-' + pad(this.getMonth() + 1) +
	// 		'-' + pad(this.getDate()) +
	// 		'T' + pad(this.getHours()) +
	// 		':' + pad(this.getMinutes()) +
	// 		':' + pad(this.getSeconds()) +
	// 		dif + pad(Math.floor(Math.abs(tzo) / 60)) +
	// 		':' + pad(Math.abs(tzo) % 60);

	// static inline cs Date now := new Date(Time_now)
	// static inline cs Date fromTime(Time time) new Date(time)
	// static inline cs Date fromValues(int year, int month=1, int day=1, int hour = 0, int minute = 0, int second = 0) new Date(year, month-1, day, hour, minute, second)
	
	// // Returns the real time, even during replay. Be careful: This can break the replay.
	// static inline cs Date realtime := new Date()
	
class Range
	int from // The start of the range
	int to   // The end of the range
	
	Range: int from       // The start of the range
		   nocolon int to // The end of the range
	
	inline cs bool contains: int value
		(value >= this.from && value < this.from)
	
	inline cs bool containsInclusively: int value
		(value >= this.from && value <= this.from)

unit Json
	inline cs dynamic parse(string str) JSON.parse(str)
	inline cs string stringify(dynamic object) JSON.stringify(object)
		
enum Language: English, German, Spanish, Frensh, Italian, Portuguese, Japanese, Chinese, Korean, Dutch, Turkish, Polish, Russian, Hindi, Arabic, Bengali, Urdu, Indonesian, Invariant = 1000

// unit Loca
// 	visible Language[] supportedLanguages = [English, German]
// 	visible string[] defaultLocaleForLanguage = ["en-001", "de-DE", "es-ES", "fr-FR", "it-IT", "pt-PT", "ja-JP", "zh-Hans-CN", "ko-KR", "nl-NL", "tr-TR", "pl-PL", "ru-RU", "hi-IN", "ar-001", "bn-BD", "ur-IN", "id-ID"]
	
// 	Language language = German
// 	string locale = defaultLocaleForLanguage[language]
	
// 	set: Language language, string locale = null
// 		this.language = language
// 		this.locale = locale or defaultLocaleForLanguage[language]
	
	
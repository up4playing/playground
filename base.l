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
	inline js int remainder: int value // The value to divide by
		(this % value)
		
	// Returns true if the integer is not zero
	inline js bool toBool := this
	
	inline js string toString := this.toString()
		
	inline js string formatWithSpaces := this.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
		
	inline js string format: int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString("en-US", {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	// Returns the absolute value of the integer
	inline js int abs
		Math.abs(this)
		
	// Shift the bits of the int to the left. Excess bits shifted off to the left are discarded
	inline js int shiftLeft: int count // The amount of bits to shift 
		(this << count)
	
	// Shift the bits of the int to the right. Excess bits shifted off to the right are discarded
	inline js int shiftRight: int count // The amount of bits to shift 
		(this >> count)
		
	// Perform a bitwise "or" operation
	inline js int bitwiseOr: implicit int value // The value to perform the bitwise "or" with
		(this | value)
	
	// Perform a bitwise "and" operation
	inline js int bitwiseAnd: implicit int value // The value to perform the bitwise "and" with
		(this & value)
	
	// Set a specific bit of the integer
	inline js int setBit: implicit int bitIndex // The index of the bit to set
		(this |= (1 << bitIndex))
	
	// Clear a specific bit of the integer
	inline js int clearBit: implicit int bitIndex // The index of the bit to clear
		(this &= ~(1 << bitIndex))
	
	// Limit the value to a specific range
	// Example: Limit the player's to be between 0 and 100
	//     Player
	//         int health
	//         changeHealth: int delta
	//             health = (health + delta) limit 0..100
	inline js int limit: int from // The inclusive minimum value
		                 int to   // The inclusive maximum value
		(this < from ? from : this > to ? to : this)
		
	// Make sure the value never exceets a maximum value
	// Example: Make sure the card count never exceets a maximum value of 5
	//     cardCount = cardCount limit ..5
	inline js int limit: int to
		(this > to ? to : this)
	
	// Make sure the value never falls below a minimum value
	// Example: Make sure the score never fall below 0
	//     score = score limit 0..
	inline js int limit: int from
		(this < from ? from : this)
	
	// Make sure the value never exceets a maximum value
	// Example: Make sure the card count never exceets a maximum value of 5
	//     cardCount = cardCount max 5
	inline js int max: int value
		(this > value ? value : this)
	
	// Make sure the value never falls below a minimum value
	// Example: Make sure the score never fall below 0
	//     score = score min 0
	inline js int min: int value
		(this < value ? value : this)
	
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
		
	inline js int incrementBy: int value
		                       int upTo
		(this+value < upTo ? (this += value) : upTo)
		
	inline js int decrementDownTo: int min
		(this > min ? --this : min)
		
	inline js int decrementDownToExclusive: int min
		(this > min+1 ? --this : min+1)
		
	inline js bool within: Range range
		(this >= range.from && this < range.to)
		
	inline js bool withinInclusively: Range range
		(this >= range.from && this <= range.to)
		
	inline js int assignIfGreater: int value
		(value > this ? this = value : this)
		
	static js TResult[] enumerate: int from, int to, TResult(int i) selector
		let result = []
		for(let i=from; i < to; ++i)
			result.push(selector(i))
		return result
		
	inline js TResult[] times: TResult(int i) selector
		int_enumerate(0, this, selector)
	
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
		
	inline js int toInt := Math.floor(this)
		
	// Returns true if the floot is not zero
	inline js bool toBool := this
	
	inline js string toString := this.toString()
		
	inline js string format: int fractionDigits, int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString("en-US", {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	inline js string format: int fractionDigits, bool grouping = false
		this.toLocaleString("en-US", {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, useGrouping:grouping})
		
	inline js string format: int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString("en-US", {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
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
		
	inline js float limit: float from
		                   float to
		(this < from ? from : this > to ? to : this)
		
	inline js float limit: float to
		(this > to ? to : this)
	
	inline js float limit: float from
		(this < from ? from : this)
	
	inline js float max: float value
		(this > value ? value : this)
	
	inline js float min: float value
		(this < value ? value : this)
	
	inline js bool isApproximately: float value
		                            float epsilon = 0.00001
		(Math.abs(this - value) < epsilon)
		
	inline js bool isAngleApproximately: float value
		                                 float epsilon = 0.0175
		(Math.abs((((this % math_TwoPI) + math_TwoPI) % math_TwoPI) - (((value % math_TwoPI) + math_TwoPI) % math_TwoPI)) < epsilon)
		
	inline js float moveTowards: float value
		                         float speed
		(this < value ? (this + speed < value ? (this += speed) : (this = value)) : (this - speed > value ? (this -= speed) : (this = value)))
		
	inline js float moveTowardsAndEaseOut: float value
		                                   float speed
		(this < value ? (this + speed * (value-this) < value ? (this += speed * (value-this)) : (this = value)) : (this - speed * (this-value) > value ? (this -= speed * (this-value)) : (this = value)))
		
	inline js float interpolateTo: float target
		                           float value
		(this + (target - this)*value)
		
	inline js float interpolateTo: float target
		                           float value
		                           EaseFunction ease
		(this + (target - this)*ease.function.invoke(value))
		
	inline js float incrementBy: float value
		                         float max
		(this+value < max ? (this += value) : max)
		
	// ------------------------------------------- Time -------------------------------------------
	
	implicit inline js Time toTime() this
	
	// Milliseconds
	inline js Time milliseconds := this
	
	// Seconds
	inline js Time seconds := (this*1000)
		
	// Minutes
	inline js Time minutes := (this*60000)
		
	// Hours
	inline js Time hours := (this*3600000)
	
	// Days
	inline js Time days := (this*86400000)
	
	// Weeks	
	inline js Time weeks := (this*604800000)
		
	// ------------------------------------------- Angle -------------------------------------------
	
	implicit inline js Angle toAngle() this
	
	inline js Angle operator °(float angle) (angle/360)
	
	// One full rotation is 1
	inline js Angle turns := this
	
	// One full rotation is 2π (about 6.2832)
	inline js Angle radians := (this/math_TwoPI)
		
	// One full rotation is 360
	inline js Angle degrees := (this/360)
		
	// One full rotation is 400
	inline js Angle gradians := (this/400)
		
class EaseFunction
	float(float value) function
	
	global const EaseFunction None    = { . }
	global const EaseFunction InQuad  = { . * . }
	global const EaseFunction OutBack = { 1 + 2.70158 * math.pow(. - 1, 3) + 1.70158 * math.pow(. - 1, 2) }
	
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
		
	inline js bool startsWith(string str) this.startsWith(str)
	inline js bool endsWith(string str) this.endsWith(str)
		
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
		(this = this.replace(new RegExp(source, "g"), target))
		
	inline js string replaced: string source
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
	inline js void each -> inline void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let i=0, _subject=this, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	inline js void each <- inline void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let _subject=this, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	inline js void eachChangable -> inline void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let i=0, _subject=[...this], _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	inline js void eachChangable <- inline void(
		                       T it,      // The current item of the list we are iterating over
		                       int i      // The index of the current item of the list we are iterating over
		                   ) do           // Do this for each item in a list
		for(let _subject=[...this], i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
			
	js void eachDistinct: TKey(T it) selector
		                         void(
		                             TKey it,
		                             T[] items,
		                             int i
		                         ) do
		if(this.length > 0) {
			let _subject = this.sort((a,b) => selector(a) - selector(b))
			for(let _nextIndex=1, it = selector(_subject[0]), i=0; _nextIndex<_subject.length; ++_nextIndex) { 
				let _nextIt = selector(_subject[_nextIndex]);
				if(_nextIt != it) {
					let items = _subject.slice(i, _nextIndex);
					do(it, items, i)
					it = _nextIt;
					i = _nextIndex;
				}
			}
		}
			
	// Add an item to the end of the list
	inline js void add: T item // The item to add
		this.push(item)
		
	inline js void add: T item  // The item to add
		                T item2 // The second item to add
		this.push(item, item2)
		
	inline js void add: T item  // The item to add
		                T item2 // The second item to add
		                T item3 // The third item to add
		this.push(item, item2, item3)
		
	inline js void add: T item  // The item to add
		                T item2 // The second item to add
		                T item3 // The third item to add
		                T item4 // The fourth item to add
		this.push(item, item2, item3, item4)
		
	inline js void add: T item  // The item to add
		                T item2 // The second item to add
		                T item3 // The third item to add
		                T item4 // The fourth item to add
		                T item5 // The fifth item to add
		this.push(item, item2, item3, item4, item5)
		
	// Add an item and remove a item from the beginning if the length exceeds a maximum value
	inline js void add: T item        // The item to add
		                int maxLength // If the list gets longer than this maximum length, remove an item from the beginning
		this.push(item)
		if(this.length > maxLength) this.splice(0, 1)
			
	// Add an list of item to the end of the list
	inline js void add: T[] items // The list of items to add
		this.push(...items)
			
	// Insert an item at a given index
	inline js void insert: T item    // The item to insert
		                   index = 0 // Insert the item at this index
		this.splice(index, 0, item)
		
	// Remove an item from the list
	// Example: Remove the current player instrance from the list of playeres when they died
	//     Player
    //         die
    //             players.remove me
	js void remove: T item // The item to remove
		var index = this.indexOf(item);
		if(index > -1) this.splice(index, 1);
			
	// Remove the item at the given index from the list
	inline js void removeAt: int index // The index of the item to remove
		this.splice(index, 1)
			
	// Remove a range of items from the list
	// Example: Remove the first 3 players from the list
	//     players.removeRange 0 to 3
	inline js void removeRange: int from = 0   // Remove items starting from this index
		                        nocolon int to // Remove items up to (but not including) this index
		this.splice(from, to-from)
			
	// Remove all item the meet a specific condition
	// Example: Remove all players that have died.
	//     Player
    //         bool hasDied
	//
	//      app
    //          gameOver
    //              players.removeWhere.hasDied
	removeWhere: bool(T a) condition // The condition to check
		for this <-
			if condition(.)
				removeAt i
		return null
		
	// Remove the first item the meet a specific condition
	// Example: Remove the first player with a health smaller than 10.
	//     Player
    //         int health
	//
	//     app
    //         gameOver
    //             players.removeFirstWhere.health < 10
	T removeFirstWhere: bool(T a) condition // The condition to check
		for this
			if condition(.)
				removeAt i
				return .
		return null
	
	// Add an item to the list if it isn't already in there
	js void ensure: T item // The item to add
		if(!this.includes(item))
			this.push(item)
		
	// Add each item from a list if it isn't already in there
	js void ensure: T[] items // The list of items to add
		for(let it of items)
			if(!this.includes(it))
				this.push(it)
		
	// Returns whether the list contains the given item
	inline js bool contains: T item // Check if the list contains this item
		this.includes(item)
		
	// The index of an item in the list
	inline js int indexOf: T item // Get the index of this item
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
		
	// Remove the last item from the list and return it
	// Example: Print and remove "Orange" from the list
	//     let fruits = ["Apple", "Lemon", "Orange"]
	//     print fruits.pop
	inline js T pop := this.pop()
		
	// Remove an item at a specific index from the list and return it
	// Example: Print and remove "Lemon" from the list
	//     let fruits = ["Apple", "Lemon", "Orange"]
	//     print fruits.popAt 1
	inline js T popAt: int index
		this.splice(index, 1)[0]
		
	// Remove a range of items from the list and return a new list containing the removed items
	// Example: Remote "Lemon" and "Orange" from the list of fruits a create a new list with those fruits 
	//     let fruits = ["Apple", "Pear", "Lemon", "Orange"]
	//     let citrusFruit  = fruits.popRange 2 to 4
	inline js T[] popRange: int from
		                    nocolon int to
		this.splice(from, to-from)
		
	// Remove the first item that meet a given condition and return it
	// Exmaple: Remove the first player with a health below 10
	//     let firstActivePlayer = players.popWhere.health < 10
	T popWhere: bool(T a) condition // The condition for the item to meet
		for length()
			let item = get(i)
			if condition(item)
				removeAt i
				return item
		return null
	
	// Remove the first item from the list and return it
	// Example: Print and remove "Apple" from the list
	//     let fruits = ["Apple", "Lemon", "Orange"]
	//     print fruits.popFirst
	js T popFirst
		if(this.length == 0) return null
		let firstItem = this[0]
		this.splice(0, 1)
		return firstItem
	
	// Gets the number of items in the list
	inline js int length() this.length
	
	// Truncated or expands the list the given number of items
	js int setLength: int length // The new length of the list
		this.length = length
	
	// Removes all items from the list
	inline js void clear := this.length = 0
	
	// Create a shallow clone of the list
	inline js T[] clone() [...this]
	
	// Create a string representation of the list
	js string toString()
		let result = "";
		for(let item of this) {
			if(result) result += ", ";
			result += item;
		}
		return "["+result+"]"
		
	// Gets a random item from the list
	T random()
		let randomInteger = math.randomInteger(length)
		return get(randomInteger)
	
	// Remove a random item from the list and return it
	T popRandom()
		int index = math.randomInteger(length)
		T item = get(index)
		this.removeAt(index)
		return item
		
	T next: T currentItem
		int index = indexOf(currentItem)
		return this.get((index+1)%length)
		
	T next: T currentItem
		    label bool(T item) where
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
	js void moveToBack: T item // The item to move to the end of the list
		var index = this.indexOf(item);
		if(index != -1) {
			let endIndex = this.length-1;
			for(let i=index; i<endIndex; ++i) {
				this[i] = this[i+1]
			}
			this[endIndex] = item
		}
		
	// Moves an item to the end of the list
	js void moveToFront: T item // The item to move to the end of the list
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
	
	inline js T[] sort: Angle(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
		this.sort(comparer)
	
	// Sort the list by a given expression
	T[] orderBy: float(T a) expression // First order by this expression
		return this.sort(expression(a) - expression(b))
		
	T[] orderBy: float(T it) expression           // First order by this expression
		         label nocolon float(T it) thenBy // Then order by this expression
		return this.sort(expression(a) - expression(b) || thenBy(a) - thenBy(b))
		
	T[] orderBy: Time(T a) expression // First order by this expression
		return this.sort(expression(a) - expression(b))
		
	T[] orderBy: Angle(T a) expression // First order by this expression
		return this.sort(expression(a) - expression(b))
		
	T[] orderBy: string(T a) expression // First order by this expression
		return this.sort(expression(a) compareTo expression(b))
		
	// Sort the list by a given expression
	T[] orderBy: float(T a) expression // First order by this expression
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
		
	// Return a list that contains the selected field or expression for each item
	inline js TValue[] select: TValue(T it) selector
		this.map(selector)
		
	// Get the selected field or expression for each item and flattens the result
	inline js TValue[] flatten: TValue[](T it) selector
		this.flatMap(selector)
		
	// Find an item the meets the given condition
	// Example: Find a player with a specific id
	//     app
	//         getPlayerById: int id
	//             return players.find.id == id
	inline js T find: bool(T a) condition // The condition to check
		this.find(condition)
		
	// Find the last item in the list the meets the given condition
	// Example: Find a player with a specific id
	//     app
	//         getLastActivePlayer
	//             return players.findLast.active
	T findLast: bool(T a) condition // The condition to check
		for this <-
			if condition(.)
				return .
		return null
		
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
		
	int total: int(T it) selector
		let sum = 0
		for this: sum += selector(.)
		return sum
		
	int total: int(T it) selector
		       label bool(T a) where
		let sum = 0
		for this: if where(.): sum += selector(.)
		return sum
		
	float total: float(T it) selector
		let sum = 0.0
		for this: sum += selector(.)
		return sum
		
	js int sum
		let sum = 0;
		for(let i=0; i<this.length; i++)
			sum += this[i];
		return sum;
	
	js float average
		return this.length > 0 ? this.sum() / this.length : 0
		
	string joinToString: string(T a) selector
		                 string separator = ", "
		let result = ""
		for this
			if result: result += separator
			result += selector(.)
		return result
		
	shuffle
		for 1 to length <- i
			var j = math.floor(math.randomFloat * (i + 1))
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
		 label bool(T a) where
		int resultValue = threshold
		for this
			if where(.)
				let value = selector(.)
				if value < resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	min: float(T a) selector 
		 float threshold = float.maxValue
		 float default = 0
		 label bool(T a) where
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
		 label bool(T a) where
		int resultValue = threshold
		for this 
			if where(.)
				let value = selector(.)
				if value > resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	max: float(T a) selector
		 float threshold = float.minValue
		 float default = 0
		 label bool(T a) where
		float resultValue = threshold
		for this
			if where(.)
				let value = selector(.)
				if value > resultValue: resultValue = value
		return resultValue != threshold ? resultValue : default
		
	max: Time(T a) selector
		 Time threshold = float.minValue
		 Time default = 0
		 label bool(T a) where
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
		     label bool(T a) where
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
		     label bool(T a) where
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
		     label bool(T a) where
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
		
	// The first item of the list
	inline js T first() this[0]
	
	// The last item of the list
	inline js T last() this[this.length-1]
		
	// Gets an item from the list
	js T get: implicit int index // The index of the item to get
		return index >= 0 ? this[index] : this[this.length+index]
		
	js T get: int from = 0 // Return a new list starting from this index
		      int to       // Return a new list up to (but not including) this index
		return this.slice(from, to)
	
	js T get: int from // Return a new list starting from this index
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
	// Get the item assosiated with the given key
	inline js TValue get: TKey key  // The key of the item to get from the map
		this.get(key)
	
	// Set the item for the given key
	inline js void set: TKey key     // The key of the item to add to the map
		                TValue value // The item to add to the map
		this.set(key, value)
		
	// Remove the item assosiated with the given key
	inline js void delete: TKey key  // The key of the item to remove from the map
		this.delete(key)
		
	// Remove all items from the map
	inline js void clear
		this.clear()
	

// Specifies that a function doesn't return a value
struct void
	
// Denotes a type that can be null
struct Nullable<T>
	
// A Hashtable with keys of type 'string' and values of type 'any'
interface dynamic
	
// Any type
interface any
	
// The base class for all classes
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
	inline js string toString() (this.file+":"+this.start)
			
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
		                      inline void() then      // Do this if the condition is true
		if(condition) then()
			
	// Executes code depending on whether a given condition is true or false
	global inline js void if: implicit bool condition          // The condition to check
		                      inline void() then               // Do this if the condition is true
		                      inline label nocolon void() else // Do this if the condition is false
		if(condition) then() @else else()
			
	// Executes code as long as a given condition is true
	global inline js void while: implicit bool condition // The condition to check
		                         inline void() do        // Do this while to condition is true
		while(condition) do()
			
	global inline js void loop: void() do
		for(;;) do()
	
	global inline js void do: inline void() do            // Do this while to condition is true
		                      nocolon implicit bool while // The condition to check
		@do do() 
		@while(while)
	
	// Do something a given number of times or for each item in a list
	global inline js void for: T[] subject    // The list to iterate over
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	// Do something a given number of times or for each item in a list
	global inline js void for: T[] subject    // The list to iterate over
		                       <- inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
		
	// Creates a new list populated with the results of calling a function on every element of the list
	global inline js TResult[] for: T[] subject // The list to iterate over
		                       -> TResult(
		                           T it         // The current item of the list we are iterating over with the for-loop
		                       ) do             // Select the field or expression to be included in the result
		subject.map(do)
		
	// Creates a new list populated with the results of calling a function on every element of the list
	global inline js TResult[] for: T[] subject // The list to iterate over
		                       <- TResult(
		                           T it         // The current item of the list we are iterating over with the for-loop
		                       ) do             // Select the field or expression to be included in the result
		subject.map(do).reverse()
		
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
	// Do something for each item in a list. You can add or remove items inside the loop.
	global inline js void forChangeable: T[] subject    // The list to iterate over
		                       -> inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let i=0, _subject=[...subject], _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	global inline js void forChangeable: T[] subject    // The list to iterate over
		                       <- inline void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(let _subject=[...subject], i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
		
	global inline js void for: int from       // The integer to start iterating from (for exmaple "for 2 to 5: print ." prints 2, 3, 4)
		                       -> inline void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this for each value in the given range
		                       label int to   // The exclusive upper bound to iterate towards (for exmaple "for 3: print ." prints 0, 1, 2)
		for(let i=from; i<to; ++i) do()
		
	global inline js void for: int from       // The integer to start iterating from
		                       <- inline void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this for each value in the given range
		                       label int to   // The exclusive upper bound to iterate towards
		for(let i=to-1; i>=from; --i) do()
		
	global inline js void for: int to         // The exclusive upper bound to iterate towards
		                       -> inline void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this the given number of times
		for(let i=0; i<to; ++i) do()
		
	global inline js void for: int to         // The exclusive upper bound to iterate towards
		                       <- inline void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this the given number of times
		for(let i=to-1; i>=0; --i) do()
		
	global inline js TResult[] for: int to,    // The exclusive upper bound to iterate towards
		                            TResult(
		                                int i  // The iteration variable of the for-loop
		                            ) do       // Select the field or expression to be included in the result
		int_enumerate(0, to, do)
		
	global inline js TResult[] for: int from,    // The integer to start iterating from
		                            TResult(
		                                int i    // The iteration variable of the for-loop
		                            ) do         // Select the field or expression to be included in the result
		                            label int to // The exclusive upper bound to iterate towards
		int_enumerate(from, to, do)
		
	global inline js void for: string subject // Iterate over every character of this string
		                       -> inline void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // Do this for each character in the given string
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
	
	global inline js void for: string subject // Iterate over every character of this string
		                       <- void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // Do this for each character in the given string
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
				
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:null)
	global inline js void forLookAhead: T[] subject    // The list to iterate over
		                                    -> inline void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, _len=_subject.length, i=0; i<_len; ++i) { let it = _subject[i], next = i+1<_len ? _subject[i+1] : null; do()}
		
	global inline js void forLookAhead: T[] subject    // The list to iterate over
		                                    <- inline void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, i=_subject.length-1; i>=0; --i) { let it = _subject[i], next = i>0 ? _subject[i-1] : null; do()}
		
	// [a,b,c] -> (prev:null, a), (prev:a, b), (prev:b, c)
	global inline js void forLookBack: T[] subject    // The list to iterate over
		                                    -> inline void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // Do this for each consecutive pair in a list
		for(let i=0, _len=subject.length; i<_len; ++i) { let it = subject[i], prev = i>0 ? subject[i-1] : null; do()}
		
	global inline js void forLookBack: T[] subject    // The list to iterate over
		                                    <- inline void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, _len=subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], prev = i+1<_len ? _subject[i+1] : null; do()}
		
	// [a,b,c] -> (prev:null, a, next:b), (prev:a, b, next:c), (prev:b, c, next:null)
	global inline js void forLookAheadAndBack: T[] subject  // The list to iterate over
		                              -> inline void(
		                                  T it,    // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,  // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,  // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i    // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do         // Do this for each triple in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i], next = i+1<_len ? _subject[i+1] : null, prev = i>0 ? _subject[i-1] : null; do()}
		
	global inline js void forLookAheadAndBack: T[] subject  // The list to iterate over
		                              <- inline void(
		                                  T it,    // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,  // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,  // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i    // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do         // Do this for each triple in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], next = i>0 ? _subject[i-1] : null, prev = i+1<_len ? _subject[i+1] : null; do()}
		
	// [a,b,c] -> (a, next:b), (b, next:c)
	global inline js void forPairs: T[] subject  // The list to iterate over
		                            -> inline void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // Do this for each consecutive pair in a list
		for(let i=0, _subject=subject, _len=_subject.length-1; i<_len; ++i) { let it = _subject[i], next = _subject[i+1]; do()}
		
	global inline js void forPairs: T[] subject  // The list to iterate over
		                            <- inline void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // Do this for each consecutive pair in a list
		for(let _subject=subject, i=_subject.length-1; i>0; --i) { let it = _subject[i], next = _subject[i-1]; do()}
		
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:a) 
	global inline js void forWrappingPairs: T[] subject    // The list to iterate over
		                                   -> inline void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, i=0, _len=_subject.length; i<_len; ++i) { let it = _subject[i], next = _subject[(i+1)%_len]; do()}
		
	global inline js void forWrappingPairs: T[] subject    // The list to iterate over
		                                   <- inline void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // Do this for each consecutive pair in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], next = _subject[(((i-1)%_len)+_len)%_len]; do()}
		
	// [a,b,c] -> (prev:a, b, next:c)
	global inline js void forTriples: T[] subject  // The list to iterate over
		                              -> inline void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // Do this for each triple in a list
		for(let i=1, _subject=subject, _len=_subject.length-1; i<_len; ++i) { let it = _subject[i], next = _subject[i+1], prev = _subject[i-1]; do()}
		
	global inline js void forTriples: T[] subject  // The list to iterate over
		                              <- inline void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // Do this for each triple in a list
		for(let _subject=subject, i=_subject.length-2; i>=1; --i) { let it = _subject[i], next = _subject[i-1], prev = _subject[i+1]; do()}
		
	// [a,b,c] -> (prev:c, a, next:b), (prev:a, b, next:c), (prev:b, c, next:a)
	global inline js void forWrappingTriples: T[] subject  // The list to iterate over
		                                     -> inline void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // Do this for each triple in a list
		for(let i=0, _subject=subject, _len=_subject.length; i<_len; ++i) { let it = _subject[i], next = _subject[(i+1)%_len], prev = _subject[(((i-1)%_len)+_len)%_len]; do()}
		
	global inline js void forWrappingTriples: T[] subject  // The list to iterate over
		                                     <- inline void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // Do this for each triple in a list
		for(let _subject=subject, _len=_subject.length, i=_len-1; i>=0; --i) { let it = _subject[i], next = _subject[(((i-1)%_len)+_len)%_len], prev = _subject[(i+1)%_len]; do()}

	// Do something a given number of times or for each item in a list
	global inline js void for: dynamic subject // The list to iterate over
		                       -> inline void(
		                           dynamic it,       // The current item of the list we are iterating over with the for-loop
		                           string key   // The index of the current item of the list we are iterating over with the for-loop
		                       ) do             // Do this for each item in a list
		{let _subject=subject; for(let key in _subject) { let it = _subject[key]; do()}}
		
	// Prints a message to the console
	global js void print: logstring text // The text, variables or expressions to print
		                  SourceCodeLocation location
		(location ? log(text, location.start, location.file) : log(text))
		
	js void log: any value
		console.log(value)
	
	// Display a message in the timeline
	global js void watch: logstring text // The text, variables or expressions to watch
		                  SourceCodeLocation location
		if(Platform_isDebug && core_frame >= core_frameWithNewWatches && location) {
			Platform_sendWatch(core_frame, text, location.start, location.file)
		}
	
	// Shows a dialog box with a given message
	global inline js void alert: implicit string message // The message to show
		alert(message)
		
	global inline js void break() break
	global inline js void continue() continue
		
	global inline js void try: inline void() code
		                       inline nocolon void(Error error) catch
		try code() @catch(error) catch()
		
		
// A collection of mathematical functions and constants
global skipInit unit math
	// Returns the absolute value
	inline js int abs: int value // The value to return the absolute value of
		Math.abs(value)
		
	// Returns the absolute value
	inline js float abs: float value // The value to return the absolute value of
		Math.abs(value)
		
	// Returns the absolute value
	inline js Angle abs: Angle value // The angle to return the absolute value of
		Math.abs(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline js int ceil: float value // The value to round up
		Math.ceil(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline js Time ceil: Time value // The value to round up
		Math.ceil(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline js Angle ceil: Angle value // The angle to round up
		Math.ceil(value)
		
	// Returns the largest integer less than or equal to the given value
	inline js int floor: float value // The value to round down
		Math.floor(value)
		
	// Returns the largest integer less than or equal to the given value
	inline js Time floor: Time value // The value to round down
		Math.floor(value)
		
	// Returns the largest integer less than or equal to the given value
	inline js Angle floor: Angle value // The angle to round down
		Math.floor(value)
		
	// Returns the given value rounded to the nearest integer
	inline js int round: float value // The value to round
		Math.round(value)
		
	// Returns the given value rounded to the nearest integer
	inline js Angle round: Angle value // The angle to round
		Math.round(value)
		
	// Returns the given value rounded to the nearest integer
	inline js Time round: Time value // The angle to round
		Math.round(value)
		
	inline js int min: int a // The first value
		               int b // The second value
		Math.min(a, b)
		
	// Returns the smallest of the given values
	inline js float min: float a // The first value
		                 float b // The second value
		Math.min(a, b)
		
	// Returns the smallest of the given values
	inline js Angle min: Angle a // The first angle
		                 Angle b // The second angle
		Math.min(a, b)
		
	// Returns the largest of the given values
	inline js int max: int a // The first value
		               int b // The second value
		Math.max(a, b)
		
	// Returns the largest of the given values
	inline js float max: float a // The first value
		                 float b // The second value
		Math.max(a, b)
		
	// Returns the largest of the given values
	inline js Angle max: Angle a // The first angle
		                 Angle b // The second angle
		Math.max(a, b)
		
	// Returns the largest of the given values
	inline js Time max: Time a // The first time
		                Time b // The second time
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
		float abs_y = math.abs(y) + .00000000001
		if x < 0.0
			r = (x + abs_y) / (abs_y - x);
			angle = .375;
		else
			r = (x - abs_y) / (x + abs_y);
			angle = .125;
		angle += (.03124211533 * r * r - .1562424076) * r;
		if y < 0.0: return cast -angle
		else        return cast angle
		
	inline js int shiftLeft: int value
		                     int count
		(value << count)
	
	inline js int shiftRight: int value
		                      int count
		(value >> count)
		
	moveTowards: float value
		         float targetValue
		         float speed = 1
		if targetValue > value: return math.min(value + speed, targetValue) else
		if targetValue < value: return math.max(value - speed, targetValue)
			
	moveTowards: Angle value
		         Angle targetValue
		         Angle speed = 1
		if targetValue > value: return math.min(value + speed, targetValue) else
		if targetValue < value: return math.max(value - speed, targetValue)
			
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
	map: float value       // The input value 
		 float from = 0    // The beginning of the input range
		 float to = 1      // The end of the input range
		 float start = 0   // The lowest possible output value, will be returned for values smaller than "from".
		 float target = 1  // The highest possible output value, will be returned for values larger than "to".
		 EaseFunction ease // The easing function to apply
		if value <= from: return start
		if value >= to:   return target
		let factor = ease.function((value-from) / (to-from))
		return start + (target-start) * factor
		
struct Average
	float total
	int count
	add: float value
		total += value
		count++
	average := total / count		

class Range
	int from // The start of the range
	int to   // The end of the range
	
	Range: int from       // The start of the range
		   nocolon int to // The end of the range
	
	inline js bool contains: int value
		(value >= this.from && value < this.from)
	
	inline js bool containsInclusively: int value
		(value >= this.from && value <= this.from)

unit Json
	inline js dynamic parse(string str) JSON.parse(str)
	inline js string stringify(any object) JSON.stringify(object)
		
enum Language: English, German, Spanish, Frensh, Italian, Portuguese, Japanese, Chinese, Korean, Dutch, Turkish, Polish, Russian, Hindi, Arabic, Bengali, Urdu, Indonesian, Invariant = 1000

unit Loca
	visible Language[] supportedLanguages = [English, German]
	visible string[] defaultLocaleForLanguage = ["en-001", "de-DE", "es-ES", "fr-FR", "it-IT", "pt-PT", "ja-JP", "zh-Hans-CN", "ko-KR", "nl-NL", "tr-TR", "pl-PL", "ru-RU", "hi-IN", "ar-001", "bn-BD", "ur-IN", "id-ID"]
	
	visible Language language = English
	visible string locale = defaultLocaleForLanguage[language]
	private dynamic localStrings
	
	init
		setLanguage English
	
	js void setLanguage: Language language
		                 string locale = null
		Loca_language = language
		Loca_locale = locale || Loca_defaultLocaleForLanguage[language]
		if(window._strings) Loca_localStrings = _strings[language]
		
	js void format: int id
		let entry = Loca_localStrings[id]
		if(!entry || entry.s.length == 0) return "##########"
		let strings = entry.s
		let result = strings[0]
		let stringIndex = 1
		for(let placeholderNumber of entry.p) {
			if(placeholderNumber >= 0) {
				// Placeholder
				//     "Step {currentStep}"                           {s:["Step "],p:[0]}
				//            ^                                           ^           ^
				let placeholderValue = arguments[placeholderNumber+1]
				result += placeholderValue
				if(stringIndex < strings.length) {
					let str = strings[stringIndex++]
					if(str) result += str
				}
			} else {
				// Placeholder with pluralization
				//     "Waiting for {playerCount} player[s]"          {s:["Waiting for ", " player.", " players."],p:[-1]}
				//                   ^                                                    ^           ^               ^
				// If the placeholder value is 1, we take the first string (sigular version), otherwise the second (plural version)
				let placeholderValue = arguments[-placeholderNumber]
				result += placeholderValue
				let str = strings[placeholderValue == 1 ? stringIndex : stringIndex+1]
				if(str) result += str
				stringIndex += 2
			}
		}
		return result
	
	
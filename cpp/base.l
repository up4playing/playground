// A number stored as a 32-bit integer
immutable struct int
	// The largest possible integer value
	static inline cpp int maxValue() 2147483647
	
	// The smallest possible integer value
	static inline cpp int minValue() = -2147483648
	
// 	inline cpp int operator ** (int a, int b) 
// 		Math.pow(a,b)
		
	cpp int operator % (int a, int b)
		return ((a % b) + b) % b
		
// 	// The remainer after a division by the given value. The sign stays the same.
// 	inline cpp int remainder: int value // The value to divide by
// 		(this % value)
		
// 	// Returns true if the integer is not zero
// 	inline cpp bool toBool := this
	
	inline cpp(string) string toString := std::to_string(this)
		
// 	inline cpp string formatWithSpaces := this.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")
		
// 	inline cpp string format: int minIntegerDigits = 1, bool grouping = false
// 		this.toLocaleString("en-US", {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
// 	// Returns the absolute value of the integer
// 	inline cpp int abs
// 		Math.abs(this)
		
// 	// Shift the bits of the int to the left. Excess bits shifted off to the left are discarded
// 	inline cpp int shiftLeft: int count // The amount of bits to shift 
// 		(this << count)
	
// 	// Shift the bits of the int to the right. Excess bits shifted off to the right are discarded
// 	inline cpp int shiftRight: int count // The amount of bits to shift 
// 		(this >> count)
		
// 	// Perform a bitwise "or" operation
// 	inline cpp int bitwiseOr: implicit int value // The value to perform the bitwise "or" with
// 		(this | value)
	
// 	// Perform a bitwise "and" operation
// 	inline cpp int bitwiseAnd: implicit int value // The value to perform the bitwise "and" with
// 		(this & value)
	
// 	// Set a specific bit of the integer
// 	inline cpp int setBit: implicit int bitIndex // The index of the bit to set
// 		(this |= (1 << bitIndex))
	
// 	// Clear a specific bit of the integer
// 	inline cpp int clearBit: implicit int bitIndex // The index of the bit to clear
// 		(this &= ~(1 << bitIndex))
	
// 	// Limit the value to a specific range
// 	// Example: Limit the player's to be between 0 and 100
// 	//     Player
// 	//         int health
// 	//         changeHealth: int delta
// 	//             health = (health + delta) limit 0..100
// 	inline cpp int limit: int from // The inclusive minimum value
// 		                 int to   // The inclusive maximum value
// 		(this < from ? from : this > to ? to : this)
		
// 	// Make sure the value never exceets a maximum value
// 	// Example: Make sure the card count never exceets a maximum value of 5
// 	//     cardCount = cardCount limit ..5
// 	inline cpp int limit: int to
// 		(this > to ? to : this)
	
// 	// Make sure the value never falls below a minimum value
// 	// Example: Make sure the score never fall below 0
// 	//     score = score limit 0..
// 	inline cpp int limit: int from
// 		(this < from ? from : this)
	
// 	// Make sure the value never exceets a maximum value
// 	// Example: Make sure the card count never exceets a maximum value of 5
// 	//     cardCount = cardCount max 5
// 	inline cpp int max: int value
// 		(this > value ? value : this)
	
// 	// Make sure the value never falls below a minimum value
// 	// Example: Make sure the score never fall below 0
// 	//     score = score min 0
// 	inline cpp int min: int value
// 		(this < value ? value : this)
	
// 	inline cpp int setIfLarger: int newValue
// 		(this = Math.max(newValue, this))
		
// 	inline cpp int incrementAndWrap: int max // When the integer reaches this value, it wraps around to zero
// 		(this = (((this+1) % max) + max) % max)
	
// 	inline cpp int decrementAndWrap: int max // When the integer reaches this value, it wraps around to zero
// 		(this = (((this-1) % max) + max) % max)
	
// 	inline cpp int incrementUpTo: int max
// 		(this < max ? ++this : max)
		
// 	inline cpp int incrementUpToExclusive: int max
// 		(this < max-1 ? ++this : max-1)
		
// 	inline cpp int incrementBy: int value
// 		                       int upTo
// 		(this+value < upTo ? (this += value) : upTo)
		
// 	inline cpp int decrementDownTo: int min
// 		(this > min ? --this : min)
		
// 	inline cpp int decrementDownToExclusive: int min
// 		(this > min+1 ? --this : min+1)
		
// 	inline cpp bool within: Range range
// 		(this >= range.from && this < range.to)
		
// 	inline cpp bool withinInclusively: Range range
// 		(this >= range.from && this <= range.to)
		
// 	inline cpp int assignIfGreater: int value
// 		(value > this ? this = value : this)
		
// 	static cpp TResult[] enumerate: int from, int to, TResult(int i) selector
// 		let result = []
// 		for(let i=from; i < to; ++i)
// 			result.push(selector(i))
// 		return result
		
// 	inline cpp TResult[] times: TResult(int i) selector
// 		int_enumerate(0, this, selector)
	
// // A number stored as a double precision 64-bit floating point value
cpp(,double)
immutable struct float
	// The largest possible floating point value
	const inline cpp(float.h) float maxValue := FLT_MAX
	
	// The smallest possible floating point value
	const inline cpp(float.h) float minValue := FLT_MIN
	
	const inline cpp(cmath) float infinity := INFINITY
	
// 	inline cpp float operator ** (float a, float b) 
// 		Math.pow(a,b)
		
	cpp float operator % (float a, float b)
		return ((a % b) + b) % b
		
// 	// The remainer after a division by the given value. The sign stays the same.
// 	inline cpp float remainder: float value
// 		(this % value)
		
// 	inline cpp int toInt := Math.floor(this)
		
// 	// Returns true if the floot is not zero
// 	inline cpp bool toBool := this
	
	inline cpp(string) string toString := std::to_string(this)
		
// 	inline cpp string format: int fractionDigits, int minIntegerDigits = 1, bool grouping = false
// 		this.toLocaleString("en-US", {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
// 	inline cpp string format: int fractionDigits, bool grouping = false
// 		this.toLocaleString("en-US", {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, useGrouping:grouping})
		
// 	inline cpp string format: int minIntegerDigits = 1, bool grouping = false
// 		this.toLocaleString("en-US", {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
// 	// Returns the absolute value
// 	inline cpp float abs
// 		Math.abs(this)
		
// 	// Returns the smallest integer greater than or equal to the given value 
// 	inline cpp int ceil
// 		Math.ceil(this)
		
// 	// Returns the largest integer less than or equal to the given value
// 	inline cpp int floor
// 		Math.floor(this)
		
// 	// Returns the given value rounded to the nearest integer
// 	inline cpp int round
// 		Math.round(this)
		
// 	inline cpp float limit: float from
// 		                   float to
// 		(this < from ? from : this > to ? to : this)
		
// 	inline cpp float limit: float to
// 		(this > to ? to : this)
	
// 	inline cpp float limit: float from
// 		(this < from ? from : this)
	
// 	inline cpp float max: float value
// 		(this > value ? value : this)
	
// 	inline cpp float min: float value
// 		(this < value ? value : this)
	
// 	inline cpp bool isApproximately: float value
// 		                            float epsilon = 0.00001
// 		(Math.abs(this - value) < epsilon)
		
// 	inline cpp float moveTowards: float value
// 		                         float speed
// 		(this < value ? (this + speed < value ? (this += speed) : (this = value)) : (this - speed > value ? (this -= speed) : (this = value)))
		
// 	inline cpp float moveTowardsAndEaseOut: float value
// 		                                   float speed
// 		(this < value ? (this + speed * (value-this) < value ? (this += speed * (value-this)) : (this = value)) : (this - speed * (this-value) > value ? (this -= speed * (this-value)) : (this = value)))
		
// 	inline cpp float interpolateTo: float target
// 		                           float value
// 		(this + (target - this)*value)
		
// 	inline cpp float interpolateTo: float target
// 		                           float value
// 		                           EaseFunction ease
// 		(this + (target - this)*ease.function.invoke(value))
		
// 	inline cpp float incrementBy: float value
// 		                         nocolon float to
// 		(this+value < to ? (this += value) : to)
		
// 	// ------------------------------------------- Time -------------------------------------------
	
// 	implicit inline cpp Time toTime() this
	
// 	// Milliseconds
// 	inline cpp Time milliseconds := this
	
// 	// Seconds
// 	inline cpp Time seconds := (this*1000)
		
// 	// Minutes
// 	inline cpp Time minutes := (this*60000)
		
// 	// Hours
// 	inline cpp Time hours := (this*3600000)
	
// 	// Days
// 	inline cpp Time days := (this*86400000)
	
// 	// Weeks	
// 	inline cpp Time weeks := (this*604800000)
		
immutable EaseFunction
	float(float value) function
	
	// global const EaseFunction None    = { . }
	// global const EaseFunction InQuad  = { . * . }
	// global const EaseFunction OutBack = { 1 + 2.70158 * math.pow(. - 1, 3) + 1.70158 * math.pow(. - 1, 2) }
	
// A sequence of characters
cpp string, std::string
immutable struct string
	// Returns the number of characters in the string
	inline cpp int length := this.length
	
	// // Returns a string with each character converted to uppercase
	// inline cpp string toUpperCase := this.toUpperCase()
		
	// // Returns a string with each character converted to lowercase
	// inline cpp string toLowerCase := this.toLowerCase()
	
	// // Returns true if the string is not null and not empty	
	// inline cpp bool toBool := this
	
	// inline cpp string toString() this
	
	// inline cpp int toInt := parseInt(this)
		
	// inline cpp int toFloat := parseFloat(this)
	
	// inline cpp string[] split: string character = " "
	// 	this.split(character)
		
	// inline cpp bool startsWith(string str) this.startsWith(str)
	// inline cpp bool endsWith(string str) this.endsWith(str)
		
	// inline cpp int indexOf(string str) this.indexOf(str)
	// inline cpp int indexOf(string str, int startPos) this.indexOf(str, startPos)
		
	// inline cpp bool contains(string str) (this.indexOf(str) != -1)
		
	// inline cpp int getCharCodeAt(int index) this.charCodeAt(index)
		
	// static inline cpp string fromCharCode(int charCode) String.fromCharCode(charCode)
		
	// inline cpp string substring: int start
	// 	this.substring(start)
		
	// inline cpp string substring: int start = 0
	// 	                        int end
	// 	this.substring(start, end)
		
	// cpp string getUntil: string value
	// 	                int start = 0
	// 	let index = this.indexOf(value)
	// 	if(index != -1) return this.substring(start, index)
	// 	else            return this
		
	// // Returns 0 for an exact match, 1 if first is larger, -1 if second is larger
	// inline cpp int compareTo: string value // The string to compare to
	// 	this.localeCompare(value)
		
	// inline cpp string trim
	// 	this.trim()
		
	// cpp string getExtension
	// 	let dot = this.lastIndexOf(".")
	// 	if(dot != -1) return this.substring(dot+1)
	// 	else          return ""
		
	// inline cpp string capitalizeFirstCharacter
	// 	(this.length > 0 ? this[0].toUpperCase() + this.substring(1) : this)
		
	// inline cpp string interleaveWith: int charCode
	// 	this.split("").join(String.fromCharCode(charCode))
		
	// inline cpp string replace: string source
	// 	                      string target
	// 	(this = this.replace(new RegExp(source, "g"), target))
		
	// inline cpp string replaced: string source
	// 	                       string target
	// 	this.replace(new RegExp(source, "g"), target)
		
	// cpp string get: int index
	// 	return index >= 0 ? this[index] : this[this.length+index]
	
	// cpp string get: int from = 0
	// 	           int to
	// 	return this.substring(from >= 0 ? from : this.length+from, to >= 0 ? to : this.length+to)
		
	// cpp string get: int from = 0
	// 	return this.substring(from >= 0 ? from : this.length+from)	
	
		
// A logical data type that can have the value true or false
enum bool: false, true
		
enum SortingOrder: Ascending, Descending
	
// A data container that grows in size as needed
cpp vector, std::vector
struct List<T>
	// // Do something for each item in a list
	// inline cpp void each -> inline void(
	// 	                       T it,      // The current item of the list we are iterating over
	// 	                       int i      // The index of the current item of the list we are iterating over
	// 	                   ) do           // Do this for each item in a list
	// 	for(let i=0, _subject=this, _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	// inline cpp void each <- inline void(
	// 	                       T it,      // The current item of the list we are iterating over
	// 	                       int i      // The index of the current item of the list we are iterating over
	// 	                   ) do           // Do this for each item in a list
	// 	for(let _subject=this, i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
		
	// // Do something for each item in a list. You can add or remove items inside the loop.
	// inline cpp void eachChangable -> inline void(
	// 	                       T it,      // The current item of the list we are iterating over
	// 	                       int i      // The index of the current item of the list we are iterating over
	// 	                   ) do           // Do this for each item in a list
	// 	for(let i=0, _subject=[...this], _len=_subject.length; i<_len; ++i) { let it = _subject[i]; do()}
		
	// inline cpp void eachChangable <- inline void(
	// 	                       T it,      // The current item of the list we are iterating over
	// 	                       int i      // The index of the current item of the list we are iterating over
	// 	                   ) do           // Do this for each item in a list
	// 	for(let _subject=[...this], i=_subject.length-1; i>=0; --i) { let it = _subject[i]; do()}
			
	// cpp void eachDistinct: TKey(T it) selector
	// 	                         void(
	// 	                             TKey it,
	// 	                             T[] items,
	// 	                             int i
	// 	                         ) do
	// 	if(this.length > 0) {
	// 		let _subject = this.sort((a,b) => selector(a) - selector(b))
	// 		for(let _nextIndex=1, it = selector(_subject[0]), i=0; _nextIndex<_subject.length; ++_nextIndex) { 
	// 			let _nextIt = selector(_subject[_nextIndex]);
	// 			if(_nextIt != it) {
	// 				let items = _subject.slice(i, _nextIndex);
	// 				do(it, items, i)
	// 				it = _nextIt;
	// 				i = _nextIndex;
	// 			}
	// 		}
	// 	}
			
	// Add an item to the end of the list
	inline cpp void add: T item // The item to add
		this.push_back(item)
		
	// inline cpp void add: T item  // The item to add
	// 	                T item2 // The second item to add
	// 	this.push(item, item2)
		
	// inline cpp void add: T item  // The item to add
	// 	                T item2 // The second item to add
	// 	                T item3 // The third item to add
	// 	this.push(item, item2, item3)
		
	// inline cpp void add: T item  // The item to add
	// 	                T item2 // The second item to add
	// 	                T item3 // The third item to add
	// 	                T item4 // The fourth item to add
	// 	this.push(item, item2, item3, item4)
		
	// inline cpp void add: T item  // The item to add
	// 	                T item2 // The second item to add
	// 	                T item3 // The third item to add
	// 	                T item4 // The fourth item to add
	// 	                T item5 // The fifth item to add
	// 	this.push(item, item2, item3, item4, item5)
		
	// // Add an item and remove a item from the beginning if the length exceeds a maximum value
	// inline cpp void add: T item        // The item to add
	// 	                int maxLength // If the list gets longer than this maximum length, remove an item from the beginning
	// 	this.push(item)
	// 	if(this.length > maxLength) this.splice(0, 1)
			
	// // Add an list of item to the end of the list
	// inline cpp void add: T[] items // The list of items to add
	// 	this.push(...items)
			
	// // Add an list of item to the end of the list
	// inline cpp void addRange: T[] items // The list of items to add
	// 	this.push(...items)
			
	// // Insert an item at a given index
	// inline cpp void insert: T item    // The item to insert
	// 	                   index = 0 // Insert the item at this index
	// 	this.splice(index, 0, item)
		
	// // Remove an item from the list
	// // Example: Remove the current player instrance from the list of playeres when they died
	// //     Player
 //   //         die
 //   //             players.remove me
	// cpp void remove: T item // The item to remove
	// 	var index = this.indexOf(item);
	// 	if(index > -1) this.splice(index, 1);
			
	// cpp void remove: T item  // The first item to remove
	// 	            T item2 // The second item to remove
	// 	var index = this.indexOf(item);
	// 	if(index > -1) this.splice(index, 1);
	// 	var index = this.indexOf(item2);
	// 	if(index > -1) this.splice(index, 1);
			
	// cpp void remove: T item  // The first item to remove
	// 	            T item2 // The second item to remove
	// 	            T item3 // The third item to remove
	// 	var index = this.indexOf(item);
	// 	if(index > -1) this.splice(index, 1);
	// 	var index = this.indexOf(item2);
	// 	if(index > -1) this.splice(index, 1);
	// 	var index = this.indexOf(item3);
	// 	if(index > -1) this.splice(index, 1);
			
	// cpp void remove: T item  // The first item to remove
	// 	            T item2 // The second item to remove
	// 	            T item3 // The third item to remove
	// 	            T item4 // The forth item to remove
	// 	var index = this.indexOf(item);
	// 	if(index > -1) this.splice(index, 1);
	// 	var index = this.indexOf(item2);
	// 	if(index > -1) this.splice(index, 1);
	// 	var index = this.indexOf(item3);
	// 	if(index > -1) this.splice(index, 1);
	// 	var index = this.indexOf(item4);
	// 	if(index > -1) this.splice(index, 1);
			
	// cpp void remove: T item  // The first item to remove
	// 	            T item2 // The second item to remove
	// 	            T item3 // The third item to remove
	// 	            T item4 // The forth item to remove
	// 	            T item5 // The fifth item to remove
	// 	var index = this.indexOf(item);
	// 	if(index > -1) this.splice(index, 1);
	// 	var index = this.indexOf(item2);
	// 	if(index > -1) this.splice(index, 1);
	// 	var index = this.indexOf(item3);
	// 	if(index > -1) this.splice(index, 1);
	// 	var index = this.indexOf(item4);
	// 	if(index > -1) this.splice(index, 1);
	// 	var index = this.indexOf(item5);
	// 	if(index > -1) this.splice(index, 1);
			
	// // Remove a list of items from the list
	// cpp void remove: T[] items // The items to remove
	// 	for(let item of items) {
	// 		var index = this.indexOf(item);
	// 		if(index > -1) this.splice(index, 1);
	// 	}
		
	// // Remove the item at the given index from the list
	// inline cpp void removeAt: int index // The index of the item to remove
	// 	this.splice(index, 1)
			
	// // Remove a range of items from the list
	// // Example: Remove the first 3 players from the list
	// //     players.removeRange 0 to 3
	// inline cpp void removeRange: int from = 0   // Remove items starting from this index
	// 	                        nocolon int to // Remove items up to (but not including) this index
	// 	this.splice(from, to-from)
			
	// // Remove all item the meet a specific condition
	// // Example: Remove all players that have died.
	// //     Player
 //   //         bool hasDied
	// //
	// //      app
 //   //          gameOver
 //   //              players.removeWhere.hasDied
	// removeWhere: bool(T a) condition // The condition to check
	// 	for this <-
	// 		if condition(.)
	// 			removeAt i
	// 	return null
		
	// // Remove the first item the meet a specific condition
	// // Example: Remove the first player with a health smaller than 10.
	// //     Player
 //   //         int health
	// //
	// //     app
 //   //         gameOver
 //   //             players.removeFirstWhere.health < 10
	// T removeFirstWhere: bool(T a) condition // The condition to check
	// 	for this
	// 		if condition(.)
	// 			removeAt i
	// 			return .
	// 	return null
	
	// // Add an item to the list if it isn't already in there
	// cpp void ensure: T item // The item to add
	// 	if(!this.includes(item))
	// 		this.push(item)
		
	// // Add each item from a list if it isn't already in there
	// cpp void ensure: T[] items // The list of items to add
	// 	for(let it of items)
	// 		if(!this.includes(it))
	// 			this.push(it)
		
	// // Returns whether the list contains the given item
	// inline cpp bool contains: T item // Check if the list contains this item
	// 	this.includes(item)
		
	// // The index of an item in the list
	// inline cpp int indexOf: T item // Get the index of this item
	// 	this.indexOf(item)
		
	// inline cpp void setList: T[] list
	// 	this.splice(0, this.length, ...list)
		
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
		
	// // Remove the last item from the list and return it
	// // Example: Print and remove "Orange" from the list
	// //     let fruits = ["Apple", "Lemon", "Orange"]
	// //     print fruits.pop
	// inline cpp T pop := this.pop()
		
	// // Remove an item at a specific index from the list and return it
	// // Example: Print and remove "Lemon" from the list
	// //     let fruits = ["Apple", "Lemon", "Orange"]
	// //     print fruits.popAt 1
	// inline cpp T popAt: int index
	// 	this.splice(index, 1)[0]
		
	// // Remove a range of items from the list and return a new list containing the removed items
	// // Example: Remote "Lemon" and "Orange" from the list of fruits a create a new list with those fruits 
	// //     let fruits = ["Apple", "Pear", "Lemon", "Orange"]
	// //     let citrusFruit  = fruits.popRange 2 to 4
	// inline cpp T[] popRange: int from
	// 	                    nocolon int to
	// 	this.splice(from, to-from)
		
	// // Remove the first item that meet a given condition and return it
	// // Exmaple: Remove the first player with a health below 10
	// //     let firstActivePlayer = players.popWhere.health < 10
	// T popWhere: bool(T a) condition // The condition for the item to meet
	// 	for length()
	// 		let item = get(i)
	// 		if condition(item)
	// 			removeAt i
	// 			return item
	// 	return null
	
	// // Remove the first item from the list and return it
	// // Example: Print and remove "Apple" from the list
	// //     let fruits = ["Apple", "Lemon", "Orange"]
	// //     print fruits.popFirst
	// cpp T popFirst
	// 	if(this.length == 0) return null
	// 	let firstItem = this[0]
	// 	this.splice(0, 1)
	// 	return firstItem
	
	// Gets the number of items in the list
	inline cpp int length() this.size()
	
	// // Truncated or expands the list the given number of items
	// cpp int setLength: int length // The new length of the list
	// 	this.length = length
	
	// // Removes all items from the list
	// inline cpp void clear := this.length = 0
	
	// // Create a shallow clone of the list
	// inline cpp T[] clone() [...this]
	
	// // Create a string representation of the list
	cpp string toString()
		std::string result = "[";
		for(int i=0; i<this.size(); i++) {
			if(i > 0) result += ", ";
			result += std::to_string(this[i]);
		}
		return result+"]";
		
	// // Gets a random item from the list
	// T random()
	// 	let randomInteger = math.randomInteger(length)
	// 	return get(randomInteger)
	
	// // Remove a random item from the list and return it
	// T popRandom()
	// 	int index = math.randomInteger(length)
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
	// inline cpp bool toBool := (this != null && this.length != 0) 
	
	// // Reverses the order of the items of the list in place
	// inline cpp T[] reverse() this.reverse()
		
	// // Return a list with all unique items of the original list
	// inline cpp T[] distinct() [...new Set(this)]
	
	// // Moves an item to the end of the list
	// cpp void moveToBack: T item // The item to move to the end of the list
	// 	var index = this.indexOf(item);
	// 	if(index != -1) {
	// 		let endIndex = this.length-1;
	// 		for(let i=index; i<endIndex; ++i) {
	// 			this[i] = this[i+1]
	// 		}
	// 		this[endIndex] = item
	// 	}
		
	// // Moves an item to the end of the list
	// cpp void moveToFront: T item // The item to move to the end of the list
	// 	var index = this.indexOf(item);
	// 	if(index != -1) {
	// 		for(let i=index; i>0; --i) {
	// 			this[i] = this[i-1]
	// 		}
	// 		this[0] = item
	// 	}
		
	// // Sort the list
	// inline cpp T[] sort
	// 	this.sort((a,b) => a - b)
	
	// inline cpp T[] sort: float(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
	// 	this.sort(comparer)
	
	// inline cpp T[] sort: Time(T a, T b) comparer // A function returning 1 if "a" is larger, -1 if "b" is larger, 0 if they are equal
	// 	this.sort(comparer)
	
	// // Sort the list by a given expression
	// T[] orderBy: float(T a) expression // First order by this expression
	// 	return this.sort(expression(a) - expression(b))
		
	// T[] orderBy: float(T it) expression           // First order by this expression
	// 	         label nocolon float(T it) thenBy // Then order by this expression
	// 	return this.sort(expression(a) - expression(b) || thenBy(a) - thenBy(b))
		
	// T[] orderBy: Time(T a) expression // First order by this expression
	// 	return this.sort(expression(a) - expression(b))
		
	// T[] orderBy: string(T a) expression // First order by this expression
	// 	return this.sort(expression(a) compareTo expression(b))
		
	// // Sort the list by a given expression
	// T[] orderBy: float(T a) expression // First order by this expression
	// 	         SortingOrder order    // Specifies if you want to sort in ascending or descending order
	// 	if order == Ascending: return this.sort(expression(a) - expression(b))
	// 	else                   return this.sort(expression(b) - expression(a))
		
	// // Returns true if the given condition is true for any item in the list
	// inline cpp bool any: bool(T a) predicate // The condition to check
	// 	this.some(predicate)
		
	// inline cpp bool none: bool(T a) predicate // The condition to check
	// 	!this.some(predicate)
		
	// // Returns true if the given condition is true for all items in the list
	// inline cpp bool all: bool(T a) predicate // The condition to check
	// 	this.every(predicate)
		
	// // Return a list that contains the selected field or expression for each item
	// inline cpp TValue[] select: TValue(T it) selector
	// 	this.map(selector)
		
	// // Get the selected field or expression for each item and flattens the result
	// inline cpp TValue[] flatten: TValue[](T it) selector
	// 	this.flatMap(selector)
		
	// // Find an item the meets the given condition
	// // Example: Find a player with a specific id
	// //     app
	// //         getPlayerById: int id
	// //             return players.find.id == id
	// inline cpp T find: bool(T a) condition // The condition to check
	// 	this.find(condition)
		
	// // Find the last item in the list the meets the given condition
	// // Example: Find a player with a specific id
	// //     app
	// //         getLastActivePlayer
	// //             return players.findLast.active
	// T findLast: bool(T a) condition // The condition to check
	// 	for this <-
	// 		if condition(.)
	// 			return .
	// 	return null
		
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
		
	// inline cpp T[] where: bool(T a) condition // The condition to check
	// 	this.filter(condition)
		
	// inline cpp T[] take: int count
	// 	this.slice(0, count)
		
	// int total: int(T it) selector
	// 	let sum = 0
	// 	for this: sum += selector(.)
	// 	return sum
		
	// int total: int(T it) selector
	// 	       label bool(T a) where
	// 	let sum = 0
	// 	for this: if where(.): sum += selector(.)
	// 	return sum
		
	// float total: float(T it) selector
	// 	let sum = 0.0
	// 	for this: sum += selector(.)
	// 	return sum
		
	// cpp int sum
	// 	let sum = 0;
	// 	for(let i=0; i<this.length; i++)
	// 		sum += this[i];
	// 	return sum;
	
	// cpp float average
	// 	return this.length > 0 ? this.sum() / this.length : 0
		
	// string joinToString: string(T a) selector
	// 	                 string separator = ", "
	// 	let result = ""
	// 	for this
	// 		if result: result += separator
	// 		result += selector(.)
	// 	return result
		
	// shuffle
	// 	for 1 to length <- i
	// 		var j = math.floor(math.randomFloat * (i + 1))
	// 		var temp = this.get(i)
	// 		this.set(i, this.get(j))
	// 		this.set(j, temp)
	// 	return this
		
	// private static transient T[] temporaryCopy
		
	// cpp T percentile: int value
	// 	if(this.length == 0) return 0
	// 	if(this.length == 1) return this[0]
	// 	if(!List_temporaryCopy) List_temporaryCopy = []
	// 	const len = List_temporaryCopy.length = this.length
	// 	for(let i=0; i<len; ++i) List_temporaryCopy[i] = this[i] 
	// 	List_temporaryCopy.sort((a,b) => a - b)
	// 	return List_temporaryCopy[Math.round((List_temporaryCopy.length-1) * value / 100)]
		
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
		
	// min: Time(T a) selector 
	// 	 Time threshold = Time.maxValue
	// 	 Time default = 0
	// 	Time resultValue = threshold
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
		
	// cpp T[] intersectWith: T[] other
	// 	const a = this || []
	// 	const b = other || []
	// 	const result = [];
	// 	const map = {};
	// 	for (let i = 0, length = b.length; i < length; ++i) {
	// 		map[b[i]] = true;
	// 	}
	// 	for (let i = 0, length = a.length; i < length; ++i) {
	// 		if (a[i] in map) result.push(a[i]);
	// 	}
	// 	return result;
		
	// // The first item of the list
	// inline cpp T first() this[0]
	
	// // The last item of the list
	// inline cpp T last() this[this.length-1]
		
	// Gets an item from the list
	inline cpp T get: implicit int index // The index of the item to get
		(index >= 0 ? this[index] : this[this.size()+index])
		
	// cpp T[] get: int from = 0 // Return a new list starting from this index
	// 	        int to       // Return a new list up to (but not including) this index
	// 	return this.slice(from, to)
	
	// cpp T[] get: int from // Return a new list starting from this index
	// 	return this.slice(from)
	
	cpp T set: int index // The index of the item to set
		       T value   // The new value to set
		return index >= 0 ? this[index] = value : this[this.size()+index] = value
		
	// // Tries to get an item from the list. If it doesn't exist, it sets it.
	// // TODO: Support index with side effect (e.g. list[index++] ?= 0)
	// inline cpp T getOrSet: int index
	// 	                  T value
	// 	(this.hasOwnProperty(index) ? this[index] : this[index] = value)
		
	// // Add a value to an item of the list
	// cpp T addToItem: int index // The index of the item to change
	// 	            T value   // The value to add to the item
	// 	return index >= 0 ? this[index] += value : this[this.length+index] += value
		
	// // Subtract a value from an item of the list
	// cpp T subtractFromItem: int index // The index of the item to change
	// 	                   T value   // The value to subtract from the item
	// 	return index >= 0 ? this[index] -= value : this[this.length+index] -= value
		
	// // Multiply an item of the list by a value
	// cpp T multiplyItem: int index // The index of the item to change
	// 	               T value   // The value to multiply the item by
	// 	return index >= 0 ? this[index] *= value : this[this.length+index] *= value
		
	// // Divide an item of the list by a value
	// cpp T divideItem: int index // The index of the item to change
	// 	             T value   // The value to divide the item by
	// 	return index >= 0 ? this[index] /= value : this[this.length+index] /= value
		
	// // Add 1 to item of the list
	// cpp T incrementItem: int index // The index of the item to change
	// 	return index >= 0 ? this[index]++ : this[this.length+index]++
	
	// // Subtract 1 from an item of the list
	// cpp T decrementItem: int index // The index of the item to change
	// 	return index >= 0 ? this[index]-- : this[this.length+index]--
		
immutable ImmutableList<T>
	// T[] list
	
	// inline T get: implicit int index // The index of the item to get
	// 	list.get(index)
		
// A data container that stores key-value pairs
cpp Map
class Map<TKey, TValue>
	// // Get the item assosiated with the given key
	// inline cpp TValue get: TKey key  // The key of the item to get from the map
	// 	this.get(key)
	
	// // Set the item for the given key
	// inline cpp void set: TKey key     // The key of the item to add to the map
	// 	                TValue value // The item to add to the map
	// 	this.set(key, value)
		
	// private cpp TValue setAndReturn: TKey key     // The key of the item to add to the map
	// 	                            TValue value // The item to add to the map
	// 	this.set(key, value);
	// 	return value;
		
	// inline cpp TValue getOrSet: TKey key
	// 	                       TValue value
	// 	(this.get(key) || (this.setAndReturn(key, value)))
		
	// // Remove the item assosiated with the given key
	// inline cpp void delete: TKey key  // The key of the item to remove from the map
	// 	this.delete(key)
		
	// // Remove all items from the map
	// inline cpp void clear
	// 	this.clear()
		

// Specifies that a function doesn't return a value
immutable struct void
	
// Denotes a type that can be null
struct Nullable<T>
	
// A Hashtable with keys of type 'string' and values of type 'any'
interface dynamic
	
// Any type
interface any
	
// The base class for all classes
interface object
	inline cpp bool toBool() (this != null)
	inline cpp string toString() object_stringify(this, 3)
		
	// static internal cpp string stringify: object subject, int depth = 0 
	// 	switch(typeof subject)
	// 	{
	// 		case "object":
	// 			if(subject === null) return "null"
	// 			let result = ""
	// 			if(subject.constructor) result += "_type: " + subject.constructor.name
	// 			if(depth > 0) {
	// 				for(let name in subject) {
	// 					let item = object_stringify(subject[name], depth-1)
	// 					if(item != "") {
	// 						if(result) result += ", "
	// 						result += name + ": " + item
	// 					}
	// 				}
	// 			}
	// 			return "\{" + result + "\}"
				
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
transient immutable SourceCodeLocation
	string file
	int start
	int end
	SourceCodeLocation left
	SourceCodeLocation right
	
	inline cpp bool toBool() (this != null)
	inline cpp string toString() (this.file+":"+this.start)

cpp exception, std::exception
immutable Error
	string message
	string stack
	implicit inline cpp string toString := this.stack
	
// A collection of basic system functions
global transient priority unit system
	// Executes code depending on whether a given condition is true or false
	global inline cpp void if: implicit bool condition // The condition to check
		                       inline void() then      // Do this if the condition is true
		if(condition) then()
			
	// Executes code depending on whether a given condition is true or false
	global inline cpp void if: implicit bool condition          // The condition to check
		                       inline void() then               // Do this if the condition is true
		                       inline label nocolon void() else // Do this if the condition is false
		if(condition) then() @else else()
			
	// Executes code as long as a given condition is true
	global inline cpp void while: implicit bool condition // The condition to check
		                         inline void() do        // Do this while to condition is true
		while(condition) do()
			
	global inline cpp void loop: void() do
		for(;;) do()
	
	global inline cpp void do: inline void() do            // Do this while to condition is true
		                      nocolon implicit bool while // The condition to check
		@do do() 
		@while(while)
	
	// Do something a given number of times or for each item in a list
	global inline cpp void for: ensureSingleExecution T[] subject    // The list to iterate over
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		                       //bool withIndex
		for(int _i=0, _len=subject.size(); _i<_len; ++_i) { auto _it = subject[_i]; do(_it, _i)}
		
	// Do something a given number of times or for each item in a list
	global inline cpp void for: ensureSingleExecution T[] subject    // The list to iterate over
		                       <- void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		for(int _i=subject.size()-1; _i>=0; --_i) { auto _it = subject[_i]; do(_it, _i)}
		
	global inline cpp void for: TValue[TKey] subject    // The map to iterate over
		                       -> void(
		                           TValue it, // The current value of the map we are iterating over with the for-loop
		                           TKey key   // The current key of the map we are iterating over with the for-loop
		                       ) do           // Do this for each item in a map
		foreach(auto _pair in subject) do(_pair.Value, _pair.Key)
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	global inline cpp void forChangeable: T[] subject    // The list to iterate over
		                       -> void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		auto _subject=new List<T>(subject);
		for(int _i=0, _len=_subject.size(); _i<_len; ++_i) { auto _it = _subject[_i]; do(_it, _i)}
		
	// Do something for each item in a list. You can add or remove items inside the loop.
	global inline cpp void forChangeable: T[] subject    // The list to iterate over
		                       <- void(
		                           T it,      // The current item of the list we are iterating over with the for-loop
		                           int i      // The index of the current item of the list we are iterating over with the for-loop
		                       ) do           // Do this for each item in a list
		auto _subject=new List<T>(subject);
		for(int _i=_subject.size()-1; _i>=0; --_i) { auto _it = _subject[_i]; do(_it, _i)}
		
	global inline cpp void for: int to // The exclusive upper bound to iterate towards
		                       -> void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this the given number of times
		for(int _i=0, _to=to; _i<_to; ++_i) do(_i)
		
	global inline cpp void for: int to // The exclusive upper bound to iterate towards
		                       <- void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this the given number of times
		for(int _i=to-1; _i>=0; --_i) do(_i)
		
	global inline cpp void for: int from
		                       -> void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this for each value in the given range
		                       int to // The exclusive upper bound
		for(int _i=from, _to=to; _i<_to; ++_i) do(_i)
		
	global inline cpp void for: int from
		                       <- void(
		                           int i      // The iteration variable of the for-loop
		                       ) do           // Do this for each value in the given range
		                       int to         // The exclusive upper bound
		for(int _i=to-1, _from=from; _i>=_from; --_i) do(_i)
		
	global inline cpp void for: string subject
		                       -> void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // Do this for each character in the given string
		for(int _i=0, _len=subject.size(); _i<_len; ++_i) { auto _it = _subject[_i]; do(_it, _i)}
	
	global inline cpp void for: string subject
		                       <- void(
		                           string it, // The current character of the string we are iterating over with the for-loop
		                           int i      // The index of the current character of the string we are iterating over with the for-loop
		                       ) do           // Do this for each character in the given string
		for(int _i=_subject.size()-1; _i>=0; --_i) { auto _it = _subject[_i]; do(_it, _i)}
				
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:null)
	global inline cpp void forLookAhead: T[] subject    // The list to iterate over
		                                    -> void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // Do this for each consecutive pair in a list
		for(auto _subject=subject, _len=_subject.size(), i=0; i<_len; ++i) { auto it = _subject[i], next = i+1<_len ? _subject[i+1] : null; do()}
		
	global inline cpp void forLookAhead: T[] subject    // The list to iterate over
		                                    <- void(
		                                        T it,      // The current item of the list we are iterating over with forLookAhead
		                                        T next,    // The next item of the list we are iterating over with forLookAhead
		                                        int i      // The index of the current item of the list we are iterating over with forLookAhead
		                                    ) do           // Do this for each consecutive pair in a list
		for(auto _subject=subject, i=_subject.size()-1; i>=0; --i) { auto it = _subject[i], next = i>0 ? _subject[i-1] : null; do()}
		
	// [a,b,c] -> (prev:null, a), (prev:a, b), (prev:b, c)
	global inline cpp void forLookBack: T[] subject    // The list to iterate over
		                                    -> void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // Do this for each consecutive pair in a list
		for(auto i=0, _len=subject.size(); i<_len; ++i) { auto it = subject[i], prev = i>0 ? subject[i-1] : null; do()}
		
	global inline cpp void forLookBack: T[] subject    // The list to iterate over
		                                    <- void(
		                                        T it,      // The current item of the list we are iterating over with forLookBack
		                                        T prev,    // The previous item of the list we are iterating over with forLookBack
		                                        int i      // The index of the current item of the list we are iterating over with forLookBack
		                                    ) do           // Do this for each consecutive pair in a list
		for(auto _subject=subject, _len=subject.size(), i=_len-1; i>=0; --i) { auto it = _subject[i], prev = i+1<_len ? _subject[i+1] : null; do()}
		
	// [a,b,c] -> (prev:null, a, next:b), (prev:a, b, next:c), (prev:b, c, next:null)
	global inline cpp void forLookAheadAndBack: T[] subject  // The list to iterate over
		                              -> void(
		                                  T it,    // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,  // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,  // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i    // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do         // Do this for each triple in a list
		for(auto i=0, _subject=subject, _len=_subject.size(); i<_len; ++i) { auto it = _subject[i], next = i+1<_len ? _subject[i+1] : null, prev = i>0 ? _subject[i-1] : null; do()}
		
	global inline cpp void forLookAheadAndBack: T[] subject  // The list to iterate over
		                              <- void(
		                                  T it,    // The current item of the list we are iterating over with forLookAheadAndBack
		                                  T prev,  // The previous item of the list we are iterating over with forLookAheadAndBack
		                                  T next,  // The next item of the list we are iterating over with forLookAheadAndBack
		                                  int i    // The index of the current item of the list we are iterating over with forLookAheadAndBack
		                              ) do         // Do this for each triple in a list
		for(auto _subject=subject, _len=_subject.size(), i=_len-1; i>=0; --i) { auto it = _subject[i], next = i>0 ? _subject[i-1] : null, prev = i+1<_len ? _subject[i+1] : null; do()}
		
	// [a,b,c] -> (a, next:b), (b, next:c)
	global inline cpp void forPairs: T[] subject  // The list to iterate over
		                            -> void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // Do this for each consecutive pair in a list
		for(auto i=0, _subject=subject, _len=_subject.size()-1; i<_len; ++i) { auto it = _subject[i], next = _subject[i+1]; do()}
		
	global inline cpp void forPairs: T[] subject  // The list to iterate over
		                            <- void(
		                                T it,    // The current item of the list we are iterating over with forPairs
		                                T next,  // The next item of the list we are iterating over with forPairs
		                                int i    // The index of the current item of the list we are iterating over with forPairs
		                            ) do         // Do this for each consecutive pair in a list
		for(auto _subject=subject, i=_subject.size()-1; i>0; --i) { auto it = _subject[i], next = _subject[i-1]; do()}
		
	// [a,b,c] -> (a, next:b), (b, next:c), (c, next:a) 
	global inline cpp void forWrappingPairs: T[] subject    // The list to iterate over
		                                   -> void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // Do this for each consecutive pair in a list
		for(auto _subject=subject, i=0, _len=_subject.size(); i<_len; ++i) { auto it = _subject[i], next = _subject[(i+1)%_len]; do()}
		
	global inline cpp void forWrappingPairs: T[] subject    // The list to iterate over
		                                   <- void(
		                                       T it,      // The current item of the list we are iterating over with forWrappingPairs
		                                       T next,    // The next item of the list we are iterating over with forWrappingPairs
		                                       int i      // The index of the current item of the list we are iterating over with forWrappingPairs
		                                   ) do           // Do this for each consecutive pair in a list
		for(auto _subject=subject, _len=_subject.size(), i=_len-1; i>=0; --i) { auto it = _subject[i], next = _subject[(((i-1)%_len)+_len)%_len]; do()}
		
	// [a,b,c] -> (prev:a, b, next:c)
	global inline cpp void forTriples: T[] subject  // The list to iterate over
		                              -> void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // Do this for each triple in a list
		for(auto i=1, _subject=subject, _len=_subject.size()-1; i<_len; ++i) { auto it = _subject[i], next = _subject[i+1], prev = _subject[i-1]; do()}
		
	global inline cpp void forTriples: T[] subject  // The list to iterate over
		                              <- void(
		                                  T it,    // The current item of the list we are iterating over with forTriple
		                                  T prev,  // The previous item of the list we are iterating over with forTriple
		                                  T next,  // The next item of the list we are iterating over with forTriple
		                                  int i    // The index of the current item of the list we are iterating over with forTriple
		                              ) do         // Do this for each triple in a list
		for(auto _subject=subject, i=_subject.size()-2; i>=1; --i) { auto it = _subject[i], next = _subject[i-1], prev = _subject[i+1]; do()}
		
	// [a,b,c] -> (prev:c, a, next:b), (prev:a, b, next:c), (prev:b, c, next:a)
	global inline cpp void forWrappingTriples: T[] subject  // The list to iterate over
		                                     -> void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // Do this for each triple in a list
		for(auto i=0, _subject=subject, _len=_subject.size(); i<_len; ++i) { auto it = _subject[i], next = _subject[(i+1)%_len], prev = _subject[(((i-1)%_len)+_len)%_len]; do()}
		
	global inline cpp void forWrappingTriples: T[] subject  // The list to iterate over
		                                     <- void(
		                                         T it,    // The current item of the list we are iterating over with forWrappingTriples
		                                         T prev,  // The previous item of the list we are iterating over with forWrappingTriples
		                                         T next,  // The next item of the list we are iterating over with forWrappingTriples
		                                         int i    // The index of the current item of the list we are iterating over with forWrappingTriples
		                                     ) do         // Do this for each triple in a list
		for(auto _subject=subject, _len=_subject.size(), i=_len-1; i>=0; --i) { auto it = _subject[i], next = _subject[(((i-1)%_len)+_len)%_len], prev = _subject[(i+1)%_len]; do()}

		
	// Prints a message to the console
	global cpp void print: logstring text // The text, variables or expressions to print
		std::cout << text << std::endl;
		
	cpp void log: any value
		std::cout << value << std::endl;
	
	// Display a message in the timeline
	global cpp void watch: logstring text // The text, variables or expressions to watch
		std::cout << text << std::endl;
	
	// Shows a dialog box with a given message
	global inline cpp void alert: implicit string message // The message to show
		alert(message)
		
	global inline cpp void break() break
	global inline cpp void continue() continue
		
	global inline cpp void try: inline void() code
		                       inline nocolon void(Error error) catch
		try code() @catch(error) catch()
		
	global inline cpp void try: inline void() code
		                       inline nocolon void(Error error) catch
		                       inline nocolon void() finally
		try code() @catch(error) catch() @finally finally()
		
	global inline cpp void try: inline void() code
		                       inline nocolon void() finally
		try code() @finally finally()
		
global transient priority low unit system		
	// Creates a new list populated with the results of calling a function on every element of the list
	// global inline cpp TResult[] for: T[] subject // The list to iterate over
	// 	                       -> TResult(
	// 	                           T it         // The current item of the list we are iterating over with the for-loop
	// 	                       ) do             // Select the field or expression to be included in the result
	// 	subject.map(do)
		
	// // Creates a new list populated with the results of calling a function on every element of the list
	// global inline cpp TResult[] for: T[] subject // The list to iterate over
	// 	                       <- TResult(
	// 	                           T it         // The current item of the list we are iterating over with the for-loop
	// 	                       ) do             // Select the field or expression to be included in the result
	// 	subject.map(do).reverse()
	
	// global inline cpp TResult[] for: int to,    // The exclusive upper bound to iterate towards
	// 	                            TResult(
	// 	                                int i  // The iteration variable of the for-loop
	// 	                            ) do       // Select the field or expression to be included in the result
	// 	int_enumerate(0, to, do)
		
	// global inline cpp TResult[] for: int from,    // The integer to start iterating from
	// 	                            TResult(
	// 	                                int i    // The iteration variable of the for-loop
	// 	                            ) do         // Select the field or expression to be included in the result
	// 	                            label int to // The exclusive upper bound to iterate towards
	// 	int_enumerate(from, to, do)
		
		
// A collection of mathematical functions and constants
global skipInit unit math
	// Returns the absolute value
	inline cpp int abs: int value // The value to return the absolute value of
		Math.abs(value)
		
	// Returns the absolute value
	inline cpp float abs: float value // The value to return the absolute value of
		Math.abs(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline cpp int ceil: float value // The value to round up
		Math.ceil(value)
		
	// Returns the smallest integer greater than or equal to the given value 
	inline cpp Time ceil: Time value // The value to round up
		Math.ceil(value)
		
	// Returns the largest integer less than or equal to the given value
	inline cpp int floor: float value // The value to round down
		Math.floor(value)
		
	// Returns the largest integer less than or equal to the given value
	inline cpp Time floor: Time value // The value to round down
		Math.floor(value)
		
	// Returns the given value rounded to the nearest integer
	inline cpp int round: float value // The value to round
		Math.round(value)
		
	// Returns the given value rounded to the nearest integer
	inline cpp Time round: Time value // The angle to round
		Math.round(value)
		
	inline cpp int min: int a // The first value
		               int b // The second value
		Math.min(a, b)
		
	// Returns the smallest of the given values
	inline cpp float min: float a // The first value
		                 float b // The second value
		Math.min(a, b)
		
	// Returns the largest of the given values
	inline cpp int max: int a // The first value
		               int b // The second value
		Math.max(a, b)
		
	// Returns the largest of the given values
	inline cpp float max: float a // The first value
		                 float b // The second value
		Math.max(a, b)
		
	// Returns the largest of the given values
	inline cpp Time max: Time a // The first time
		                Time b // The second time
		Math.max(a, b)
		
	// Returns the positive square root of the given value
	inline cpp float sqrt: float value // The value to return the square root of
		Math.sqrt(value)
		
	inline cpp float pow: float base
		                 float exponent
		Math.pow(base, exponent)
		
	inline cpp int shiftLeft: int value
		                     int count
		(value << count)
	
	inline cpp int shiftRight: int value
		                      int count
		(value >> count)
		
	moveTowards: float value
		         float targetValue
		         float speed = 1
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
			
	// // Maps a value from an input range to an output range
	// map: Time value        // The input value 
	// 	 Time from = 0     // The beginning of the input range
	// 	 Time to = 1       // The end of the input range
	// 	 float start = 0   // The lowest possible output value, will be returned for values smaller than "from".
	// 	 float target = 1  // The highest possible output value, will be returned for values larger than "to".
	// 	if value <= from: return start
	// 	if value >= to:   return target
	// 	let factor = (value-from) / (to-from)
	// 	return start + (target-start) * factor
			
	// // Maps a value from an input range to an output range
	// map: float value       // The input value 
	// 	 float from = 0    // The beginning of the input range
	// 	 float to = 1      // The end of the input range
	// 	 float start = 0   // The lowest possible output value, will be returned for values smaller than "from".
	// 	 float target = 1  // The highest possible output value, will be returned for values larger than "to".
	// 	if value <= from: return start
	// 	if value >= to:   return target
	// 	let factor = (value-from) / (to-from)
	// 	return start + (target-start) * factor
			
	// // Maps a value from an input range to an output range
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
		
struct Average
	float total
	int count
	// add: float value
	// 	total += value
	// 	count++
	// average := total / count		

immutable Range
	int from // The start of the range
	int to   // The end of the range
	
	Range: int from       // The start of the range
		   nocolon int to // The end of the range
	
	inline cpp bool contains: int value
		(value >= this.from && value < this.from)
	
	inline cpp bool containsInclusively: int value
		(value >= this.from && value <= this.from)

unit Json
	inline cpp dynamic parse(string str) JSON.parse(str)
	inline cpp string stringify(any object) JSON.stringify(object)
		
enum Language: English, German, Spanish, Frensh, Italian, Portuguese, Japanese, Chinese, Korean, Dutch, Turkish, Polish, Russian, Hindi, Arabic, Bengali, Urdu, Indonesian, Invariant = 1000

unit Loca
	// private const string[] defaultLocaleForLanguage = ["en-001", "de-DE", "es-ES", "fr-FR", "it-IT", "pt-PT", "ja-JP", "zh-Hans-CN", "ko-KR", "nl-NL", "tr-TR", "pl-PL", "ru-RU", "hi-IN", "ar-001", "bn-BD", "ur-IN", "id-ID"]
	
	// visible Language[] supportedLanguages = [English, German]
	// visible Language language = English
	// visible string locale = defaultLocaleForLanguage[language]
	
	// init
	// 	setLanguage English
	
	// cpp void setLanguage: Language language
	// 	                 string locale = ""
	// 	Loca_language = language
	// 	Loca_locale = locale || Loca_defaultLocaleForLanguage[language]
		
	// cpp void format: int id
	// 	let entry = _strings[Loca_language][id]
	// 	if(!entry || entry.s.length == 0) return "##########"
	// 	let strings = entry.s
	// 	let result = strings[0]
	// 	let stringIndex = 1
	// 	for(let placeholderNumber of entry.p) {
	// 		if(placeholderNumber >= 0) {
	// 			// Placeholder
	// 			//     "Step {currentStep}"                           {s:["Step "],p:[0]}
	// 			//            ^                                           ^           ^
	// 			let placeholderValue = arguments[placeholderNumber+1]
	// 			result += placeholderValue
	// 			if(stringIndex < strings.length) {
	// 				let str = strings[stringIndex++]
	// 				if(str) result += str
	// 			}
	// 		} else {
	// 			// Placeholder with pluralization
	// 			//     "Waiting for {playerCount} player[s]"          {s:["Waiting for ", " player.", " players."],p:[-1]}
	// 			//                   ^                                                    ^           ^               ^
	// 			// If the placeholder value is 1, we take the first string (sigular version), otherwise the second (plural version)
	// 			let placeholderValue = arguments[-placeholderNumber]
	// 			result += placeholderValue
	// 			let str = strings[placeholderValue == 1 ? stringIndex : stringIndex+1]
	// 			if(str) result += str
	// 			stringIndex += 2
	// 		}
	// 	}
	// 	return result

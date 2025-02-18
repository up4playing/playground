skipInit transient float Time
	// // The number of milliseconds elapsed since January 1, 1970
	static Time now = 0
	
	// // The largest possible time value
	// const inline cpp Time maxValue := Number.MAX_VALUE
	
	// // The smallest possible time value
	// const inline cpp Time minValue := Number.MIN_VALUE
	
	static internal cpp(chrono) int realTime
		return std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::high_resolution_clock::now().time_since_epoch()).count();
	
	// The current frame
	static inline cpp int frame := core::frame

	// static Time fromTimeString(string timeString)
	// 	if !timeString: return 0 milliseconds
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
		
	// static inline cpp Time fromIsoString: string isoString
	// 	new Date(isoString).getTime()
		
	inline cpp float toFloat() ((doubel)this)
	
	inline cpp(string) string toString := std::to_string(this)
		
	// Returns true if the time is not zero
	inline cpp bool toBool := this
	
	// inline cpp string format: int fractionDigits, int minIntegerDigits = 1, bool grouping = false
	// 	this.toLocaleString('en-US', {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	// inline cpp string format: int fractionDigits, bool grouping = false
	// 	this.toLocaleString('en-US', {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, useGrouping:grouping})
		
	// inline cpp string format: int minIntegerDigits = 1, bool grouping = false
	// 	this.toLocaleString('en-US', {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
	
	// inline cpp int milliseconds := Math.floor((this %    1000)          ) 
	// inline cpp int seconds      := Math.floor((this %   60000) /    1000) 
	// inline cpp int minutes      := Math.floor((this % 3600000) /   60000) 
	// inline cpp int hours        := Math.floor((this          ) / 3600000)
		
	// // (31.12.)
	// inline cpp string dayMonthString(language = Loca.language) new Date(this).dayMonthString(language)
		
	// // (31.12.2000)
	// inline cpp string dayMonthYearString(language = Loca.language) new Date(this).dayMonthYearString(language)
	
	// // (31 December 2000)
	// inline cpp string dayLongMonthNameYearString(language = Loca.language) new Date(this).dayLongMonthNameYearString(language)
	
	// // (31 Dec 2000)
	// inline cpp string dayShortMonthNameYearString(language = Loca.language) new Date(this).dayShortMonthNameYearString(language)
	
	// // (Monday)
	// inline cpp string weekdayString(language = Loca.language) new Date(this).weekdayString(language)
	
	// // (23:59)
	// inline cpp string hourMinuteString(language = Loca.language) new Date(this).hourMinuteString(language)
	
 //	// (59:59)
	// inline cpp string minuteSecondString() (Math.floor((this % 3600000) / 60000) + (this % 60000 < 10000 ? ":0":":") + Math.floor((this % 60000) / 1000))
	
	// // (23:59:59)
	// inline cpp string hourMinuteSecondString(language = Loca.language) new Date(this).hourMinuteSecondString(language)
	
	// // (31.12.2000 23:59)
	// inline cpp string dayMonthYearHourMinuteString(language = Loca.language) new Date(this).dayMonthYearHourMinuteString(language)
	
	// // (31.12.2000 23:59:59)
	// inline cpp string dayMonthYearHourMinuteSecondString(language = Loca.language) new Date(this).dayMonthYearHourMinuteSecondString(language)
	
	// // (31-12-2000 23-59-59)
	// inline cpp string invariantDayMonthYearHourMinuteSecondString() new Date(this).invariantDayMonthYearHourMinuteSecondString()
			
	inline cpp Time  operator +  (Time a, Time b) a+b
	inline cpp Time  operator +  (Time a, int b) a+b
	inline cpp Time  operator +  (Time a, float b) a+b
	
	inline cpp Time  operator -  (Time a, Time b) a-b
	inline cpp Time  operator -  (Time a, int b) a-b
	inline cpp Time  operator -  (Time a, float b) a-b
	
	inline cpp float operator /  (Time a, Time b) a/b
	inline cpp Time  operator /  (Time a, int b) a/b
	inline cpp Time  operator /  (Time a, float b) a/b
	
	inline cpp Time  operator *  (Time a, int b) a*b
	inline cpp Time  operator *  (Time a, float b) a*b
	inline cpp Time  operator *  (int a, Time b) a*b
	inline cpp Time  operator *  (float a, Time b) a*b
	
	inline cpp Time  operator %  (Time a, int b) a%b
	inline cpp Time  operator %  (Time a, Time b) a%b
	
	inline cpp bool  operator <  (Time a, Time b) a<b
	inline cpp bool  operator <= (Time a, Time b) a<=b
	inline cpp bool  operator >  (Time a, Time b) a>b
	inline cpp bool  operator >= (Time a, Time b) a>=b
	
	// static measure: void() do
	// 	let startTime = preciseTime
	// 	do
	// 	return preciseTime - startTime
		
	// inline cpp float in: TimeUnit unit // Convert the time to this unit
	// 	(unit==1 ? this/1000 : unit==2 ? this/60000 : unit==3 ? this/3600000 : unit==4 ? this/86400000 : this)
		
	// cpp static void startTimer
	// 	window._timerStart = performance.now();
		
	// cpp static void printTimer: string text
	// 	let now = performance.now();
	// 	log(text+": "+(now-window._timerStart));
	// 	window._timerStart = now;
		
	// static inline cpp float preciseTime := performance.now()
		
enum TimeUnit
	ms   // Milliseconds
	s    // Seconds
	min  // Minutes
	h    // Hours
	days // Days
		
cpp(Date) transient struct Date
	// inline cpp Date() new Date()
	// static inline cpp Date now := new Date()
		
	// const dayStrings = [
	// 	["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	// 	["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
	// ]
		
	// const shortDayStrings = [
	// 	["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
	// 	["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
	// ]
	
	// inline cpp int year := this.getFullYear()
	// inline cpp int month := (this.getMonth()+1)
	// inline cpp int day := this.getDate()
	// inline cpp int dayOfWeek := this.getDay()
		
	// inline cpp int hour := this.getHours()
	// inline cpp int minute := this.getMinutes()
	// inline cpp int second := this.getSeconds()
		
	// inline cpp string twoDigitMonth := (this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})
	// inline cpp string twoDigitDay := this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})
	// inline cpp string twoDigitHour := this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})
	// inline cpp string twoDigitMinute := this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	// inline cpp string twoDigitSecond := this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
		
	// inline cpp Time timeOfDay := this.getHours()*3600000 + this.getMinutes()*60000
	
	// private static string toTwoDigitString: int value
	// 	return value < 10 ? "0"+value.toString : value.toString
	
	// // (31.12.)
	// cpp string dayMonthString: language = Loca.language
	// 	return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."
	
	// // (31.12.2000)
	// cpp string dayMonthYearString: language = Loca.language
	// 	return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()
	
	// // (31 December 2000)
	// cpp string dayLongMonthNameYearString: language = Loca.language
	// 	return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+" "+this.toLocaleString('en-US', {month: 'long'})+" "+this.getFullYear()
	
	// // (31 Dec 2000)
	// cpp string dayShortMonthNameYearString: language = Loca.language
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
	// cpp string dayMonthYearHourMinuteString: language = Loca.language
	// 	if(language == 1000) return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	// 	else                 return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// // (31.12.2000 23:59:59)
	// cpp string dayMonthYearHourMinuteSecondString: language = Loca.language
	// 	return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+":"+this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// // (31-12-2000 23-59-59)
	// cpp string invariantDayMonthYearHourMinuteSecondString: language = Loca.language
	// 	return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getFullYear()+" "+this.getHours().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getMinutes().toLocaleString('en-US', {minimumIntegerDigits:2})+"-"+this.getSeconds().toLocaleString('en-US', {minimumIntegerDigits:2})
	
	// // The number of milliseconds elapsed since January 1, 1970
	// inline cpp Time time := this.getTime()
		
	// // The data and time in ISO 8601 format, for example "2000-12-31T17:30:00.000Z"
	// cpp string isoString()
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

	// static inline cpp Date fromTime(Time time) new Date(time)
	// static inline cpp Date fromValues(int year, int month=1, int day=1, int hour = 0, int minute = 0, int second = 0) new Date(year, month-1, day, hour, minute, second)
	
	// // Returns the real time, even during replay. Be careful: This can break the replay.
	// static inline cpp Date realtime := new Date()

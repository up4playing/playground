skipInit transient float Time
	static int timezoneOffset
	
	// The largest possible time value
	const inline js Time maxValue := Number.MAX_VALUE
	
	// The smallest possible time value
	const inline js Time minValue := Number.MIN_VALUE
	
	static internal inline js float realTime := Date.now()

	inline js Time += float value: this += value

	static Time fromTimeString(string timeString)
		if !timeString: return 0 milliseconds
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
		
	static inline js Time fromValues(int year, int month=1, int day=1, int hour = 0, int minute = 0, int second = 0) new Date(year, (month)-1, day, hour, minute, second).getTime()
		
	inline js implicit float toFloat() this
	inline js int toInt() Math.floor(this)
	inline js string toString() this.toString()
		
	// Returns true if the time is not zero
	inline js bool toBool := this
	
	inline js string format: int fractionDigits, int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString('en-US', {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
		
	inline js string format: int fractionDigits, bool grouping = false
		this.toLocaleString('en-US', {maximumFractionDigits:fractionDigits, minimumFractionDigits:fractionDigits, useGrouping:grouping})
		
	inline js string format: int minIntegerDigits = 1, bool grouping = false
		this.toLocaleString('en-US', {minimumIntegerDigits:minIntegerDigits, useGrouping:grouping})
	
	inline js int milliseconds := Math.floor((this %    1000)          ) 
	inline js int seconds      := Math.floor((this %   60000) /    1000) 
	inline js int minutes      := Math.floor((this % 3600000) /   60000) 
	inline js int hours        := Math.floor((this          ) / 3600000)
		
	inline js int totalSeconds      := Math.floor(this /      1000) 
	inline js int totalMinutes      := Math.floor(this /     60000) 
	inline js int totalHours        := Math.floor(this /   3600000)
	inline js int totalDays         := Math.floor(this /  86400000)
	inline js int totalWeeks        := Math.floor(this / 604800000)
		
	// (31.12.)
	inline js string dayMonthString(language = Loca.language) new DateTime(this).dayMonthString(language)
		
	// (31.12.2000)
	inline js string dayMonthYearString(language = Loca.language) new DateTime(this).dayMonthYearString(language)
	
	// (31 December 2000)
	inline js string dayLongMonthNameYearString(language = Loca.language) new DateTime(this).dayLongMonthNameYearString(language)
	
	// (31 Dec 2000)
	inline js string dayShortMonthNameYearString(language = Loca.language) new DateTime(this).dayShortMonthNameYearString(language)
	
	// (Monday, December 31)
	inline string dayOfWeekDayMonthString(language = Loca.language) new DateTime(this).dayOfWeekDayMonthString(language)
	
	// (Monday)
	inline js string weekdayString(language = Loca.language) new DateTime(this).weekdayString(language)
	
	// (Monday, December 31 at 12:59 pm)
	inline js string dayOfWeekDayMonthAtHourMinuteString(language = Loca.language) new DateTime(this).dayOfWeekDayMonthAtHourMinuteString(language)
	
	// (23:59) The time is assumed to be local time, doesn't account for timezone offset
	inline string hourMinuteString(language = Loca.language) Time.toHourMinuteString(this, language)
		
	// (23:59) The time is assumed to be local time, doesn't account for timezone offset
	static string toHourMinuteString: Time value, language = Loca.language
		let hour = math.floor (value % 86400000) / 3600000
		let minute = math.floor (value % 3600000) / 60000
		if language == English: return ""+((hour-1)%12+1)+":"+(minute < 10 ? "0":"")+minute+(hour < 12 ? " am":" pm")
		else                    return ""+hour+":"+(minute < 10 ? "0":"")+minute
	
 	// (59:59) The time is assumed to be local time, doesn't account for timezone offset
	inline js string minuteSecondString() (Math.floor((this % 3600000) / 60000) + (this % 60000 < 10000 ? ":0":":") + Math.floor((this % 60000) / 1000))
	
	// (23:59:59)
	inline js string hourMinuteSecondString(language = Loca.language) new Date(this).hourMinuteSecondString(language)
	
	// (31.12.2000 23:59)
	inline js string dayMonthYearHourMinuteString(language = Loca.language) new Date(this).dayMonthYearHourMinuteString(language)
	
	// (31.12.2000 23:59:59)
	inline js string dayMonthYearHourMinuteSecondString(language = Loca.language) new Date(this).dayMonthYearHourMinuteSecondString(language)
	
	// (31-12-2000 23-59-59)
	inline js string invariantDayMonthYearHourMinuteSecondString() new Date(this).invariantDayMonthYearHourMinuteSecondString()
			
	// (20001231235959+02:00)
	inline js string compactString() new DateTime(this).compactString()
		
	// (7 weeks)
	inline string minutesHoursDaysOrWeeksString(showWeeksAfterDays = 31) toMinutesHoursDaysOrWeeksString(this, showWeeksAfterDays)
		
	private static string toMinutesHoursDaysOrWeeksString: Time time, showWeeksAfterDays = 31
		if time < 2 minutes: return "1 minute"
		if time < 1 hours:   return "{time.totalMinutes} minutes"
		if time < 2 hours:   return "1 hour"
		if time < 1 days:    return "{time.totalHours} hours"
		if time < 2 days:    return "1 day"
		if time < showWeeksAfterDays days: return "{time.totalDays} days"
		if time < 2 weeks:   return "1 week"
		                     return "{time.totalWeeks} weeks"
	inline Time + Time value
	inline Time - Time value
	inline float / Time value
	inline float * Time value
	
	inline Time += Time value
	inline Time -= Time value
	inline Time /= Time value
	inline Time *= Time value
	
	inline bool == Time value
	inline bool != Time value
	inline bool < Time value
	inline bool <= Time value
	inline bool > Time value
	inline bool >= Time value
	
	inline js Time % ensureSingleExecution Time value
		((this % value) + value) % value
	
	static measure: void() do
		let startTime = preciseTime
		do
		return preciseTime - startTime
		
	inline js float in: TimeUnit unit // Convert the time to this unit
		(unit==1 ? this/1000 : unit==2 ? this/60000 : unit==3 ? this/3600000 : unit==4 ? this/86400000 : this)
		
	js static void startTimer() window._timerStart = performance.now()
	js static void printTimer(string text) log(text+": "+(performance.now()-window._timerStart))
	static inline js float preciseTime := performance.now()
		
enum TimeUnit
	milliseconds // Milliseconds
	seconds      // Seconds
	minutes      // Minutes
	hours        // Hours
	days         // Days
	
// Calculate dates using pure math for better performance without using the Date class
immutable struct DateTime
	const dayNames = [
		["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
		["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
	]
	const shortDayNames = [
		["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
		["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
	]
	const monthNames = [
		["","January","February","March","April","May","June","July","August","September","October","November","December"]
		["","Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
	]
	const atString = [" at ", " um "]
	const timeSuffixString = ["", " Uhr"]
	
	const daysInMonthCommon = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	const daysInMonthLeap = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

	int year
	int month
	int day
	int dayOfWeek
	int hour
	int minute
	int second
	
	string twoDigitDay    := (this.day < 10 ? "0"+this.day : this.day.toString())
	string twoDigitMonth  := (this.month < 10 ? "0"+this.month : this.month.toString())
	string twoDigitHour   := (this.hour < 10 ? "0"+this.hour : this.hour.toString())
	string twoDigitMinute := (this.minute < 10 ? "0"+this.minute : this.minute.toString())
	string twoDigitSecond := (this.second < 10 ? "0"+this.second : this.second.toString())
	
	DateTime: Time time
		const localTime = time - Time.timezoneOffset
		const daysSinceEpoch = math.floor(localTime / 86400000)
		
		// Year
		let currentYear = 1970;
		let daysLeft = daysSinceEpoch;
		
		loop
			let daysInYear = ((currentYear remainder 4) == 0 && (currentYear remainder 100) != 0) || (currentYear remainder 400 == 0) ? 366 : 365;
			if daysLeft < daysInYear: break
			daysLeft -= daysInYear
			currentYear++
		
		// Month and Day
		let daysInMonth = ((currentYear remainder 4) == 0 && (currentYear remainder 100) != 0) || (currentYear remainder 400 == 0) ? daysInMonthLeap : daysInMonthCommon
		let currentMonth = 0
		
		while daysLeft >= daysInMonth[currentMonth]
			daysLeft -= daysInMonth[currentMonth]
			currentMonth++
			
		this.day = daysLeft + 1
		this.month = currentMonth + 1
		this.year = currentYear
		this.dayOfWeek = (daysSinceEpoch + 4) % 7; // January 1, 1970 was a Thursday
		this.hour = math.floor (localTime % 86400000) / 3600000
		this.minute = math.floor (localTime % 3600000) / 60000
		this.second = math.floor (localTime % 60000) / 1000
		
	// (31.12.)
	dayMonthString: language = Loca.language
		if language == German return "{day}.{month}."
		else                  return "{month}-{day}"
		
	// (31.12.2000)
	dayMonthYearString: language = Loca.language
		if language == German return "{day}.{month}.{year}"
		else                  return "{year}-{month}-{day}"
	
	// (31 December 2000)
	dayMonthNameYearString: language = Loca.language
		return "{day} {monthNames[language][month]} {year}"
		
	// (Monday, December 31)
	dayOfWeekDayMonthString: language = Loca.language
		if language == German return "{dayNames[language][dayOfWeek]}, {day}. {monthNames[language][month]}"
		else                  return "{dayNames[language][dayOfWeek]}, {day} {monthNames[language][month]}"
			
	// (Monday)
	dayOfWeekString: language = Loca.language
		return dayNames[language][dayOfWeek]
		
	// (12:59 pm)
	hourMinuteString: language = Loca.language
		if language == English: return ""+((hour-1)%12+1)+":"+(minute < 10 ? "0":"")+minute+(hour < 12 ? " am":" pm")
		else                    return ""+hour+":"+(minute < 10 ? "0":"")+minute
		
	// (Monday, December 31 at 12:59 pm)
	dayOfWeekDayMonthAtHourMinuteString: language = Loca.language
		return dayOfWeekDayMonthString(language) + atString[language] + hourMinuteString(language) + timeSuffixString[language]
		
	// (20001231235959+02:00)
	compactString
		return "{year}{twoDigitMonth}{twoDigitDay}T{twoDigitHour}{twoDigitMinute}{twoDigitSecond}+02:00"
		
// Calculate dates using the JavaScript Date class
js(Date) transient class Date
	inline js Date() new Date()
	static inline js Date now := new Date()
		
	const dayStrings = [
		["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
		["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
	]
		
	const shortDayStrings = [
		["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
		["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]
	]
	
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
	
	// (31.12.)
	js string dayMonthString: language = Loca.language
		return this.getDate().toLocaleString('en-US', {minimumIntegerDigits:2})+"."+(this.getMonth()+1).toLocaleString('en-US', {minimumIntegerDigits:2})+"."
	
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
	
	// (Mon)
	string shortWeekdayString: language = Loca.language
		return shortDayStrings[language][dayOfWeek]
	
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
			"-" + pad(this.getMonth() + 1) +
			"-" + pad(this.getDate()) +
			"T" + pad(this.getHours()) +
			":" + pad(this.getMinutes()) +
			":" + pad(this.getSeconds()) +
			dif + pad(Math.floor(Math.abs(tzo) / 60)) +
			":" + pad(Math.abs(tzo) % 60);

	static inline js Date fromTime(Time time) new Date(time)
	static inline js Date fromValues(int year, int month=1, int day=1, int hour = 0, int minute = 0, int second = 0) new Date(year, (month)-1, day, hour, minute, second)
	
	// Returns the real time, even during replay. Be careful: This can break the replay.
	static inline js Date realtime := new Date()

global unit system
	global cpp(android/log.h) void print(string value)
		__android_log_print(ANDROID_LOG_VERBOSE, "LiveTime", "%s", value.c_str());
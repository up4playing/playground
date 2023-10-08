global skipInit unit math
	init
		initDefaultRandomGenerator
		
	cpp(cstdlib, ctime) void initDefaultRandomGenerator
		std::srand(std::time(nullptr));
		
	// Generates a random integer
	global inline cpp(cstdlib, cmath) int randomInteger: int from // The inclusive lower bound of the random integer
		                                          int to // The exclusive upper bound of the random integer
		(from + std::floor(std::rand() * (to-from)))
	
	global inline cpp(cstdlib, cmath) int randomInteger: int to = 2147483647 // The exclusive upper bound of the random integer
		(from + std::floor(std::rand() * (to-from)))
	
	// Generates a random float
	global inline cpp(cstdlib) int randomFloat: float from
		                                 float to
		(from + std::rand() * (to-from))
	
	global inline cpp(cstdlib) int randomFloat: float to = 1.0
		(std::rand() * to)

// Language: LiveTime
// A student class with a name and a score
class Student
	int id
	string studentName
    int score
	bool alive
    Vector2 position
	IntVector2 size
	Touch dragTouch
    // Draw a button 3 times
    draw
        for 3
            drawImage Button, position
	tick
		for size.x -> x
			for size.y -> y
				IntVector2 pos = {x,y}
				print pos
		
		// Drag the student with the mouse
		Input.onTouchDownWithin position, size
			dragTouch = .
		Input.onTouchMove dragTouch
			position = .position
		Input.onTouchUp
			dragTouch = null
			
		// If the student is clicked, restart the game
		Input.onTouchDownWithin position, size
			training.restartGame
			
		// Create a list with all number from 5 to 10
		int[] list
		for 5 to 10
			list.add .
			
    restartGame 
	
// A school class
unit training
    // List of students
    Student[] students
	// Function to restart the game for each student
    restartGame
        students.each.restartGame
    tick
		int studentId = 7
		let student = students.find.id == studentId
		let bestStudent = students.withMax.score
		let highestScore = students.max.score
		let top3Students = students.orderBy(.score).reverse.take 3
	
		students = []
		// Add student
		students.add {studentName:"John", score:0}
	
        // Draw all students
		students.each.draw
		
		// Create a list with all even numbers between 10 and 20
		int[] list
		for 10 to 20
		   if . % 2 == 0: list.add .
		
		// Iterate the list in revers order and remove all values smaller than 15
		for list <-
			if . < 15: list.remove .
		
		// Print list
		for list
			print .
		   
		// If the student clicks, restart the game
		Input.onTouchDown
		   restartGame
		
		// Print the average score of all students
		let totalScore = 0
		for students
		   totalScore += .score
		let averageScore = totalScore / students.length
		print "Average score of all students: {averageScore}"
		
		// Create a list of students that have an even score and print their names
		Student[] evenStudents
		for students
			if .score % 2 == 0: evenStudents.add .
		for evenStudents
			print .studentName
				
		// Count the number of students that are not alive and have a score higher than 10
		let number = students.count.alive and .score > 10
		
		// Get all students that are still alive and sort them by score
		let aliveStudents = students.where.alive
		aliveStudents.orderBy.score

class AStarNode
	IntVector2 pos
	f = 0
	g = 0
	h = 0
	cost = 1
	visited = false
	closed = false
	AStarNode parent

class BinaryHeap
	AStarNode[] content
	
	scoreFunction: AStarNode node
		return node.f
	
	push: AStarNode element
		// Add the new element to the end of the array.
		content.add element

		// Allow it to sink down.
		sinkDown content.length - 1
		
	pop
		// Store the first element so we can return it later.
		let result = content[0]
		
		// Get the element at the end of the array.
		let end = this.content.pop()
		
		// If there are any elements left, put the end element at the
		// start, and let it bubble up.
		if content.length > 0
			content[0] = end
			bubbleUp(0)
			
		return result
		
	remove: AStarNode node
		let i = content.indexOf(node)

		// When it is found, the process seen in 'pop' is repeated
		// to fill up the hole.
		let end = content.pop()

		if i != content.length - 1
			content[i] = end
			if scoreFunction(end) < scoreFunction(node)
				sinkDown(i)
			else
				bubbleUp(i)
	size
		return content.length
		
	rescoreElement: AStarNode node
		sinkDown(content.indexOf(node))
		
	sinkDown: int number
		// Fetch the element that has to be sunk.
		int n = number
		let element = content[n]

		// When at 0, an element can not sink any further.
		while (n > 0)
			
			// Compute the parent element's index, and fetch it.
			let parentN = ((n + 1) shiftRight 1) - 1
			let parent = content[parentN]
			
			// Swap the elements if the parent is greater.
			if scoreFunction(element) < scoreFunction(parent)
				content[parentN] = element
				content[n] = parent
				
				// Update 'n' to continue at the new position.
				n = parentN
			else
				// Found a parent that is less, no need to sink any further.
				break
				
	bubbleUp: int number
		// Look up the target element and its score.
		let n = number
		let length = content.length,
			element = content[n],
			elemScore = scoreFunction(element)

		while(true)
			// Compute the indices of the child elements.
			let child2N = (n + 1) shiftLeft 1
			let child1N = child2N - 1
			
			// This is used to store the new position of the element, if any.
			int swap = -1
			int child1Score
			
			// If the first child exists (is inside the array)...
			if child1N < length
				
				// Look it up and compute its score.
				let child1 = content[child1N]
				child1Score = scoreFunction(child1)

				// If the score is less than our element's, we need to swap.
				if child1Score < elemScore
					swap = child1N

			// Do the same checks for the other child.
			if child2N < length
				let child2 = content[child2N]
				let child2Score = scoreFunction(child2)
				if child2Score < (swap == -1 ? elemScore : child1Score)
					swap = child2N

			// If the element needs to be moved, swap it, and continue.
			if swap != -1
				content[n] = content[swap]
				content[swap] = element
				n = swap
			else 
				// Otherwise, we are done.
				break
class BoxCollider
	Vector2 position, size
	Line rightLine, bottomLine, leftLine, topLine
	bottomRight = true
	bottomLeft = true
	topLeft = true
	topRight = true	
	
	BoxCollider: Vector2 position
		         Vector2 size
		         float radius
		         right = true
		         bottom = true
		         left = true
		         top = true
		if left
			leftLine = {
				start:position + {-(size.x/2+radius), -(size.y/2+(topLeft    ? radius : 0))}
				end:  position + {-(size.x/2+radius),  (size.y/2+(bottomLeft ? radius : 0))}
				Segment
			}
		if right
			rightLine = {
				start:position + {(size.x/2+radius), -(size.y/2+(topRight    ? radius : 0))}
				end:  position + {(size.x/2+radius),  (size.y/2+(bottomRight ? radius : 0))}
				Segment
			}
		if top
			topLine = {
				start:position + {-(size.x/2+(topLeft  ? radius : 0)), -(size.y/2+radius)}
				end:  position + { (size.x/2+(topRight ? radius : 0)), -(size.y/2+radius)}
				Segment
			}
		if bottom
			bottomLine = {
				start:position + {-(size.x/2+(bottomLeft  ? radius : 0)), (size.y/2+radius)}
				end:  position + { (size.x/2+(bottomRight ? radius : 0)), (size.y/2+radius)}
				Segment
			}
 	
unit game
	// Finds the shortest path between two position using the astar algorithm
	AStarNode[] findPath: IntVector2 startPos
		                  IntVector2 endPos
		                  IntVector2 size
		                  AStarNode[](AStarNode[][] grid, int x, int y) getNeighbors
		                  int(IntVector2 a, IntVector2 b) heuristic
		
		AStarNode[][] grid
		for size.x -> x
			grid[x] = []
			for size.y -> y
				grid[x][y] = {pos:{x,y}}
				
		let diagonal = false
		let start = grid[startPos.x][startPos.y]
		let end = grid[endPos.x][endPos.y]
		
		BinaryHeap openHeap = {}
		openHeap.push(start)

		while(openHeap.size() > 0)

			// Grab the lowest f(x) to process next.  Heap keeps this sorted for us.
			let currentNode = openHeap.pop()

			// End case -- result has been found, return the traced path.
			if currentNode == end
				let curr = currentNode
				AStarNode[] result
				while(curr.parent)
					result.add curr
					curr = curr.parent
				result.add curr
				return result.reverse()

			// Normal case -- move currentNode from open to closed, process each of its neighbors.
			currentNode.closed = true

			// Find all neighbors for the current node. Optionally find diagonal neighbors as well (false by default).
			let neighbors = getNeighbors(grid, currentNode.pos.x, currentNode.pos.y)

			for neighbors.length
				let neighbor = neighbors[i]

				if neighbor.closed
					// Not a valid node to process, skip to next neighbor.
					continue

				// The g score is the shortest distance from start to current node.
				// We need to check if the path we have arrived at this neighbor is the shortest one we have seen yet.
				let gScore = currentNode.g + neighbor.cost
				let beenVisited = neighbor.visited

				if !beenVisited || gScore < neighbor.g

					// Found an optimal (so far) path to this node.  Take score for node to see how good it is.
					neighbor.visited = true
					neighbor.parent = currentNode
					neighbor.h = neighbor.h || heuristic(neighbor.pos, end.pos)
					neighbor.g = gScore
					neighbor.f = neighbor.g + neighbor.h

					if !beenVisited
						// Pushing to heap will put it in proper place based on the 'f' value.
						openHeap.push(neighbor)
					else
						// Already seen the node, but since it has been rescored we need to reorder it in the heap
						openHeap.rescoreElement(neighbor)

		// No result was found - empty array signifies failure to find path.
		return []
		
	showColliders = false
	log = false

	resolveCollision: Vector2 sourcePosition
		              Vector2 targetPosition
		              BoxCollider[] colliders
		              float radius
		              float slideThreshold = 5
		let threshold = radius + slideThreshold
		let primarilyX = math.abs(targetPosition.x - sourcePosition.x) > math.abs(targetPosition.y - sourcePosition.y)
		Line movement = {sourcePosition, targetPosition, Segment}
		bool hasCollided
		for colliders -> c
			// Migrate to 3D
			// if showColliders
			// 	if c.leftLine: drawLine c.leftLine.start, c.leftLine.end, color:Red, width:5
			// 	if c.rightLine: drawLine c.rightLine.start, c.rightLine.end, color:Red, width:5
			// 	if c.topLine: drawLine c.topLine.start, c.topLine.end, color:Red, width:5
			// 	if c.bottomLine: drawLine c.bottomLine.start, c.bottomLine.end, color:Red, width:5
			
			if c.leftLine and movement.end.x > movement.start.x
				// We are moving right -> check left side
				Line line = c.leftLine
				let p = movement intersectionWith line
					hasCollided = true
					if c.topLeft and (p.y - line.start.y) <= threshold
						if log: watch "Move Right, Hit TopLeft Corner"
						//           o
						//                 o
						//                       o     ⬆
						//                             ┌─
						if primarilyX: targetPosition.y = math.min(targetPosition.y, line.start.y-1)
						//                          o
						//                           o
						//                            o
						//                         ⬅  ┌─
						else           targetPosition.x = math.min(targetPosition.x, line.start.x-1)
					else
					if c.bottomLeft and (line.end.y - p.y) <= threshold
						if log: watch "Move Right, Hit BottomLeft Corner"
						//                             └─
						//                       o     ⬇
						//                 o
						//           o
						if primarilyX: targetPosition.y = math.max(targetPosition.y, line.end.y+1)
						//                         ⬅  └─    
						//                            o
						//                           o
						//                          o
						else           targetPosition.x = math.min(targetPosition.x, line.end.x-1)
					else
						if log: watch "Move Right, Hit Left Side"
						//                              │
						//            o     o     o     │ ⬅
						//                              │
						targetPosition.x = math.min(targetPosition.x, line.end.x-1)
			else
			if c.rightLine and movement.end.x < movement.start.x
				// We are moving left -> check right side
				Line line = c.rightLine
				let p = movement intersectionWith line
					hasCollided = true
					if c.topRight and (p.y - line.start.y) <= threshold
						if log: watch "Move Left, Hit TopRight Corner"
						//                                                 o
						//                                           o     
						//                               ⬆    o
						//                              ─┐
						if primarilyX: targetPosition.y = math.min(targetPosition.y, line.start.y-1)
						//                                  o
						//                                 o     
						//                                o
						//                              ─┐  ⮕
						else           targetPosition.x = math.max(targetPosition.x, line.start.x+1)
					else
					if c.bottomRight and (line.end.y - p.y) <= threshold
						if log: watch "Move Left, Hit BottomRight Corner"
						//                               ─┘
						//                               ⬇    o
						//                                           o     
						//                                                 o
						if primarilyX: targetPosition.y = math.max(targetPosition.y, line.end.y+1)
						//                              ─┘  ⮕
						//                                o
						//                                 o     
						//                                  o
						else           targetPosition.x = math.max(targetPosition.x, line.end.x+1)
					else
						if log: watch "Move Left, Hit Right Side"
						//                              │
						//                              │ ⮕   o      o      o
						//                              │
						targetPosition.x = math.max(targetPosition.x, line.end.x+1)
				
			if c.topLine and movement.end.y > movement.start.y
				// We are moving down -> check top side
				Line line = c.topLine
				let p = movement intersectionWith line
					hasCollided = true
					if c.topLeft and (p.x - line.start.x) <= threshold
						if log: watch "Move Down, Hit TopLeft Corner"
						//           o
						//                 o
						//                       o     ⬆
						//                             ┌─
						if primarilyX: targetPosition.y = math.min(targetPosition.y, line.start.y-1)
						//                          o
						//                           o
						//                            o
						//                         ⬅  ┌─
						else           targetPosition.x = math.min(targetPosition.x, line.start.x-1)
					else
					if c.topRight and (line.end.x - p.x) <= threshold
						if log: watch "Move Down, Hit TopRight Corner"
						//                                                 o
						//                                           o     
						//                               ⬆    o
						//                              ─┐
						if primarilyX: targetPosition.y = math.min(targetPosition.y, line.end.y-1)
						//                                  o
						//                                 o     
						//                                o
						//                              ─┐  ⮕
						else           targetPosition.x = math.max(targetPosition.x, line.end.x+1)
					else
						if log: watch "Move Down, Hit Top Side"
						//                              o
						//                              o
						//                              o
						//                           ───────
						targetPosition.y = math.min(targetPosition.y, line.end.y-1)
			else
			if c.bottomLine and movement.end.y < movement.start.y
				// We are moving up -> check bottom side
				Line line = c.bottomLine
				// drawLine line.start, line.end, color:Red, width:10
				let p = movement intersectionWith line
					hasCollided = true
					if c.bottomLeft and (p.x - line.start.x) <= threshold
						if log: watch "Move Up, Hit BottomLeft Corner"
						//                             └─
						//                       o     ⬇
						//                 o
						//           o
						if primarilyX: targetPosition.y = math.max(targetPosition.y, line.start.y+1)
						//                         ⬅  └─    
						//                            o
						//                           o
						//                          o
						else           targetPosition.x = math.min(targetPosition.x, line.start.x-1)
					else
					if c.bottomRight and (line.end.x - p.x) <= threshold
						if log: watch "Move Up, Hit BottomRight Corner"
						//                               ─┘
						//                               ⬇    o
						//                                           o     
						//                                                 o
						if primarilyX: targetPosition.y = math.max(targetPosition.y, line.end.y+1)
						//                              ─┘  ⮕
						//                                o
						//                                 o     
						//                                  o
						else           targetPosition.x = math.max(targetPosition.x, line.end.x+1)
					else
						if log: watch "Move Up, Hit Bottom Side"
						//                           ───────
						//                              o
						//                              o
						//                              o
						targetPosition.y = math.max(targetPosition.y, line.end.y+1)
				
		int iterations
		while hasCollided
			// If we collided, we check if we weren't pushed into another collider,
			// until there are no more collision. This time, we only check the sides (not the corners).
			// This prevents beeing pushed through a collider by being pushed around two corners.
			primarilyX = math.abs(targetPosition.x - sourcePosition.x) > math.abs(targetPosition.y - sourcePosition.y)
			movement = {sourcePosition, targetPosition, Segment}
			hasCollided = false
			
			// Prevent endless loops: If we are still colliding after 3 iteration, we don't move at all
			if ++iterations > 3: return sourcePosition
				
			for colliders -> c
				if c.leftLine and movement.end.x > movement.start.x
					// We are moving right -> check left side
					Line line = c.leftLine
					let p = movement intersectionWith line
						hasCollided = true
						if log: watch "Check after collision, Hit Left Side"
						//                              │
						//            o     o     o     │ ⬅
						//                              │
						targetPosition.x = math.min(targetPosition.x, line.end.x-1)
				else
				if c.rightLine and movement.end.x < movement.start.x
					// We are moving left -> check right side
					Line line = c.rightLine
					let p = movement intersectionWith line
						hasCollided = true
						if log: watch "Check after collision, Hit Right Side"
						//                              │
						//                              │ ⮕   o      o      o
						//                              │
						targetPosition.x = math.max(targetPosition.x, line.end.x+1)
					
				if c.topLine and movement.end.y > movement.start.y
					// We are moving down -> check top side
					Line line = c.topLine
					let p = movement intersectionWith line
						hasCollided = true
						if log: watch "Check after collision, Hit Top Side"
						//                              o
						//                              o
						//                              o
						//                           ───────
						targetPosition.y = math.min(targetPosition.y, line.end.y-1)
				else
				if c.bottomLine and movement.end.y < movement.start.y
					// We are moving up -> check bottom side
					Line line = c.bottomLine
					let p = movement intersectionWith line
						hasCollided = true
						if log: watch "Check after collision, Hit Bottom Side"
						//                           ───────
						//                              o
						//                              o
						//                              o
						targetPosition.y = math.max(targetPosition.y, line.end.y+1)
			
		return targetPosition
				
		

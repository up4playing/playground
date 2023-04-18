transient unit Physics
	object world
	float scale = 100
	
	js void start
		if(window.world) _b2World_Delete(world)
		window.world = new b2World(new b2Vec2(0, 10))
		
	js void step
		if(window.world) window.world.Step(1/Network_targetFps, 8, 3)
			
	js void destroy: PhysicsBody body
		world.DestroyBody(body.body)
			
	js PhysicsBody createCircle: Vector2 pos
		                         float radius
		                         BodyType type = Dynamic
		let bodyDef = new b2BodyDef()
		bodyDef.type = type
		bodyDef.position = new b2Vec2(pos.x/Physics_scale, pos.y/Physics_scale)
		let body =  window.world.CreateBody(bodyDef)
		let shape = new b2CircleShape
		shape.radius = radius/Physics_scale
		body.CreateFixtureFromShape(shape, type == 2 ? 1 : 0)
		return new PhysicsBody(body)
			
	js PhysicsBody createRectangle: Vector2 pos
		                            Vector2 size
		                            BodyType type = Dynamic
		let bodyDef = new b2BodyDef()
		bodyDef.type = type
		bodyDef.position = new b2Vec2(pos.x/Physics_scale, pos.y/Physics_scale)
		let body =  window.world.CreateBody(bodyDef)
		let shape = new b2PolygonShape
		shape.SetAsBoxXY(size.x/Physics_scale/2, size.y/Physics_scale/2)
		body.CreateFixtureFromShape(shape, type == 2 ? 1 : 0)
		return new PhysicsBody(body)
			
	js PhysicsBody createPolygon: Vector2 pos
		                          Vector2[] vertices
		                          bool closed = true
		                          BodyType type = Dynamic
		let bodyDef = new b2BodyDef()
		bodyDef.type = type
		bodyDef.position = new b2Vec2(pos.x/Physics_scale, pos.y/Physics_scale)
		let body =  window.world.CreateBody(bodyDef)
		let shape = new b2ChainShape();
		for(let v of vertices)
			shape.vertices.push(new b2Vec2(v.x/Physics_scale, v.y/Physics_scale));
		if(closed) shape.CreateLoop();
		body.CreateFixtureFromShape(shape, type == 2 ? 1 : 0)
		return new PhysicsBody(body)
	
transient enum BodyType
	Static,
	Kinematic,
	Dynamic,

transient enum BodyShape
	None,
	Rectangle,
	Circle,
	Chain,
	ClosedChain
		
transient class PhysicsBody
	object body
	js Vector2 position:
		let pos = this.body.GetPosition()
		return new Vector2(pos.x*Physics_scale, pos.y*Physics_scale, null)

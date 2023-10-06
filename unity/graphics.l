cs UnityEngine
Behaviour
	
cs UnityEngine
Behaviour MonoBehaviour
	// Gets a component of a given type on this game object
	inline cs TComponent getComponent: TComponent<Behaviour> type // The type of the component to get
		this.GetComponent<TComponent>()

cs UnityEngine
struct Vector2
	float x, y

cs UnityEngine
struct Quaternion
	static inline cs(UnityEngine) Quaternion identity() Quaternion.identity
	static inline cs(UnityEngine) Quaternion Euler(float x, float y, float z) Quaternion.Euler(x,y,z)
	inline cs(UnityEngine) Quaternion() Quaternion.identity
	
cs UnityEngine
Transform
	Vector3 position
	Quaternion rotation
	
	Vector3 localPosition
	Quaternion localRotation
	Vector3 localScale
	
cs UnityEngine
GameObject
	Transform transform
	// Gets a component of a given type on this game object
	inline cs TComponent getComponent: TComponent<Behaviour> type // The type of the component to get
		this.GetComponent<TComponent>()
	
cs UnityEngine
Behaviour Animator
	inline cs void crossfade: Animation animation
		                      float transitionDuration = .5
		this.CrossFadeInFixedTime(animation, transitionDuration)

cs UnityEngine
struct Color
	inline cs(UnityEngine) Color() Color.white
		
View
	string key
	GameObject gameObject
	bool drawnThisFrame
	
	private Animation currentAnimation
	private Animator animator = gameObject.getComponent(Animator)
		
	inline cs void destroy
		Object.Destroy(this.gameObject)
		
	play: Animation animation
		  float crossfade
		if animation != currentAnimation
			animator.crossfade animation, crossfade
			currentAnimation = animation
	
Model
	string name
	GameObject gameObject
	
int Animation
	inline cs bool toBool() (this != 0)
	static inline cs(UnityEngine) Animation fromName: string name
		Animator.StringToHash(name)	
		
LocationBucket
	int nextViewIndex
	View[] views
	
global unit graphics
	global cs GameObject create: Model model
		if(model.gameObject == null)
		    model.gameObject = Resources.Load<GameObject>(model.name);
		return Object.Instantiate<GameObject>(model.gameObject);
		
	int nextId
	LocationBucket[string] locationBuckets
		
	startFrame
		nextId = 0
			
	finsishFrame
		for locationBuckets.values -> bucket
			for bucket.views <-
				if !.drawnThisFrame
					bucket.views.removeAt i
					.destroy
				else
					.drawnThisFrame = false
			bucket.nextViewIndex = 0
					
	cs Vector3 toGroundPlane: Vector2 screenPosition
		var plane = new Plane(Vector3.up, Vector3.zero);
		var ray = Camera.main.ScreenPointToRay(screenPosition);
		plane.Raycast(ray, out float distance);
		return ray.GetPoint(distance);
						
	global View drawModel: Model model
		                   Vector3 position = Vector3.zero
		                   Quaternion rotation = Quaternion.identity
		                   Animation animation = {}
		                   float crossfade = .5
		                   SourceCodeLocation location
		string key = location.toString + ":" + model.name
		let bucket = locationBuckets[key] ?= {}
		let view = bucket.views[bucket.nextViewIndex] ?= {gameObject:create(model)}
		..drawnThisFrame = true
		view.gameObject.transform
		..localPosition = position
		..localRotation = rotation
		if animation: view.play animation, crossfade
		bucket.nextViewIndex++
		return view

		// View view
		// if bucket.nextViewIndex >= bucket.views.length
		// 	bucket.views.add {gameObject:create(model)}
			
		

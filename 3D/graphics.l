// A texture that can be loaded into video memory
class Texture
	string file
	Vector2 size
	
	transient dynamic texture
	
	Texture
		if Platform.engineStarted
			open
			
	js bool ensureIsAvailable()
		if(!this._htmlImage) {
			this._htmlImage = _textureCache[this.file]
		}
		return this._htmlImage != null
	
	js void open
		if(!window._textureCache) _textureCache = {}
		this.texture = _textureCache[this.file]
		if(!this.texture) {
			return new Promise((resolve, reject) => {
				let path = this.file.startsWith("http") ? this.file : _basePath+this.file
				this.texture = new THREE.TextureLoader().load(path, () => {
					this.texture.colorSpace = THREE.SRGBColorSpace;
					window._textureCache[this.file] = this.texture
					this.size = new Vector2(this.texture.image.width, this.texture.image.height, null)
					resolve(this);
				});
			})
		} else {
			this.size = new Vector2(this.texture.image.width, this.texture.image.height, null)
			return this
		}
		
// A font that can be used to draw text
skipInit class Font
	string name
	string file
	string textureFile
	
	js void open
		if(!window._fontCache) _fontCache = {}
		let font = _fontCache[this.file]
		if(!font && this.file && this.textureFile) {
			return new Promise((resolve, reject) => {
				let path = this.file.startsWith("http") ? "" : _basePath
				this.texture = new THREE.TextureLoader().load(path+this.textureFile, async texture => {
					window._textureCache[this.file] = this.texture;
					let json = await (await fetch(path+this.file)).json()
					ThreeMeshUI.FontLibrary.addFont(this.name, json, texture);
					resolve(this);
				});
			})
		}
		return this

// A single frame of an animated image
struct ImageFrame
	float x1, y1, x2, y2, w, h

// An image that can be drawn on the screen and can have several frames of animation
skipInit class Image
	string file
	Texture texture
	Vector2 size
	ImageFrame[] frames
	
struct GizomInfluence
	string file
	int start
	int end
	float[] deltas
	float[] initialValues
	string label
	
skipInit unit gizmo
	init
	internal tick
	clear
	internal onTouch: InputType InputType, int id, Vector2 pixelPos, Vector2 referencePos, shift = false, alt = false, cmdOrCtrl = false	

unit Framework
	float checksum
	tick
	
enum ScaleMode: Auto, FixedWidth, FixedHeight, None
enum AnchorMode: TopLeft, TopCenter, Center
enum HorizontalAlignment: Left = "left", Center = "center", Right = "right"
enum VerticalAlignment: Top = "start", Middle = "center", Bottom = "end"
enum FontStyle: Normal, Bold
class ClippingPath: Vector2[] points; bool show
		

js THREE.Mesh	
Mesh
	Vector3 position
	Quaternion quaternion
	
	bool drawnThisFrame
	
	inline js Mesh(dynamic geometry, dynamic material) new THREE.Mesh(geometry, material)
	inline js void setText(dynamic value) this.childrenTexts[0].set(value)
	inline js void set(dynamic value) this.set(value)
	
Bucket
	int nextMeshIndex
	Mesh[] meshes
	
js THREE.Quaternion
Quaternion
	inline js Quaternion(float x = 0.0, float y = 0.0, float z = 0.0) new THREE.Quaternion().setFromEuler(new THREE.Euler(x*math_TwoPI, y*math_TwoPI, z*math_TwoPI))
		
	js Quaternion operator = (Quaternion a, Quaternion b) a.x = b.x; a.y = b.y; a.z = b.z; a.w = b.w; return a
	
// Draw on the screen
transient skipInit global unit graphics
	internal Matrix2D baseMatrix, totalMatrix, localMatrix
	
	public float fieldOfView = 70
	public Vector2 referenceSize = {1920, 1080}
	
	public ScaleMode scaleMode = Auto, effectiveScaleMode
	public AnchorMode anchor = Center
	visible Vector2 pixelSize
	visible Vector2 size
	visible float pixelRatio
	
	private dynamic three
	internal dynamic scene
	private dynamic canvas
	private dynamic renderer
	private dynamic camera
	
	internal js async void setup
		graphics_canvas = document.getElementById("canvas");
		graphics_canvas.imageSmoothingEnabled = true;
		graphics_canvas.imageSmoothingQuality = "high";
		
		window.THREE = await import('./lib/three.module.js');
		await import("./lib/three-mesh-ui.js");
		graphics_scene = new THREE.Scene();
		
		let posZ = (graphics_referenceSize.y/2) / Math.tan(graphics_fieldOfView * Math.PI / 360)
		let aspectRatio = graphics_referenceSize.x / graphics_referenceSize.y
		graphics_camera = new THREE.PerspectiveCamera(graphics_fieldOfView, aspectRatio, 10, 10000)
		graphics_camera.position.set(0, 0, posZ)
		
		graphics_renderer = new THREE.WebGLRenderer( { antialias: true, canvas:graphics_canvas } );
	
	internal js void onResize
		graphics_pixelRatio = window.devicePixelRatio;
		graphics_pixelSize = new Vector2(window.innerWidth*graphics_pixelRatio, window.innerHeight*graphics_pixelRatio, null);
		graphics_isSmallScreen = screen.width < 600 || (localStorage.getItem("smallScreen") == "true")
		graphics_canvas.style.width = window.innerWidth + "px";
		graphics_canvas.style.height = window.innerHeight + "px";
		graphics_canvas.width = graphics_pixelSize.x;
		graphics_canvas.height = graphics_pixelSize.y;
		graphics_updateBaseMatrix()
		
		graphics_camera.aspect = graphics_pixelSize.x / graphics_pixelSize.y;
		graphics_camera.updateProjectionMatrix();
		graphics_renderer.setPixelRatio(graphics_pixelRatio);
		graphics_renderer.setSize(window.innerWidth, window.innerHeight);
		
	internal updateBaseMatrix
		let statisticsMargin = Platform.showDebugInfo ? statistics.margin : {}
		let referenceSizeWithMargin = referenceSize + statisticsMargin
		Vector2 ratio = {pixelSize.x / referenceSizeWithMargin.x, pixelSize.y / referenceSizeWithMargin.y}
		float scale
		if scaleMode == Auto
			if ratio.x < ratio.y: effectiveScaleMode = FixedWidth;  scale = ratio.x
			else                  effectiveScaleMode = FixedHeight; scale = ratio.y
			size = referenceSize
		else
		if scaleMode == FixedWidth
			effectiveScaleMode = scaleMode
			scale = ratio.x
			size = {referenceSize.x, pixelSize.y/scale}
		else
		if scaleMode == FixedHeight
			effectiveScaleMode = scaleMode
			scale = ratio.y; 
			size = {pixelSize.x/scale, referenceSize.y}
			
		let offsetX = anchor > 0 ? pixelSize.x/2 : 0
		let offsetY = anchor > 1 ? pixelSize.y/2 : 0
		baseMatrix = {scale,0,0,-scale,offsetX-(statisticsMargin.x/2)*scale,offsetY-(statisticsMargin.y/2)*scale}
		
	// The default player colors
	const Color[] defaultColors = [{"#398CA9", "Blue"}, {"#C01352", "Red"}, {"#16C66E", "Green"}, {"#FFD166", "Yellow"}]

	internal js void startFrame
			
	internal finishFrame
		for buckets -> bucket
			for bucket.meshes <-
				if !.drawnThisFrame
					bucket.meshes.removeAt i
					scene.remove(.)
				else
					.drawnThisFrame = false
			bucket.nextMeshIndex = 0
		render
		
	private js void render
		ThreeMeshUI.update();
		graphics_renderer.render(graphics_scene, graphics_camera);
			
	internal js void drawSafeArea
	
	Bucket[string] buckets
	
	// ------------------------------------------------------- Visibility -------------------------------------------------------
	
	// All drawing operations in a block of code will only be visible to certain players
	// Example: Draw a button that is only visible to the current player instance
	//     Player
	//         tick
	//             visibleFor me
	//                 drawText "OK"
	//                 drawImage Button
	// Image: graphicsVisibleFor.png
	visibleFor: implicit Player[] player // Only this player or list of players will see the drawing operations
		        void() code              // All drawing operations in this block of code will only be visible to the given players
		let prev = currentlyVisibleFor
		currentlyVisibleFor = player
		code()
		currentlyVisibleFor = prev
		return currentlyVisibleFor
		
	private Player[] currentlyVisibleFor = null
	
	private isVisibleFor: Player[] visibleFor
		if(Platform.fastForward) return false
		let effectiveVisibleFor = visibleFor or currentlyVisibleFor
		return effectiveVisibleFor == null or effectiveVisibleFor.any . == null or .id == input.localUser.id
	
	// ------------------------------------------------------- Font -------------------------------------------------------
	
	// The default font for all drawing operations
	font
		return currentFont
	font: Font font
		currentFont = font
		return currentFont
	font: Font font
		  void() code
		let prev = currentFont
		currentFont = font
		code()
		currentFont = prev
		return currentFont
	private Font currentFont = Roboto
	
	// The default font size for all drawing operations
	fontSize
		return currentFontSize
	fontSize: int fontSize
		currentFontSize = fontSize
		return currentFontSize
	fontSize: int fontSize
		      void() code
		let prev = currentFontSize
		currentFontSize = fontSize
		code()
		currentFontSize = prev
		return currentFontSize
	private currentFontSize = 64
	
	// ------------------------------------------------------- Image -------------------------------------------------------
	
	private js Mesh createPlane: Image image
		const geometry = new THREE.PlaneGeometry(image.size.x, image.size.y)
		const frame = image.frames[0]
		const x1 = frame.x1 / image.texture.size.x
		const x2 = frame.x2 / image.texture.size.x
		const y1 = 1 - frame.y1 / image.texture.size.y
		const y2 = 1 - frame.y2 / image.texture.size.y
		geometry.setAttribute( 'uv', new THREE.Float32BufferAttribute( [
			x1, y1,
			x2, y1,
			x1, y2,
			x2, y2,
		], 2 ))
		const material = new THREE.MeshBasicMaterial( { map: image.texture.texture } )
		material.transparent = true
		// material.opacity = .5
		const mesh = new THREE.Mesh(geometry, material)
		mesh.drawnThisFrame = false
		graphics_scene.add(mesh)
		return mesh
		
	global drawImage: Image image
		              Vector3 position = {}
		              Quaternion rotation = {}
		              implicit Player[] visibleFor = null // Only this player or list of players will see the image
		              SourceCodeLocation location = null
		if !isVisibleFor(visibleFor) or !image.texture?.ensureIsAvailable return null
			
		string key = "{location}.{image.file}"
		let bucket = buckets[key] ?= {}
		let mesh = bucket.meshes[bucket.nextMeshIndex] ?= createPlane(image)
		mesh.drawnThisFrame = true
		mesh.position = position
		mesh.quaternion = rotation
		bucket.nextMeshIndex++
		return mesh
		
	// ------------------------------------------------------- Text -------------------------------------------------------
	
	private js Mesh createText: Font font
		const mesh = new ThreeMeshUI.Block({
			fontFamily: font.name,
			fontTexture: font.name,
		});
		mesh.add(new ThreeMeshUI.Text());
		mesh.drawnThisFrame = false
		graphics_scene.add(mesh)
		return mesh
		
	// Draw text on the screen
	// Example: If the current player instance is the winner, we show "You've won!" to the current player instance.
	//     Player
	//         tick
	//             if winner == me
	//                 drawText "You've won!", size:100, color:Black, font:Roboto, visibleFor:me
	// Image: drawText.png
	global drawText: implicit string text                         // A string or anything that can be converted into a string (for example, an interger or a float)
		             Vector2 position = {}                        // By default, {0,0} is the center, {-960,-540} is the bottom left, {960,540} is the top right
		             Quaternion rotation = {}                     // The rotation of the text
		             float size = 0                               // The size of the text
		             implicit Vector2 containerSize = {1920,1080} // The size of the container
		             Color color = null                           // The color of the text
		             Color backgroundColor = null                 // The background color of the text
		             HorizontalAlignment align = Center           // The horizontal alignment of the text
		             VerticalAlignment valign = Middle            // The vertical alignment of the text
		             Font font = null                             // The font of the text
		             implicit Player[] visibleFor = null          // Only this player or list of players will see the text
		             SourceCodeLocation location = null
		if !isVisibleFor(visibleFor): return null
			
		string key = "{location}.{font.name}"
		let bucket = buckets[key] ?= {}
		let mesh = bucket.meshes[bucket.nextMeshIndex] ?= createText(font or currentFont)
		if(!containerSize.y) containerSize.y = 1080
		mesh.drawnThisFrame = true
		mesh.position = position
		mesh.quaternion = rotation
		mesh.set({ textAlign: align, justifyContent: valign, width: containerSize.x, height: containerSize.y, backgroundColor })
		mesh.setText({content:text, fontSize:size or currentFontSize, fontColor:color})
		bucket.nextMeshIndex++
		return mesh

	global drawPointer: Player player                    // Show the mouse position of this player
	                	Color color = null               // The color of the pointer. If this is left out, the player color is used
	                	showPointer = input.showPointers // Choose whether you want to draw the pointers for local players, remote players or both

// A color comprised of a red, green, blue and alpha component
class Color
	global const Color White   = {"ffffff", "White"}
	global const Color Black   = {"000000", "Black"}
	global const Color Red     = {"ef476f", "Red"}
	global const Color Yellow  = {"ffd166", "Yellow"}
	global const Color Green   = {"06d6a0", "Green"}
	global const Color Blue    = {"118ab2", "Blue"}
	global const Color Gray    = {"3d3d3d", "Gray"}
	global const Color TransparentRed   = {"ff000080", "Transparent Red"}
	string hex
	string name
	
	string toString := name or hex
	
	Color: string hex = ""
		   int red = 0
		   int green = 0
		   int blue = 0
		   int alpha = 255
		if hex: this.hex = "#" + hex
		else    this.hex = "#" + componentToHex(red) + componentToHex(green) 
		                       + componentToHex(blue) + componentToHex(alpha)
			
	static js string componentToHex: int c
		var hex = c.toString(16);
		return hex.length == 1 ? "0" + hex : hex;
		
	inline js bool operator ==(Color a, Color b) a.hex == b.hex
	inline js bool operator !=(Color a, Color b) a.hex != b.hex
	
	Color withAlpha: float alpha
		return {hex[1..7]+componentToHex(math.floor(alpha*255))}
	
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
	Vector2 offset
	actualHeightFactor = .76
	
	js void open
		if(!window._fontCache) _fontCache = {}
		let font = _fontCache[this.file]
		if(!font) {
			// let font = new FontFace(this.name, "url("+_basePath+this.file+")");
			let font = new FontFace(this.name, "url("+this.file+")");
			await font.load();
			document.fonts.add(font);
			_fontCache[this.file] = font;
			setTimeout(() => this.calculateOffset(), 0)
		}
		this.calculateOffset()
		return this
		
	private js void calculateOffset
		const fontsize = 64.0
		const margin = 32.0
		const canvas = document.createElement("canvas");
		const context=canvas.getContext("2d");
		const w = fontsize*2+margin, h = fontsize*2+margin;
		canvas.height = h;
		canvas.width = w;
		context.textBaseline="top";
		context.font=fontsize+"px "+this.name;
		context.fillStyle="red";
		context.fillText("M", margin, margin);
		let pixels = context.getImageData(0,0,w,h).data;
		
		let minY = 0
		findMinY:
		for(var y=0;y<h;y++) {
			for(var x=0;x<w;x++) {
			    if(pixels[(y*w+x)*4+3] > 0) {
				  minY = y-margin; break findMinY;
			    }
			}
		}
		
		let minX = 0
		findMinX:
		for(var x=0;x<w;x++) {
			for(var y=0;y<h;y++) {
			    if(pixels[(y*w+x)*4+3] > 0) {
        			minX = x-margin; break findMinX;
			    }
			}
		}
		this.offset = new Vector2(minX/fontsize, minY/(fontsize*this.actualHeightFactor))
		// log(this.name+" "+this.offset)

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
enum HorizontalAlignment: Left, Center, Right
enum VerticalAlignment: Top, Middle, Bottom
enum FontStyle: Normal, Bold
class ClippingPath: Vector2[] points; bool show
		

js THREE.Mesh	
Mesh
	Vector3 position
	Quaternion quaternion
	
	bool drawnThisFrame
	
	inline js Mesh(dynamic geometry, dynamic material) new THREE.Mesh(geometry, material)
	
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
		baseMatrix = {scale,0,0,scale,offsetX-(statisticsMargin.x/2)*scale,offsetY-(statisticsMargin.y/2)*scale}
		
	// The default player colors
	const Color[] defaultColors = [{"398CA9", "Blue"}, {"C01352", "Red"}, {"16C66E", "Green"}, {"FFD166", "Yellow"}]

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
				
		renderer.render(scene, camera)
			
	internal js void drawSafeArea
	
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
		const mesh = new THREE.Mesh(geometry, material)
		mesh.drawnThisFrame = false
		graphics_scene.add(mesh)
		return mesh
		
	Bucket[string] buckets
		
	global drawImage: Image image
		              Vector3 position = {}
		              Quaternion rotation = {}
		              SourceCodeLocation location = null
		string key = "{location}.{image.file}"
		let bucket = buckets[key] ?= {}
		let mesh = bucket.meshes[bucket.nextMeshIndex] ?= createPlane(image)
		mesh.drawnThisFrame = true
		mesh.position = position
		mesh.quaternion = rotation
		// if animation: view.play animation, crossfade
		bucket.nextMeshIndex++
		return mesh

	global drawPointer: Player player                    // Show the mouse position of this player
	                	Color color = null               // The color of the pointer. If this is left out, the player color is used
	                	showPointer = input.showPointers // Choose whether you want to draw the pointers for local players, remote players or both

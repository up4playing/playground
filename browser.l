HTMLElement
	Vector2 position, size = {1920,100}
	Color color
	
	internal static HTMLElement[] elements
	private transient dynamic element
	
	HTMLElement
		elements.add this
	tick
	
	static js void clear
		if(HTMLElement_elements) {
			for(let el of HTMLElement_elements) {
				el.remove()
			}
		}
		
HTMLElement HTMLInput
	fontSize = 50
	borderColor = Color("ffffff00")
	HorizontalAlignment align = Center
	visible string value
	
	void(string value) onEnterKey
	private int changeCallbackId, enterCallbackId
	
	HTMLInput
		changeCallbackId = networkData.addCallback
			value = .
			if not core.isPremiere: this.element.value = .
				
		enterCallbackId = networkData.addCallback
			value = .
			onEnterKey .
			
		ensureElement
		focus
		
	private js void ensureElement
		if(this.element) return
		let alignString = this.align == 0 ? "left" : this.align == 1 ? "center" : "right";
		this.element = document.createElement("input")
		this.element.type = "text"
		this.element.style = "margin:0;padding:0 12px 0 12px;position:absolute;border:1px solid "+this.borderColor.hex+";text-align:"+alignString+";outline:none;background-color:#00000000"
		this.element.value = this.value
		let prevValue = this.value
		this.element.onkeyup = e => {
			let value = this.element.value
			if(value != prevValue) {
				input_handleString(this.changeCallbackId, value);
				prevValue = value;
			}
			if(e.keyCode == 13) {
				input_handleString(this.enterCallbackId, value);
			}
		}
		document.body.appendChild(this.element)
		
	js void remove() this.element?.remove()
	js void focus() this.element?.focus()
		
	internal tick
		ensureElement
		let pos = graphics.getPixelPosition(this.position)
		let size = graphics.getPixelSize(this.size)
		let fontSize = this.fontSize * graphics.totalMatrix.m0 / Platform.pixelRatio
		this.element.style.font = "{fontSize/Platform.pixelRatio}px OpenSans"
		this.element.style.left = "{pos.x-size.x/2}px"
		this.element.style.top = "{pos.y-size.y/2}px"		
		this.element.style.width = "{size.x}px"
		this.element.style.height = "{size.y}px"
		this.element.style.font = "{fontSize}px OpenSans"
		
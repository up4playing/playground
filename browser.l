HTMLElement
	static HTMLElement[] elements
	dynamic element
	Vector2 position, size = {1920,100}
	Color color
	
	HTMLElement
		elements.add this
	tick
	
	static js void clear
		if(HTMLElement_elements) {
			for(let el of HTMLElement_elements) {
				el.remove()
			}
		}
		
HTMLElement HTMLField
	fontSize = 50
	void(string value) onEnterKey
	
	HTMLField
		setup
		this.element.type = "text"
		this.element.value = ""
		this.element.style = "font:{fontSize/Platform.pixelRatio}px OpenSans;margin:0;padding:0;position:absolute;border:none;text-align:center;outline: none;background-color:#00000000"
		
	js void setup
		this.element = document.createElement('input')
		this.element.onkeydown = e => {
			if(e.keyCode == 13) {
				log("click")
				this.onEnterKey.invoke();
			}
		}
		document.body.appendChild(this.element)
		this.element.focus()
		
	js void remove
		this.element?.remove()
		
	js string value
		return this.element.value
		
	tick
		let pos = graphics.getPixelPosition(this.position)
		let size = graphics.getPixelSize(this.size)
		let fontSize = this.fontSize * graphics.totalMatrix.m0 / Platform.pixelRatio
		this.element.style.left = "{pos.x-size.x/2}px"
		this.element.style.top = "{pos.y-size.y/2}px"		
		this.element.style.width = "{size.x}px"
		this.element.style.height = "{size.y}px"
		this.element.style.font = "{fontSize}px OpenSans"
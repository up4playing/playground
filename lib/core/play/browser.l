transient skipInit unit Platform
	public inline js string url := location.href
	public inline js string hostname := location.hostname
	public protocolAndHost := hostname && hostname != "127.0.0.1" ? "https://"+hostname : "http://127.0.0.1"
	public inline js int userAgent := navigator.userAgent.replace(/,/g," ")
	public inline js float usedMemory := (performance.memory ? performance.memory.usedJSHeapSize : 0)
	
	js string getAbsoluteUrl: string relativeUrl
		return relativeUrl.startsWith("http") || relativeUrl.startsWith("data:") ? relativeUrl : _basePath+relativeUrl

	js void setTitle: string title
		document.title = title
		
	js async void setFullscreen: value = true
		                         Player forPlayer = null
		if(!Platform.isStaging && !Platform.isDebug && !Platform.fastForward && (forPlayer == null || input.localUser?.id == forPlayer.id)) {
			try {
				if(value) await document.body.requestFullscreen()
				else      await document.exitFullscreen()
			} catch(error) {
				core.onError(error)
			}
		}	
		
	inline js void preventScrolling
		window.scrollTo(0,0)
		
	js void setLocalStorageObject: string key
		                           any value
		                           void() then = null
		                           void() else = null
		try {
			localStorage.setItem(key, JSON.stringify(value))
			then?.()
		} catch(e) {
			else?.()
		}
		
	js any getLocalStorageObject: string key
		try {
			let str = localStorage.getItem(key)
			return str ? JSON.parse(str) : null 
		} catch {
			return null
		}
			
	js bool setLocalStorageString: string key
		                           string value
		try {
			localStorage.setItem(key, value)
			return true
		} catch(e) {
			return false
		}
		
	js string getLocalStorageString: string key
		try {
			return localStorage.getItem(key) || ""
		} catch {
			return ""
		}
		
	inline js void vibrate: int duration = 100
		if(navigator.vibrate) navigator.vibrate(duration)
		
	inline js void alert: string message
		alert(message)
		log(message)
		
	inline js void delay: Time time
		                  void() then
		setTimeout(then, time)
		
	inline js void copyToClipboard(string text)
		if(core.isPremiere && input.isCertain) {
			navigator.clipboard.writeText(text)
		}
		
	inline js void setLocation: string url
		location.href = url
		
	inline js void openLink: string url
		window.open(url)
		
	js void setInterval: Time interval
		                 void() code
		setInterval(code, interval)
		
	inline js int setTimeout: Time time
		                      void() code
		setTimeout(code, time)
		
	inline js void clearTimeout: int id
		clearTimeout(id)
		
	inline js void pushState: string url
		                      dynamic state = null
		if(core.isPremiere) history.pushState(state, "", url);
		
	inline js void replaceState: string url
		                         dynamic state = null
		if(core.isPremiere) history.replaceState(state, "", url);
		
	inline js void back
		if(core.isPremiere) history.back();
		
	inline js void reload
		if(!Platform.isDebug) location.reload();
	
unit file
	js void saveText: string filename, string text
		var element = document.createElement("a");
		element.setAttribute("href", "data:text/plain;charset=utf-8," + encodeURIComponent(text));
		element.setAttribute("download", filename);
		element.style.display = "none";
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
		
	js void saveBinary: string filename, Buffer buffer
		var binary = "";
		var bytes = new Uint8Array(buffer.buffer);
		var len = bytes.byteLength;
		for (var i = 0; i < len; i++) {
		    binary += String.fromCharCode(bytes[i]);
		}
		var base64 = window.btoa( binary );
		var dataUrl = "data:text/plain;base64," + base64;
		
		var element = document.createElement("a");
		element.setAttribute("href", dataUrl);
		element.setAttribute("download", filename);
		element.style.display = "none";
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
		
	js void openBinary: void(Buffer buffer) then, void(string error) else = null
		fileInput = document.createElement("input")
		fileInput.type = "file"
		fileInput.style.display = "none"
		fileInput.onchange = e => {
			var file = e.target.files[0];
			if (!file) {
				else?.("")
				return
			}
			var reader = new FileReader();
			reader.onload = function(e) {
				let buffer = new Buffer(e.target.result, 0, 0, 0);
				document.body.removeChild(fileInput);
				then(buffer);
			}
			reader.onabort = e => {
				else?.(reader.error)
			}
			reader.onerror = e => {
				else?.(reader.error)
			}
			reader.readAsArrayBuffer(file)
		}
		document.body.appendChild(fileInput)
		fileInput.click()
	
internal HTMLElement
	Vector2 position, size = {1920,100}
	Color color
	
	internal static HTMLElement[] elements
	private transient dynamic element
	
	HTMLElement
		elements.add this
	tick
	
	static js void clear
		if(HTMLElement.elements) {
			for(let el of HTMLElement.elements) {
				el.remove()
			}
		}
		
internal HTMLElement HTMLInput
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
				input.handleString(this.changeCallbackId, value);
				prevValue = value;
			}
			if(e.keyCode == 13) {
				input.handleString(this.enterCallbackId, value);
			}
		}
		document.body.appendChild(this.element)
		
	js void remove() this.element?.remove()
	js void focus() this.element?.focus()
		
	internal tick
		// Migrate to 3D
		// ensureElement
		// let pos = graphics.getPixelPosition(this.position)
		// let size = graphics.getPixelSize(this.size)
		// let fontSize = this.fontSize * graphics.totalMatrix.m0 / graphics.pixelRatio
		// this.element.style.font = "{fontSize/graphics.pixelRatio}px OpenSans"
		// this.element.style.left = "{pos.x-size.x/2}px"
		// this.element.style.top = "{pos.y-size.y/2}px"		
		// this.element.style.width = "{size.x}px"
		// this.element.style.height = "{size.y}px"
		// this.element.style.font = "{fontSize}px OpenSans"
		
internal IndexedDBIndex
	string name
	string[] keyPaths
	
	IndexedDBIndex
		if not keyPaths: keyPaths.add name
		
internal IndexedDBStore
	string name
	IndexedDBIndex[] indices
	
	string keyPath = "id"
	bool autoIncrement = false
	
	IndexedDBStore
		IndexedDB.stores.add this
		print "Adding store {name} {IndexedDB.stores.length}"
		
	js void put: any data, void() then = null, void(Error error) else = null
		try {
			let trans = IndexedDB.db.transaction(this.name, "readwrite")
			trans.onerror = e => {
				core.log("Error in IndexedDB.save: "+trans.error)
				else?.()
			}
			trans.objectStore(this.name).put(data).onsuccess = e => {
				then?.()
			}
		} catch(error) {
			core.onError(error)
			else?.(error)
		}
		
	js async any get: any id
		return new Promise((resolve, reject) => {
			try {
				let trans = IndexedDB.db.transaction(this.name, "readonly");
				let req = trans.objectStore(this.name).get(id);
				req.onsuccess = async e => resolve(req.result)
				req.onerror = e => { core.onError(e); reject(); }
			} catch(e) {
				core.onError(e);
				reject();
			}
		})
		
	js void get: any id, void(any result) then, void(Error error) else = null
		try {
			let trans = IndexedDB.db.transaction(this.name, "readonly");
			let req = trans.objectStore(this.name).get(id);
			req.onsuccess = async e => {
				let result = req.result;
				if(result) {
					then(result);
				} @else {
					else?.();
				}
			}
			req.onerror = e => {
				core.onError(e);
				else?.();
			}
		} catch(e) {
			core.onError(e);
			else?.();
		}
		
	js async any[] getAllFromIndex: string index, any query
		return new Promise((resolve, reject) => {
			try {
				let trans = IndexedDB.db.transaction(this.name, "readonly");
				let req = trans.objectStore(this.name).index(index).getAll(query);
				req.onsuccess = async e => resolve(req.result)
				req.onerror = e => { core.onError(e); reject(); }
			} catch(e) {
				core.onError(e);
				reject();
			}
		})
		
	js void getAllFromIndex: string index, any query, void(any[] result) then, void(Error error) else = null
		try {
			let trans = IndexedDB.db.transaction(this.name, "readonly");
			let req = trans.objectStore(this.name).index(index).getAll(query);
			req.onsuccess = async e => {
				let result = req.result;
				if(result) {
					then(result);
				} @else {
					else?.();
				}
			}
			req.onerror = e => {
				core.onError(e);
				else?.();
			}
		} catch(e) {
			core.onError(e);
			else?.();
		}

internal transient skipInit unit IndexedDB
	internal dynamic db
	IndexedDBStore[] stores
	
	inline bool isReady := (IndexedDB.db != null)
	
	js async void start: string databaseName, int version = 1
		return new Promise((resolve, reject) => {
			try {
				System.print("IndexedDB: start stores:"+IndexedDB.stores.length);
				var request = indexedDB.open(databaseName, version)
				request.onupgradeneeded = e => {
					core.log("IndexedDB: upgradeneeded");
					IndexedDB.db = e.target.result;
					for(let store of IndexedDB.stores) {
						if(!IndexedDB.db.objectStoreNames.contains(store.name)) {
							let storeObject = IndexedDB.db.createObjectStore(store.name, { keyPath: store.keyPath, autoIncrement: store.autoIncrement });
							System.print("IndexedDB: created store "+store.name)
							for(let index of store.indices) {
								storeObject.createIndex(index.name, index.keyPaths.length == 1 ? index.keyPaths[0] : index.keyPaths)
							}
						}
					}
					System.print("IndexedDB: successfully upgraded to version "+version)
				}
				request.onsuccess = e => {
					System.print("IndexedDB: success");
					IndexedDB.db = e.target.result;
					for(let store of IndexedDB.stores) {
						store.db = IndexedDB.db
					}
					resolve();
				}
				request.onerror = e => {
					core.onError(request.error);
					reject(request.error);
				}
				core.log("IndexedDB: finished");
			} catch(e) {
				core.onError(e);
				reject(e);
			}
		})
		
	js void start: string databaseName, int version = 1, void() success = null, void(Error error) else = null
		try {
			System.print("IndexedDB: start stores:"+IndexedDB.stores.length);
			var request = indexedDB.open(databaseName, version)
			request.onupgradeneeded = e => {
				core.log("IndexedDB: upgradeneeded");
				IndexedDB.db = e.target.result;
				for(let store of IndexedDB.stores) {
					if(!IndexedDB.db.objectStoreNames.contains(store.name)) {
						let storeObject = IndexedDB.db.createObjectStore(store.name, { keyPath: store.keyPath, autoIncrement: store.autoIncrement });
						System.print("IndexedDB: created store "+store.name)
						for(let index of store.indices) {
							storeObject.createIndex(index.name, index.keyPaths)
						}
					}
				}
				System.print("IndexedDB: successfully upgraded to version "+version)
			}
			request.onsuccess = e => {
				System.print("IndexedDB: success");
				IndexedDB.db = e.target.result;
				for(let store of IndexedDB.stores) {
					store.db = IndexedDB.db
				}
				success?.();
			}
			request.onerror = e => {
				core.onError(request.error);
				else?.(request.error);
			}
			core.log("IndexedDB: finished");
		} catch(e) {
			core.onError(e);
			else?.(e);
		}
		
	js void open: string storeName, string id, void(object data) then, void() else = null
		try {
			let trans = IndexedDB.db.transaction(storeName, "readonly")
			let req = trans.objectStore(IndexedDB.storeName).get(id)
			req.onsuccess = async e => {
				let result = req.result
				if(result) {
					then(result)
				} @else {
					else?.()
				}
			}
			req.onerror = e => {
				core.log("Error in IndexedDB.open: "+req.error)
				else?.()
			}
		} catch(e) {
			core.log("Error in IndexedDB.open: "+e.message)
			else?.()
		}
				
	js void openBuffer: string storeName, string id, void(Buffer buffer) then, void() else = null
		try {
			let trans = IndexedDB.db.transaction(storeName, "readonly")
			let req = trans.objectStore(IndexedDB.storeName).get(id)
			req.onsuccess = async e => {
				let result = req.result
				if(result) {
					let arrayBuffer = await result.data.arrayBuffer()
					let buffer = new Buffer(arrayBuffer, 0, 0, 0)
					then(buffer)
				} @else {
					else?.()
				}
			}
			req.onerror = e => {
				core.log("Error in IndexedDB.open: "+req.error)
				else?.()
			}
		} catch(e) {
			core.log("Error in IndexedDB.open: "+e.message)
			else?.()
		}
				
	js void save: string storeName, object data, void() then = null, void() else = null
		try {
			let trans = IndexedDB.db.transaction(storeName, "readwrite")
			trans.onerror = e => {
				core.log("Error in IndexedDB.save: "+trans.error)
				else?.()
			}
			trans.objectStore(IndexedDB.storeName).put(data).onsuccess = e => {
				then?.()
			}
		} catch(e) {
			core.log("Error in IndexedDB.save: "+e.message)
			else?.()
		}
		
	js void saveBuffer: string storeName, string id, Buffer buffer, void() then = null, void() else = null
		try {
			let trans = IndexedDB.db.transaction(storeName, "readwrite")
			trans.onerror = e => {
				core.log("Error in IndexedDB.save: "+trans.error)
				else?.()
			}
			let dataView = new DataView(buffer.buffer, 0, buffer.writePos)
			let data = new Blob([dataView])
			trans.objectStore(IndexedDB.storeName).put({id, data}).onsuccess = e => {
				then?.()
			}
		} catch(e) {
			core.log("Error in IndexedDB.save: "+e.message)
			else?.()
		}


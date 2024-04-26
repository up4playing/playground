networkData
	void(any data)[] callbacks
	call: int id, any data
		callbacks[id](data)
		
	addCallback: stored void(any data) do
		let id = networkData.callbacks.length
		networkData.callbacks.add do
		return id
				
storage
	inline js void set: string key, object value
		localStorage.setItem(key, JSON.stringify(value))
		
	internal inline js string getStringDirectly: string key
		(localStorage.getItem(key) || "")
		
	internal js dynamic getObjectDirectly: string key
		try {
			let data = localStorage.getItem(key)
			if(!data) return {}
			return JSON.parse(data)
		} catch {
			return {}
		}
		
	get: string key, stored void(any data) do
		let id = networkData.addCallback do
		let data = getStringDirectly(key)
		input.handleObject id, data
		
http
	inline js string encodeURIComponent(string str) encodeURIComponent(str)
	
	// Perform an http get request
	js void get: string url
		         stored void(any result) code
		let id = networkData.addCallback(code)
		if(core.frame == 0 || Platform.waitingForInitialData) Platform.waitingForInitialData++
		if(core.isPremiere && input.isCertain) {
			let data = await (await fetch(url)).text()
			log("http.get "+url+" -> "+data?.length+" bytes")
			input.handleObject(id, data, 1)
		}
		
	js void getString: string url
		               bool storeForDeterministicReplay = true
		               stored void(string result) code
		if(core.frame == 0 || Platform.waitingForInitialData) {
			Platform.waitingForInitialData++
			log("getString: "+url)
		}
		if(storeForDeterministicReplay) {
			let id = networkData.addCallback(code)
			if(core.isPremiere && input.isCertain) {
				let data = await (await fetch(url)).text()
				input.handleString(id, data, 1)
			}
		} else {
			if(core.isPremiere && input.isCertain) {
				let data = await (await fetch(url)).text()
				log("received: "+url)
				code.invoke(data)
				if(Platform.waitingForInitialData > 0) Platform.receivedInitialData++
			}
		}
		
	internal js async string getStringDirectly string url
		return await (await fetch(url)).text()
		
	internal js async dynamic getJsonDirectly: string url
		if(!core.isPremiere || !input.isCertain) return null
		return await (await fetch(url)).json()
		
	internal js async dynamic getJsonDirectly: string url, dynamic options
		return await (await fetch(url, options)).json()
		
	internal js void postDirectly: string url, any body, void(any result) code
		let data = await (await fetch(url, {method:"POST", body:JSON.stringify(body)})).text()
		code(data)
		
	// Perform an http post request
	js void post: string url
		          stored void(any result) code
		let id = networkData.addCallback(code)
		if(core.frame == 0) Platform.waitingForInitialData++
		if(core.isPremiere && input.isCertain) {
			let data = await (await fetch(url, {method:"POST"})).text()
			log("http.post "+url+" -> "+data?.length+" bytes")
			input.handleObject(id, data)
		}
		
	// Perform an http post request
	js void post: string url
		          any body
		          stored void(any result) code
		let id = networkData.addCallback(code)
		if(core.frame == 0) Platform.waitingForInitialData++
		if(core.isPremiere && input.isCertain) {
			log("Actually fetching data: POST "+url)
			let data = await (await fetch(url, {method:"POST", body:JSON.stringify(body)})).text()
			log("http.post "+url+" -> "+data?.length+" bytes")
			input.handleObject(id, data)
		}
		
	js void post: string url
		          any body
		if(core.isPremiere && input.isCertain) {
			(await fetch(url, {method:"POST", body:JSON.stringify(body)})).text()
		}
		
	// Perform an http put request
	js void put: string url
		         stored void(any result) code
		let id = networkData.addCallback(code)
		if(core.frame == 0) Platform.waitingForInitialData++
		if(core.isPremiere && input.isCertain) {
			let data = await (await fetch(url, {method:"PUT"})).text()
			log("http.put "+url+" -> "+data?.length+" bytes")
			input.handleObject(id, data)
		}
		
	// Perform an http put request
	js void put: string url
		         any body
		         stored void(any result) code
		let id = networkData.addCallback(code)
		if(core.frame == 0) Platform.waitingForInitialData++
		if(core.isPremiere && input.isCertain) {
			let data = await (await fetch(url, {method:"PUT", body:JSON.stringify(body)})).text()
			log("http.put "+url+" -> "+data?.length+" bytes")
			input.handleObject(id, data)
		}
		
	// Perform an http delete request
	js void delete: string url
		            stored void(any result) code
		let id = networkData.addCallback(code)
		if(core.isPremiere && input.isCertain) {
			let data = await (await fetch(url, {method:"DELETE"})).text()
			log("http.delete "+url+" -> "+data?.length+" bytes")
			input.handleObject(id, data)
		}
		
	// Perform an http delete request
	js void delete: string url
		            any body
		            stored void(any result) code
		let id = networkData.addCallback(code)
		if(core.isPremiere && input.isCertain) {
			let data = await (await fetch(url, {method:"DELETE", body:JSON.stringify(body)})).text()
			log("http.delete "+url+" -> "+data?.length+" bytes")
			input.handleObject(id, data)
		}

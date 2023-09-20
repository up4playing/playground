networkData
	void(any data)[] callbacks
	call: int id, any data
		callbacks[id](data)
		
	addCallback: stored void(any data) do
		let id = networkData.callbacks.length
		networkData.callbacks.add do
		return id
				
localStorage
	inline js void set: string key, object value
		localStorage.setItem(key, JSON.stringify(value))
		
	internal inline js string getStringDirectly: string key
		(localStorage.getItem(key) || "")
		
	internal inline js dynamic getObjectDirectly: string key
		JSON.parse(localStorage.getItem(key) || {})
		
	get: string key, stored void(any data) do
		let id = networkData.addCallback do
		let data = getStringDirectly(key)
		input.handleObject id, data
		
http
	// Perform an http get request
	js void get: string url
		         stored void(any result) code
		let id = networkData_addCallback(code)
		if(core_frame == 0) Platform_waitingForInitialData++
		if(core_isPremiere && input_isCertain) {
			let data = await (await fetch(url)).text()
			log("http.get "+url+" -> "+data?.length+" bytes")
			input_handleObject(id, data, 1)
		}
		
	internal js void getDirectly string url
		return await (await fetch(url)).text()
		
	internal js void postDirectly: string url, any body, void(any result) code
		let data = await (await fetch(url, {method:"POST", body:JSON.stringify(body)})).text()
		code(data)
		
	// Perform an http post request
	js void post: string url
		          stored void(any result) code
		let id = networkData_addCallback(code)
		if(core_frame == 0) Platform_waitingForInitialData++
		if(core_isPremiere && input_isCertain) {
			let data = await (await fetch(url, {method:"POST"})).text()
			log("http.post "+url+" -> "+data?.length+" bytes")
			input_handleObject(id, data)
		}
		
	// Perform an http post request
	js void post: string url
		          any body
		          stored void(any result) code
		let id = networkData_addCallback(code)
		if(core_frame == 0) Platform_waitingForInitialData++
		if(core_isPremiere && input_isCertain) {
			log("Actually fetching data: POST "+url)
			let data = await (await fetch(url, {method:"POST", body:JSON.stringify(body)})).text()
			log("http.post "+url+" -> "+data?.length+" bytes")
			input_handleObject(id, data)
		}
		
	js void post: string url
		          any body
		if(core_isPremiere && input_isCertain) {
			(await fetch(url, {method:"POST", body:JSON.stringify(body)})).text()
		}
		
	// Perform an http put request
	js void put: string url
		         stored void(any result) code
		let id = networkData_addCallback(code)
		if(core_frame == 0) Platform_waitingForInitialData++
		if(core_isPremiere && input_isCertain) {
			let data = await (await fetch(url, {method:"PUT"})).text()
			log("http.put "+url+" -> "+data?.length+" bytes")
			input_handleObject(id, data)
		}
		
	// Perform an http put request
	js void put: string url
		         any body
		         stored void(any result) code
		let id = networkData_addCallback(code)
		if(core_frame == 0) Platform_waitingForInitialData++
		if(core_isPremiere && input_isCertain) {
			let data = await (await fetch(url, {method:"PUT", body:JSON.stringify(body)})).text()
			log("http.put "+url+" -> "+data?.length+" bytes")
			input_handleObject(id, data)
		}
		
	// Perform an http delete request
	js void delete: string url
		            stored void(any result) code
		let id = networkData_addCallback(code)
		if(core_isPremiere && input_isCertain) {
			let data = await (await fetch(url, {method:"DELETE"})).text()
			log("http.delete "+url+" -> "+data?.length+" bytes")
			input_handleObject(id, data)
		}
		
	// Perform an http delete request
	js void delete: string url
		            any body
		            stored void(any result) code
		let id = networkData_addCallback(code)
		if(core_isPremiere && input_isCertain) {
			let data = await (await fetch(url, {method:"DELETE", body:JSON.stringify(body)})).text()
			log("http.delete "+url+" -> "+data?.length+" bytes")
			input_handleObject(id, data)
		}

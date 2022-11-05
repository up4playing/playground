unit networkData
	void(dynamic data)[] callbacks
	call: int id, dynamic data
		callbacks[id](data)
		
	addCallback: stored void(dynamic data) do
		let id = networkData.callbacks.length
		networkData.callbacks.add do
		return id
				
unit localStorage
	inline js void set: string key, object value
		localStorage.setItem(key, JSON.stringify(value))
		
	private inline js string getStringDirectly: string key
		(localStorage.getItem(key) || "")
		
	get: string key, stored void(dynamic data) do
		let id = networkData.addCallback do
		let data = getStringDirectly(key)
		Input.handleObject id, data
		
unit http
	// Perform an http get request
	js void get: string url
		         stored void(dynamic result) code
		let id = networkData_addCallback(code)
		if(Network_isPremiere) {
			let data = await (await fetch(url)).text()
			log("Actually fetching data: GET "+url+" -> "+data?.length+" bytes")
			Input_handleObject(id, data, 1)
		}
		
	internal js void getInternal: string url
		return await (await fetch(url)).text()
		
	// Perform an http post request
	js void post: string url
		          stored void(dynamic result) code
		let id = networkData_addCallback(code)
		if(Network_isPremiere) {
			let data = await (await fetch(url, {method:"POST"})).text()
			log("Actually fetching data: POST "+url+" -> "+data?.length+" bytes")
			Input_handleObject(id, data)
		}
		
	// Perform an http post request
	js void post: string url
		          dynamic body
		          stored void(dynamic result) code
		let id = networkData_addCallback(code)
		if(Network_isPremiere) {
			let data = await (await fetch(url, {method:"POST", body:JSON.stringify(body)})).text()
			log("Actually fetching data: POST "+url+" -> "+data?.length+" bytes")
			Input_handleObject(id, data)
		}
		
	// Perform an http put request
	js void put: string url
		         stored void(dynamic result) code
		let id = networkData_addCallback(code)
		if(Network_isPremiere) {
			let data = await (await fetch(url, {method:"PUT"})).text()
			log("Actually fetching data: PUT "+url+" -> "+data?.length+" bytes")
			Input_handleObject(id, data)
		}
		
	// Perform an http put request
	js void put: string url
		         dynamic body
		         stored void(dynamic result) code
		let id = networkData_addCallback(code)
		if(Network_isPremiere) {
			let data = await (await fetch(url, {method:"PUT", body:JSON.stringify(body)})).text()
			log("Actually fetching data: PUT "+url+" -> "+data?.length+" bytes")
			Input_handleObject(id, data)
		}
		
	// Perform an http delete request
	js void delete: string url
		            stored void(dynamic result) code
		let id = networkData_addCallback(code)
		if(Network_isPremiere) {
			let data = await (await fetch(url, {method:"DELETE"})).text()
			log("Actually fetching data: DELETE "+url+" -> "+data?.length+" bytes")
			Input_handleObject(id, data)
		}
		
	// Perform an http delete request
	js void delete: string url
		            dynamic body
		            stored void(dynamic result) code
		let id = networkData_addCallback(code)
		if(Network_isPremiere) {
			let data = await (await fetch(url, {method:"DELETE", body:JSON.stringify(body)})).text()
			log("Actually fetching data: DELETE "+url+" -> "+data?.length+" bytes")
			Input_handleObject(id, data)
		}

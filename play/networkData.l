networkData
	void(any data)[] callbacks
	call: int id, any data
		callbacks[id](data)
		
	addCallback: stored void(any data) do
		let id = networkData.callbacks.length
		networkData.callbacks.add do
		return id
				
storage
	inline js void set: string key, nocolon Player of, object value
		if(input.internalUsers[of.id]?.local) {
			localStorage.setItem(key, JSON.stringify(value));
		}
		
	get: string key, nocolon Player of, stored void(any data) do
		let id = networkData.addCallback do
		if core.isPremiere and input.isCertain and input.internalUsers[of.id]?.local
			let data = getStringDirectly(key)
			input.handleObject id, data
		
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
		
	js void postStreamDirectly: string url
		                        dynamic body
		                        void(string result, void() cancel) onData
		                        void() onEnd = null
		if(!core.isPremiere || !input.isCertain) return
		try {
			let response = await fetch(url, {method:"POST", body:JSON.stringify(body)})
			let reader = response.body.getReader();
			let decoder = new TextDecoder();
			let cancelled = false
			function cancel() { cancelled = true; }
			for(;;) {
				const { value, done } = await reader.read();
				if (value) {
					let chunk = decoder.decode(value, { stream: true });
					onData(chunk, cancel);
					if(cancelled) return;
				}
				if(done) break;
			}
			onEnd?.();
		} catch (error) {
			console.error('Error during fetch or stream processing:', error);
		}
		
	internal js async string getStringDirectly string url
		return await (await fetch(url)).text()
		
	internal js async dynamic getJsonDirectly: string url
		if(!core.isPremiere || !input.isCertain) return null
		return await (await fetch(url)).json()
		
	internal js async dynamic getJsonDirectly: string url, dynamic options
		return await (await fetch(url, options)).json()
	
	internal js async string postDirectly: string url, any body
		return (await fetch(url, {method:"POST", body:JSON.stringify(body)})).text()	
		
	internal js void postDirectly: string url, any body, void(any result) code, void() else = null
		try {
			let data = await (await fetch(url, {method:"POST", body:JSON.stringify(body)})).text();
			code(data);
		} catch(e) {
			core.log(e.stack.toString());
			else();
		}
		
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

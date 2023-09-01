http
	// Perform an http get request
	js void get: string url
		         void(dynamic result) do = null
		let result = await (await fetch(url)).json()
		do(result)
		
	js void getText: string url
		             void(string result) do = null
		let result = await (await fetch(url)).text()
		do(result)
		
	// Perform an http post request
	js void post: string url
		          dynamic body = null
		          void(any result) do = null
		let result = await (await fetch(url, {method:"POST", body:JSON.stringify(body)})).json()
		do(result)
		
	// Perform an http post request
	js void put: string url
		         dynamic body = null
		         void(dynamic result) do = null
		let result = await (await fetch(url, {method:"PUT", body:JSON.stringify(body)})).json()
		do(result)
		
	// Perform an http delete request
	js void delete: string url
		            void(dynamic result) do = null
		let result = await (await fetch(url, {method:"DELETE"})).json()
		do(result)

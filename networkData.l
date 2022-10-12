unit networkData
	void(dynamic data)[] callbacks
	call: int id, dynamic data
		callbacks[id](data)
	
unit localStorage
	inline js void set: string key, object value
		localStorage.setItem(key, JSON.stringify(value))
		
	private inline js string getStringDirectly: string key
		(localStorage.getItem(key) || "")
		
	get: string key, stored void(dynamic data) do
		let id = networkData.callbacks.length
		networkData.callbacks.add do(data)
		let value = getStringDirectly(key)
		if(value) Input.handleData id, value
		

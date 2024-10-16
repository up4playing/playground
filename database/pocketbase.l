skipInit pocketBase
	string url
	dynamic pb
	
	setup
		url = ""
	
	async js void connect
		if(!pocketBase.url) pocketBase.url = location.host && !Platform.isDebug ? location.origin : "http://localhost:8090"
		const PocketBase = (await import("./lib/pocketbase.es.mjs")).default
		if(pocketBase.pb) pocketBase.pb.realtime.unsubscribe();
		pocketBase.pb = new PocketBase(pocketBase.url);
	
Collection<T>
	string name
	
	async inline js void subscribe: string topic
		                            any options = {}
		                            void(any e) do
		pocketBase.pb.collection(this.name).subscribe(topic, do, options)
		
	async T[] getFullList
		return pocketBase.pb.collection(this.name).getFullList()
		
	async T add: T item
		any newRecord = pocketBase.pb.collection(this.name).create(item)
		any anyItem = cast item
		anyItem.id = newRecord.id
		
	async inline js void update: T item
		pocketBase.pb.collection(this.name).update(item.id, item)
		
	async inline js void remove: T item
		pocketBase.pb.collection(this.name).delete(item.id)
		
	async js void upload: T item, string fileFieldName = "images", File[] files
		const formData = new FormData();
		for(let key in item) {
			if(key != fileFieldName) {
				let value = item[key];
				let type = typeof(value);
				if(type != "function" && type != "undefined") {
					formData.append(key, value);
				}
			}
		}
		for(let file of files) {
			formData.append(fileFieldName, file);
		}
		let newItem = await pocketBase.pb.collection(this.name).create(formData);
		item.id = newItem.id;
		item[fileFieldName] = newItem[fileFieldName]
		return newItem;

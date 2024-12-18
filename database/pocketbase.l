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
		
	inline js void autoCancellation: value = true
		pocketBase.pb.@autoCancellation(value);

interface File
	Time lastModified
	string lastModifiedDate
	string name
	string path
	int size
	string type
	
	inline js string objectUrl() URL.createObjectURL(this)

Collection<T>
	string name
	
	async inline js void subscribe: string topic
		                            any options = {}
		                            void(any e) do
		pocketBase.pb.collection(this.name).subscribe(topic, do, options)
		
	async T[] getFullList
		return pocketBase.pb.collection(this.name).getFullList()
		
	async T add: T item
		any newRecord = await pocketBase.pb.collection(this.name).create(item)
		any anyItem = cast item
		anyItem.id = newRecord.id
		
	async inline js T update: T item
		pocketBase.pb.collection(this.name).update(item.id, item)
		
	async js T addOrUpdate: T item
		if(!item.id) return this.add(item)
		else         return pocketBase.pb.collection(this.name).update(item.id, item)
		
	async inline js T update: string id, dynamic update
		pocketBase.pb.collection(this.name).@update(id, update)
		
	async inline js void remove: T item
		pocketBase.pb.collection(this.name).delete(item.id)
		
	async js void upload: T item, string fileFieldName = "images", File[] files
		const formData = new FormData();
		for(let file of files) {
			formData.append(fileFieldName, file);
		}
		let newItem
		if(item.id) {
			newItem = await pocketBase.pb.collection(this.name).update(item.id, formData)
		} else {
			for(let key in item) {
				if(key != fileFieldName) {
					let value = item[key];
					let type = typeof(value);
					if(type != "function" && type != "undefined") {
						formData.append(key, value);
					}
				}
			}
			newItem = await pocketBase.pb.collection(this.name).create(formData);
			item.id = newItem.id;
		}
		item[fileFieldName] = newItem[fileFieldName]
		return newItem;
		
	async js void uploadFromUrls: T item, string fileFieldName = "images", string[] urls
		const formData = new FormData();
		for(let url of urls) {
			const response = await fetch(url);
			const imageBlob = await response.blob();
			formData.append('images', imageBlob, 'moved-image.jpg');
		}
		if(item.id) {
			newItem = await pocketBase.pb.collection(this.name).update(item.id, formData)
		} else {
			for(let key in item) {
				if(key != fileFieldName) {
					let value = item[key];
					let type = typeof(value);
					if(type != "function" && type != "undefined") {
						formData.append(key, value);
					}
				}
			}
			newItem = await pocketBase.pb.collection(this.name).create(formData);
			item.id = newItem.id;
		}
		item[fileFieldName] = newItem[fileFieldName]
		return newItem;


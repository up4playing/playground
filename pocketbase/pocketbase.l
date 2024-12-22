// skipInit transient pocketBase
// 	string url
// 	dynamic pb
	
// 	setup
// 		url = ""
	
transient skipInit pocketBase
	string url
	dynamic pb
		
	async js void connect
		if(!pocketBase.url) pocketBase.url = window.location && window.location.host && !Platform.isDebug ? location.origin : "http://localhost:8090"
		const PocketBase = (await import("./lib/pocketbase.es.mjs")).default
		if(pocketBase.pb) pocketBase.pb.realtime.unsubscribe();
		pocketBase.pb = new PocketBase(pocketBase.url);
		
	inline js void autoCancellation: value = true
		pocketBase.pb.@autoCancellation(value);
		
	inline js void onAuthChanged: inline void(any user) code
		pocketBase.pb.authStore.onChange((token, record) => code(record))
		
	js void authRefresh()
		try {
			await pocketBase.pb.collection("users").authRefresh();
		} catch(e) {
			console.log(e);
		}
	
	async dynamic authWithPassword: string email
		                            string password
		return await pocketBase.pb.collection("users").authWithPassword(email, password)

class PocketBaseFileUpload
	Time lastModified
	string lastModifiedDate
	string name
	string path
	int size
	string type
	
	inline js string objectUrl() URL.createObjectURL(this)

Collection<T>
	string name
	T[] items = []
	
	// Find an item the meets the given condition
	// Example: Find a player with a specific id
	//     app
	//         getPlayerById: int id
	//             return players.find.id == id
	inline js T find: bool(T a) condition // The condition to check
		this.items.find(condition)
		
	inline js T[] where: bool(T a) condition // The condition to check
		this.items.filter(condition)
		
	async inline js void subscribe: string topic
		                            any options = {}
		                            void(any e) do
		pocketBase.pb.collection(this.name).subscribe(topic, do, options)
		
	async T[] getFullList
		items = cast await pocketBase.pb.collection(this.name).getFullList()
		return items
		
	async T[] fetch: string filter = null
		             string sort = null
		             string expand = null
		             int page = 1
		             int perPage = 1000
		items = cast ((await pocketBase.pb.collection(this.name).getList(page, perPage, {filter})).items)
		return items
		
	async inline js T get: string id
		pocketBase.pb.collection(this.name).getOne(id)
		
	async T add: T item
		any newRecord = await pocketBase.pb.collection(this.name).create(item)
		any anyItem = cast item
		anyItem.id = newRecord.id
		
	async inline js T update: T item
		pocketBase.pb.collection(this.name).update(item.id, item)
		
	async js T save: T item
		if(!item.id) return this.add(item)
		else         return pocketBase.pb.collection(this.name).update(item.id, item)
		
	async inline js T update: string id, dynamic update
		pocketBase.pb.collection(this.name).@update(id, update)
		
	async inline js void remove: T item
		pocketBase.pb.collection(this.name).delete(item.id)
		
	async js void upload: T item, string fileFieldName = "images", PocketBaseFileUpload[] files
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


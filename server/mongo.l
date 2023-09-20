unit db
	private object db
	
	js async void connect: string database
		var mongodb = require('mongodb')
		var mongoClient = mongodb.MongoClient
		window.ObjectID = mongodb.ObjectID
		var mongo = await mongoClient.connect("mongodb://0.0.0.0:27099")
		db_db = mongo.db(database);
		
	js inline Collection collection: string name
		db_db.collection(name)
		
	js inline object ObjectId: string id
		new ObjectID(id)
		
	js inline bool operator==(ObjectID a, string b) a.equals(b)
	js inline bool operator==(ObjectID a, ObjectID b) a.equals(b)

js ObjectID
class ObjectID
	string id
	implicit inline js string toString() this.toString()
	static inline js ObjectID generate() new ObjectID()

class Collection
	string collectionName
	
	inline js async string add: any value
		this.insertOne(value)
	
	inline js async any findOne: dynamic query
		this.findOne(query)
	
	inline js async any findAll
		this.find().toArray()
	
	inline js async any find: dynamic query
		this.find(query).toArray()
	
	inline js async any find: dynamic query, dynamic sort
		this.find(query).@sort(sort).toArray()
	
	inline js async any find: dynamic query, dynamic sort, int skip = 0, int limit
		this.find(query).@sort(sort).@skip(skip).@limit(limit).toArray()
	
	inline js async any find: dynamic query, dynamic project
		this.find(query).@project(project).toArray()
	
	inline js async any find: dynamic query, dynamic project, int skip = 0, int limit
		this.find(query).@project(project).@skip(skip).@limit(limit).toArray()
	
	inline js async any find: dynamic query, dynamic sort, dynamic project
		this.find(query).@project(project).@sort(sort).toArray()
	
	inline js async any find: dynamic query, dynamic sort, dynamic project, int skip = 0, int limit
		this.find(query).@project(project).@sort(sort).@skip(skip).@limit(limit).toArray()
	
	inline js async dynamic set: dynamic query, dynamic value
		this.updateOne(query,{$set:value})
	
	inline js async dynamic setAll: dynamic query, dynamic value
		this.updateMany(query,{$set:value})
		
	inline js async dynamic update: dynamic query, dynamic value
		this.updateOne(query,value)
		
	inline js async dynamic upsert: dynamic query, dynamic value
		this.updateOne(query,{$set:value}, {upsert: true})
		
	inline js async dynamic delete: dynamic query
		this.deleteOne(query)
		
class UpdateResult
	bool acknowledged
	int matchedCount
	int modifiedCount
	int upsertedCount
	object upsertedId
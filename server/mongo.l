unit db
	private object db
	
	js async void connect: string database
		var mongodb = require('mongodb')
		var mongoClient = mongodb.MongoClient
		global.ObjectId = mongodb.ObjectId
		var mongo = await mongoClient.connect("mongodb://"+(process.env.databaseHost || "0.0.0.0:27099"))
		db.db = mongo.db(database);
		
	js inline Collection collection: string name
		db.db.collection(name)
		
	js inline object ObjectId: string id
		new ObjectId(id)
		

js ObjectId
class ObjectId
	string id
	implicit inline js string toString() this.toString()
	static inline js ObjectId generate() new ObjectId()
		
	js inline bool == ObjectId b: this?.equals(b)
	js inline bool == string b:   this?.equals(b)
		
DatabaseResult
	bool acknowledged
	int modifiedCount
	ObjectId upsertedId
	int upsertedCount
	int matchedCount

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
	
	inline js async DatabaseResult set: dynamic query, dynamic value
		this.updateOne(query,{$set:value})
	
	inline js async DatabaseResult setMany: dynamic query, dynamic value
		this.updateMany(query,{$set:value})
		
	inline js async DatabaseResult update: dynamic query, dynamic value
		this.updateOne(query,value)
		
	inline js async DatabaseResult updateMany: dynamic query, dynamic value
		this.updateMany(query,value)
		
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

transient class ServerMessage
	int senderId
	
class Partner
	int userId
	int connectionId

transient ServerMessage JoinMessage
	string roomId
	int userId = -1
	int version

transient ServerMessage JoinResponseMessage
	string roomId
	int userId         // The userId stays the same when a user reconnects
	int connectionId   // The connectionId increments with every connection, lowest connectionId means oldest user
	int version        // The app version
	string seed        // The random seed
	Partner[] partners // List of users that are connected to the server
	
transient ServerMessage OffersMessage
	Signal[] offers
	
transient ServerMessage SignalMessage
	Signal signal
	
transient class Signal
	int receiverId
	string type
	object sdp
	int acknowledgePos
	int connectionId
	
transient ServerMessage IceMessage
	int receiverId
	object iceCandidate
	
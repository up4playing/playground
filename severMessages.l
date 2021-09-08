transient class ServerMessage
	int senderId

transient ServerMessage JoinMessage
	string roomId
	int userId = -1
	int version

transient ServerMessage JoinResponseMessage
	string roomId
	int userId
	int version
	string seed
	int[] partnerIds
	
// ServerMessage UserJoinedMessage
// 	int userId
	
transient ServerMessage OffersMessage
	Signal[] offers
	
transient ServerMessage SignalMessage
	Signal signal
	
transient class Signal
	int receiverId
	string type
	object sdp
	int acknowledgePos
	
transient ServerMessage IceMessage
	int receiverId
	object iceCandidate
	
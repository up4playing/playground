class ServerMessage
	int senderId

ServerMessage JoinMessage
	string roomId
	int userId = -1
	int version

ServerMessage JoinResponseMessage
	string roomId
	int userId
	int version
	string seed
	int[] partnerIds
	
// ServerMessage UserJoinedMessage
// 	int userId
	
ServerMessage OffersMessage
	Signal[] offers
	
ServerMessage SignalMessage
	Signal signal
	
class Signal
	int receiverId
	string type
	object sdp
	int acknowledgePos
	
ServerMessage IceMessage
	int receiverId
	object iceCandidate
	
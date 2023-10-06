// A byte array that we can write to and read from
struct Buffer
	int readPos, writePos
	private Array<byte> buffer
	
	Buffer: int size = 1024
		setup(size)
		
	cs void setup: int size = 1024
		this.buffer = new byte[size];

	reset
		this.readPos = 0
		this.writePos = 0
		
	rewind
		this.readPos = 0
		
	bool canRead := readPos < writePos
	
	cs(System) void expandBuffer(int size)
		var len = Math.Max(this.buffer.Length*2, size);
		byte[] newBuffer = new byte[size];
		System.Buffer.BlockCopy(this.buffer, 0, newBuffer, 0, this.writePos);
		this.buffer = newBuffer;

	cs(System) int writeInt: int value
		if(value <= -2147483647 || value >= 2147483647)
			throw new Exception("$Value out of integer range: {value}");
		int n;
		byte lastByte;
		if(value > 0) {
			n = value;
			lastByte = (byte)(n & 0x3f);
		} else {
			n = -value;
			lastByte = (byte)((n & 0x3f) | 0x40);
		}
		
		if (n < (1 << 13)) {
			if (n < (1 << 6)) {
				if(this.writePos+1 > this.buffer.Length) this.expandBuffer(this.writePos+1);
				buffer[writePos++] = lastByte;
				return 1;
			} else {
				if(this.writePos+2 > this.buffer.Length) this.expandBuffer(this.writePos+2);
				buffer[writePos++] = (byte)((n >> 6) | 0x80);
				buffer[writePos++] = lastByte;
				return 2;
			}
		} else if (n < (1 << 27)) {
			if (n < (1 << 20)) {
				if(this.writePos+3 > this.buffer.Length) this.expandBuffer(this.writePos+3);
				buffer[writePos++] = (byte)((n >> 13) | 0x80);
				buffer[writePos++] = (byte)(((n >> 6) & 0x7f) | 0x80);
				buffer[writePos++] = lastByte;
				return 3;
			} else {
				if(this.writePos+4 > this.buffer.Length) this.expandBuffer(this.writePos+4);
				buffer[writePos++] = (byte)( (n >> 20) | 0x80);
				buffer[writePos++] = (byte)(((n >> 13) & 0x7f) | 0x80);
				buffer[writePos++] = (byte)(((n >>  6) & 0x7f) | 0x80);
				buffer[writePos++] = lastByte;
				return 4;
			}
		} else {
			if(this.writePos+5 > this.buffer.Length) this.expandBuffer(this.writePos+5);
			buffer[writePos++] = (byte)( (n >> 27) | 0x80);
			buffer[writePos++] = (byte)(((n >> 20) & 0x7f) | 0x80);
			buffer[writePos++] = (byte)(((n >> 13) & 0x7f) | 0x80);
			buffer[writePos++] = (byte)(((n >>  6) & 0x7f) | 0x80);
			buffer[writePos++] = lastByte;
			return 5;
		}
	
	cs int readInt
		var a = buffer[this.readPos++];
		if((a & 0x80) == 0) {
			return (a & 0x40) != 0 ? -(a & 0x3f) 
			                       :   a;
		} else {
			a &= 0x7f;
			var b = buffer[this.readPos++];
			if((b & 0x80) == 0) {
				return (b & 0x40) != 0 ? -((b & 0x3f) | (a << 6)) 
				                       :   (b         | (a << 6));
			} else {
				b &= 0x7f;
				var c = buffer[this.readPos++];
				if((c & 0x80) == 0) {
					return (c & 0x40) != 0 ? -((c & 0x3f) | (b << 6) | (a << 13))
					                       :   (c         | (b << 6) | (a << 13));
				} else {
					c &= 0x7f;
					var d = buffer[this.readPos++];
					if((d & 0x80) == 0) {
						return (d & 0x40) != 0 ? -((d & 0x3f) | (c << 6) | (b << 13) | (a << 20))
						                       :   (d         | (c << 6) | (b << 13) | (a << 20));
					} else {
						d &= 0x7f;
						var e = buffer[this.readPos++];
						return (e & 0x40) != 0 ? -((e & 0x3f) | (d << 6) | (c << 13) | (b << 20) | (a << 27))
						                       :   (e         | (d << 6) | (c << 13) | (b << 20) | (a << 27));
					}
				}
			}
		}
				
	cs int peekInt
		int prevWritePos = this.writePos;
		int result = this.readInt();
		this.writePos = prevWritePos;
		return result;

	cs int readInt16
		return (buffer[this.readPos++] << 8) | buffer[this.readPos++];

	cs int readUnsignedInt8
		return buffer[this.readPos++];

	cs int readUnsignedInt16
		return (buffer[this.readPos++] << 8) | buffer[this.readPos++] & 0xff;

	cs int readInt32
		return (buffer[this.readPos++] << 24) | (buffer[this.readPos++] << 16) | (buffer[this.readPos++] << 8) | buffer[this.readPos++];

	cs int peekInt32
		int readPos = this.readPos;
		return (buffer[readPos++] << 24) | (buffer[readPos++] << 16) | (buffer[readPos++] << 8) | buffer[readPos++];

	cs int readUnsignedInt32
		return (buffer[this.readPos++] << 24) | (buffer[this.readPos++] << 16) | (buffer[this.readPos++] << 8) | buffer[this.readPos++] & 0xff;

	cs void writeInt16: int value
		if(this.writePos+2 > this.buffer.Length) this.expandBuffer(this.writePos+2);
		buffer[this.writePos++] = (byte)(value >> 8);
		buffer[this.writePos++] = (byte)value;

	cs void writeUnsignedInt8: int value
		if(this.writePos+1 > this.buffer.Length) this.expandBuffer(this.writePos+1);
		buffer[this.writePos++] = (byte)value;

	cs void writeUnsignedInt16: int value
		if(this.writePos+2 > this.buffer.Length) this.expandBuffer(this.writePos+2);
		buffer[this.writePos++] = (byte)(value >> 8);
		buffer[this.writePos++] = (byte)value;

	cs void writeInt32: int value
		if(this.writePos+4 > this.buffer.Length) this.expandBuffer(this.writePos+4);
		buffer[this.writePos++] = (byte)(value >> 24);
		buffer[this.writePos++] = (byte)(value >> 16);
		buffer[this.writePos++] = (byte)(value >> 8);
		buffer[this.writePos++] = (byte)value;

	cs void writeUnsignedInt32: int value
		if(this.writePos+4 > this.buffer.Length) this.expandBuffer(this.writePos+4);
		buffer[this.writePos++] = (byte)(value >> 24);
		buffer[this.writePos++] = (byte)(value >> 16);
		buffer[this.writePos++] = (byte)(value >> 8);
		buffer[this.writePos++] = (byte)value;

	cs(System.Text) string readString
		int length = this.readInt32();
		if(length == 0) return "";
		string result = Encoding.UTF8.GetString(buffer, this.readPos, length);
		this.readPos += length;
		return result;

	cs(System.Text) void writeString: string value
		if(value == null) {
			this.writeInt32(0);
			return;
		}
		byte[] bytes = Encoding.UTF8.GetBytes(value);
		this.writeBytes(bytes);

	cs void writeBytes: Array<byte> value
		if(value == null) {
			this.writeInt32(0);
			return;
		}
		this.writeInt32(value.Length);
		if(this.writePos+value.Length > this.buffer.Length) this.expandBuffer(this.writePos+value.Length);
		System.Buffer.BlockCopy(value, 0, buffer, this.writePos, value.Length);
		this.writePos += value.Length;
		
	cs void writeFloat: float value
		byte[] bytes = BitConverter.GetBytes(value);
		if(this.writePos+4 > this.buffer.Length) this.expandBuffer(this.writePos+4);
		System.Buffer.BlockCopy(bytes, 0, buffer, this.writePos, 4);
		this.writePos += 4;
		
	cs float readFloat
		float result = BitConverter.ToSingle(buffer, readPos);
		this.readPos += 4;
		return result;	
	


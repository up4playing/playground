transient struct Buffer
	int readPos, writePos
	private object buffer
	private object dataView
	
	Buffer: object buffer = null
		    int size = 1024
		setup(size)
		
	private js void setup: int size = 1024
		if(!this.buffer) this.buffer = new ArrayBuffer(size)
		else             this.writePos = this.buffer.byteLength
		this.dataView = new DataView(this.buffer)
		
	canRead := readPos < writePos

	reset
		this.writePos = 0
		this.readPos = 0   
		
	js void expandBuffer: int size
		let prevLength = this.buffer.byteLength
		let len = Math.max(prevLength*2, size)
		this.buffer = new ArrayBuffer(len)
		let prevDataView = this.dataView
		let newDataView = new DataView(this.buffer)
		for(let i=0; i<prevLength; i++)
			newDataView.setInt8(i, prevDataView.getInt8(i))
				
		this.dataView = newDataView
		
	inline js void setInt16: int index, int value
		this.dataView.setInt16(index, value)
		
	internal skip: int count
		this.readPos += count
		
	internal js int reserveSize
		this.writePos += 4
		return this.writePos
	
	internal js void writeSize: int pos
		this.dataView.setInt32(pos-4, this.writePos-pos)
	
	js void writeInt8: int value
		if(this.writePos+1 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+1)
		this.dataView.setInt8(this.writePos, value)
		this.writePos += 1
	
	js void writeUnsignedInt8: int value
		if(this.writePos+1 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+1)
		this.dataView.setUint8(this.writePos, value)
		this.writePos += 1
	
	js void writeInt16: int value
		if(this.writePos+2 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+2)
		this.dataView.setInt16(this.writePos, value)
		this.writePos += 2
	
	js void writeUnsignedInt16: int value
		if(this.writePos+2 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+2)
		this.dataView.setUint16(this.writePos, value)
		this.writePos += 2
	
	js void writeInt32: int value
		if(this.writePos+4 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+4)
		this.dataView.setInt32(this.writePos, value)
		this.writePos += 4
	
	js void writeFloat64: float value
		if(this.writePos+8 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+8)
		this.dataView.setFloat64(this.writePos, value)
		this.writePos += 8
		
	js void writeBool: bool value
		if(this.writePos+1 > this.buffer.byteLength)
			this.expandBuffer(this.writePos+1)
		this.dataView.setInt8(this.writePos, value ? 1 : 0)
		this.writePos += 1
		
	js void writeString: string value
		let len = value.length
		let size = 4+len*4
		if(this.writePos+size > this.buffer.byteLength)
			this.expandBuffer(this.writePos+size)
		this.dataView.setInt32(this.writePos, len*4)
		this.writePos += 4
		for(let i=0; i<len; ++i) {
			this.dataView.setInt32(this.writePos, value.charCodeAt(i))
			this.writePos += 4
		}
		
	void writeBuffer: Buffer source
		writeBuffer source, 0, source.writePos
	
	js void writeBuffer: Buffer source
		                 int start
		                 int length
		let readPos = start
		let writePos = this.writePos
		
		// Expand if neccessary
		if(writePos+length+4 > this.buffer.byteLength)
			this.expandBuffer(writePos+length+4)
			
		// Write length
		this.dataView.setInt32(writePos, length)
		writePos += 4
		
		// Write bytes
		let readPosEnd = start + length
		while(readPos < readPosEnd)
			this.dataView.setUint8(writePos++, source.dataView.getUint8(readPos++))
			
		this.writePos = writePos
		
	js void copyFromBuffer: Buffer source
		let readPos = 0
		let length = source.writePos
		let writePos = this.writePos
		
		// Expand if neccessary
		if(writePos+length > this.buffer.byteLength)
			this.expandBuffer(writePos+length)
			
		// Write bytes
		let readPosEnd = readPos + length
		while(readPos < readPosEnd)
			this.dataView.setUint8(writePos++, source.dataView.getUint8(readPos++))
			
		this.writePos = writePos
		
	inline js int peekInt8  := this.dataView.getInt8(this.readPos)
	inline js int peekInt16 := this.dataView.getInt16(this.readPos)
	inline js int peekInt32 := this.dataView.getInt32(this.readPos)
	
	js int readInt8
		return this.dataView.getInt8(this.readPos++)
		
	js int readUnsignedInt8
		return this.dataView.getUint8(this.readPos++)
		
	js int readInt16
		let value = this.dataView.getInt16(this.readPos)
		this.readPos += 2
		return value
		
	js int readUnsignedInt16
		let value = this.dataView.getUint16(this.readPos)
		this.readPos += 2
		return value
		
	js int readInt32
		let value = this.dataView.getInt32(this.readPos)
		this.readPos += 4
		return value

	js float readFloat64
		let value = this.dataView.getFloat64(this.readPos)
		this.readPos += 8
		return value
		
	js bool readBool
		return this.dataView.getInt8(this.readPos++) != 0
		
	js string readString
		let value = ""
		let len = this.dataView.getInt32(this.readPos)/4
		this.readPos += 4
		for(let i=0; i<len; ++i) {
			value += String.fromCharCode(this.dataView.getInt32(this.readPos))
			this.readPos += 4
		}
		return value

	js int readBuffer: Buffer writeBuffer
		               int writeStart = 0
		let readPos = this.readPos
		let writePos = writeStart
		
		// Read length
		let length = this.dataView.getInt32(readPos)
		readPos += 4
		
		// Expand writeBuffer if neccessary
		if(writeStart+length > writeBuffer.buffer.byteLength)
			writeBuffer.expandBuffer(writeStart+length)
			
		// Read bytes
		let readPosEnd = readPos + length
		while(readPos < readPosEnd)
			writeBuffer.dataView.setUint8(writePos++, this.dataView.getUint8(readPos++))
			
		this.readPos = readPos
		writeBuffer.writePos = writePos
		return length
			
	js string toString
		let result = "readPos:" + this.readPos + " writePos:" + this.writePos
		for(let i=0; i<this.writePos; i ++)
			result += " " + this.dataView.getUint8(i)
		return result
		
	js string toRangeString: int start, int end
		let result = ""
		for(let i=start; i<end; i++)
			result += " " + this.dataView.getUint8(i)
		return result
		

unit snapshot
	// integer to unicode:
	private js string itou: int i
		i += 32;
		if (i > 33 && i < 39) {
			i++;
		} else if (i > 38 && i < 44) {
			i += 2;
		} else if (i > 43 && i < 127) {
			i += 3;
		} else if (i > 126 && i < 55258) {
			i += 37; // === 160 - 128 + 3
		} else if (i > 55295) {
			i += 8485; // === 63744 - 55296 + 37  
		}
		return String.fromCharCode(i);
		
	private js int utoi: int i
		return i - (i > 63743 ? 8517 :
			i > 159 ? 69 :
				i > 46 && i < 130 ? 35 :
					i > 40 && i < 46 ? 34 :
						i > 34 && i < 40 ? 33 :
							32);

	js string compress: dynamic input
		var _node = function(val) { return {v: val, d: {} }; }
		function itou(i) {
			i += 32;
			if (i > 33 && i < 39) {
				i++;
			} else if (i > 38 && i < 44) {
				i += 2;
			} else if (i > 43 && i < 127) {
				i += 3;
			} else if (i > 126 && i < 55258) {
				i += 37; // === 160 - 128 + 3
			} else if (i > 55295) {
				i += 8485; // === 63744 - 55296 + 37  
			}
			return String.fromCharCode(i);
		}
		if (input === null) return "";
		let i = 0,
			j = 0,
			value = 0,
			dictionary = { d: {} },
			freshNode = true,
			c = 0,
			node = _node(2), // first node will always be initialised like this.
			nextNode,
			enlargeIn = 2,
			dictSize = 3,
			numBits = 2,
			data = [],
			data_val = 0,
			data_position = 0;

		if (input.length) {
			// Write length of the input as the first four unicode characters,
			// Or 45 bits. 1<<45 bytes is about 35 terabytes, so more than enough.
			value = input.length;
			data.push(itou(value / 40000000 & 0x7FFF));
			data.push(itou((value >>> 15) & 0x7FFF));
			data.push(itou(value & 0x7FFF));

			// If there is an array, the first byte is guaranteed to
			// be new, so we write it to output stream, and add it to the
			// dictionary. For the same reason we can initialize freshNode
			// as true, and new_node, node and dictSize as if
			// it was already added to the dictionary (see above).

			c = input[0];

			// === Write first byte token to output ==

			// insert new byte token into bitstream
			for (i = 0; i < numBits; i++) {
				// Value for "new token" is 0
				data_val <<= 1;
				if (++data_position === 15) {
					data_position = 0;
					data.push(itou(data_val));
					data_val = 0;
				}
			}
			// insert byt bits into bitstream
			for (i = 0; i < 8; i++) {
				// shifting has precedence over bitmasking
				data_val = c >> i & 1 | data_val << 1;
				if (++data_position === 15) {
					data_position = 0;
					data.push(itou(data_val));
					data_val = 0;
				}
			}

			// Add charCode to the dictionary.
			dictionary[c] = node;

			for (j = 1; j < input.length; j++) {
				c = input[j];
				// does the new charCode match an existing prefix?
				nextNode = node.d[c];
				if (nextNode) {
					// continue with next prefix
					node = nextNode;
				} else {

					// Prefix+charCode does not exist in trie yet.
					// We write the prefix to the bitstream, and add
					// the new charCode to the dictionary if it's new
					// Then we set `node` to the root node matching
					// the charCode.

					if (freshNode) {
						// Prefix is a freshly added character token,
						// which was already written to the bitstream
						freshNode = false;
					} else {
						// write out the current prefix token
						value = node.v;
						for (i = 0; i < numBits; i++) {
							// shifting has precedence over bitmasking
							data_val = value >> i & 1 | data_val << 1;
							if (++data_position === 15) {
								data_position = 0;
								data.push(itou(data_val));
								data_val = 0;
							}
						}
					}

					// Is the byte a new byte
					// that needs to be stored at the root?
					if (dictionary[c] === undefined) {
						// increase token bitlength if necessary
						if (--enlargeIn === 0) {
							enlargeIn = 1 << numBits++;
						}

						// insert new byte token
						for (i = 0; i < numBits; i++) {
							data_val <<= 1;
							if (++data_position === 15) {
								data_position = 0;
								data.push(itou(data_val));
								data_val = 0;
							}
						}
						for (i = 0; i < 8; i++) {
							data_val = c >> i & 1 | data_val << 1;
							if (++data_position === 15) {
								data_position = 0;
								data.push(itou(data_val));
								data_val = 0;
							}
						}
						dictionary[c] = _node(dictSize++);
						// Note of that we already wrote
						// the charCode token to the bitstream
						freshNode = true;
					}
					// add node representing prefix + new charCode to trie
					node.d[c] = _node(dictSize++);
					// increase token bitlength if necessary
					if (--enlargeIn === 0) {
						enlargeIn = 1 << numBits++;
					}
					// set node to first charCode of new prefix
					node = dictionary[c];
				}
			}

			// === Write last prefix to output ===
			if (freshNode) {
				// character token already written to output
				freshNode = false;
			} else {
				// write out the prefix token
				value = node.v;
				for (i = 0; i < numBits; i++) {
					// shifting has precedence over bitmasking
					data_val = value >> i & 1 | data_val << 1;
					if (++data_position === 15) {
						data_position = 0;
						data.push(itou(data_val));
						data_val = 0;
					}
				}
			}

			// Is c a new character?
			if (dictionary[c] === undefined) {
				// increase token bitlength if necessary
				if (--enlargeIn === 0) {
					enlargeIn = 1 << numBits++;
				}
				for (i = 0; i < numBits; i++) {
					data_val <<= 1;
					if (++data_position === 15) {
						data_position = 0;
						data.push(itou(data_val));
						data_val = 0;
					}
				}
				for (i = 0; i < 8; i++) {
					data_val = c >> i & 1 | data_val << 1;
					if (++data_position === 15) {
						data_position = 0;
						data.push(itou(data_val));
						data_val = 0;
					}
				}
			}
			// increase token bitlength if necessary
			if (--enlargeIn === 0) {
				enlargeIn = 1 << numBits++;
			}
		}

		// Mark the end of the stream
		for (i = 0; i < numBits; i++) {
			// shifting has precedence over bitmasking
			data_val = 1 >> i | data_val << 1;
			if (++data_position === 15) {
				data_position = 0;
				data.push(itou(data_val));
				data_val = 0;
			}
		}

		// Flush the last char
		data_val <<= 15 - data_position;
		data.push(itou(data_val));

		data.push(" ");
		return data.join("");

	js dynamic decompress: string compressed
		function utoi(i) {
			return i - (i > 63743 ? 8517 :
				i > 159 ? 69 :
					i > 46 && i < 130 ? 35 :
						i > 40 && i < 46 ? 34 :
							i > 34 && i < 40 ? 33 :
								32);
		}
		if (compressed === null || compressed.length < 4) return null;

		let length = compressed.length,
			getNextValue = function (index) { return utoi(compressed.charCodeAt(index)); };
		let dictionary = [0, 1],
			enlargeIn = 1,
			dictSize = 3,
			numBits = 2,
			bytes = null,
			bytes_concat = null,
			result = new Uint8Array(
				getNextValue(0) * 0x40000000 +
				(getNextValue(1) << 15) +
				getNextValue(2)),
			result_index = 0,
			bits = 0,
			maxPower = 2,
			power = 0,
			data_val = getNextValue(3),
			data_position = 15,
			data_index = 4;

		// Get first token, guaranteed to be either
		// a new byte token or end of stream token.
		while (power < maxPower) {
			// shifting has precedence over bitmasking
			bits += (data_val >> --data_position & 1) << power++;
			if (data_position === 0) {
				data_position = 15;
				data_val = getNextValue(data_index++);
			}
		}

		if (bits === 1) {
			return null;
		}

		// else, get byte value
		bits = power = 0;
		while (power < 8) {
			// shifting has precedence over bitmasking
			bits += (data_val >> --data_position & 1) << power++;
			if (data_position === 0) {
				data_position = 15;
				data_val = getNextValue(data_index++);
			}
		}
		bytes = [bits];
		dictionary[2] = bytes;
		result[result_index++] = bits;

		// read rest of string
		while (data_index <= length) {
			// read out next token
			maxPower = numBits;
			bits = power = 0;
			while (power < maxPower) {
				// shifting has precedence over bitmasking
				bits += (data_val >> --data_position & 1) << power++;
				if (data_position === 0) {
					data_position = 15;
					data_val = getNextValue(data_index++);
				}
			}

			// 0 implies new byte
			if (!bits) {
				bits = power = 0;
				while (power < 8) {
					// shifting has precedence over bitmasking
					bits += (data_val >> --data_position & 1) << power++;
					if (data_position === 0) {
						data_position = 15;
						data_val = getNextValue(data_index++);
					}
				}
				dictionary[dictSize] = [bits];
				bits = dictSize++;
				if (--enlargeIn === 0) {
					enlargeIn = 1 << numBits++;
				}
			} else if (bits === 1) {
				// end of stream token
				return result;
			}

			if (bits > dictionary.length) {
				return null;
			}
			bytes_concat = bits < dictionary.length ? dictionary[bits] : bytes.concat(bytes[0]);
			for (let i = 0; i < bytes_concat.length; i++) {
				result[result_index++] = bytes_concat[i];
			}
			dictionary[dictSize++] = bytes.concat(bytes_concat[0]);
			bytes = bytes_concat;

			if (--enlargeIn === 0) {
				enlargeIn = 1 << numBits++;
			}

		}
		return null;

	js void testCompression
		console.log("Testing utoi/itou functions");
		let utoiMismatches = [];
		for (let i = 0; i < 1 << 15; i++) {
			let j = LZ.utoi(LZ.itou(i).charCodeAt(0));
			if (i !== j) {
				utoiMismatches.push({itou: i, utio: j});
			}
		}
	
		if (utoiMismatches.length) {
			console.log("Errors in itou/utoi conversion detected:", utoiMismatches);
		} else {
			console.log("No errors in itou/utoi conversion detected");
		}
	
		let input = new Uint16Array(1 << 15);
		for (let i = 0; i < input.length; i++) {
			input[i] = i>>4;
		}
		let inputUint8 = new Uint8Array(input.buffer);
		let compressed = LZ.compress(inputUint8);
		let decompressed = new Uint16Array(LZ.decompress(compressed).buffer);
		let mismatches = [];
		for (let i = 0; i < input.length; i++) {
			if (input[i] !== decompressed[i]) {
				mismatches.push({index: i, input: input[i], decompressed: decompressed[i]});
			}
		}
		console.log({
			compressed,
			mismatches,
			length: compressed.length,
			inputLength: input.length,
		});

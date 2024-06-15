file
	js async void save: any object
		                string to
		const fs = require("fs").promises;
		await fs.writeFile(to, JSON.stringify(object, null, "\t"))
		
	js async void save: ArrayBuffer buffer
		                string to
		const fs = require("fs").promises;
		const { Buffer } = require('node:buffer');
		await fs.writeFile(to, Buffer.from(buffer), {encoding:null})
		
	js async void save: string text
		                string to
		const fs = require("fs").promises;
		await fs.writeFile(to, text)
	
interface ArrayBuffer

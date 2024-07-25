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
		
	js void download: string text
		              string to
		var element = document.createElement("a");
		element.setAttribute("href", "data:text/plain;charset=utf-8," + encodeURIComponent(text));
		element.setAttribute("download", to);
		element.style.display = "none";
		document.body.appendChild(element);
		element.click();
		document.body.removeChild(element);
		
	inline js async string[] readDirectory: string path
		require("fs").promises.readdir(path)
		
	inline js async string[] getInfo: string path
		require("fs").promises.stat(filePath)
		
	js async string[] readDirectorySortedByTime: string path
		try {
			const fs = require("fs").promises
			const p = require("path")
			
			const files = await fs.readdir(path)
			const filesWithStats = await Promise.all(files.map(async name => {
				const filePath = p.join(path, name);
				const stats = await fs.stat(filePath);
				return { name, time: stats.birthtimeMs };
			}));
	
			filesWithStats.sort((a, b) => a.time - b.time);
			return filesWithStats.map(file => file.name);
		} catch (error) {
			console.error(error);
			return [];
		}
		
	inline js async void rename: string from, string to
		require("fs").promises.rename(from, to)
		
	inline js async string read: string filename
		require("fs").promises.readFile(filename, "utf8")
				
	inline js async string write: string filename, string data
		require("fs").promises.writeFile(filename, data, "utf8")
		
	inline js bool exists: string filename
		require("fs").existsSync(filename)
		
	inline js void createDirectory: string path
		require("fs").mkdirSync(path)
		
	js string[] showOpenDialog: FileFilter[] filters = null
		return require('@electron/remote').dialog.showOpenDialogSync({ filters, properties: ["openFile"] })
		
	js string showSaveDialog: FileFilter[] filters = null
		return require('@electron/remote').dialog.showSaveDialogSync({ filters, properties: ["createDirectory"] })
	
	async string[] readCsv: string filename, void(string[] values) processLine, void() then = null
		let content = await read(filename)
		for content.split("\n")[1..] as line
			bool inQuotes
			string value
			string[] results
			for line
				if . == "\""
					inQuotes = !inQuotes
				else
				if . == ',' and !inQuotes
					results.add value.trim
					value = ""
				else
					value += .
			if results.length
				results.add value.trim
				processLine(results)
		if then != null: then()
	
interface ArrayBuffer
immutable struct FileFilter
	string name
	string[] extensions
	
interface FileInfo
	int dev
	int ino
	int mode
	int nlink
	int uid
	int gid
	int rdev
	int size
	int blksize
	int blocks
	Time atimeMs
	Time mtimeMs
	Time ctimeMs
	Time birthtimeMs
	string atime
	string mtime
	string ctime
	string birthtime

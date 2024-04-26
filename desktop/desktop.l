transient skipInit unit Platform
	inline js string resourcesPath := process.resourcesPath
	
	js void showIcon
		if(!Platform.isDebug && window.require) {
			const { remote } = require("electron")
			remote.app.dock?.show()
		}
	
	js void hideIcon
		if(!Platform.isDebug && window.require) {
			const { remote } = require("electron")
			remote.app.dock?.hide()
		}
	
	js void show
		if(!Platform.isDebug && window.require) {
			const { remote } = require("electron")
			remote.getCurrentWindow().show()
		}
	
	js void hide
		if(!Platform.isDebug && window.require) {
			const { remote } = require("electron")
			remote.getCurrentWindow().hide()
		}
		
	js void registerGlobalShotcut: string shortcut
		                           void() do
		if(!Platform.isDebug && window.require) {
			const { remote } = require("electron")
			remote.globalShortcut.unregister(shortcut)
			remote.globalShortcut.register(shortcut, () => do())
		}

unit file
	js string readPartial: string filename, int offset=0, int length, void(string result) callback
		let fs = require("fs")
		let file = fs.open(filename, "r", (err, file) => {
			fs.read(file, {offset, length}, (err, bytesRead, buffer) => {
				callback(buffer.toString())
				fs.closeSync(file)
			})
		})
		
	js string read: string filename, void(string data) then
		if(!core.isPremiere || !input.isCertain) return
		let fs = require("fs")
		fs.readFile(filename, "utf8", (err, data) => {
			then(data)
		})
				
	js string readLineByLine: string filename, void(string line) processLine, void() then = null
		if(!core.isPremiere || !input.isCertain) return
		var lineReader = require('readline').createInterface({
			input: require('fs').createReadStream(filename)
		});
		lineReader.on('line', processLine);
		if(then != null) lineReader.on('close', then);
		
	js string write: string filename, string data, void() then = null
		if(core.isPremiere && input.isCertain) {
			require("fs").writeFile(filename, data, "utf8", (err, data) => {
				then?.()
			})
		}
		
	inline js bool exists: string filename
		require("fs").existsSync(filename)
		
	inline js void createDirectory: string path
		require("fs").mkdirSync(path)
		
	js void saveImage: string dataUrl, string file
		var base64Data = dataUrl.replace(/data:image\/png;base64,/, "");
		var fs = require("fs")
		fs.writeFile(file, base64Data, "base64", function (err) {
			if(err) log(err)
		});
		
	js string[] showOpenDialog: FileFilter[] filters = null
		if(!Network.isPremiere || !Input.isCertain) return
		const { remote } = require("electron")
		return remote.dialog.showOpenDialogSync({ filters, properties: ["openFile"] })
		
	js string showSaveDialog: FileFilter[] filters = null
		if(!Network.isPremiere || !Input.isCertain) return
		const { remote } = require("electron")
		return remote.dialog.showSaveDialogSync({ filters, properties: ["createDirectory"] })
	
	
	string[] readCsv: string filename, void(string[] values) processLine, void() then = null
		read filename
			for .split("\n")[1..] as line
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

immutable struct FileFilter
	string name
	string[] extensions


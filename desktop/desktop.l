transient skipInit unit Platform
	inline js string resourcesPath := process.resourcesPath
	
	js void showIcon
		if(!Platform_isDebug && window.require) {
			const { remote } = require("electron")
			remote.app.dock?.show()
		}
	
	js void hideIcon
		if(!Platform_isDebug && window.require) {
			const { remote } = require("electron")
			remote.app.dock?.hide()
		}
	
	js void show
		if(!Platform_isDebug && window.require) {
			const { remote } = require("electron")
			remote.getCurrentWindow().show()
		}
	
	js void hide
		if(!Platform_isDebug && window.require) {
			const { remote } = require("electron")
			remote.getCurrentWindow().hide()
		}
		
	js void registerGlobalShotcut: string shortcut
		                           void() do
		if(!Platform_isDebug && window.require) {
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
		let fs = require("fs")
		fs.readFile(filename, "utf8", (err, data) => {
			then(data)
		})		
		
	js string write: string filename, string data, void() then = null
		if(core_isPremiere && input_isCertain) {
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
		if(!Network_isPremiere || !Input_isCertain) return
		const { remote } = require("electron")
		return remote.dialog.showOpenDialogSync({ filters, properties: ["openFile"] })
		
	js string showSaveDialog: FileFilter[] filters = null
		if(!Network_isPremiere || !Input_isCertain) return
		const { remote } = require("electron")
		return remote.dialog.showSaveDialogSync({ filters, properties: ["createDirectory"] })

immutable struct FileFilter
	string name
	string[] extensions


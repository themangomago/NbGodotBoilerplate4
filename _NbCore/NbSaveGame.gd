class_name SaveGameFile

var _version : int = 0
var _timestamp : int
var _savename := ""
var _filename := ""
var _is_autosave : bool

func _init(version: int, timestamp: int, savename: String, filename: String, is_autosave: bool) -> void:
	_version = version
	_timestamp = timestamp
	_filename = filename
	_savename = savename
	_is_autosave = is_autosave

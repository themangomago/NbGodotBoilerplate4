class_name SaveGameHeader

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

func get_version() -> int: return _version

func get_autosave() -> bool: return _is_autosave

func get_timestamp() -> int: return _timestamp

func get_savename() -> String: return _savename

func get_filename() -> String: return _filename

func get_datetime() -> Array[String]: 
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(_timestamp)

	# TODO: configurable date time format
	var date: String = "%04d-%02d-%02d" % [dt.year, dt.month, dt.day]
	var time: String = "%02d:%02d:%02d" % [dt.hour, dt.minute, dt.second]
	
	return [date, time]

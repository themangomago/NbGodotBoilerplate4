extends Node

## Color used in logger and console
const GENERAL_COLORS_ERROR: String = "#b13e53"
## Color used in logger and console
const GENERAL_COLORS_WARNING: String = "#ef7d57"
## Color used in logger and console
const GENERAL_COLORS_INFO: String = "#a7f070"
## Color used in logger and console
const GENERAL_COLORS_DEBUG: String = "#41a6f6"
## Color used in logger and console
const GENERAL_COLORS_UNKNOWN: String = "#257179"

var logger_file_enabled: bool = false
var logger_file_file_name: String = "log.txt"
var logger_file_file_path: String = "user://"
var logger_file_time_stamp: bool =  true
var logger_file_trace_level_flags: int = 1 + 2 #"Error", "Warning", "Info", "Debug"

var logger_stdout_enabled: bool = true
var logger_stdout_rich_text: bool = false
var logger_stdout_time_stamp: bool =  true
var logger_stdout_trace_level_flags: int = 1 + 2 + 4 + 8

var logger_console_enabled: bool = false
var logger_console_time_stamp: bool =  true
var logger_console_trace_level_flags: int = 1 + 2 + 4

func setup(res: NbCoreConfig):
	logger_file_enabled = res.logger_file_enabled
	logger_file_file_name = res.logger_file_file_name
	logger_file_file_path = res.logger_file_file_path
	logger_file_time_stamp = res.logger_file_time_stamp
	logger_file_trace_level_flags = res.logger_file_trace_level_flags

	logger_stdout_enabled = res.logger_stdout_enabled
	logger_stdout_rich_text = res.logger_stdout_rich_text
	logger_stdout_time_stamp = res.logger_stdout_time_stamp
	logger_stdout_trace_level_flags = res.logger_stdout_trace_level_flags

	logger_console_enabled = res.logger_console_enabled
	logger_console_time_stamp = res.logger_console_time_stamp
	logger_console_trace_level_flags = res.logger_console_trace_level_flags
	
	if logger_file_enabled:
		_init_log_file()

## Log error message
func error(message: String):
	_write(Types.LogLevel.ERROR, message)


## Log warning message
func warn(message: String):
	_write(Types.LogLevel.WARNING, message)


## Log info message
func info(message: String):
	_write(Types.LogLevel.INFO, message)


## Log debug message
func debug(message: String):
	_write(Types.LogLevel.DEBUG, message)

## Log remote message
func remote(message: String):
	pass

func _write(flag: Types.LogLevel, message: String):
	var flag_name := ""
	var color
	
	match flag:
		Types.LogLevel.ERROR:
			flag_name = "ERROR"
			color = GENERAL_COLORS_ERROR
		Types.LogLevel.WARNING:
			flag_name = "WARNING"
			color = GENERAL_COLORS_WARNING
		Types.LogLevel.INFO:
			flag_name = "INFO"
			color = GENERAL_COLORS_INFO
		Types.LogLevel.DEBUG:
			flag_name = "DEBUG"
			color = GENERAL_COLORS_DEBUG
		_:
			flag_name = "UNKNOWN"
			color = GENERAL_COLORS_UNKNOWN

	# File Log
	if logger_file_enabled and logger_file_trace_level_flags & flag:
		var file := FileAccess.open(logger_file_file_path + "/" + logger_file_file_name, FileAccess.READ_WRITE)
		file.seek_end()
		var string := ""
		if logger_file_time_stamp:
			string = Time.get_datetime_string_from_system() + " " + flag_name + ": " + message
		else:
			string = flag_name + ": " + message
		file.store_line(string)
	
	# Stdout Log
	if logger_stdout_enabled and logger_stdout_trace_level_flags & flag:
		var string := ""
		if logger_stdout_time_stamp:
			string = Time.get_datetime_string_from_system() + " " + flag_name + ": " + message
		else:
			string = flag_name + ": " + message
		if logger_stdout_rich_text:
			print_rich("[color=" + color + "]" + flag_name + "[/color]: " + message)
		else:
			print(string)

	# Console Log
	if logger_console_enabled and logger_console_trace_level_flags & flag:
		Console.add_line(message, flag)
#
	#if cfg.logger_remote_enabled and cfg.logger_remote_trace_level_flags & flag:
		#pass

func _init_log_file() -> void:
	# TODO: me might need to do directoy check
	var f := FileAccess.open(logger_file_file_path + "/" + logger_file_file_name, FileAccess.WRITE)
	if f == null:
		logger_file_enabled = false
		Log.error("Failed to open log file.")
		return

	var header := "Log start"
	if logger_file_time_stamp:
		header = Time.get_datetime_string_from_system() + " INFO: " + header
	f.store_line(header)
	f.close()

extends Node

## Singleton: Log
##
## Ingame logging class

#===============================================================================
# Constants
#===============================================================================

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

#===============================================================================
# Public APIs
#===============================================================================

## Setup the Logger
func setup():
	if Global.core_config.logger_file_enabled:
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

#===============================================================================
# Internal APIs
#===============================================================================

# Write to outputs
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
	if Global.core_config.logger_file_enabled and Global.core_config.logger_file_trace_level_flags & flag:
		var file := FileAccess.open(Global.core_config.logger_file_file_path + "/" + Global.core_config.logger_file_file_name, FileAccess.READ_WRITE)
		file.seek_end()
		var string := ""
		if Global.core_config.logger_file_time_stamp:
			string = Time.get_datetime_string_from_system() + " " + flag_name + ": " + message
		else:
			string = flag_name + ": " + message
		file.store_line(string)
	
	# Stdout Log
	if Global.core_config.logger_stdout_enabled and Global.core_config.logger_stdout_trace_level_flags & flag:
		var string := ""
		if Global.core_config.logger_stdout_time_stamp:
			string = Time.get_datetime_string_from_system() + " " + flag_name + ": " + message
		else:
			string = flag_name + ": " + message
		if Global.core_config.logger_stdout_rich_text:
			print_rich("[color=" + color + "]" + flag_name + "[/color]: " + message)
		else:
			print(string)

	# Console Log
	if Global.core_config.logger_console_enabled and Global.core_config.logger_console_trace_level_flags & flag:
		Console.add_line(message, flag)

# Initialize logging file
func _init_log_file() -> void:
	# TODO: me might need to do directoy check
	var f := FileAccess.open(Global.core_config.logger_file_file_path + "/" + Global.core_config.logger_file_file_name, FileAccess.WRITE)
	if f == null:
		Global.core_config.logger_file_enabled = false
		Log.error("Failed to open log file.")
		return

	var header := "Log start"
	if Global.core_config.logger_file_time_stamp:
		header = Time.get_datetime_string_from_system() + " INFO: " + header
	f.store_line(header)
	f.close()

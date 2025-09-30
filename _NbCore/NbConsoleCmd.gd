class_name ConsoleCmd

## Class: ConsoleCmd
##
## Class to utilizes adding and handling of console commands


# Console command name
var _name: String
# Default value (null if none)
var _default_value: Variant
# Help text which will be shown when using the help command
var _help_text: String
# Constructed callalbe (There was a reason why it is constructed here, but i cant remember)
var _callable: Callable
# Range limits for commands with values
var _range_limits: Array
# Is this command a cheat
var _cheat: bool = false

## Constructor
func _init(
	command_name: StringName,
	callable: Callable,
	default_value: Variant = null,
	help_text: String = ""
):
	_name = command_name
	_default_value = default_value
	_help_text = help_text
	_callable = callable

## Set the default value - if any.
func set_default_value(default_value: Variant) -> void:
	_default_value = default_value

## Set the help text which will be shown using the help command.
func set_help_text(help_text: String) -> void:
	_help_text = help_text

## Set callback. 
func set_callback(callable: Callable) -> void:
	_callable = callable

## Set range boundaries for the adjustable value.
func set_range(lower: Variant, upper: Variant) -> void:
	assert(typeof(lower) == typeof(upper), "Error: Boundaries must be of the same type")
	_range_limits = [lower, upper] 

## Set the command cheat protected.
func set_cheat_protection(protected: bool):
	_cheat = protected

## Get the command name.
func get_name() -> String:
	return _name

## Get the value type.
func get_value_type() -> int:
	return typeof(_default_value)

## Get the callable.
func get_callable() -> Callable:
	return _callable

## Get help text.
func get_help() -> String:
	if _cheat:
		return _help_text + " (cheat)"
	return _help_text

## Get Cheat state.
func is_cheat() -> bool:
	return _cheat

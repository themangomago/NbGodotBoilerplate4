class_name ConsoleCmd

## Class ConsoleCmd
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
var _cheat: bool

## Constructor
func _init(
	command_name: StringName,
	default_value: Variant = null,
	help_text: String = "",
	object: Object = null,
	method: String = "",
):
	_name = command_name
	_default_value = default_value
	_help_text = help_text
	if object and method.length() > 0:
		_callable = Callable(object, method)

## Set the default value - if any.
func set_default_value(default_value: Variant) -> void:
	_default_value = default_value

## Set the help text. Which will be shown using the help command.
func set_help_text(help_text: String) -> void:
	_help_text = help_text

## Set callback. 
func set_callback(object: Object, method: String):
	assert(object, "Error: No reference provided")
	assert(method.length() > 0, "Error: Please provide a function name")
	_callable = Callable(object, method)

func set_range(lower: Variant, upper: Variant):
	assert(typeof(lower) == typeof(upper), "Error: Boundaries must be of the same type")
	_range_limits = [lower, upper] 

func set_cheat_protection(protected: bool):
	_cheat = protected

func get_name() -> String:
	return _name

func get_value_type() -> int:
	return typeof(_default_value)

func get_callable() -> Callable:
	return _callable

func get_help() -> String:
	if _cheat:
		return _help_text + " (cheat)"
	return _help_text

func is_cheat() -> bool:
	return _cheat

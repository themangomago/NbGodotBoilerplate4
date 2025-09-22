class_name ConsoleCmd

var state: Dictionary = {
	"name": "",
	"default_value": 0,
	"help_text": "",
	"callable": null,
	"range_limits": [],
	"cheat": false,
}

func _init(
	command_name: StringName,
	default_value: Variant = null,
	help_text: String = "",
	object: Object = null,
	method: String = "",
):
	state.name = command_name
	state.default_value = default_value
	state.help_text = help_text
	if object and method.length() > 0:
		state.callable = Callable(object, method)

func set_default_value(default_value: Variant):
	state.defaul_value = default_value

func set_help_text(help_text: String):
	state.help_text = help_text

func set_callback(object: Object, method: String):
	assert(object, "Error: No reference provided")
	assert(method.length() > 0, "Error: Please provide a function name")
	state.callable = Callable(object, method)

func set_range(lower: Variant, upper: Variant):
	assert(typeof(lower) == typeof(upper), "Error: Boundaries must be of the same type")
	state.range_limits = [lower, upper] 

func set_cheat_protection(protected: bool):
	state.cheat = protected

func get_name() -> String:
	return state.name

func get_value_type() -> int:
	return typeof(state.default_value)

func get_callable() -> Callable:
	return state.callable

func get_help() -> String:
	if state.cheat:
		return state.help_text + " (cheat)"
	return state.help_text

func is_cheat() -> bool:
	return state.cheat

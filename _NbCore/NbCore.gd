extends Node



## User config. Holds the actual config.
## The user config is derived from USER_CONFIG_MODEL and will be overwritten
## by the loading the user config file.
var user_config := {}

var core_config : Resource = null

## Resolution list derived from USER_CONFIG_MODEL
var resolution_list: Array


################################################################################
# Video Functions
################################################################################
func vid_set_resolution_list(list: Array):
	resolution_list = list

## Set vsync
func vid_set_vsync(value: bool) -> void: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED)

## Set fps cap
func vid_set_fps_cap(value: int) -> void: Engine.max_fps = value

## Set resolution
func vid_set_resolution(res: int) -> void: 
	if res >= resolution_list.size() or res < 0:
		res = 0
	var resolution = resolution_list[res]
	get_window().size = resolution

## Center the window
func vid_center_window() -> void: get_window().position = (DisplayServer.screen_get_size() - get_window().size) / 2

## Sets fullscreen
func vid_set_fullscreen(value: bool) -> void: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) if value else DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


################################################################################
# User Config Functions
################################################################################
func parse_user_config_model(model: Dictionary) -> Dictionary:
	var config := {}
	
	# Add meta
	for entry in model.meta:
		var value = null
		if typeof(model.meta[entry]) == TYPE_STRING and get(model.meta[entry]):
			value = get(model.meta[entry])
		else:
			value = model.meta[entry]
		config.merge({
			entry: value
		})
	# Add configurables
	for category in model.configurable:
		var option_entry = {}
		for option in category.options:
			if option.has("name"):
				var value
				if option.has("default"):
					value = option.default
				elif option.has("keys"):
					value = option.keys
				option_entry.merge({option.name: value})
		config.merge({category.name: option_entry})

	return config

func config_merge_recursive(base: Dictionary, add: Dictionary) -> Dictionary:
	var out = base.duplicate(true)
	for key in add.keys():
		if out.has(key) and typeof(out[key]) == TYPE_DICTIONARY and typeof(add[key]) == TYPE_DICTIONARY:
			out[key] = config_merge_recursive(out[key], add[key])
		else:
			out[key] = add[key]
	return out

## Load user config file. Create one if no cfg exists. Also does upgrade and sanity checks.
func load_user_config(schema: Dictionary) -> Dictionary:
	## User config does not exist - create one
	if not FileAccess.file_exists("user://config.cfg"):
		save_user_config(schema)
		return schema.duplicate(true)
	## Open the config file
	var file := FileAccess.open("user://config.cfg", FileAccess.READ)
	if file == null:
		Log.error("Could not open config file. Using default config as fallback.")
		return schema.duplicate(true)
	
	var read_data: Dictionary = JSON.new().parse_string(file.get_as_text())
	
	## Overwrite corrupt configs
	if not read_data.has("configVersion"):
		save_user_config(schema)
		Log.error("Corrupt config file found. Using default config as fallback.")
		return schema.duplicate(true)
	
	## Merge user data with schema
	return config_merge_recursive(schema, read_data)


## Save user config file
func save_user_config(data: Dictionary) -> void:
	var file := FileAccess.open("user://config.cfg", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

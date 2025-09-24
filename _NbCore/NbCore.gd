extends Node



## User config. Holds the actual config.
## The user config is derived from USER_CONFIG_MODEL and will be overwritten
## by the loading the user config file.
var user_config := {}

var core_config : Resource = null

## Resolution list derived from USER_CONFIG_MODEL
var resolution_list: Array

var savegames_headers : Array[SaveGameHeader]

const SAVE_PATH := "user://saves"

################################################################################
# Video Functions
################################################################################
#region Video Functions
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
#endregion

################################################################################
# User Config Functions
################################################################################
#region User Config Functions
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
#endregion

################################################################################
# Save Game Helper
################################################################################
#region Save Game Helper
func scan_savegames() -> void:
	var dir := DirAccess.open(SAVE_PATH)
	savegames_headers = []
	
	# Directory does not exist - create it
	if dir == null:
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".sav"):
			var header = load_save_header(file_name)
			if header: savegames_headers.append(header)
		file_name = dir.get_next()
	dir.list_dir_end()
	return

func sort_savegames() -> void:
	if savegames_headers.is_empty():
		return
	savegames_headers.sort_custom(func(a: SaveGameHeader, b: SaveGameHeader) -> bool:
		var at := a.get_timestamp()
		var bt := b.get_timestamp()
		if at == bt:
			return a.get_savename().nocasecmp_to(b.get_savename()) < 0
		return at > bt
	)

func load_save_header(file_name: String) -> SaveGameHeader:
	var path = SAVE_PATH + "/" + file_name
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null: return null
	var version = file.get_32()
	var timestamp = file.get_64()
	var savename = file.get_pascal_string()
	var is_autosave = file.get_8() == 1
	file.close()
	return SaveGameHeader.new(version, timestamp, savename, file_name, is_autosave)

func load_save_payload(file_name: String) -> Dictionary:
	var path = SAVE_PATH + "/" + file_name
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	
	# Skip header
	var _version = file.get_32()
	var _timestamp = file.get_64()
	var _savename = file.get_pascal_string()
	var _is_autosave = file.get_8() == 1
	
	# Dictionary laden
	var payload: Dictionary = {}
	if not file.eof_reached():
		payload = file.get_var()
	
	file.close()
	return payload

func save_game(header: SaveGameHeader, payload: Dictionary) -> bool:
	var path := SAVE_PATH + "/" + header.get_filename()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not open file for writing: %s" % path)
		return false

	# Header
	file.store_32(header.get_version())
	file.store_64(header.get_timestamp())
	file.store_pascal_string(header.get_savename())
	file.store_8(1 if header.get_autosave() else 0)

	# Payload - use store_var so load_save_payload() can read it with get_var()
	# Keep objects disabled for safety and portability
	file.store_var(payload, false)

	file.flush() # optional but nice to have
	file.close()
	Log.info("Game saved to file: " + str(header.get_filename()))
	return true

func delete_savegame(id: int) -> void:
	var file_name := savegames_headers[id].get_filename()
	var save_path := SAVE_PATH + "/" + file_name

	if FileAccess.file_exists(save_path):
		var dir := DirAccess.open(SAVE_PATH)
		if dir:
			var err = dir.remove(file_name)
			print(err)
			if err != OK:
				Log.error("Could not delete save file: " + str(file_name))
				return
		Log.info("Deleted save file: " + str(file_name))


#endregion

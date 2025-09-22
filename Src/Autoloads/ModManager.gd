extends Node

enum HookType {
	Pre,
	Post
}

var pre_hooks := []
var post_hooks := []
var gd_instances := []

func _ready() -> void:
	load_mod("res://Mods/TestMod")



func pre_hook(function: String, arguments: Array = []) -> bool:
	for hook in pre_hooks:
		if hook["hook"] == function:
			hook["gd_file"].call(hook["api"], arguments)
	return false

func post_hook(function: String, arguments: Array = []):
	for hook in post_hooks:
		if hook["hook"] == function:
			hook["gd_file"].call(hook["api"], arguments)



	
func load_mod(path: String) -> bool:
	var mod_script_path = path.path_join("Mod.gd")
	if not FileAccess.file_exists(mod_script_path):
		printerr("ModManager: Mod.gd not found in path: ", path)
		return false

	var mod_script = load(mod_script_path)
	if not mod_script:
		printerr("ModManager: Failed to load Mod.gd script at: ", mod_script_path)
		return false

	var mod_instance = mod_script.new()
	if not "api_list" in mod_instance:
		printerr("ModManager: No api_list found in Mod.gd")
		return false

	var api_list = mod_script.api_list
	for entry in api_list:
		if not entry.has("file") or not entry.has("hook") or not entry.has("api") or not entry.has("type"):
			printerr("ModManager: Invalid api_list entry in ", mod_script_path)
			continue
		
		## Load gd script if not already loaded
		var gd_index = load_gd_script(path, entry.file)
		if gd_index == -1:
			printerr("ModManager: Invalid script file: ", entry.file)
			return false
		
		## Store entry
		var new_entry = entry.duplicate()
		new_entry["gd_file"] = gd_instances[gd_index].instance
		match new_entry["type"]:
			HookType.Pre:
				pre_hooks.append(new_entry)
			HookType.Post:
				post_hooks.append(new_entry)
			_:
				printerr("ModManager: Unknown HookType in entry: ", entry)

	print("ModManager: Loaded mod at ", path, " with ", api_list.size(), " hooks.")
	return true

# Loads a gd script to our instance space if necessary; returns the index
func load_gd_script(path, file) -> int:
	## Check if the GdScript is already loaded
	var i = 0;
	for entry in gd_instances:
		if entry.file == file and entry.path == path:
			## Script already loaded, return index
			return i
		i += 1
	## Instance the script
	var script_path = path.path_join(file)
	if not FileAccess.file_exists(script_path):
		push_error("ModManager: File not found: " + script_path)
		return -1
	
	var script = load(script_path)
	if script == null:
		push_error("ModManager: Failed to load script at: " + script_path)
		return -1
	
	var instance = script.new()
	var entry := {
		"path": path,
		"file": file,
		"instance": instance
	}
	gd_instances.append(entry)
	return gd_instances.size() - 1

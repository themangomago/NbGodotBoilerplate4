extends Control

# TODO:
# - adapt pending changes to fit all settings options

@export var debug: bool = false

@export var category_button_scene: PackedScene = preload("./Elements/category_button.tscn")
@export var spinbox_button_scene: PackedScene = preload("./Elements/spinbox_button.tscn")
@export var input_button_scene: PackedScene = preload("./Elements/input_button.tscn")
@export var spacer_scene: PackedScene = preload("./Elements/spacer.tscn")

@export var load_save_scene: PackedScene = preload("./Elements/load_save_game.tscn")


var _focus_object: Control = null
var _focus_keyboard: bool = false

var _current_view: String = "MainMenu"

var _loadsave_window_id: int = -1
var _loadsave_window_type: String = "load"


# Menu settings that has changed but not yet accepted
var _pending_changes := []


func _ready():
	_init_menu()
	
	get_viewport().connect("gui_focus_changed", Callable(self, "_gui_focus_changed"))
	
	#Events.connect("menu_control_key_assign_entered", Callable(self, "_window_assign_show"))
	#Events.connect("menu_control_key_assign_finished", Callable(self, "_window_assign_hide"))

func show_menu(isGameActive: bool) -> void:
	if isGameActive:
		$Views/MainMenu/v/ButtonResume.show()
		$Views/MainMenu/v/ButtonSaveGame.show()
	else:
		$Views/MainMenu/v/ButtonResume.hide()
		$Views/MainMenu/v/ButtonSaveGame.hide()
	show()


func _window_assign_show():
	$Views/Settings/WindowAssign.show()

func _window_assign_hide():
	$Views/Settings/WindowAssign.hide()

func _debug(str: String):
	if debug:
		print(str)

func _input(event):
	# If no element has focus and the player uses keyboard or gamepad - grab focus
	if not _focus_object:
		_focus_check(event)


func _init_menu():
	# Init option buttons
	for category in Global.USER_CONFIG_MODEL.configurable:
		# Setup option buttons
		var callback = Callable(self, "_submenu_button_up")
		callback = callback.bind(category.name)
		
		var button = category_button_scene.instantiate()
		button.text = tr(category.tr)
		button.name = category.name
		button.connect("button_up", callback)
		$Views/Settings/w/SubMenu.add_child(button)
	
	$Views/Settings/w/ButtonAccept.hide()
	$Views/Settings/w/OptionMenu.hide()
	
	# Switch to main menu view
	_switch("MainMenu")


func _focus_check(event):
	# TODO: necessary?
	if event is InputEventKey:
		#if not event.pressed:
		# TODO: keyboard and gamepad codes
		if event.keycode == KEY_UP or event.keycode == KEY_DOWN:
			if $Views/MainMenu.visible:
				if $Views/MainMenu/v/ButtonResume.visible:
					$Views/MainMenu/v/ButtonResume.grab_focus()
				else:
					$Views/MainMenu/v/ButtonNewGame.grab_focus()
			else:
				$Views/Settings/w/ButtonBack.grab_focus()


func _setup_submenu(category: String):
	# Clear old
	for child in $Views/Settings/w/OptionMenu.get_children():
		#child.disconnect() TODO
		child.queue_free()
	
	# Find configurable option in user config model
	var index := -1
	for i in range(Global.USER_CONFIG_MODEL.configurable.size()):
		if Global.USER_CONFIG_MODEL.configurable[i].name == category:
			index = i
			break
		i += 1
	assert(index != -1, "HUD: Provided category does not exists in user config model")
	
	# Set submenu title
	$Views/Settings/w/Label.set_text(Global.USER_CONFIG_MODEL.configurable[index].tr)
	
	# TODO: button remapper case
	
	for option in Global.USER_CONFIG_MODEL.configurable[index].options:
		if option.has("name"):
			if option.has("keys"):
				_setup_submenu_add_input(category, option)
			else:
				_setup_submenu_add_spinbox(category, option)
		else:
			if option.has("tr"):
				_setup_submenu_add_spacer(option)
			else:
				# TODO
				#Log.debug("invalid configuration option found")
				print("invalid configuration option found")


func _setup_submenu_add_input(category: String, option: Dictionary):
	var callback := Callable(self, "_input_button_up")
	callback = callback.bind(category)
	callback = callback.bind(option.name)
	var input_button := input_button_scene.instantiate()
	input_button.set_text(tr(option.tr))
	input_button.set_key_data(Global.user_config[category][option.name])
	input_button.connect("button_assigned", callback)
	$Views/Settings/w/OptionMenu.add_child(input_button)

func _setup_submenu_add_spinbox(category: String, option: Dictionary):
	var callback := Callable(self, "_config_button_up")
	callback = callback.bind(category)
	callback = callback.bind(option.name)
	var choice_button := spinbox_button_scene.instantiate()
	choice_button.text = tr(option.tr)
	if option.has("values"):
		choice_button.set_choices(option.values, Global.user_config[category][option.name])
	elif option.has("range"):
		choice_button.set_range(option.range, Global.user_config[category][option.name], option.step)
	choice_button.connect("spinbox_button_updated", callback)
	$Views/Settings/w/OptionMenu.add_child(choice_button)

func _setup_submenu_add_spacer(option: Dictionary):
	var spacer = spacer_scene.instantiate()
	spacer.set_text(tr(option.tr))
	$Views/Settings/w/OptionMenu.add_child(spacer)

func _input_button_up(slot_id, key_event, option, category):
	print("...")
	print(slot_id)
	print(key_event)
	print(Global.user_config[category][option])
	print("...")
	
	
	_control_remapping_remove_duplicate_entries(category, key_event)

	
	_pending_changes.append({
		"category": category,
		"option": option,
		"value": key_event,
		"slot": slot_id
	})
	_setup_submenu("controls")


func _control_remapping_remove_duplicate_entries(category: String, key_event: Dictionary) -> void:
	# Check if key is already assigned
	for option in Global.user_config[category]:
		for i in range(Global.user_config[category][option].size()):
			var key = Global.user_config[category][option][i]
			if key > 0:
				if key_event.device == key.device and key_event.type == key.type:
					if key_event.code == key.code:
						# Double entry found - remove it
						_pending_changes.append({
							"category": category,
							"option": option,
							"value": {},
							"slot": i
						})
						break
						break



func _config_button_up(value, option, category):
	# Check if pending change entry exists
	var exists := false
	for i in range(_pending_changes.size()):
		if _pending_changes[i].category == category:
			if _pending_changes[i].option == option:
				# Update pending change
				_pending_changes[i].value = value
				exists = true
		i += 1
	
	if not exists:
		# Add new pending change entry
		_pending_changes.append(
			{
				"category": category,
				"option": option,
				"value": value
			}
		)


func _submenu_button_up(category_name):
	_setup_submenu(category_name)
	$Views/Settings/w/SubMenu.hide()
	$Views/Settings/w/OptionMenu.show()
	$Views/Settings/w/ButtonAccept.show()
	_focus_object = null


func _switch(to):
	_current_view = to
	if to == "MainMenu":
		$Views/LoadSaveWindow.hide()
		$Views/Settings.hide()
		$Views/MainMenu.show()
		_focus_object = null
	elif to == "Settings":
		$Views/LoadSaveWindow.hide()
		$Views/MainMenu.hide()
		$Views/Settings.show()
		_focus_object = null
	elif to == "Load":
		$Views/LoadSaveWindow/w/Label.set_text(tr("TR_MENU_LOAD_GAME"))
		$Views/MainMenu.hide()
		$Views/Settings.hide()
		# Remove savegames
		for e in $Views/LoadSaveWindow/w/scroll/v.get_children(): e.queue_free()
		# Load savegames
		var id = 0
		for header in Global.savegames_headers:
			var el = load_save_scene.instantiate()
			el.setup(id, header, true)
			el.connect("loadsave_load", _loadsave_load)
			el.connect("loadsave_delete", _loadsave_delete)
			$Views/LoadSaveWindow/w/scroll/v.add_child(el)
			id += 1
		$Views/LoadSaveWindow.show()
		_focus_object = null
	elif to == "Save":
		$Views/LoadSaveWindow/w/Label.set_text(tr("TR_MENU_SAVE_GAME"))
		$Views/MainMenu.hide()
		$Views/Settings.hide()
		# Remove savegames
		for e in $Views/LoadSaveWindow/w/scroll/v.get_children(): e.queue_free()
		# Load savegames
		var id = 0
		for header in Global.savegames_headers:
			var el = load_save_scene.instantiate()
			el.setup(id, header, false)
			el.connect("loadsave_overwrite", _loadsave_overwrite)
			el.connect("loadsave_delete", _loadsave_delete)
			$Views/LoadSaveWindow/w/scroll/v.add_child(el)
			id += 1
		$Views/LoadSaveWindow.show()
		_focus_object = null

#region load-save
func _loadsave_load(id: int) -> void:
	_switch("MainMenu")
	Events.emit_signal("menu_save_load_game", id)
	
func _loadsave_overwrite(id) -> void:
	$Views/LoadSaveWindow/Window/Panel/s/Text.set_text(tr("TR_MENU_LOADSAVE_OVERWRITE_WINDOW_TEXT"))
	$Views/LoadSaveWindow/Window.show()
	_loadsave_window_id = id
	_loadsave_window_type = "overwrite"
	
func _loadsave_delete(id) -> void:
	$Views/LoadSaveWindow/Window/Panel/s/Text.set_text(tr("TR_MENU_LOADSAVE_DELETE_WINDOW_TEXT"))
	$Views/LoadSaveWindow/Window.show()
	_loadsave_window_id = id
	_loadsave_window_type = "delete"


func _on_load_save_button_no_button_up() -> void:
	$Views/LoadSaveWindow/Window.hide()


func _on_load_save_button_yes_button_up() -> void:
	$Views/LoadSaveWindow/Window.hide()
	if _loadsave_window_type == "overwrite":
		_switch("MainMenu")
		Events.emit_signal("menu_save_overwrite_game", _loadsave_window_id)
	elif _loadsave_window_type == "delete":
		_switch("MainMenu")
		Events.emit_signal("menu_save_delete_game", _loadsave_window_id)


func _on_save_button_button_up() -> void:
	var file = $Views/LoadSaveWindow/w/NewSave/LineEdit.text
	_switch("MainMenu")
	Events.emit_signal("menu_save_game", file)
	

#endregion


func _gui_focus_changed(control: Control) -> void:
	_focus_object = control
	if Input.is_action_pressed("ui_down") or Input.is_action_just_released("ui_down")\
		or Input.is_action_pressed("ui_up") or Input.is_action_just_released("ui_up"):
		_focus_keyboard = true
	else:
		_focus_keyboard = false


func _on_button_quit_button_up():
	get_tree().quit()


func _on_button_settings_button_up():
	_switch("Settings")
	


func _on_button_new_game_button_up():
	#Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("menu_switch_new_game")
	self.hide()

func _on_button_resume_button_up():
	#Events.emit_signal("play_sound", "menu_click")
	Events.emit_signal("menu_switch_resume_game")
	self.hide()



func _on_button_back_button_up():
	
	
	if $Views/Settings/w/SubMenu.visible:
		_switch("MainMenu")
	else:
		$Views/Settings/w/Label.set_text("TR_MENU_SETTINGS")
		$Views/Settings/w/SubMenu.show()
		$Views/Settings/w/OptionMenu.hide()
		$Views/Settings/w/ButtonAccept.hide()
	_pending_changes = []


func _on_button_accept_button_up():
	for change in _pending_changes:
		for category in Global.USER_CONFIG_MODEL.configurable:
			if change.category == category.name:
				for option in category.options:
					if change.option == option.name:
						# Update config
						Global.user_config[change.category][change.option] = change.value
						if option.has("signal"):
							Events.emit_signal(option.get("signal"), change.value)
							_debug("Emitting: " + str(option.get("signal")))
						# Option found break loop
						break
				# Category found break loop
				break
	# Save config
	Global.save_user_config(Global.user_config)
	# Navigate back
	_on_button_back_button_up()


func _on_button_save_game_button_up() -> void:
	_switch("Save")


func _on_button_load_game_button_up() -> void:
	_switch("Load")

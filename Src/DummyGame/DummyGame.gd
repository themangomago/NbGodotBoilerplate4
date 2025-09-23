extends Node

var gameState: GameState

func _ready() -> void:
	if ModManager.pre_hook("dummy_game_ready"): return
	print("Original Game")
	ModManager.post_hook("dummy_game_ready")



# Loads new game state and resets the game
func new_game():
	gameState = GameState.new()
	change_counter(gameState.counter_value)

func load_game(id: int):
	var file_name: String = Global.savegames_headers[id].get_filename()
	var payload: Dictionary = Global.load_save_payload(file_name)
	
	print("load " + str(id))
	print(payload)
	gameState = GameState.new()
	if not gameState.load_game(payload):
		Log.error("Could not load save file: " + str(file_name))
		Events.emit_signal("menu_switch_main_menu")
		return
	change_counter(gameState.counter_value)

func save_game(id: int):
	var payload = gameState.get_payload()
	print("save " + str(id))
	print(payload)
	# Header is created at game manager
	var header: SaveGameFile = Global.savegames_headers[id]
	
	if Global.save_game(header, payload):
		print("Save completed")
	else:
		printerr("Save failed")


func _on_menu_button_button_up() -> void:
	Events.emit_signal("menu_switch_main_menu")


func change_counter(value):
	gameState.counter_value = value
	$HUD/Label.set_text("Count: " + str(gameState.counter_value))


func _on_dec_button_button_up() -> void:
	change_counter(gameState.counter_value - 1)


func _on_inc_button_button_up() -> void:
	change_counter(gameState.counter_value + 1)

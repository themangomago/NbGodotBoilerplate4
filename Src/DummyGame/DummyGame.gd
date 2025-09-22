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

func load_game():
	gameState = GameState.new()
	gameState.load_state()


func _on_menu_button_button_up() -> void:
	Events.emit_signal("menu_switch_main_menu")


func change_counter(value):
	gameState.counter_value = value
	$HUD/Label.set_text("Count: " + str(gameState.counter_value))


func _on_dec_button_button_up() -> void:
	change_counter(gameState.counter_value - 1)


func _on_inc_button_button_up() -> void:
	change_counter(gameState.counter_value + 1)

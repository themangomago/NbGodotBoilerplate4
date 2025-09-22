extends Node


func _ready() -> void:
	if ModManager.pre_hook("dummy_game_ready"): return
	print("Original Game")
	
	ModManager.post_hook("dummy_game_ready")

func _on_button_button_up() -> void:
	Events.emit_signal("menu_switch_main_menu")

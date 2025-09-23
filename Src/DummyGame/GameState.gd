class_name GameState extends Node

var counter_value: int = 0

func _init() -> void:
	pass

func new_game() -> void:
	counter_value = 0

func load_game(state: Dictionary) -> bool:
	if state.has("counter_value"):
		counter_value = state.get("counter_value")
		return true
	return false

func get_payload() -> Dictionary:
	return {"counter_value": counter_value}

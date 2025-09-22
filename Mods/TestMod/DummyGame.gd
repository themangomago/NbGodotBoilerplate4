extends Node


func dummy_game_ready_pre(arguments: Array = []):
	print("Pre Game Hook")
	return false

func dummy_game_ready_post(arguments: Array = []):
	print("Post Game Hook")

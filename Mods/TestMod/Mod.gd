extends Node


const api_list = [
	{"file": "DummyGame.gd", "hook": "dummy_game_ready", "api": "dummy_game_ready_pre", "type": ModManager.HookType.Pre},
	{"file": "DummyGame.gd", "hook": "dummy_game_ready", "api": "dummy_game_ready_post", "type": ModManager.HookType.Post},
]

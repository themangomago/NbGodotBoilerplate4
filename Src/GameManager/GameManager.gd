extends Control

@export var config: NbCoreConfig

func _ready() -> void:
	# Set Game Manager reference to be accessible from everwhere
	Global.initialize(self)

	# Intro handling
	if not config.skip_intro:
		$Intro/IntroPlayer.play()
	else:
		$Intro.hide()
		
	# Connect Events
	Events.connect("menu_switch_new_game", new_game)
	Events.connect("menu_switch_resume_game", resume_game)
	Events.connect("menu_switch_main_menu", main_menu)


func new_game() -> void:
	var game_scene = load("res://Src/DummyGame/DummyGame.tscn").instantiate()
	$GameHolder.add_child(game_scene)
	$Menu/Menu.hide()

func resume_game() -> void:
	$Menu/Menu.hide()
	get_tree().paused = false

func main_menu() -> void:
	$Menu/Menu.show()
	get_tree().paused = true

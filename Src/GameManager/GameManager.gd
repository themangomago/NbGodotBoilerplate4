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
	
	# Show the main menu
	main_menu() 

func new_game() -> void:
	# Remove instances if any
	for instance in $GameHolder.get_children(): instance.queue_free()
	# Create new instance
	var game = load("res://Src/DummyGame/DummyGame.tscn").instantiate()
	game.new_game()
	$GameHolder.add_child(game)
	# Hide the menu and process the game instance
	$Menu/Menu.hide()
	$GameHolder.process_mode = Node.PROCESS_MODE_INHERIT

func resume_game() -> void:
	$Menu/Menu.hide()
	$GameHolder.process_mode = Node.PROCESS_MODE_INHERIT

func main_menu() -> void:
	print("menu")
	$Menu/Menu.show_menu(true if $GameHolder.get_child_count() > 0 else false)
	$GameHolder.process_mode = Node.PROCESS_MODE_DISABLED

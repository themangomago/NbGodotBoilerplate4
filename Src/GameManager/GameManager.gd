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
	Events.connect("menu_save_load_game", load_game)
	
	
	Events.connect("menu_save_game", save_game)
	Events.connect("menu_save_overwrite_game", overwrite_game)
	Events.connect("menu_save_delete_game", delete_game)
	
	# Show the main menu
	main_menu() 

func new_game(id: int = -1) -> void:
	# Remove instances if any
	for instance in $GameHolder.get_children(): instance.queue_free()
	# Create new instance
	var game = load("res://Src/DummyGame/DummyGame.tscn").instantiate()
	if id == -1:
		game.new_game()
	else:
		game.load_game(id)
		
	$GameHolder.add_child(game)
	# Hide the menu and process the game instance
	$Menu/Menu.hide()
	$GameHolder.process_mode = Node.PROCESS_MODE_INHERIT

func load_game(id: int) -> void:
	new_game(id)

func save_game(savename: String) -> void:
	# TODO: add save game version
	var timestamp: int = Time.get_unix_time_from_system()
	if savename == "": savename = "Unnamed " + str(timestamp)
	var filename = "Save_" + str(timestamp) + ".sav"
	var header = SaveGameHeader.new(1, timestamp, savename, filename, false)
	Global.savegames_headers.append(header)
	var id = Global.savegames_headers.size() - 1
	# Unpause game
	$GameHolder.process_mode = Node.PROCESS_MODE_INHERIT
	$GameHolder.get_child(0).save_game(id)
	$Menu/Menu.hide()

func overwrite_game(id: int) -> void:
	$GameHolder.process_mode = Node.PROCESS_MODE_INHERIT
	$GameHolder.get_child(0).save_game(id)
	$Menu/Menu.hide()

func delete_game(id: int) -> void:
	Global.delete_savegame(id)
	main_menu() 
	

func resume_game() -> void:
	$Menu/Menu.hide()
	$GameHolder.process_mode = Node.PROCESS_MODE_INHERIT

func main_menu() -> void:
	print("main_menu() : GameManager")
	Global.scan_savegames()
	Global.sort_savegames()
	$Menu/Menu.show_menu(true if $GameHolder.get_child_count() > 0 else false)
	$GameHolder.process_mode = Node.PROCESS_MODE_DISABLED

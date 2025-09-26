extends Control

## Singleton: Console 
##
## Interface between user and console UI


## Console toggle requested
signal console_toggle()
## Pushes add line event to the UI
signal console_ui_add_line(line: String, level: Types.LogLevel)

# Stored console commands
var _commands: Array[ConsoleCmd] = []


func _ready() -> void:
	# Add default commands
	_add_default_commands()

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_toggle_console"):
		emit_signal("console_toggle")

#===============================================================================
# Public APIs
#===============================================================================

## Add a new command to the console.
## Takes [param command] as input.
func add_command(command: ConsoleCmd) -> void:
	assert(get_command(command.get_name()) == null, "Error: Command already exist. Please remove it first.")
	_commands.append(command)

## Get and return a command by name.
## Returns the command of [ConsoleCmd] or [code]null[/code] else.
func get_command(cmd_name: String) -> ConsoleCmd:
		for cmd in _commands:
			if cmd_name == cmd.get_name():
				return cmd
		return null

## Helper function for the UI to get autocompletion suggestions from given string.
## Returns an array of matching [ConsoleCmd] entries.
func get_autocompletion(start: String) -> Array[ConsoleCmd]:
	var found_cmds : Array[ConsoleCmd]
	for cmd in _commands:
		var name_string: String = cmd.get_name()
		if name_string.begins_with(start):
			found_cmds.append(cmd)
	return found_cmds

## Remove a command by name.
## Returns [code]true[/code] if deleted - [code]false[/code] else.
func remove_command(cmd_name: String) -> bool:
	for i in range(_commands.size()):
		if cmd_name == _commands[i].get_name():
			_commands.remove_at(i)
			return true
		i += 1
	return false

## Add a text line to the console.
func add_line(line: String, level: Types.LogLevel = Types.LogLevel.NONE) -> void:
	emit_signal("console_ui_add_line", line, level)


#===============================================================================
# Private APIs
#===============================================================================

# Adding the default commands
func _add_default_commands() -> void:
	# Version
	add_command(
		ConsoleCmd.new(
			"version",
			null,
			"Get the game version",
			self,
			"_get_version"
		)
	)
	# Help
	add_command(
		ConsoleCmd.new(
			"help",
			"",
			"Diplay help",
			self,
			"_get_help"
		)
	)
	# Quit
	add_command(
		ConsoleCmd.new(
			"quit",
			null,
			"Just quit.",
			self,
			"_quit",
		)
	)

# Console Command: version
func _get_version() -> void:
	add_line("Game Version " + str(Global.GAME_VERSION), Types.LogLevel.INFO)

# Console Command: help
func _get_help(cmd_name: String) -> void:
	if cmd_name == "":
		add_line("Commands available:", Types.LogLevel.NONE)
		for command in _commands:
			var cheat = ""
			if command.is_cheat():
				cheat  = " *"
			add_line("	" + command.get_name() + cheat, Types.LogLevel.NONE)
	else:
		var command = get_command(cmd_name)
		if command:
			add_line(cmd_name + ": " + command.get_help(), Types.LogLevel.NONE)
		else:
			add_line("Help: Command not found", Types.LogLevel.ERROR)

# Console Command: quit
func _quit() -> void:
	get_tree().quit()

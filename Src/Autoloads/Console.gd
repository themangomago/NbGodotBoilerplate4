extends Control

signal console_toggle()
signal console_add_line(line: String, level: Types.LogLevel)

var _commands: Array = []

# TODO: rework as plugin and add to singletons??

func _ready():
	# Add default commands
	_add_default_commands()


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_toggle_console"):
		emit_signal("console_toggle")

# Add a new command to the console
func add_command(command: ConsoleCmd):
	assert(get_command(command.get_name()) == null, "Error: Command already exist. Please remove it first.")
	_commands.append(command)

# Remove a command by name; Returns true if deleted - false else
func remove_command(cmd_name: String) -> bool:
	for i in range(_commands.size()):
		if cmd_name == _commands[i].get_name():
			_commands.remove_at(i)
			return true
		i += 1
	return false

func get_command(cmd_name: String) -> ConsoleCmd:
		for cmd in _commands:
			if cmd_name == cmd.get_name():
				return cmd
		return null

func get_autocompletion(start: String) -> Array:
	var found_cmds := []
	for cmd in _commands:
		var name_string: String = cmd.get_name()
		if name_string.begins_with(start):
			found_cmds.append(cmd)
	return found_cmds

func _add_default_commands():
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

func add_line(line: String, level: Types.LogLevel = Types.LogLevel.NONE):
	emit_signal("console_add_line", line, level)

func _get_version():
	add_line("Game Version " + str(Global.GAME_VERSION), Types.LogLevel.INFO)

func _get_help(cmd_name: String):
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

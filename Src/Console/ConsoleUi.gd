extends Control

var _history = []
var _history_index = 0
var _autocomplete_index = -1
var _autocompletes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	Console.connect("console_toggle", Callable(self, "_console_toggle"))
	Console.connect("console_add_line", Callable(self, "_console_add_line"))
	_console_add_line("Type 'help' for an overview.", Types.LogLevel.INFO)
	$Window/v/Input.keep_editing_on_text_submit = true


func _console_add_line(text: String, level: Types.LogLevel):
	var flag_name := ""
	var color := ""

	match level:
		Types.LogLevel.ERROR:
			flag_name = "ERROR"
			color = Log.GENERAL_COLORS_ERROR
		Types.LogLevel.WARNING:
			flag_name = "WARNING"
			color = Log.GENERAL_COLORS_WARNING
		Types.LogLevel.INFO:
			flag_name = "INFO"
			color = Log.GENERAL_COLORS_INFO
		Types.LogLevel.DEBUG:
			flag_name = "DEBUG"
			color = Log.GENERAL_COLORS_DEBUG

	if flag_name == "":
		$Window/v/History.append_text("\n" + text)
	else:
		$Window/v/History.append_text("\n" + "[color=" + color + "]" + flag_name + "[/color]: " + text)

func _console_toggle():
	if not self.visible:
		self.show()
		#$Window/v/Input.grab_focus()
		$Window/v/Input.call_deferred("grab_focus")
		
	else:
		self.hide()


func _process_input(line: String):
	var input = line.split(" ")
	var command = Console.get_command(input[0])
	
	if command:
		if input.size() > 1:
			# Value provided
			if command.get_value_type() != TYPE_NIL:
				# Function expects a value
				command.get_callable().call(input[1])
			else:
				# Function does not expect a value - so ignore it
				command.get_callable().call()
		else:
			# No value provided
			if command.get_value_type() != TYPE_NIL:
				# Function expects a value
				if command.get_name() == "help":
					# Special handling for help
					command.get_callable().call("")
				else:
					# Error
					_console_add_line("Command '" + str(input[0]) + "' not found.", Types.LogLevel.ERROR)
					return
			else:
				# Function does not expect a value
				command.get_callable().call()
	else:
		_console_add_line("Command '" + str(input[0]) + "' not found.", Types.LogLevel.ERROR)


func _on_input_text_submitted(new_text):
	$Window/v/Input.text = ""
	_process_input(new_text)
	_history.append(new_text)
	_history_index = _history.size() - 1


func _on_input_focus_exited() -> void:
	if self.visible:
		# Make sure we dont ever lose focus while console is active
		$Window/v/Input.call_deferred("grab_focus")
		# TODO: extend this while completion is active


func _on_input_text_changed(new_text: String) -> void:
	if new_text.length() >= 3:
		_autocompletes = Console.get_autocompletion(new_text)
		$AutocompleteWindow.clear()
		$AutocompleteWindow.auto_height = false
		$AutocompleteWindow.size.y = 18 * (_autocompletes.size() + 1)
		
		if _autocompletes.size() > 0:
			for cmd in _autocompletes:
				$AutocompleteWindow.add_item(cmd.get_name())
		
			$AutocompleteWindow.show()


			if _autocomplete_index == -1:
				_autocomplete_index = 0
			elif _autocomplete_index >= _autocompletes.size():
				_autocomplete_index = _autocompletes.size() - 1
				
			$AutocompleteWindow.select(_autocomplete_index)
				
		else:
			$AutocompleteWindow.hide()
			_autocomplete_index = -1
		
	else:
		$AutocompleteWindow.hide()
		_autocomplete_index = -1


func _on_input_gui_input(event: InputEvent) -> void:
	# Autocomplete is up
	if $AutocompleteWindow.visible:
		if _autocomplete_index == -1: return 
		if event is InputEventKey:
			if event.pressed: 
				if event.keycode == KEY_UP:
					_autocomplete_index -= 1
					if _autocomplete_index < 0:
						_autocomplete_index = _autocompletes.size() - 1
					$AutocompleteWindow.select(_autocomplete_index)
					accept_event()
				elif event.keycode == KEY_DOWN:
					_autocomplete_index += 1
					if _autocomplete_index == _autocompletes.size():
						_autocomplete_index  = 0
					$AutocompleteWindow.select(_autocomplete_index)
					accept_event()
				elif event.keycode == KEY_ESCAPE:
					$AutocompleteWindow.hide()
					accept_event()
				elif event.keycode == KEY_TAB:
					$Window/v/Input.text = _autocompletes[_autocomplete_index].get_name()
					$Window/v/Input.set_caret_column($Window/v/Input.text.length())
					$AutocompleteWindow.hide()
					accept_event()
				elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
					$AutocompleteWindow.hide()
	else:
		if _history.size() > 0:
			if event is InputEventKey:
				if event.pressed: 
					if event.keycode == KEY_UP:
						$Window/v/Input.text = _history[_history_index]
						$Window/v/Input.set_caret_column($Window/v/Input.text.length())
						_history_index -= 1
						if _history_index < 0:
							_history_index = _history.size() - 1
						accept_event()
					elif event.keycode == KEY_DOWN:
						$Window/v/Input.text = _history[_history_index]
						$Window/v/Input.set_caret_column($Window/v/Input.text.length())
						_history_index += 1
						if _history_index == _history.size():
							_history_index = 0
						accept_event()

# NimbleBeasts Boilerplate

## About

This is a simple kickstarter project for Godot projects. It comes with some standard features and little helpers as well as some stuff, no one has time for in a game jam.

## Some Features

- Basic GameManager
- Console
- Log Management
- Advanced Menu System
- Localization
- Basic save game handling
- Basic mod functionality
- User confing handling
- Global Signal Driven Events
- Global Enums 
- Helpers  


---

# 1. Basics

## 1.1 File Structure

- \_NbCore -> Core boilerplate core functionalities and classes
  - Templates\Node\DefaultTemplate.gd -> Basic Coding Template.
  - NbCore.gd -> This is inherited by the Autoload `Global`.
  - NbCoreConfig.gd -> Class for GameManager configuration.
  - NbConsoleCmd.gd -> Class to add console commands.
  - NbSaveGameHeader.gd -> Class to store save game header.
- Assets -> Every sound, sprite, font, model & music goes here
  - Fonts\ -> OpenSans font as default font
  - Icons\ -> Icons by Icon8. (Check the license)
- Localization -> Here goes the translation files
- Shaders -> Store shaders here
- Src -> Scenes and Source goes here. Also 
  - Autoloads -> Autoloads / Globals / Singletons are stored here.
	- Types.gd -> Global enums.
	- Events.gd -> Global signal events.
	- Log.gd -> Powerful logger with stdout, file and console output.
	- Global.gd -> Inherits NbCore.
	- Console.gd -> Console with autocomplete and history.
	- ModManager.gd -> Basic modding framework.

## 1.2 Autoloads / Globals / Singletons
For easier global access, the boilerplate uses two approaches: first, autoloads, and second, signal-driven events (Events.gd). A list of all autoloads can be found in section 1.1 File Structure.

## 1.3 Game Manager Configuration
The starting point of every boilerplate project is the GameManager. The provided GameManager is just an example of how a game manager could look like.
Configuration of the Boilerplate has been streamlined for the Godot 4.x rework.

## 1.4 User Configuration Model


# 2. Features
## 2.1 Log
The Logger was renamed to just Log because of a new debugging feature of Godot. The `Log` is a powerful util to output infos, warning and output to the user using console, file or stdout (must be build accordingly).
In the `NbCoreConfig` you can select which output severity shall be loggeg to which output.
There are APIs for `info`, `warning`, `error` and `debug`.

Example:
`Log.warning("This is a test warning")`

## 2.2 Console
The console consists of tree building blocks. The Autoload `Console.gd` for global access and storage of commands. The file `NbConsoleCmd.gd` which contains the `ConsoleCmd` class. This is the structure for the commands. And the `ConsoleUi.gd`and `ConsoleUi.tscn` which is the user interface for the console.
The console features a command history, a simple autocomplete and easy to use command interface.

### 2.2.1 Constructing a Console Command
Console commands can be constructed from everywhere in the project after loading the autoload. To construct a new command you will need to utilize the `ConsoleCmd` class. 
`
	Console.add_command(
		ConsoleCmd.new(
			"set_ammo", #Console command name
			_cheat_ammo, #The callback function that will be called
			10, #Default value
			"Adds ammo to the player", #Help text
		)
	)
`
There are some extendible parameters like `set_range` and `set_cheat_protection` which need to be set on the `ConsoleCmd` variable before adding to the `Console`.

### 2.2.2 Cheat Protection
While cheat commands help a lot during development you wont allow the player to use them while unlocking achievements. Therefore there is a small function `Console.is_cheating_allowed()` which needs to be implemented. By default this is just true, because saving the cheat state is highly recommended in your game state.

## 2.3 Menu

## 2.4 Localization
 The whole boilerplate (expect the log and console) are supporting localization out of the box. We encourage everyone starting a new project to directly utilize it. For more informations look up tr() in the Godot docs.

## 2.5 Savegames
The built-in save game system is derived in different parts

### x.x.1 Core 
#### Core Class SaveGameHeader (NbSaveGameHeader.gd)
This class provides all the save game header informations we need for everything.

It will store the following attributes:
- Version (Savegame version)s
- Timestamp (Unix Timestamp)
- Savename (User title of the save)
- Filename (Actual save file name)
- IsAutosave (Marker for autosaves)
  
#### Autoload Global Core (NbCore.gd)
This autoload utilizes all the save file writing and reading stuff and holds the found save games in an array (Global.savegames_headers).

Functions provided:

scan_savegames() -> void:
Look for *.sav in SAVE_PATH, parse the header and store it in savegames_headers[].

sort_savegames() -> void:
Sort savegames_headers[] by timestamp DESC.

load_save_header(file_name) -> SaveGameHeader:
Load and parse the header information.

load_save_payload(file_name: String) -> Dictionary:
Load the stored payload. This is where all our game states are stored.

### x.x.2 Components
#### Component: Menu
The menu needs to handle all the GUI related stuff. The provided ModernMenu is capable of displaying all the save games. It allows the user to create new, overwrite, delete or load save games. The menu uses 'Events' signals to propagate the actual handling to the GameManager.

#### Component: GameManager
The game manager will handle all the user related requests. Some requests are propagaded to the actual game (all game state related stuff) others are directly call the Cores save functions.

Connected Signals:
menu_save_load_game(index: int)
menu_save_game(save_name: String)
menu_save_overwrite_game(index: int)
menu_save_delete_game(index: int)

### x.x.3 Game Implemantation
The DummyGame provides a example on how to change the game state. 

## 2.6 Mods

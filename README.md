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

## 1.3 Game Manager Configuration

## 1.4 User Configuration Model


# 2. Features

## 2.1 Console

## 2.2 Log

## 2.3 Menu

## 2.4 Localization

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

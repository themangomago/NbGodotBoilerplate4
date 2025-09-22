class_name NbCoreConfig extends Resource

@export_group("General")
## Enable Boilerplate-Debug Options
@export var debug: bool = true
## Skip Intro
@export var skip_intro: bool = false
## Default seed for seed based RNG. (Opt.)
@export var rng_default_seed: int = 0



@export_group("User Config", "user_config")
## Latest config version
@export var user_config_version: int = 1
## Upgrade existing config with new version options
@export var user_config_auto_upgrade: bool = true
## Repair config if needed
@export var user_config_sanity_check: bool = true

@export_group("Controls", "controls")
## Allowed input devices in menu/game
@export_flags("Keyboard", "Mouse", "Joypad", "Touch") var controls_allowed_input_devices: int = 1 + 2 + 4

@export_group("Video", "video")
## Is fullscreen mode supported?
@export var video_support_fullscreen: bool = true
## Enable screenshots?
@export var video_enable_screenshots: bool = true
@export_subgroup("Upscaler", "video_upscaler")
## Upscaling enabled (relevant for pixel art games)
@export var video_upscaler_enabled: bool = true
## (Not used right now)
@export var video_upscaler_base_resolution: Vector2i = Vector2i(320, 180)

@export_group("Logger", "logger")
@export_subgroup("File", "logger_file")
@export var logger_file_enabled: bool = true
@export var logger_file_file_name: String = "log.txt"
@export var logger_file_file_path: String = "user://"
@export var logger_file_time_stamp: bool =  true
@export_flags("Error", "Warning", "Info", "Debug") var logger_file_trace_level_flags: int = 1 + 2

@export_subgroup("Stdout", "logger_stdout")
@export var logger_stdout_enabled: bool = true
@export var logger_stdout_rich_text: bool = true
@export var logger_stdout_time_stamp: bool =  true
@export_flags("Error", "Warning", "Info", "Debug") var logger_stdout_trace_level_flags: int = 1 + 2 + 4 + 8

@export_subgroup("Console", "logger_console")
@export var logger_console_enabled: bool = true
@export var logger_console_time_stamp: bool =  true
@export_flags("Error", "Warning", "Info", "Debug") var logger_console_trace_level_flags: int = 1 + 2 + 4

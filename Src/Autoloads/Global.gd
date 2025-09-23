###############################################################################
# Copyright (c) 2026 NimbleBeasts
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
###############################################################################
extends "res://_NbCore/NbCore.gd"
##
## Global singleton
##
## @desc:
##		This is mainly used for configurative purposes. As well as global helper
##		functions.
##

const GAME_VERSION = 1.0
const CONFIG_VERSION = 1

const USER_CONFIG_MODEL := {
	"meta": {
		"configVersion": "CONFIG_VERSION", #Generated
	},
	"configurable": [
		{
			"name": "video",
			"tr": "TR_MENU_SETTINGS_VIDEO",
			"options": [
				{
					"name": "resolution", #Generated
					"tr": "TR_MENU_SETTINGS_RESOLUTION",
					"values": [
						#Vector2(320, 180),
						#Vector2(640, 360),
						Vector2(1280, 720), #our default
						Vector2(1366, 768), #7.47%
						Vector2(1920, 1080), #67.60%
						Vector2(2560, 1440), #8.23%
						Vector2(3840, 2160) #2.41%
					],
					"default": 0,
					"signal": "vid_resolution_changed"
				},
				{
					"name": "fullscreen", #Generated
					"tr": "TR_MENU_SETTINGS_FULLSCREEN",
					"values": [
						false,
						true
					],
					"default": false,
					"signal": "vid_fullscreen_changed"
				},
				{
					"name": "vsync", #Generated
					"tr": "TR_MENU_SETTINGS_VSYNC",
					"values": [
						false,
						true
					],
					"default": true,
					"signal": "vid_vsync_changed"
				},
				{
					"name": "brightness", #Generated
					"tr": "TR_MENU_SETTINGS_BRIGHTNESS",
					"range": [
						0.5,
						1.5
					],
					"step": 0.1,
					"default": 1.0,
					"signal": "vid_brightness_change"
				},
			]
		},
		{
			"name": "audio",
			"tr": "TR_MENU_SETTINGS_AUDIO",
			"options": [
				{
					"name": "sound",  #Generated
					"tr": "TR_MENU_SETTINGS_SOUND",
					"range": [
						0,
						100
					],
					"step": 5,
					"default": 50,
					"signal": "menu_sound_changed"
				},
				{
					"name": "music",  #Generated
					"tr": "TR_MENU_SETTINGS_MUSIC",
					"range": [
						0,
						100
					],
					"step": 5,
					"default": 50,
					"signal": "menu_music_changed"
				},
			]
		},
		{
			"name": "language",
			"tr": "TR_MENU_SETTINGS_LANGUAGE",
			"options": [
				{
					"name": "language",  #Generated
					"tr": "TR_MENU_SETTINGS_LANGUAGE",
					"values": [
						"TR_MENU_SETTINGS_LANGUAGE_EN"
					],
					"default": 0,
					"signal": "menu_language_change"
				}
			]
		},
		{
			"name": "controls",
			"tr": "TR_MENU_SETTINGS_CONTROLS",
			"options": [
				{
					"tr": "TR_MENU_SETTINGS_CONTROL_CATEGORY_MOVEMENT",
				},
				{
					"name": "control_up",
					"tr": "TR_MENU_SETTINGS_CONTROL_UP",
					"keys": [
						{"type": 1, "device": 0, "code": 4194320},
						{"type": 2, "device": 0, "code": 1},
						{"type": 1, "device": 0, "code": 87},
						{ "type": 4, "device": 0, "code": 3 }
					]
				},
				{
					"name": "control_right",
					"tr": "TR_MENU_SETTINGS_CONTROL_RIGHT",
					"keys": [{}, {}, {}, {}]
				},
			]
		}
	]
}

var game_manager



func _ready():
	# Config Handling
	## Initially parse the user config model
	user_config = parse_user_config_model(USER_CONFIG_MODEL)
	## Retrieve actual user config settings, based on the model
	user_config = load_user_config(user_config)
	# Parse boilerplate core config
	#NbCore.core_init(CORE_CONFIG_RESOURCE)
	# Setup signals
	#signal_init()
	##user_config = core_get_user_config_model()
	#
	## Parse user config model
	#user_config = parse_user_config_model(USER_CONFIG_MODEL)
	## Load user config file
	#user_config = core_load_user_config(user_config)
	#input_config()
	
	print(user_config)
	## Setup signals
	vid_signal_setup()
	
	scan_savegames()
	sort_savegames()
	
	
	## DUMMY
	#(version: int, timestamp: int, savename: String, filename: String, is_autosave: bool)
	#var dummysave1 = SaveGameFile.new(1, 1758472438, "Test Save 1", "dummyfile.sav", false)
	#var dummysave2 = SaveGameFile.new(1, 1758198589, "Test Save 2", "dummyfile2.sav", false)
	#savegames_headers.append(dummysave1)
	#savegames_headers.append(dummysave2)
	


func initialize(manager: Node):
	# Set the game manager for further references
	game_manager = manager
	
	# Setup Logger
	Log.setup(manager.config)
	# Log.error("test error")
	# Log.info("test info")
	# Log.warn("test warn")
	# Log.debug("test debug")

	# Video setup
	vid_setup()


func vid_setup():
	# Parse resolutions
	for configurable in Global.USER_CONFIG_MODEL.configurable:
		if configurable.name == "video":
			for option in configurable.options:
				if option.name == "resolution":
					vid_set_resolution_list(option.values.duplicate())
					break
	
	# Vsync
	vid_set_vsync(bool(user_config.video.vsync))
	# FPS Cap
	vid_set_fps_cap(60)
	# Set resolution # TODO: this might not be so good to hardcode
	vid_set_resolution(int(user_config.video.resolution))
	# Set fullscreen
	vid_set_fullscreen(bool(user_config.video.fullscreen))

	
func vid_signal_setup():
	Events.connect("vid_resolution_changed", vid_set_resolution)
	Events.connect("vid_fullscreen_changed", vid_set_fullscreen)
	Events.connect("vid_vsync_changed", vid_set_vsync)
	Events.connect("vid_fps_cap_changed", vid_set_fps_cap)
	Events.connect("vid_window_center_changed", vid_center_window)
	

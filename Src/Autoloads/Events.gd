extends Node

# Suppress all warnings for unused signals in this file
@warning_ignore_start("unused_signal")

###############################################################################
# Global Signal List
###############################################################################

# Level Management

signal new_game()

# Sound
signal play_sound(sound)
# Music
signal play_music(track)
signal change_music(track_id)
# Menu Related
signal menu_popup()
signal menu_back()


signal take_screenshot()

###########################################################################
# User Config Changes
###########################################################################

signal menu_switch_new_game()
signal menu_switch_resume_game()
signal menu_switch_main_menu()


signal menu_save_load_game(index: int)
signal menu_save_game(save_name: String)
signal menu_save_overwrite_game(index: int)
signal menu_save_delete_game(index: int)

signal menu_control_key_assign_entered()
signal menu_control_key_assign_finished()

## Emitted if sound volume has changed in menus
signal menu_sound_changed(new)
## Emitted if music volume has changed in menus
signal menu_music_changed(new)
## Emitted if resolution has changed in menus
signal vid_resolution_changed(value: int)
## Emitted if fullscreen mode has changed in menus
signal vid_fullscreen_changed(value: bool)
## Emitted if vsync mode has changed in menus
signal vid_vsync_changed(value: bool)
## Emitted if fps cap has changed
signal vid_fps_cap_changed(value: int)
## Emitted if window center was requested
signal vid_window_center_changed()
## Emitted if the brightness has changed in menus
signal vid_brightness_change(value)
## Emitted if the language has changed in menus
signal menu_language_change(value)



@warning_ignore_restore("unused_signal")

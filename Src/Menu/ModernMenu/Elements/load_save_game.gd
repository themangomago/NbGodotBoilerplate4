@tool
extends Control


## Theme to derive button colors from.
@export var theme_scene: Theme = preload("./../ModernMenu.theme")

var text := "TITLE"

signal loadsave_load(id)
signal loadsave_overwrite(id)
signal loadsave_delete(id)

# Colors
var _bg_color_hover: Color
var _font_color_hover: Color
var _font_color_normal: Color

# States
var _id : int = -1
var _is_focused := false
var _header : SaveGameFile = null
var _isLoad: bool = false

func _ready() -> void:
		# Choice Button Colors
	var menu_theme: Theme = theme_scene
	var style_box: StyleBox = menu_theme.get_stylebox("hover", "Button")
	assert(style_box, "menu_modern: Stylebox not found in theme")
	_bg_color_hover = style_box.bg_color
	_font_color_normal = menu_theme.get_color("font_color", "Button")
	_font_color_hover = menu_theme.get_color("font_hover_color", "Button")
	# TODO: This could be optimized by doing it on higher level and pass down the colors
	$h/Titel.set("theme_override_colors/font_color", _font_color_normal)
	$h/Timestamp/Date.set("theme_override_colors/font_color", _font_color_normal)
	$h/Timestamp/Time.set("theme_override_colors/font_color", _font_color_normal)
	$Bg.color = _bg_color_hover
	$Bg.hide()

func setup(id: int, header: SaveGameFile, isLoad: bool):
	_id = id
	_header = header
	_isLoad = isLoad
	
	if _isLoad:
		$h/LoadButton.show()
		$h/OverwriteButton.hide()
		$h/DeleteButton.show()
	else:
		$h/LoadButton.hide()
		$h/OverwriteButton.show()
		$h/DeleteButton.show()
	
	$h/Titel.set_text(_header.get_savename())
	var datetime: Array[String] = _header.get_datetime()
	$h/Timestamp/Date.set_text(datetime[0])
	$h/Timestamp/Time.set_text(datetime[1])
	
	

func _on_focus_entered() -> void:
	_is_focused = true
	$Bg.show()
	$h/Titel.set("theme_override_colors/font_color", _font_color_hover)
	$h/Timestamp/Date.set("theme_override_colors/font_color", _font_color_hover)
	$h/Timestamp/Time.set("theme_override_colors/font_color", _font_color_hover)


func _on_focus_exited() -> void:
	_is_focused = false
	$Bg.hide()
	$h/Titel.set("theme_override_colors/font_color", _font_color_normal)
	$h/Timestamp/Date.set("theme_override_colors/font_color", _font_color_normal)
	$h/Timestamp/Time.set("theme_override_colors/font_color", _font_color_normal)



func _on_mouse_entered() -> void:
	_on_focus_entered()


func _on_mouse_exited() -> void:
	_on_focus_exited()


func _on_delete_button_focus_entered() -> void:
	_on_focus_entered()


func _on_delete_button_focus_exited() -> void:
	_on_focus_exited()


func _on_delete_button_mouse_entered() -> void:
	_on_focus_entered()

func _on_delete_button_mouse_exited() -> void:
	_on_focus_exited()


func _on_delete_button_button_up() -> void:
	emit_signal("loadsave_delete", _id)


func _on_overwrite_button_button_up() -> void:
	emit_signal("loadsave_overwrite", _id)


func _on_load_button_button_up() -> void:
	emit_signal("loadsave_load", _id)

extends Control

@onready var option_button = $Panel/SettingsGridContainer/Graphics/Window_Mode as OptionButton
@onready var resolution = $Panel/SettingsGridContainer/Graphics/Resolution as OptionButton
@onready var colorblind_mode = $Panel/SettingsGridContainer/Filtro/Colorblind_Mode as OptionButton


const WINDOW_MODE_ARRAY: Array[String] = [
	"Full-Screen",
	"Window Mode",
	"Borderless Window",]

const RESOLUTION_DICTIONARY : Dictionary = {
	"360 x 360" : Vector2i(360,360),
	"1280 x 720" : Vector2i(1280, 720),
	"1920 x 1018" : Vector2i(1920, 1018)
}

const COLORBLIND_ARRAY : Array[String] = [
	"Disabled",
	"Protanopia",
	"Deuteranopia",
	"Tritanopia",]

func _ready():
	_add_window_mode_items()
	_add_resolution_itemns()
	_add_colorblind_items()
		
func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _add_window_mode_items() ->void:
	for window_mode in WINDOW_MODE_ARRAY:
		option_button.add_item(window_mode)

func _add_resolution_itemns() ->void:
	for resolution_item in RESOLUTION_DICTIONARY:
		resolution.add_item(resolution_item)
		
func _add_colorblind_items() ->void:
	for colorblind_item in COLORBLIND_ARRAY:
		colorblind_mode.add_item(colorblind_item)

func _on_option_button_item_selected(index):
	match index:
		0: #Full-Secreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
		1: #Window mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
		2:#Borderless window
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)

func _on_resolution_item_selected(index):
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])


func _on_colorblind_mode_item_selected(index):	
	pass
	#GlobalRect.updateShader(index)
	




extends Control


func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://Scenes/Levels/tutorial.tscn")

func _on_d_level_pressed():
	get_tree().change_scene_to_file("res://Scenes/Levels/3d_world.tscn")

func _on_d_level_1_pressed():
	get_tree().change_scene_to_file("res://Scenes/Levels/4D Level.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")

func _on_d_level_2_pressed():
	get_tree().change_scene_to_file("res://Scenes/Levels/4DLev1.tscn")

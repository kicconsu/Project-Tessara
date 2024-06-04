extends Area3D

@export var NextScene: String
var scene_folder = "res://scenes/Levels/"

func _on_body_entered(_body):
	var full_path = scene_folder + NextScene + ".tscn"
	var scene_tree = get_tree()
	print(full_path)
	print("res://scenes/Levels/Lev1.tscn")
	scene_tree.change_scene_to_file(full_path)
	

extends Area3D

@export var NextScene: String
var scene_folder = "res:://scenes/Levels/"

func _on_body_entered(body):
	var full_path = scene_folder + NextScene + ".tscn"
	var scene_tree = get_tree()
	print(full_path)
	scene_tree.change_scene_to_file("res://scenes/Levels/Lev1.tscn")
	

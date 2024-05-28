extends Area3D

@export var NextScene: String
var scene_folder = "res:://scenes/Levels/"

func _on_body_entered(body):
	var full_path = scene_folder + NextScene + ".tscn"
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file(full_path)
	

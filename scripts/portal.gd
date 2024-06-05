extends Area3D

@export var NextScene: String
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer
@onready var audio = $AudioStreamPlayer

var scene_folder = "res://scenes/Levels/"

func _on_body_entered(_body):
	audio.play()
	animation_player.play("transition")
	timer.set_wait_time(1.7)
	timer.start()
	
func _on_timer_timeout():
	var full_path = scene_folder + NextScene + ".tscn"
	var scene_tree = get_tree()
	print(full_path)
	scene_tree.change_scene_to_file(full_path)

extends Control
@onready var transition = $Transition

func _on_start_button_pressed():
	transition.play("fade_out")

func _on_exit_button_pressed():
	get_tree().quit()

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_transition_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://scenes/Levels/tutorial.tscn")

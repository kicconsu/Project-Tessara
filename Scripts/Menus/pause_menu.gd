extends Control
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()

func resume():
	get_tree().paused = false
	$Blur.play_backwards("Blur")	

func pause():
	get_tree().paused = true
	$Blur.play("Blur")

func _input(event):
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		

func _on_continuar_pressed():
	resume()
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_reiniciar_pressed():
	if get_tree().paused:
		resume()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().reload_current_scene()
	 

func _on_salir_pressed():
	resume()
	get_tree().change_scene_to_file("res://Scenes/Menus/main_menu.tscn")


	

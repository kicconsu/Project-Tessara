extends Control
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()

func resume():
	get_tree().paused = false
	$Blur.play_backwards("Blur")
	hide()

func pause():
	get_tree().paused = true
	$Blur.play("Blur")

func testEsc():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		resume()

func _on_continuar_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	resume()

func _on_reiniciar_pressed():
	resume()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().reload_current_scene()

func _on_salir_pressed():
	get_tree().quit()

func _process(_delta):
	testEsc()


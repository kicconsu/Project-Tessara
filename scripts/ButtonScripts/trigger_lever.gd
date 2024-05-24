extends Trigger

@onready var lever = $Lever
@onready var timer = $Timer

var tg = false
var act = false # Si esta activado o no

var getInit = false
var Tdest
var Rdest
var A: Vector3
var B: Vector3
				
			
func toggle(): # Toggle de Animaciones
	
	match tg:
		true:
			Tdest = A
			Rdest = B
			
			lever.animation.play("ToggleOff")
			lever.aux.play("ToggleOffColor")
		false:			
			
			Tdest = destination
			Rdest = rotate
			
			lever.animation.play("ToggleOn")
			lever.aux.play("ToggleOnColor")

	tg = !tg

func _on_timer_timeout():
	act = false
	pass # Replace with function body.

func _on_interacted():
	if !act: # Para activarlo
		
		if !getInit:
			getInitialValues()
		
		act = true
		timer.start()
		toggle()
		move()

func getInitialValues():
	A = target.get_position()			
	B = target.get_rotation()
	getInit = true

func move():
	target.set_freeze_enabled(false)
	
	var translate = get_tree().create_tween()
	var rotated = get_tree().create_tween()
	
	translate.tween_property(target, "position", Tdest, translateDuration).set_ease(Tween.EASE_IN_OUT)
	rotated.tween_property(target, "rotation", Rdest, rotationDuration).set_ease(Tween.EASE_IN_OUT)
	
	target.set_freeze_enabled(true)
	


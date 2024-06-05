extends Trigger

@onready var button = $Button
@onready var timer = $Timer
@export var hyperDest: Vector4

var act = false # Si esta activado o no

func _on_timer_timeout():
	act = false	
	pass # Replace with function body.

func _on_interacted():
	if !act:
		act = true	
		button.animation.play("CylinderAction")
		timer.start()
		move()	

func move():
	target.set_freeze_enabled(false)
	
	var translate = get_tree().create_tween()
	var rotated = get_tree().create_tween()
	var hyperRotated = get_tree().create_tween()
	
	translate.tween_property(target, "position", destination, translateDuration).set_ease(Tween.EASE_IN_OUT)
	
	rotated.tween_property(target, "rotation", rotate, rotationDuration).set_ease(Tween.EASE_IN_OUT)
	
	hyperRotated.tween_property(target, "hyperInfo", hyperDest, rotationDuration).set_ease(Tween.EASE_IN_OUT)
	
	target.set_freeze_enabled(true)


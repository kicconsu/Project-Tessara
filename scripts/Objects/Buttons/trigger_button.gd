extends Trigger

@onready var button = $Button
@onready var timer = $Timer
@export var hyperDest: Vector4

var act = false # Si esta activado o no

func _on_timer_timeout():
	#act = false	
	pass # Replace with function body.

func _on_interacted():
	if !act:
		act = true	
		button.animation.play("CylinderAction")
		timer.start()
		move()	

func move():
	target.set_freeze_enabled(false)
	
	var A = target.get_global_position()
	var B = target.get_global_rotation()
	var C = target.getHyperInfo()
	
	var translate = get_tree().create_tween()
	var rotated = get_tree().create_tween()
	var hyperRotated = get_tree().create_tween()
	
	if destination.length() > 0:
		translate.tween_property(target, "position", A + destination, translateDuration).set_ease(Tween.EASE_IN_OUT)
	
	if rotate.length() > 0:
		rotated.tween_property(target, "rotation", B + rotate, rotationDuration).set_ease(Tween.EASE_IN_OUT)
	
	if hyperDest.length() > 0:
		hyperRotated.tween_property(target, "hyperInfo", C + hyperDest, rotationDuration).set_ease(Tween.EASE_IN_OUT)
	
	target.set_freeze_enabled(true)


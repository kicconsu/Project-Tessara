extends Area3D

@export var dimensions : Vector3 = Vector3(0.3,1,1)

@export var target : Node3D
@export var destination: Vector3 = Vector3(0,0,0)
@export var rotate: Vector3 = Vector3(0,0,0)
@export var translateDuration: float
@export var rotationDuration: float

var activated = false

func _ready():
	$CollisionShape3D.get_shape().set_size(dimensions)

func _on_body_entered(body):
	if !activated:
		activated = true
		move()

func move():
	
	var translate = get_tree().create_tween()
	var rotated = get_tree().create_tween()
	
	translate.tween_property(target,"position", target.get_global_position() + destination, translateDuration).set_ease(Tween.EASE_IN_OUT)
	rotated.tween_property(target, "rotation", rotate, rotationDuration).set_ease(Tween.EASE_IN_OUT)

extends Area3D

@export var dimensions : Vector3 = Vector3(0.3,1,1)

var targets = []
@export var target : Node3D
@export var destination: Vector3 = Vector3(0,0,0)
@export var rotate: Vector3 = Vector3(0,0,0)
@export var translateDuration: float
@export var rotationDuration: float

@export var change_scene_state = false
signal change_state

var activated = false

func _ready():
	$CollisionShape3D.set_shape(BoxShape3D.new())
	$CollisionShape3D.get_shape().set_size(dimensions)
	if target != null:
		targets.append(target)

func _on_body_entered(body):
	if !activated:
		
		if change_scene_state:
			change_state.emit()
		
		if body.is_in_group("Player"):
			activated = true
			move(target)
		else:
			for trgt in targets:
				if trgt == body:
					teleport(trgt)
					pass

func move(object):
	
	var translate = get_tree().create_tween()
	var rotated = get_tree().create_tween()
	
	translate.tween_property(object,"position", object.get_global_position() + destination, translateDuration).set_ease(Tween.EASE_IN_OUT)
	rotated.tween_property(object, "rotation", rotate, rotationDuration).set_ease(Tween.EASE_IN_OUT)

func teleport(object):
	object.set_global_position(object.get_global_position() + destination)

func addTarget(addOn):
	targets.append(addOn)

extends Area3D

@export var dimensions : Vector3 = Vector3(0.3,1,1)

@export var target : Control
@export var message : String

@export var change_scene_state = false
signal change_state

var activated = false

func _ready():
	$CollisionShape3D.set_shape(BoxShape3D.new())
	$CollisionShape3D.get_shape().set_size(Vector3(dimensions[0], dimensions[1], dimensions[2]))

func _on_body_entered(body):
	if !activated:
		activated = true
		
		target.change_state(target.State.FINISHED)
		target.text_queue.clear()
		target.hide_textbox()
		target.change_state(target.State.READY)
		target.queue_text(message)
		
		if change_scene_state:
			change_state.emit()

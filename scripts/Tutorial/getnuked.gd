extends Node3D

@onready var timer = $Timer

func nuke():
	self.translate(Vector3(0,4,0))
	timer.set_wait_time(1.8)
	timer.start()
	var t1 = get_tree().create_tween()
	t1.tween_property(self, "scale", Vector3(0.00001,0.00001,0.00001), 2).set_trans(Tween.TRANS_BACK)

func _on_timer_timeout():
	self.translate(Vector3(0,20,0))


func _on_body_entered(body):
	pass # Replace with function body.

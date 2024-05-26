extends Node3D

@onready var timer = $Timer

func nuke():
	timer.set_wait_time(1.8)
	timer.start()
	var t1 = get_tree().create_tween()
	t1.tween_property(self, "scale", Vector3(0,0,0), 2).set_trans(Tween.TRANS_BACK)

func _on_timer_timeout():
	queue_free()

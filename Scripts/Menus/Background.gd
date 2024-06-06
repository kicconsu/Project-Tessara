extends Node2D

func _physics_process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset += Vector2(0.5,2)

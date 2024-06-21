extends Node2D

func _physics_process(_delta):
	$ParallaxBackground/ParallaxLayer.motion_offset += Vector2(0.5,2)

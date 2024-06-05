extends Node3D

@onready var ball:Node3D = $redBall
var rng := RandomNumberGenerator.new()
var points = 0

func _on_red_ball_body_entered(body):
	respawnBall()
	points += 10


func _on_ball_refresh_timeout():
	respawnBall()
	

func respawnBall() -> void:
	var x:float = rng.randf_range(-23, 23)
	var y:float = rng.randf_range(0.3, 35)
	var z:float = rng.randf_range(-23, 23)
	ball.set_global_position(Vector3(x, y, z))

func getPoints() -> float:
	return self.points

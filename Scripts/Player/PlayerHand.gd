extends Marker3D

var pull_power = 4
var rotation_power = 0.2
var picked_object = null


func pull_object(distOffset:Vector3) -> void:
	var a : Vector3 = picked_object.global_transform.origin
	var b : Vector3 = global_transform.origin
	b += distOffset	
	picked_object.set_linear_velocity((b-a)*pull_power)

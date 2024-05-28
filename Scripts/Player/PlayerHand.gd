extends Marker3D

var pull_power:float = 4
var rotation_power:float = 0.2
var picked_object:Node = null


func pull_object(distOffset:Vector3) -> void:
	var objPos : Vector3 = picked_object.global_transform.origin
	var currPos : Vector3 = global_transform.origin
	currPos += distOffset #Offset position (so that the obj can be pulled closer or pushed away)
	picked_object.set_linear_velocity((currPos-objPos)*pull_power)
	

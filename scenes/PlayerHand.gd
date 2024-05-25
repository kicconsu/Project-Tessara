extends Marker3D

var pull_power = 4
var rotation_power = 0.2
var picked_object = null

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pull_object():
	var a = picked_object.global_transform.origin
	var b = global_transform.origin
	
	picked_object.set_linear_velocity((b-a)*pull_power)

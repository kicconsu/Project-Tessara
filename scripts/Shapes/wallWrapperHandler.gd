extends CSGBox3D

func _ready():
	var wrapper:RigidBody3D = get_child(0)
	wrapper.setDimensions(Vector4(size.x, size.y, size.z, 1.0)*0.5)


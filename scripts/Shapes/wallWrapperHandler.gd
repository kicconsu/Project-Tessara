extends CSGBox3D

func _ready():
	var wrapper:StaticBody3D = get_child(0)
	wrapper.setDimensions(Vector4(size.x, size.y, size.z, 1.0)*0.5)
	wrapper.set_transform(self.get_global_transform())


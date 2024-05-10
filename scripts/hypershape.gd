extends StaticBody3D

@onready var _shapeContainer:CollisionShape3D = get_node("CollisionShape3D")
@onready var _hyperRegion:CollisionShape3D = get_node("hyperRegion/regionShape")

@export_category("RayMarched Properties")
@export var color:Vector3 = Vector3(0.2, 0.7, 0.3)
@export var dimensions:Vector4 = Vector4(1.0, 1.0, 1.0, 1.0)
@export var shapeType := int(0)

func _ready():
	_shapeContainer.set_shape(BoxShape3D.new())
	_shapeContainer.get_shape().set_size(Vector3(dimensions[0], dimensions[1], dimensions[2]))
	var maxExtent = max(dimensions[0], dimensions[1], dimensions[2])
	#Divide by 2 'cuz its a radius
	_hyperRegion.get_shape().set_radius(maxExtent/2)
	print("Shape ", self.name, " region radius of: ", maxExtent/2)

func getSize():
	return _shapeContainer.get_shape().get_size()

func getColor():
	return color

func getShapeType():
	return shapeType
	

extends StaticBody3D

@onready var shapeContainer:Node = get_node("CollisionShape3D")
@export_category("RayMarched Properties")
@export var color:Vector3 = Vector3(0.2, 0.7, 0.3)
@export var dimensions:Vector3 = Vector3(1.0, 1.0, 1.0)
@export var shapeType := int(0)

func _ready():
	shapeContainer.set_shape(BoxShape3D.new())
	shapeContainer.get_shape().set_size(dimensions)

func getSize():
	return shapeContainer.get_shape().get_size()

func getColor():
	return color

func getShapeType():
	return shapeType
	

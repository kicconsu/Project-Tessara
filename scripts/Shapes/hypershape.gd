extends RigidBody3D

@onready var _shapeContainer:CollisionShape3D = get_node("CollisionShape3D")
@onready var _hyperRegion:CollisionShape3D = get_node("hyperRegion/regionShape")

@export_category("RayMarched Properties")
@export var base_color := Vector3(0.2, 0.7, 0.3)
var color = Vector3(0.0,0.0,0.0)
@export var dimensions := Vector4(1.0, 1.0, 1.0, 1.0)
@export var shapeType := int(0)
@export var hyperInfo := Vector4(0.0, 0.0, 0.0, 0.0) 

#the first three elements in this vector are xw, yw, zw rotation degrees.
#the last one is the w coordinate position.

func _ready():
	_shapeContainer.set_shape(BoxShape3D.new())
	_shapeContainer.get_shape().set_size(Vector3(dimensions[0], dimensions[1], dimensions[2]))
	var maxExtentX:float = max(dimensions[0], dimensions[1])
	var maxExtentY:float =  max(dimensions[2], dimensions[3])
	var regionRadius:float = sqrt(pow(maxExtentX, 2)+pow(maxExtentY, 2)) + 1
	_hyperRegion.set_shape(SphereShape3D.new())
	_hyperRegion.get_shape().set_radius(regionRadius)
	color = base_color
	#print("Shape ", self.name, " region radius of: ", regionRadius)

func getSize() -> Vector4:
	return self.dimensions

func getColor() -> Vector3:
	return self.color

func getShapeType() -> int:
	return self.shapeType
	
func getHyperInfo() -> Vector4:
	return self.hyperInfo

func setDimensions(size:Vector4):
	self.dimensions = size

func setColor(color:Vector3):
	self.color = color

func adjustHyperInfo(xw,yw,zw,w):
	hyperInfo += Vector4(xw,yw,zw,w)
	
func colorOnInspection():
	color = Vector3(0, 0, 5.0)
	
func colorAsTarget():
	color = Vector3(5.0, 5.0, 0)
	
func colorSelected():
	color = Vector3(0, 5.0, 0)

func colorFromScratch():
	color = base_color

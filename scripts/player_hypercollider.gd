extends Area3D

#Collider for any body part that ought to interact with hypershapes

var _dist = 1000.0

#Collider type for the controller to know what to do.
@export_category("Collider data")
@export var type:int = 0
@export var force_direction:Vector3 = Vector3(0, 0, 0)

@onready var _radius = $feetshape.get_shape().get_radius()

func _distToBox(shapeTransform:Transform3D, shapeSize:Vector3):
	#Get current point
	var pos:Vector3 = self.transform.origin
	
	#Multiply point by the transformMatrix to involve translation and rotation
	pos *= shapeTransform
	
	#Regular SDF evaluation for a cube as seen in: https://iquilezles.org/articles/distfunctions/
	var toSurface:Vector3 = abs(pos) - shapeSize
	
	#length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
	var offset:Vector3 = Vector3(max(toSurface.x, 0), max(toSurface.y, 0), max(toSurface.z, 0))
	return offset.length() + min(max(toSurface.x, max(toSurface.y, toSurface.z)), 0)

func _distFromShapes() -> float:
	var dist = 1000
	
	for area in self.get_overlapping_areas():
		var shape = area.get_parent()
		match shape.getShapeType():
			_:
				var distToShape = _distToBox(shape.get_transform(), shape.getSize())
				if distToShape < dist:
					dist = distToShape
	return dist

func _process(_delta):
	_dist = _distFromShapes() - _radius

func _on_area_entered(_area):
	_dist = _distFromShapes() - _radius
	print("Raycasted shape detected! distance: ", _dist)

func get_dist() -> float:
	return self._dist
	
func get_radius() -> float:
	return self._radius

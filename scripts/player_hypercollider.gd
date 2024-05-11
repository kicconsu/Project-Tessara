extends Area3D

#Collider for any body part that ought to interact with hypershapes

var _dist:float = 1000.0
var _collisionNormal:Vector3 = Vector3(0, 0 ,0)
const _epsilon = 0.005

#Collider type for the controller to know what to do.
@export_category("Collider data")
@export var _type:int = 0
@export var _collision_check_aperture:float = 45.0

#@onready var _radius = $feetshape.get_shape().get_radius()
@export var _radius:float = 0.3

@onready var _collidingWith:Node #terrible. just terrible. you should die and go to hell

func _distToBox(shapeTransform:Transform3D, shapeSize:Vector3, pos:Vector3) -> float:
	#Multiply point by the inversezsc transformMatrix to involve translation and rotation
	pos = (shapeTransform.inverse()) * pos
	
	#Regular SDF evaluation for a cube as seen in: https://iquilezles.org/articles/distfunctions/
	var toSurface:Vector3 = abs(pos) - shapeSize
	
	#length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
	var distVec:Vector3 = Vector3(max(toSurface.x, 0), max(toSurface.y, 0), max(toSurface.z, 0))
	
	return distVec.length() + min(max(toSurface.x, max(toSurface.y, toSurface.z)), 0)

#Get the minimum distance to all nearby shapes
func _distFromShapes() -> float:
	var dist = 1000
	for area in self.get_overlapping_areas():
		var shape = area.get_parent()
		match shape.getShapeType():
			_:
				var shapeTransform = shape.get_global_transform()
				var pos = self.get_global_transform().origin
				var distToShape = _distToBox(shapeTransform, shape.getSize(), pos)
				if distToShape < dist:
					#Get the minimum of all distances
					dist = distToShape
					#Know what you're colliding with
					_collidingWith = shape
	return dist

#Evaluate the SDF on the points on the surface found inside the check_aperture
#Whichever point is <=epsillon or simply the smallest is considered to be
#the point fron which the normal originates.
func getCollisionNormal() -> Vector3:
	#Return variables
	var normal:Vector3
	var collidePoint:Vector3
	
	#default val for taking the minimum
	var minDist:float = 100
	
	#collision info.
	var translation:Vector3 = self.get_global_transform().origin
	var shapeTrans:Transform3D = _collidingWith.get_global_transform()
	var shapeSize:Vector3 = _collidingWith.getSize()
	
	#vector building comes from https://stackoverflow.com/questions/30011741/3d-vector-defined-by-2-angles
	for anglexz:int in range(0, 360, 10):#alpha
		for angleyz:int in range(-90, 90, 10):#beta
			
			#basically building a round-lid cone (gracias bernardo)
			var radalpha = deg_to_rad(anglexz)
			var radbeta = deg_to_rad(angleyz)
			var dir:=Vector3(cos(radalpha)*cos(radbeta), sin(radbeta), sin(radalpha)*cos(radbeta))
			var point:Vector3 = dir*_radius #vector that points to the surface of the sphere
			
			#TODO: sdf depending on shape
			var dist = _distToBox(shapeTrans, shapeSize, point+translation)
			
			if dist <= _epsilon: #early return
				normal = (point+translation).direction_to(translation)
				#return normal
			
			if dist<minDist:
				minDist = dist
				collidePoint = point
	#normal is the normalized vector that points from the global collision point to the global sphere center
	#which means normal = localpoint + translation, pointing towars sphere center
	normal = (collidePoint+translation).direction_to(translation)
	return normal

func _process(_delta):
	_dist = _distFromShapes() - _radius

func _on_area_entered(_area):
	_dist = _distFromShapes() - _radius

func get_dist() -> float:
	return self._dist
	
func get_radius() -> float:
	return self._radius

func get_forceDir() -> Vector3:
	return self._force_direction

func get_collPoint() -> Vector3:
	return self._collisionPoint

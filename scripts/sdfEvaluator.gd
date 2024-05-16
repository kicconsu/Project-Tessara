extends RayCast3D

@onready var areas:Area3D = self.get_parent().get_node("sdfregion")
var localPos:Vector3 = self.get_transform().origin

func evaluateVelCast(displacement:Vector3):
	#Evaluate SDF along casted velocity vector. This means we ray march along it to check if theres any object in our way
	#if theres a hit, we send the collision info to be handled by hyperCnS.
	
	var globalPos = areas.get_global_transform().origin
	#Initial point
	var pos = Vector3(globalPos.x, globalPos.y + localPos.y, globalPos.z)
	#Final point
	var castedPoint:Vector3 = pos+(displacement/10)
	
	#Some raycast visualization stuff
	self.set_position(pos)
	self.set_target_position(displacement)
	
	var dist:float = _getCollisionAcross(pos, castedPoint)
	
	if dist == -1: #Theres no hit across casted velocity
		return [false, 0, Vector3.ZERO]
	else: #There is a hit across casted velocity
		#collisionDist = the distance to the surface as calculated
		var collisionDist = dist
		#evaluate the normal at (shortenedDisplacement)+positionOffset
		var normalEvalPoint = (displacement.normalized()*collisionDist)+pos
		var normal =  _approximateNormalAt(normalEvalPoint)
		return [true, collisionDist, normal]

#Raymarch across a vector to define a collision distance, if there is one
func _getCollisionAcross(from:Vector3, to:Vector3) -> float:
	var vec:Vector3 = to-from
	var dist:float = 0
	var hit:bool = false
	var steps:int = 0
	while dist<vec.length() and steps < 20:
		var rayPos:Vector3 = from + vec.normalized() * dist
		var pointDist = _distFromShapes(rayPos)
		dist += pointDist
		steps += 1
		if pointDist < 0.005:
			hit = true
			break
	return dist if hit else -1

#Get the minimum distance to all nearby shapes (take this as a compound SDF)
func _distFromShapes(pos:Vector3) -> float:
	var dist = 1000
	for area in areas.get_overlapping_areas():
		var shape = area.get_parent()
		match shape.getShapeType():
			_:
				var shapeTransform = shape.get_global_transform()
				var distToShape = _distToBox(shapeTransform, shape.getSize(), pos)
				if distToShape < dist:
					#Get the minimum of all distances
					dist = distToShape
					#Know what you're colliding with (unnecesary i think)
					#_collidingWith = shape
	return dist

#Distance from a point to the surface of a box
func _distToBox(shapeTransform:Transform3D, shapeSize:Vector3, pos:Vector3) -> float:
	#Multiply point by the inverse transformMatrix to involve translation and rotation
	pos = (shapeTransform.inverse()) * pos
	
	#Regular SDF evaluation for a cube as seen in: https://iquilezles.org/articles/distfunctions/
	var toSurface:Vector3 = abs(pos) - shapeSize
	
	#length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
	var distVec:Vector3 = Vector3(max(toSurface.x, 0), max(toSurface.y, 0), max(toSurface.z, 0))
	
	return distVec.length() + min(max(toSurface.x, max(toSurface.y, toSurface.z)), 0)

#Normal vector approximation through finite difference
func _approximateNormalAt(pos:Vector3) -> Vector3:
	var epsillon = 0.005
	var x = _distFromShapes(Vector3(pos.x+epsillon, pos.y, pos.z)) - _distFromShapes(Vector3(pos.x-epsillon, pos.y, pos.z))
	var y = _distFromShapes(Vector3(pos.x, pos.y +epsillon, pos.z)) - _distFromShapes(Vector3(pos.x, pos.y-epsillon, pos.z))
	var z = _distFromShapes(Vector3(pos.x, pos.y, pos.z+epsillon)) - _distFromShapes(Vector3(pos.x, pos.y, pos.z-epsillon))
	return Vector3(x, y, z).normalized()

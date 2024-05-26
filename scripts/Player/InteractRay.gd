extends RayCast3D

@onready var prompt = $prompt

#This is useful to detect if a hypershape is being pointed to (see getShape()
@onready var areas:Area3D = self.get_parent().get_parent().get_parent().get_node("collider").get_node("sdfregion")
var localPos:Vector3 = self.get_transform().origin
var RAYCAST_LENGTH = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	prompt.text = ""
	if is_colliding():
		
		var detected = get_collider()
		
		if detected is Interactable:
			prompt.text = detected.get_prompt()
			
			if Input.is_action_just_pressed(detected.prompt_action):
				detected.interact(owner)

func getShape(direction:Vector3):
	#Evaluate SDF along the ray, using the direction (which could be normalized or not). This means we ray march along it to check if theres any object in our way
	#if theres a hit, we send the shape information, so the player can interact with it
	
	#print("\nCurrently pointing at: ",direction.normalized())
	
	var globalPos = areas.get_global_transform().origin
	
	#Initial point
	var pos = Vector3(globalPos.x, globalPos.y + localPos.y, globalPos.z)
	#The point at which the raycast will stop if nothing is found
	var castedPoint:Vector3 = pos+(direction.normalized()*RAYCAST_LENGTH)
	
	#Some raycast visualization stuff
	self.set_position(pos)
	self.set_target_position(direction)
	
	var shape = _getColliderAcross(pos, castedPoint)
	return shape

#Raymarch across a vector to define a collision distance, if there is one
func _getColliderAcross(from:Vector3, to:Vector3):
	var vec:Vector3 = to-from
	var dist:float = 0
	var steps:int = 0
	
	#print("Travelling from",from," to ",to)
	
	#March the ray (haha, you know, it's funny, cuz it's rayma-)
	while dist<vec.length() and steps < 20:
		var rayPos:Vector3 = from + vec.normalized() * dist
		
		#print("So far we traveled: ",dist)
		# popo[_,_] will contain:
		# [0] -> Distance to the closest shape
		# [1] -> Closest shape
		var popo = _distFromShapes(rayPos)
		#print("The closest we were to a shape was: ",popo[0])
		dist += popo[0]
		steps += 1
		if popo[0] < 0.05:
			#print("Found it baby!!!!")
			return popo[1]
	#print("Well... it was a fun ride...\n")
	return null

#Get the minimum distance to all nearby shapes (take this as a compound SDF)
func _distFromShapes(pos:Vector3) -> Array:
	var dist = 1000
	var collidingWith = null
	for area in areas.get_overlapping_areas():
		var shape = area.get_parent()
		match shape.getShapeType():
			_:
				var shapeTransform = shape.get_global_transform()
				var distToShape = _distToBox(shapeTransform, shape.getSize(), Vector4(pos.x, pos.y, pos.z, 0.0), shape.getHyperInfo())
				if distToShape < dist:
					#Get the minimum of all distances
					dist = distToShape
					#Know what you're colliding with 
					collidingWith = shape
	return [dist, collidingWith]

#Distance from a point to the surface of a box
func _distToBox(shapeTransform:Transform3D, shapeSize:Vector4, pos:Vector4, hyperInfo:Vector4) -> float:
	#Multiply 3d point by the inverse transformMatrix to involve 3d translation and rotation
	var trans3d:Vector3 = shapeTransform.inverse() * Vector3(pos.x, pos.y, pos.z)
	pos = Vector4(trans3d.x, trans3d.y, trans3d.z, pos.w)
	
	#hyper transforms ----
	#translation
	pos.w -= hyperInfo.w
	#vec2 to hold rotation transformations
	var rot : Vector2 
	#XW rotation
	rot = _vec2ByMat2(Vector2(pos.x, pos.w), [ [cos(hyperInfo.x), -sin(hyperInfo.x)], [sin(hyperInfo.x), cos(hyperInfo.x)]])
	pos = Vector4(rot.x, pos.y, pos.z, rot.y)
	#ZW rotation
	rot = _vec2ByMat2(Vector2(pos.z, pos.w), [ [cos(hyperInfo.z), sin(hyperInfo.z)], [-sin(hyperInfo.z), cos(hyperInfo.z)]])
	pos = Vector4(pos.x, pos.y, rot.x, rot.y)
	#YW rotation
	rot = _vec2ByMat2(Vector2(pos.y, pos.w), [ [cos(hyperInfo.y), sin(hyperInfo.y)], [-sin(hyperInfo.y), cos(hyperInfo.y)]])
	pos = Vector4(pos.x, rot.x, pos.z, rot.y)
	
	
	#Regular SDF evaluation for a hypercube as seen in: https://github.com/Jellevermandere/4D-Raymarching
	var toSurface:Vector4 = abs(pos) - shapeSize
	
	var snappedComponents:= Vector4(max(toSurface.x, 0), max(toSurface.y, 0), max(toSurface.z, 0), max(toSurface.w, 0))
	
	#return length(max(vectorDistance, 0.0)) + min(max(vectorDistance.x, max(vectorDistance.y, max(vectorDistance.z, vectorDistance.w))), 0.0);
	return snappedComponents.length() + min(max(toSurface.x, max(toSurface.y, max(toSurface.z, toSurface.w))), 0.0)

#Vec2 * Mat2 auxiliary method (this works)
func _vec2ByMat2(vec:Vector2, mat:Array) -> Vector2:
	@warning_ignore("unassigned_variable")
	var out:Vector2
	for i in range(2):
		out[i] = vec.dot(Vector2(mat[i][0], mat[i][1]))
	return out


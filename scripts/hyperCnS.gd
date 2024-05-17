extends CollisionShape3D

#Code to collide and slide with hypersurfaces, based heavily on:
#https://www.youtube.com/watch?v=YR6Q7dUz2uk

const maxDepth:int = 5

#From the actual collider bound, walk back this distance
const skinOffset:float = 0.05

const maxSlopeAngle:float = 50

@onready var feet:RayCast3D = $feetsdf
@onready var region:Area3D = $sdfregion
@onready var player:CharacterBody3D = get_parent()


#Take a velocity vector and cast it forward. Then, use SDF's to check for collisions in its path.
#If there is a collision, take the collision normal to slide() the velocity vector across the surface.
#Repeat this process until there are no more collisions or recursive maxDepth is reached.
func hyperCollideAndSlide(vel:Vector3, pos:Vector3, depth:int, gravityPass:bool, velInit:Vector3)->Vector3:
	#TODO: dont increase depth unnecessarily
	if depth>=maxDepth:
		return Vector3.ZERO
	
	#Compensate skinOffset so that distances are tracked from the collider boundary
	var dist:float = vel.length() + skinOffset
	
	var hit:Array = []
	
	#Collision detection that returns dist from surface to collision
	#and the collision normal
	hit = self.castVelocity(vel)
	
	if hit[0]: #if the velocity hits something,
		#Snap dist from surface to collision (with walkback)
		var velSnap:Vector3 = vel.normalized() * (hit[1] - skinOffset)
		#Get the leftover velocity vector
		var leftover:Vector3 = vel - velSnap
		#Get floor angle (angle between +y and the hit normal)
		var angle:float = rad_to_deg(hit[2].angle_to(Vector3.UP))
		
		#Give the collision detection some breathing room...
		if velSnap.length() <= skinOffset:
			velSnap = hit[2]*skinOffset
			
		#Decide what to do depending on slope angle:
		if angle <= maxSlopeAngle:
			#Logic for walkable ground
			if gravityPass: # If on gravity pass, dont slide
				player.hypercolliding = true
				return velSnap
			leftover = projectAndScale(leftover, hit[2])
		else:
			#Logic for un-walkable ground (like, walls)
			#Scale vel depending on the angle between initVel and the wall
			var scale:float = 1 - (Vector3(hit[2].x, 0, hit[2].z)).dot(Vector3(velInit.x, 0, velInit.z))
			leftover = projectAndScale(leftover, hit[2]) / (scale/2)
			
		#Recursively resolve hypercollsions
		return velSnap + hyperCollideAndSlide(leftover, pos+velSnap, depth+1, gravityPass, velInit)
	player.hypercolliding = false
	return vel

func castVelocity(vel:Vector3)->Array:
	# [0] -> did it hit something?
	# [1] -> how far did it hit?
	# [2] -> hit normal
	var hitData:Array = []
	
	#Check if theres any potential hypershapes near; if there arent any, return [0] = false
	if not region.has_overlapping_areas():
		hitData = [false, 0, Vector3.ZERO]
	else:
		hitData = feet.evaluateVelCast(vel)
	return hitData

func projectAndScale(leftover:Vector3, normal:Vector3):
	#Get leftover magnitude to scale it back up after it gets projected
	#var mag:float = leftover.length()
	#Project the leftover velocity vector onto sliding plane and normalize it
	leftover = (leftover.slide(normal))
	#Scale back up and return
	return leftover #* mag

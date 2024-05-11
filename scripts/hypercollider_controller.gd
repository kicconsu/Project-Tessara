extends Node
class_name HypercolliderController

#Controller to handle the information from each hypercollider. 
#It checks every frame every hypercollider for collisions
#Depending on what hypercollider detects collisions, applies a force to the PlayerBody
#i.e. if the feet hypercollider detects a collision, apply a force upwards!

var _epsilon = 0.005

@onready var colliders:Array[Node] = self.get_children()
@onready var player:CharacterBody3D = self.get_parent()

func _process(_delta):
	var hasCollided = false
	for collider in colliders:
		if collider.get_dist() < self._epsilon:
			hasCollided = true
			var slidingPlaneNormal:Vector3 = collider.getCollisionNormal()
			var originalVel:Vector3 = player.getVel() #Vector to be projected on sliding plane
			var projectedVel:Vector3 = ((originalVel.slide(slidingPlaneNormal)).normalized())*originalVel
			var sendVel:Vector3 = projectedVel
			print("plane normal: ", slidingPlaneNormal)
			print("player vel: ", originalVel)
			print("slid vel: ",projectedVel)
			print("sent vel: ",sendVel)
			player.set_velocity(sendVel)
			player.hypercolliding = hasCollided 
	if not hasCollided:
		player.hypercolliding = false
	print("colliding?: ",hasCollided)


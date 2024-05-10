extends CollisionShape3D

#Controller to handle the information from each hypercollider. 
#It checks every frame every hypercollider for collisions
#Depending on what hypercollider detects collisions, applies a force to the PlayerBody
#i.e. if the feet hypercollider detects a collision, apply a force upwards!

var _epsilon = 0.005

@onready var colliders:Array[Node] = self.get_children()
@onready var player:CharacterBody3D = self.get_parent()

# This is where the magic happens.... 
func _process(_delta):
	for collider in colliders:
		if collider.get_dist() < self._epsilon:
			print("Colliding with hypershape!")

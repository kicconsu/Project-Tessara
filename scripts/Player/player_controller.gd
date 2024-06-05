extends CharacterBody3D

@onready var head:Node3D = $Head
@onready var region:CollisionShape3D = $collider/sdfregion/sdfsphere
@onready var body:CollisionShape3D = $collider

signal hyper_inspection
var inspection_enabled = false;

var physVel:Vector3
var hypercolliding:bool = false

var mouseToggle = true
var currentSpeed

const walkSpeed = 5.0
const sprintSpeed = 15
const jumpVelocity = 4.5

const mouse_sens = 0.25

var lerp_speed = 10.0
var direction = Vector3.ZERO
var locked = true


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass	

func _input(event):
	
	if !locked:
		if event is InputEventMouseMotion and mouseToggle and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	
	#print("hypercolliding" if hypercolliding else "not hypercolliding")
	
	# Add the gravity.
	if not is_on_floor() and not hypercolliding:
		velocity.y -= gravity * delta
		velocity = body.hyperCollideAndSlide(velocity, self.get_global_transform().origin, 0, true, velocity)

	if Input.is_action_pressed("sprint"):
		currentSpeed = sprintSpeed
	else:
		currentSpeed = walkSpeed
	
	 #Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or hypercolliding):
		velocity.y = jumpVelocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() , delta*lerp_speed ) 
	
	
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	physVel = velocity
	
	#Set region radius to the velocity magnitude for hypercollision detection
	region.get_shape().set_radius(max(lerp(region.get_shape().get_radius(), physVel.length(), 0.2), 1))

	velocity = body.hyperCollideAndSlide(velocity, self.get_global_transform().origin, 0, false, velocity)
	#$collider/feetsdf.evaluateVelCast(velocity)
	
	#HyperHand initial implementation
	if Input.is_action_just_pressed("ui_focus_next"):
		hyper_inspection.emit()
	
	move_and_slide()
	
func getVel():
	return physVel
	
func isInspectionEnabled():
	return inspection_enabled
	
func setInspectionEnabled(boolean:bool):
	inspection_enabled = boolean

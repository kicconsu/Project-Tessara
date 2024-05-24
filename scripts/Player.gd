extends CharacterBody3D

@onready var head = $Head
@onready var player_cam = $Head/playerCam
@onready var interact_ray = $Head/playerCam/InteractRay

@onready var hand = $Head/playerCam/Hand
@onready var joint = $Head/playerCam/joint
@onready var aux = $Head/playerCam/aux


var mouseToggle = false
var currentSpeed

const walkSpeed = 5.0
const sprintSpeed = 15.0
const jumpVelocity = 4.5

const mouse_sens = 0.25

var lerp_speed = 10.0
var direction = Vector3.ZERO

var locked = false
var playerLocked = false

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func rotate_head(event):
	if event is InputEventMouseMotion and mouseToggle and Input.get_mouse_mode() == 2:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _input(event):
	
	if !locked:
		rotate_head(event)			
			
func _physics_process(delta):

	if !playerLocked:
	
		if not is_on_floor():
			velocity.y -= gravity * delta

		if Input.is_action_pressed("sprint"):
			currentSpeed = sprintSpeed
		else:
			currentSpeed = walkSpeed
		
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jumpVelocity

		var input_dir = Input.get_vector("left", "right", "up", "down")
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() , delta*lerp_speed ) 
		
		if direction:
			velocity.x = direction.x * currentSpeed
			velocity.z = direction.z * currentSpeed
		else:
			velocity.x = move_toward(velocity.x, 0, currentSpeed)
			velocity.z = move_toward(velocity.z, 0, currentSpeed)

	move_and_slide()

extends CharacterBody3D

@onready var head:Node3D = $Head
@onready var region:CollisionShape3D = $collider/sdfregion/sdfsphere
@onready var body:CollisionShape3D = $collider
@onready var raycast:RayCast3D = $Head/eyes/InteractRay
@onready var camera = $Head/eyes
@onready var hand = $Head/eyes/Hand
@onready var joint = $Head/eyes/joint
@onready var aux = $Head/eyes/aux

signal enable_hyper_inspection
signal disable_hyper_inspection
var inspection_enabled = false
var target_shape = null

var locked = false
var hyper_locked = false
var physVel:Vector3
var hypercolliding:bool = false

var mouseToggle = true
var currentSpeed

const walkSpeed = 5.0
const sprintSpeed = 8.0
const jumpVelocity = 4.5

const mouse_sens = 0.25

var lerp_speed = 10.0
var direction = Vector3.ZERO


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass	

func _input(event):
	
	if !locked and !hyper_locked:
		rotate_head(event)	
	
	if Input.is_action_pressed("lclick"):
		pick_object()
	
	if hand.picked_object != null and Input.is_action_just_released("lclick"):
		hand.picked_object.set_freeze_enabled(true)
		hand.picked_object.colorFromScratch()
		hand.picked_object = null
		joint.set_node_b(joint.get_path())
		
	if Input.is_action_pressed("rclick"):
		locked = true
		rotate_object(event)
	
	if Input.is_action_just_released("rclick"):
		locked = false
	
	if Input.is_action_just_pressed("ctrl"):
		hyper_locked = true
	
	if hyper_locked:
		hyper_rotate_object(event)
	
	if Input.is_action_just_released("ctrl"):
		hyper_locked = false
	
	

func _physics_process(delta):
	#print("\ninspection enabled: ",inspection_enabled)
	#print("target_shape: ",target_shape)
	#print("hand.picked_object: ",hand.picked_object,"\n")
	
	#print("hypercolliding" if hypercolliding else "not hypercolliding")
	
	if Input.is_action_just_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE)
	
	# Add the gravity.
	if not is_on_floor() and not hypercolliding:
		velocity.y -= gravity * delta
		#velocity = body.hyperCollideAndSlide(velocity, self.get_global_transform().origin, 0, true, velocity)

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

	#velocity = body.hyperCollideAndSlide(velocity, self.get_global_transform().origin, 0, false, velocity)
	#$collider/feetsdf.evaluateVelCast(velocity)
	
	#HyperHand initial implementation
	if Input.is_action_just_pressed("ui_focus_next"):
		disable_hyper_inspection.emit() if inspection_enabled else enable_hyper_inspection.emit()

	if inspection_enabled:
		var shape = raycast.getShape(-camera.get_global_transform().basis.z) #That weird camera thing returns the forward direction of the camera as a Vector3
		if shape != null:
			if target_shape == null:
				shape.colorAsTarget()
				target_shape = shape
			elif target_shape != shape:
				target_shape.colorOnInspection()
				shape.colorAsTarget()
				target_shape = shape
		elif target_shape != null:
			target_shape.colorOnInspection()
			target_shape = null
		
	if hand.picked_object != null and not hyper_locked:
		hand.pull_object()
	
	move_and_slide()

func rotate_head(event):
	if event is InputEventMouseMotion and mouseToggle and Input.get_mouse_mode() == 2:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func pick_object():
	if  target_shape != null:# and collider is Trigger:
		disable_hyper_inspection.emit()
		inspection_enabled = false
		target_shape.colorSelected()
		target_shape.set_freeze_enabled(false)
		hand.picked_object = target_shape
		target_shape = null
		joint.set_node_b(hand.picked_object.get_path())

func rotate_object(event):
	if hand.picked_object != null:
		if event is InputEventMouseMotion:
			aux.rotate_x(deg_to_rad(event.relative.y * hand.rotation_power))
			aux.rotate_y(deg_to_rad(event.relative.x * hand.rotation_power))

func hyper_rotate_object(event):
	if hand.picked_object != null:
		var xw = 0
		var yw = 0
		var zw = 0
		var w = hand.picked_object.getHyperInfo().w
		if event is InputEventMouseMotion:
			xw = event.relative.x * 0.001
			yw = event.relative.y *0.001
		elif Input.is_action_just_released("wheelup"):
			zw += hand.rotation_power
		elif Input.is_action_just_released("wheeldown"):
			zw -= hand.rotation_power 
		hand.picked_object.adjustHyperInfo(xw,yw,zw,w)


func getVel():
	return physVel
	
func isInspectionEnabled():
	return inspection_enabled
	
func setInspectionEnabled(boolean:bool):
	inspection_enabled = boolean

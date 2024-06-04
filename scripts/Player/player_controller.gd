extends CharacterBody3D

@onready var head:Node3D = $Head
@onready var region:CollisionShape3D = $collider/sdfregion/sdfsphere
@onready var body:CollisionShape3D = $collider
@onready var raycast:RayCast3D = $Head/InteractRay
@onready var camera = $Head/eyes

@onready var hand:Node3D = $Head/Hand
@onready var joint:Node3D = $Head/joint
@onready var aux:Node3D = $Head/aux

signal enable_hyper_inspection
signal disable_hyper_inspection

var inspection_enabled := false
var target_shape : Node = null

var locked := false
var freezed := false
var hyper_locked := false
var physVel:Vector3
var hypercolliding := false
var cameraForward:=Vector3(1,0,0)

var mouseToggle := true

var currentSpeed:float
const walkSpeed := 5.0
const sprintSpeed := 8.0
const jumpVelocity := 10

const mouse_sens := 0.25

var lerp_speed := 10.0
var direction := Vector3.ZERO
var distOffset:float = 5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass	

func _input(event):
	
	if Input.is_action_just_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE)
	
	if !freezed:
		if event is InputEventMouseMotion:
			if mouseToggle and Input.get_mouse_mode() == 2 and !locked and !hyper_locked:
				rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
				head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
				head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
		
		if Input.is_action_pressed("lclick"):
			pick_object()
			
		if Input.is_action_just_pressed("lclick"): 
			distOffset = raycast.distToShape
		
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
		
		if Input.is_action_just_released("wheeldown") and hand.picked_object != null and !hyper_locked:
			print("holding at dst: ", distOffset)
			distOffset -= 0.2
			distOffset = clamp(distOffset, 0.2, 7)
		
		if Input.is_action_just_released("wheelup") and hand.picked_object != null and !hyper_locked:
			print("holding at dst: ", distOffset)
			distOffset += 0.2
			distOffset = clamp(distOffset, 0.2, 7)
		
		#Toggle Hyperhand coloration mode by emitting a signal
		if Input.is_action_just_pressed("ui_focus_next"):
			inspection_enabled = !inspection_enabled
			if inspection_enabled:
				enable_hyper_inspection.emit()
			else:
				disable_hyper_inspection.emit()

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor() and not hypercolliding:
		velocity.y -= gravity * delta
		velocity = body.hyperCollideAndSlide(velocity, self.get_global_transform().origin, 0, true, velocity)

	if Input.is_action_pressed("sprint"):
		currentSpeed = sprintSpeed
	else:
		currentSpeed = walkSpeed
	
	 #Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or hypercolliding):
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
	
	move_and_slide()
	
	if hand.picked_object != null:
		hand.pull_object(cameraForward*distOffset)
	
func _process(_delta):
	#-camera.transform.basis.z returns the forward direction of the camera as a Vector3
	cameraForward = -camera.get_global_transform().basis.z
	if inspection_enabled:
		var shape = raycast.getShape(cameraForward) 
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

func pick_object():
	if  target_shape != null:# and collider is Trigger:
		disable_hyper_inspection.emit()
		inspection_enabled = false
		target_shape.colorSelected()
		target_shape.set_freeze_enabled(false)
		hand.picked_object = target_shape
		target_shape = null
		hand.picked_object.set_constant_force(Vector3(0,0,0))
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
		if event is InputEventMouseMotion:
			xw = event.relative.x * 0.001
			yw = event.relative.y *0.001
		elif Input.is_action_just_released("wheelup"):
			zw += hand.rotation_power
		elif Input.is_action_just_released("wheeldown"):
			zw -= hand.rotation_power 
		hand.picked_object.adjustHyperInfo(xw,yw,zw,0)


func getVel():
	return physVel
	
func isInspectionEnabled():
	return inspection_enabled
	
func setInspectionEnabled(boolean:bool):
	inspection_enabled = boolean
	

func isFreezed():
	return freezed

func setFreezed(boolean:bool):
	freezed = boolean
	self.set_physics_process(!boolean)
	self.set_process(!boolean)

extends Camera3D

#Script that sets up and runs the ray-march.glsl shader!!
#Most (if not everything) of what's here is based on (or pasted from) this:
#https://github.com/nekotogd/Raytracing_Godot4/blob/master/

#CAMERA CONTROL STUFF (got it from https://godotengine.org/asset-library/asset/1561)
# Modifier keys' speed multiplier
const SHIFT_MULTIPLIER = 2.5
const ALT_MULTIPLIER = 1.0 / SHIFT_MULTIPLIER

@export_range(0.0, 1.0) var sensitivity = 0.25

# Mouse state
var _mouse_position = Vector2(0.0, 0.0)
var _total_pitch = 0.0


# Movement state
var _direction = Vector3(0.0, 0.0, 0.0)
var _velocity = Vector3(0.0, 0.0, 0.0)
var _acceleration = 30
var _deceleration = -10
var _vel_multiplier = 4

# Keyboard state
var _w = false
var _s = false
var _a = false
var _d = false
var _q = false
var _e = false
var _shift = false
var _alt = false
# ================================ 

#Actual variables for shaders
var shader
var pipeline
var uniform_set
var outputTex : RID
var bindings : Array

var screen = PackedInt32Array([ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height")])

var rd: RenderingDevice = RenderingServer.create_local_rendering_device()
@onready var sceneCam = self
@onready var texRect = $Control/TextureRect

func _ready():
	texRect.imageSize = Vector2(screen[0], screen[1])
	texRect.textureInit()
	setupCompute()
	render()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_mouselook()
	_update_movement(delta)
	updateCompute()
	render()
	

#These two fellas here take matrixes and turn them into bytearrays to send to the shader
#The order of the byte array matters!! OpenGL constructs matrixes in column major order
#Basically, it fills up a column before moving to the next...
func transform_to_bytes(t : Transform3D):
	
	# Helper function
	# Encodes the values of a "global_transform" into bytes
	
	var basis : Basis = t.basis
	var origin : Vector3 = t.origin
	var bytes : PackedByteArray = PackedFloat32Array([
		basis.x.x, basis.x.y, basis.x.z, 0.0, #Primera columna,
		basis.y.x, basis.y.y, basis.y.z, 0.0, #Segunda columna...
		basis.z.x, basis.z.y, basis.z.z, 0.0,
		origin.x, origin.y, origin.z, 1.0     # Ultima columna; la columna de indice [3] corresponde a la traslación!
	]).to_byte_array()
	return bytes

func ProjectionToBytes(proj : Projection): 
	#Could hypothetically convert any 4x4 matrix just pass it like a Projection n ur goode
	var bytes : PackedByteArray = PackedFloat32Array([
		proj.x.x, proj.x.y, proj.x.z, proj.x.w,
		proj.y.x, proj.y.y, proj.y.z, proj.y.w,
		proj.z.x, proj.z.y, proj.z.z, proj.z.w,
		proj.w.x, proj.w.y, proj.w.z, proj.w.w,
	]).to_byte_array()
	return bytes

#Transforming a vector3 to a bytearray of length 4
func vec3ToBytes(vec : Vector3):
	var bytes : PackedByteArray = PackedFloat32Array([vec.x, vec.y, vec.z, 1.5]).to_byte_array()
	return bytes

func setupCompute():
	# Create shader and pipeline
	var shader_file = load("res://assets/shaders/ray_marcher.glsl")
	var shader_spirv = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)
	
	# Set all the SSBO data over here!!
	
	#Camera SSBO 
	var camBytes := PackedByteArray() #Array to be sent to the shader
	var camTransform : Transform3D = sceneCam.get_camera_transform()
	var inverseProjMat : Projection = sceneCam.get_camera_projection().inverse()
	
	camBytes.append_array(transform_to_bytes(camTransform)) # Send the transformMatrix of the camera, as bytes
	camBytes.append_array(ProjectionToBytes(inverseProjMat))
	
	var camBuffer = rd.storage_buffer_create(camBytes.size(), camBytes)
	var camUniform := RDUniform.new()
	camUniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	camUniform.binding = 0
	camUniform.add_id(camBuffer)
	
	#Shapes SSBO
	var shapeBytes := PackedByteArray()
	var shapesInScene = get_tree().get_nodes_in_group("hyperShapes")
	var shapeCount = shapesInScene.size()
	
	shapeBytes.append_array(PackedInt32Array([shapeCount, 0, 0, 0]).to_byte_array())
	#padding so that openGL wont shit its stupid fucking baby pants
	
	for shape in shapesInScene:
		var shapeTransform : Transform3D = shape.get_transform() #4x4 matrix
		var shapeCol = shape.getColor() #vec3
		var shapeSize = shape.getSize() #vec3
		var shapeType = shape.getShapeType() #int
		
		shapeBytes.append_array(PackedInt32Array([shapeType, 0, 0, 0]).to_byte_array())
		shapeBytes.append_array(vec3ToBytes(shapeCol))
		shapeBytes.append_array(vec3ToBytes(shapeSize))
		shapeBytes.append_array(transform_to_bytes(shapeTransform))
	
	var shapeBuffer = rd.storage_buffer_create(shapeBytes.size(), shapeBytes)
	var shapeUniform := RDUniform.new()
	shapeUniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	shapeUniform.binding = 1
	shapeUniform.add_id(shapeBuffer)
	
	#Screen SSBO
	var screenBytes := PackedByteArray()
	screenBytes.append_array(PackedFloat32Array([screen[0]]).to_byte_array())
	screenBytes.append_array(PackedFloat32Array([screen[1]]).to_byte_array())
	var screenBuffer = rd.storage_buffer_create(screenBytes.size(), screenBytes)
	var screenUniform := RDUniform.new()
	screenUniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	screenUniform.binding = 2
	screenUniform.add_id(screenBuffer)
	
	#Output image
	var texFormat := RDTextureFormat.new()
	texFormat.width = screen[0]
	texFormat.height = screen[1]
	#no idea what these next 2 lines do
	texFormat.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	texFormat.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	var view := RDTextureView.new()
	var outputImg := Image.create(screen[0], screen[1], false, Image.FORMAT_RGBAF)
	outputTex = rd.texture_create(texFormat, view, [outputImg.get_data()])
	var outTexUniform := RDUniform.new()
	outTexUniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	outTexUniform.binding = 3
	outTexUniform.add_id(outputTex)
	
	#DONE WITH SSBO'S FINALLY (this is Not going to Run and I Will Die and Go To Hell)
	
	#Uniform set creation:
	bindings = [
		
		camUniform,
		shapeUniform,
		screenUniform,
		outTexUniform,
		
	]
	
	uniform_set = rd.uniform_set_create(bindings, shader, 0)

func updateCompute():
	#Update whichever uniforms need to be updated every frame
	#That would be the camera uniform and the shapes uniform
	
	#I *could* refactor everything so that i dont have to copy and paste code....
	#TODO: do it.
	
	#Camera SSBO 
	var camBytes := PackedByteArray() #Array to be sent to the shader
	var camTransform : Transform3D = sceneCam.get_camera_transform()
	var inverseProjMat : Projection = sceneCam.get_camera_projection().inverse()
	
	camBytes.append_array(transform_to_bytes(camTransform)) # Send the transformMatrix of the camera, as bytes
	camBytes.append_array(ProjectionToBytes(inverseProjMat))
	
	var camBuffer = rd.storage_buffer_create(camBytes.size(), camBytes)
	var camUniform := RDUniform.new()
	camUniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	camUniform.binding = 0
	camUniform.add_id(camBuffer)
	
	#Shapes SSBO
	var shapeBytes := PackedByteArray()
	var shapesInScene = get_tree().get_nodes_in_group("hyperShapes")
	var shapeCount = shapesInScene.size()
	
	shapeBytes.append_array(PackedInt32Array([shapeCount, 0, 0, 0]).to_byte_array())
	#padding so that openGL wont shit its stupid fucking baby pants
	
	for shape in shapesInScene:
		var shapeTransform : Transform3D = shape.get_transform() #4x4 matrix
		var shapeCol = shape.getColor() #vec3
		var shapeSize = shape.getSize() #vec3
		var shapeType = shape.getShapeType() #int
		
		shapeBytes.append_array(PackedInt32Array([shapeType, 0, 0, 0]).to_byte_array())
		shapeBytes.append_array(vec3ToBytes(shapeCol))
		shapeBytes.append_array(vec3ToBytes(shapeSize))
		shapeBytes.append_array(transform_to_bytes(shapeTransform))
	
	var shapeBuffer = rd.storage_buffer_create(shapeBytes.size(), shapeBytes)
	var shapeUniform := RDUniform.new()
	shapeUniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	shapeUniform.binding = 1
	shapeUniform.add_id(shapeBuffer)
	
	#Update bindings!
	bindings[0] = camUniform
	bindings[1] = shapeUniform
	uniform_set = rd.uniform_set_create(bindings, shader, 0)

func render():
	# Start compute list to start recording our compute commands
	var compute_list = rd.compute_list_begin()
	
	# Bind the pipeline, this tells the GPU what shader to use
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	# Binds the uniform set with the data we want to give our shader 
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	# Dispatch (X,Y,Z) work groups
	rd.compute_list_dispatch(compute_list, (screen[0] / 8)+1, screen[1] / 8, 1)
	
	# Tell the GPU we are done with this compute task
	rd.compute_list_end()
	#Force the GPU to start our commands
	rd.submit()
	# Force the CPU to wait for the GPU to finish with the recorded commands
	rd.sync()
	
	#REAP THEM REWARDS MATEY
	var outputBytes : PackedByteArray = rd.texture_get_data(outputTex, 0)
	texRect.setData(outputBytes)

#Debug function to print out pixel data as RGB values
func checkPixelsFromBytes(outputBytes : PackedByteArray):
	# Define the bytes per pixel for RGBAF format (4 channels, 4 bytes each)
	var bytes_per_pixel: int = 16
	
	# Iterate through the bytes and interpret as pixels
	for i in range(0, outputBytes.size(), bytes_per_pixel):
		# Extract the bytes for each pixel
		var index = i
		
		# Convert the bytes to RGBA values (32-bit floating-point each)
		var r: float = outputBytes.decode_float(index)
		index += 4
		var g: float = outputBytes.decode_float(index)
		index += 4
		var b: float = outputBytes.decode_float(index)
		index += 4
		var a: float = outputBytes.decode_float(index)
		
		# Display the RGBA values of the pixel
		if(r != 0 || g != 0 || b != 0 || a != 0):
			print("Pixel (", i / bytes_per_pixel, ") RGBA: (", r, ", ", g, ", ", b, ", ", a, ")")

#CAMERA STUFF AGAIN ===============================================================

func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
	
	# Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_RIGHT: # Only allows rotation if right click down
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
			MOUSE_BUTTON_WHEEL_UP: # Increases max velocity
				_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
			MOUSE_BUTTON_WHEEL_DOWN: # Decereases max velocity
				_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)

	# Receives key input
	if event is InputEventKey:
		match event.keycode:
			KEY_W:
				_w = event.pressed
			KEY_S:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
			KEY_D:
				_d = event.pressed
			KEY_Q:
				_q = event.pressed
			KEY_E:
				_e = event.pressed

# Updates camera movement
func _update_movement(delta):
	# Computes desired direction from key states
	_direction = Vector3((_d as float) - (_a as float), 
						(_e as float) - (_q as float), 
						(_s as float) - (_w as float))
	
	# Computes the change in velocity due to desired direction and "drag"
	# The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	# Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	# Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		# Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		# Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
	
		translate(_velocity * delta * speed_multi)

# Updates mouse look 
func _update_mouselook():
	# Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_position *= sensitivity
		var yaw = _mouse_position.x
		var pitch = _mouse_position.y
		
		# Prevents looking up/down too far
		pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
		_total_pitch += pitch
	
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))


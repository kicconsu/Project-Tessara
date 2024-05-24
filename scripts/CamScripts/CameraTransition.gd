extends Node

@onready var camera3D = $Camera3D
var transitioning = false

func _ready() -> void:
	pass
	#camera3D.current = false
	
func transition_camera3D(from: Camera3D, to: Camera3D, duration: float = 1.0) -> void:
	if transitioning: return
	# Copiar los parametros de la primera camara
	camera3D.fov = 70
	camera3D.near = from.near
	camera3D.far = from.far
	camera3D.cull_mask = from.cull_mask
	
	# Mover la camera de transicion a la posicion de la primera camara
	camera3D.global_transform = from.global_transform
	
	# Hacer current nuestra camara de transicion
	camera3D.set_current(true)
	
	transitioning = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera3D, "global_transform", to.global_transform, duration).from(camera3D.global_transform)
	tween.tween_property(camera3D, "fov", to.fov, duration).from(camera3D.fov)

	# Wait for the tween to complete
	await tween.finished
	to.set_current(true)
	


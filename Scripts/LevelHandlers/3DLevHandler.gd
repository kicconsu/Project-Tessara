extends Node3D

@onready var textBox:Control = $"../../TextBox"
@onready var animation_player = $AnimationPlayer
@onready var camera = $Camera
@onready var timer = $Player/Timer
@onready var player = $Player
@onready var audio = $Area3D/AudioStreamPlayer
@onready var color_rect = $Player/Head/InteractRay/ColorRect
@onready var theme = $AudioStreamPlayer

func _ready():
	theme.play()
	player.setFreezed(true)
	timer.set_wait_time(12.5)
	timer.start()
	animation_player.play("transition")
	animation_player.queue("camera")


func _on_timer_timeout():
	player.setFreezed(false)
	
	textBox.queue_text("¡Bienvenido a mi caja de arena tridimensional!")
	textBox.queue_text("Me imagino que ya sabes cual es la meta...")
	textBox.queue_text("¿Alguna idea de como llegar hasta alla?")
	textBox.queue_text("Tranquilidad ante todo ¿Si ves esas figuras coloreadas?")
	textBox.queue_text("Serán nuestras herramientas para avanzar")
	textBox.queue_text("¿Ves esa tabla verde en el piso al lado tuyo?")
	textBox.queue_text("Presiona TAB y agarrala con CLICK IZQUIERDO")
	textBox.queue_text("¿Que tal?")
	textBox.queue_text("Mientras presiones CLICK DERECHO y lo muevas, puedes rotar la figura siendo su eje de rotacion, donde apuntes")
	textBox.queue_text("Ademas, puedes alejar y retroceder la figura con la ruedita del MOUSE")
	textBox.queue_text("¡Nos vemos al final!")
	
func _on_area_3d_body_exited(body):
	audio.play()
	player.position = Vector3(-32.847,10,-15.84)


func _on_audio_stream_player_finished():
	theme.play()

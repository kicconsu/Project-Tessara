extends Node3D

@onready var textBox:Control = $"../../TextBox"
@onready var animation_player = $AnimationPlayer
@onready var camera = $Camera
@onready var timer = $Player/Timer
@onready var player = $Player

func _ready():
	player.locked = true
	timer.set_wait_time(12.5)
	timer.start()
	animation_player.play("transition")
	animation_player.queue("camera")


func _on_timer_timeout():
	player.locked = false
	
	textBox.queue_text("¡Bienvenido a mi caja de arena tridimensional!")
	textBox.queue_text("Me imagino que ya sabes cual es la meta...")
	textBox.queue_text("¿Alguna idea de como llegar hasta alla?")
	textBox.queue_text("Tranquilidad ante todo ¿Si ves esas figuras coloreadas?")
	textBox.queue_text("Serán nuestras herramientas para avanzar")
	textBox.queue_text("¿Ves esa tabla verde en el piso al lado tuyo?")
	textBox.queue_text("Presiona TAB y agarrala con CLICK IZQUIERDO")
	textBox.queue_text("¿Que tal?")

extends Node3D

@onready var player = $Player
@onready var audio = $Area3D/AudioStreamPlayer
@onready var anim = $anim
@onready var anim2 = $anim2
@onready var transition = $Control/AnimationPlayer
@onready var timer = $Timer
@onready var textBox = $"../../TextBox"

var jujo = false

func _ready():
	timer.set_wait_time(12)
	timer.start()
	
	player.setFreezed(true)
	transition.play("transition")
	transition.queue("camera")
	anim.play("platformsMoving")


func _on_area_3d_body_exited(body):
	player.position = Vector3(-10.309,5,-0.333) 
	audio.play()

func _on_trigger_anim_body_entered(body):
	if !jujo:
		anim2.play("eyeTurn")
		jujo = true

func _on_timer_timeout():
	player.setFreezed(false)
	
	textBox.queue_text("¡ALGUIEN HA ROBADO LA ULTRAMANO!")
	textBox.queue_text("¡TODAVIA NO SE ENTIENDE LA CUARTA DIMENSION!")
	textBox.queue_text("Agh, ¿Y ahora que hacemos?")
	textBox.queue_text("¡NO PRESIONE CTRL !")

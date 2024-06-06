extends Node3D

@onready var player = $Player
@onready var audio = $Area3D/AudioStreamPlayer
@onready var anim = $anim
@onready var anim2 = $anim2
@onready var transition = $Control/AnimationPlayer
@onready var timer = $Timer
@onready var textBox = $"../../TextBox"

var monologue = true
var otherMonologue = true
var jujo = false


func _ready():
	timer.set_wait_time(2)
	timer.start()
	
	player.setFreezed(true)
	anim.play("platformsMoving")

func _process(delta):
	
	if textBox.text_queue.is_empty() and textBox.State.FINISHED and monologue:	
		
		if Input.is_action_just_pressed("textInteract"):
			transition.play("transition")
			transition.queue("camera")
			
			monologue = false
			timer.set_wait_time(13)
			timer.start()
			

func _on_area_3d_body_exited(body):
	player.position = Vector3(-10.309,5,-0.333) 
	audio.play()

func _on_trigger_anim_body_entered(body):
	if !jujo:
		anim2.play("eyeTurn")
		jujo = true

func _on_timer_timeout():
	
	if monologue:
		textBox.queue_text("...")
		textBox.queue_text("...")
		textBox.queue_text("Espero que estés satisfecho contigo mismo...")
		textBox.queue_text("Podías quedarte en la habitación, recibir las últimas novedades sobre el desarrollo...")
		textBox.queue_text("Pero tenías que arruinarlo, ¿no?")
		textBox.queue_text("Felicidades, encontraste el contenido oculto de nuestra versión Alpha")
		textBox.queue_text("Para tu pesar, los niveles 4D te plantean desafíos que no puedes superar sin ayuda de la hiperm-")
		textBox.queue_text("O-olvida eso que dije. Me temo que te quedaste atrapado aquí, para siempre...")
		textBox.queue_text("Perdido en un universo tetradimensional...")
		textBox.queue_text("En fin, me temo que iré a ayudar a nuevos usuarios con el tutorial, ¡Nos vemos!")
	else:
		
		textBox.queue_text("(Hmmm… ¿se habrá creído que me fui?)")
		textBox.queue_text("(Parece dispuesto a intentar avanzar...)")
		textBox.queue_text("(Bah, da lo mismo, no tiene forma de descubrir la hipermano…)")
		textBox.queue_text("(Quiero decir, ¿En qué pensaba el diseñador de los controles?)")
		textBox.queue_text("(¿Mantener ctrl con una hiperfigura en la mano?)")
		textBox.queue_text("(¿Transformar la figura que sujeta con movimientos del mouse y la rueda?)")
		textBox.queue_text("(Absurdo...)")
		textBox.queue_text("(Espera... por qué lo está intentan-)")
		textBox.queue_text("¡¿QUIÉN HIZO QUE MI DIÁLOGO INTERNO SE MUESTRE EN PANTALLA?!")
		
		player.setFreezed(false)
	


func _on_exp_body_entered(body):
	if otherMonologue:
		
		# HACER AQUI
		
		otherMonologue = false

extends Node3D

@onready var player = $Player
@onready var audio = $Area3D/AudioStreamPlayer
@onready var anim = $anim
@onready var anim2 = $anim2
@onready var transition = $Control/AnimationPlayer
@onready var timer = $Timer
@onready var textBox = $"../../TextBox"
@onready var theme = $"../AudioStreamPlayer"


var state = 0
var jujo = false


func _ready():
	$Platforms/plat2/TextTrigger.change_state.connect(_change_state)
	
	theme.play()
	timer.set_wait_time(2)
	timer.start()
	
	player.setFreezed(true)
	anim.play("platformsMoving")

func _process(delta):
	
	if textBox.text_queue.is_empty() and textBox.State.FINISHED:
		
		match state:
			1:
				if Input.is_action_just_pressed("textInteract"):
					transition.play("transition")
					transition.queue("camera")
					textBox.hide_textbox()
					state = 2
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
	
	match state:
		0:
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
			
		2: 
			player.setFreezed(false)
			textBox.force_next_text("(Hmmm… ¿se habrá creído que me fui?)")
			timer.set_wait_time(3)
			
		3: 
			textBox.force_next_text("(Parece dispuesto a intentar avanzar...)")
		4:
			textBox.hide_textbox()
		6: 
			textBox.force_next_text("(Quiero decir, ¿En qué pensaba el diseñador de los controles?)")
		7: 
			textBox.force_next_text("(¿Mantener ctrl con una hiperfigura en la mano?)")
		8: 
			textBox.force_next_text("(¿Transformar la figura que sujeta con movimientos del mouse y la rueda?)")
		9: 
			textBox.force_next_text("(Absurdo...)")
		10: 
			timer.set_wait_time(1.5)
			textBox.force_next_text("(Espera... por qué lo está intentan-)")
		11:
			timer.set_wait_time(3)
			textBox.force_next_text("¡¿QUIÉN HIZO QUE MI DIÁLOGO INTERNO SE MUESTRE EN PANTALLA?!")
		12:
			textBox.force_next_text("J-j-¡Jajá, me descubriste!")
		13:
			textBox.force_next_text("Ah, ¿Te sientes listo porque puedes usar la hipermano? ")
		14:
			textBox.force_next_text("Pffft, no me hagas reír... como si supieras lo que estás haciendo...")
		15:
			timer.set_wait_time(5)
			textBox.force_next_text("Aunque no puedas verla, agregamos una nueva dimensión al mundo, a la que llamaremos 'W'")
		16:
			textBox.force_next_text("Usar tus nuevos poderes hace rotaciones que no eran posibles en tres dimensiones.")
		17:
			textBox.force_next_text("Cuando mantienes Ctrl, arrastrar el mouse hará rotaciones en xw y yw")
		18:
			textBox.force_next_text("Del mismo modo, mover la rueda del mouse rotará en zw.")
		19:
			textBox.force_next_text("Pero, seguimos viendo un mundo en tres dimensiones. ¿Adivinas lo que pasa?")
		20:
			textBox.force_next_text("¡Ajá! lo mismo que ocurría con el cubo que rota cuando lo veías en dos dimensiones")
		21:
			textBox.force_next_text("La figura 3D que observas es solamente un corte, una rebanada de toda la figura 4D.")
		22:
			timer.set_wait_time(6)
			textBox.force_next_text("Al cambiar la orientación de la figura, estás alterando la posición y la forma del corte que vemos en el mundo tridimensional.")
		23:
			timer.set_wait_time(1)
			textBox.force_next_text("...")
		24:
			textBox.force_next_text("...")
		25:
			timer.set_wait_time(3)
			textBox.force_next_text("Ni siquiera me estás prestando atención, ¿cierto?")
		26:
			textBox.force_next_text("En fin, dudo que salgas de aquí sin mi ayuda...")
		27:
			textBox.hide_textbox()
	
	if state != 1: state += 1
	if state > 1 and state != 5 and state < 28: timer.start()


func _on_audio_stream_player_finished():
	theme.play()

func _change_state():
	state += 1
	timer.start()

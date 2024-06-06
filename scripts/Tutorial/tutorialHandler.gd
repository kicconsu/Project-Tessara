extends Node3D

@onready var text_box = $TextBox

@onready var red_ball = $redBall

# Animations
@onready var Animations = $Animations
@onready var _2d_anim = $"SecondDimensionQuest/2DAnim"
@onready var anim_explicacion = $Anim/animExplicacion


# Sounds
@onready var expansion_sound = $World/expansionSound
@onready var pop = $World/popSound
@onready var fall = $SecondDimensionQuest/fall
@onready var pop_xd = $"SecondDimensionQuest/pop?xd"

# Player
@onready var player = $Player
@onready var color_rect = $Player/Head/InteractRay/ColorRect

# Camera
@onready var ceilingCamera = $Ceiling/Camera3D
@onready var playerCam = $"Player/Head/eyes"

# Timer
@onready var timer = $World/Timer
@onready var camera_transition = $"Ceiling/cameraTransition"

# Tests
@onready var obstacle = $Obstacle
@onready var labyrinth = $SecondDimensionQuest/Labyrinth

# Second Dimension Quest
@onready var tutbut1 = $"SecondDimensionQuest/2DButtons/TutBut1"
@onready var tutbut2 = $"SecondDimensionQuest/2DButtons/TutBut2"
@onready var tutbut3 = $"SecondDimensionQuest/2DButtons/TutBut3"
@onready var tutbut4 = $"SecondDimensionQuest/2DButtons/TutBut4"
@onready var tutbut5 = $"SecondDimensionQuest/2DButtons/TutBut5"

#@onready var pillar = $SecondDimensionQuest/Pillar

# Global Quest VARs
var current_state = State.Void
var twoDimension = false
var flag = true
var relatedQuest = false 
var questCompleted = false
var questFailed = false
var questFlag = false

var rng = RandomNumberGenerator.new()
var rand = 0
var randomPos = 0

# State funciona de tal manera que se cumpla una secuencia dentro del programa. Si esta en una dimension,
# esta va a tener su "Quest". State cambia acorde al final de los dialogos en un estado.

enum State{
	Void,
	FirstDimension,
	FirstDimensionQuest,
	SecondDimension,
	SecondDimension1stQuest,
	SecondDimension2ndQuest,
	Explaining,
	ThirdDimension,
	ThirdDimensionQuest,
	FourthDimension
}


func _ready():
	
	ceilingCamera.set_current(true)
	player.locked = true
	color_rect.set_visible(false)
			
	text_box.queue_text("¡Hola pequeña bolita!")
	text_box.queue_text("¡Bienvenido a Téssara!")
	text_box.queue_text("Vamos, intenta moverte usando las teclas WASD.")
	text_box.queue_text("Uh oh, parece que es imposible moverse.")
	text_box.queue_text("¡Ah! Ya se lo que pasa.")
	text_box.queue_text("Actualmente no estamos residiendo en ninguna dimension.")
	text_box.queue_text("¡Dejame ayudarte extendiendo nuestro espacio!")
	
func _process(_delta):
	
	if State.SecondDimension1stQuest:
		if questFailed and questFlag and flag:
			if tutbut1 != null:
				tutbut1.nuke()
			if tutbut2 != null:
				tutbut2.nuke()
				
			relatedQuest = true
			questFailed = false
			questFlag = false
				
			labyrinth.nuke()
			change_state()
			timer.emit_signal("timeout")
			flag = false
		
		if questCompleted and flag:
			timer.stop()
			flag = false
			questCompleted = false
			questFailed = false
			questFlag = false
			relatedQuest = true
			change_state()
			timer.emit_signal("timeout")


	# Cuando no hay mas dialogos en un estado, significa que seguira la secuencia de State
	if text_box.text_queue.is_empty() and text_box.State.FINISHED:	
		
		if Input.is_action_just_pressed("textInteract"):
			match current_state:
				
				State.Void:
					expansion_sound.play()
					timer.set_wait_time(2)
					timer.start()
					change_state()
					
				State.FirstDimension:
					if relatedQuest:
						red_ball.set_position(Vector3(5, 0.08, 0))
						timer.set_wait_time(5)
						timer.start()
						change_state()
						relatedQuest = false

				State.FirstDimensionQuest:
					if relatedQuest:
						expansion_sound.set_pitch_scale(0.7)
						expansion_sound.play()
						twoDimension = true
						timer.set_wait_time(2)
						timer.start()
						change_state()
						relatedQuest = false
						
				State.SecondDimension:
					if relatedQuest:
						timer.set_wait_time(2)
						timer.start()
						change_state()
						relatedQuest = false
				
				State.SecondDimension1stQuest:
					if relatedQuest:		

						timer.set_wait_time(20)
						timer.start()
						
						Animations.play("Labyrinth")
						red_ball.nuke()
						
						labyrinth.set_visible(true)
						tutbut1.set_visible(true)
						tutbut2.set_visible(true)
															
						var t1 = get_tree().create_tween()
						var t2 = get_tree().create_tween()
						var t3 = get_tree().create_tween()
						
						t1.tween_property(tutbut1, "scale", Vector3(1,1,1), 1).set_ease(Tween.EASE_IN_OUT)
						t2.tween_property(tutbut2, "scale", Vector3(1,1,1), 1).set_ease(Tween.EASE_IN_OUT)
						t3.tween_property(player, "position", Vector3(0.2,1,1), 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
											
						tutbut1.translate(Vector3(0,-6,0))
						tutbut2.translate(Vector3(0,-6,0))
					
						relatedQuest = false
						questFailed = true
						
				State.SecondDimension2ndQuest:
					
					if questFlag:
						anim_explicacion.play("animSlide")
						anim_explicacion.queue("plainExtend")
						anim_explicacion.queue("cubeRotation")
						
						questFlag = false
						
						change_state()
						timer.set_wait_time(7)
						timer.start()
						
						
											
					if relatedQuest:
						Animations.play("pillarRise")
						_2d_anim.play("tutbutRise")
						
						relatedQuest = false
				
				State.Explaining:
					
					if questFailed:
						anim_explicacion.play("plainShrink")
						anim_explicacion.queue("animExit")
						_2d_anim.play("butRise")
						questFailed = false
					
					if relatedQuest:
						timer.set_wait_time(2)
						timer.start()
						questFlag = true
						anim_explicacion.play("cubeTranslate")
						relatedQuest = false
				
				State.ThirdDimension:
					if relatedQuest:
						timer.set_wait_time(2)
						timer.start()
						Animations.play("obstacleRise")
						change_state()
						relatedQuest = false	
					
				State.ThirdDimensionQuest:
					
					
					if relatedQuest:
						Animations.play("blink")
						player.locked = false
						
						questFailed = true
						timer.set_wait_time(2)
						timer.start()

						camera_transition.start()
						relatedQuest = false
					
func change_state():
	match current_state:
		State.Void: # De 0D a 1D
			current_state = State.FirstDimension
			Animations.play("extendWalls Left & Right")
		State.FirstDimension:	# De 1D a 1DQuest
			current_state = State.FirstDimensionQuest
		State.FirstDimensionQuest:	# De 1DQuest a 2D
			current_state = State.SecondDimension
			Animations.play("extendWalls Up & Down")
		State.SecondDimension:	# De 2D a 2DQuest
			current_state = State.SecondDimension1stQuest
		State.SecondDimension1stQuest:	# De 2DQuest a 3D
			current_state = State.SecondDimension2ndQuest
		State.SecondDimension2ndQuest:
			current_state = State.Explaining
		State.Explaining:
			current_state = State.ThirdDimension
		State.ThirdDimension:
			current_state = State.ThirdDimensionQuest
	
# Carga de dialogos
func _on_timer_timeout(): 
	match current_state:
		State.FirstDimension:
			text_box.queue_text("Y... ¡Voilá!")
			text_box.queue_text("¿Que te parece? ¡Ahora eres libre!")
			text_box.queue_text("¿Que tal este pequeño juego? ¡Toca la bola roja la mayor cantidad de veces!")		
			relatedQuest = true
		State.FirstDimensionQuest:
			text_box.queue_text("Que... divertido...")
			text_box.queue_text("Ah, ¡Ya se!")
			text_box.queue_text("Intenta agarrar la bola roja ahora")
			relatedQuest = true
		State.SecondDimension:
			text_box.queue_text("Perfecto")
			text_box.queue_text("Ahora si podemos movernos mejor")
			text_box.queue_text("¡Intenta ir mas rapido con SHIFT!")
			relatedQuest = true
		State.SecondDimension1stQuest:
			if !questFailed:
				text_box.queue_text("Juguemos este juego, trata de tocar ambos botones en el menor tiempo posible")
				relatedQuest = true
			elif questFailed and !questCompleted:
				text_box.queue_text("Oh, parece que te tardastes un poco.")
				text_box.queue_text("Tranquilidad, no pasa nada.")
				relatedQuest = true
				questFlag = true
		State.SecondDimension2ndQuest:
			if !questFlag:
				text_box.queue_text("¿Que tal mi pequeño laberinto?")
				text_box.queue_text("Aunque no se le puede llamar laberinto a esto...")
				text_box.queue_text("Bueno, intentemos otra cosa")
				text_box.queue_text("Trata de tocar ambos botones, y puedes ignorar ese cuadrado blanco...")
				relatedQuest = true
			else:
				text_box.queue_text("Parece que no puedes tocar el siguiente boton")
				text_box.queue_text("Bueno, falta entender algo.")
				text_box.queue_text("Voy a explicarte acerca de las analogias dimensionales")
				
		State.Explaining:
			
			if !questFlag:
				text_box.queue_text("Por un momento se alcanzo a ver un cuadrado. Pero empezo a deformarse ¿Lo que parece raro verdad?")
				text_box.queue_text("Un objeto 2D solo ve 'cortes' de un objeto 3D, por lo que significa...")
				text_box.queue_text("¡Los objetos 3D estan compuestos de objetos 2D!")
				text_box.queue_text("Voy a atravesar un objeto 3D en nuestro plano para que logres entender mejor")
				relatedQuest = true
			else:
				text_box.queue_text("Estoy atravesando un cubo adentro y fuera de nuestro espacio de 2 dimensiones")
				text_box.queue_text("¿Notas que cuando lo roto se ve como un triangulo?")
				text_box.queue_text("Es debido a que solo vemos los cortes que atraviesan nuestro espacio")
				text_box.queue_text("Este espacio 2D es una extension de la 1era Dimension")
				text_box.queue_text("Añadimos otro eje para movernos, y si queremos pasar de dimension...")
				text_box.queue_text("Toca extender nuestro espacio hacia otro eje")
				text_box.queue_text("Objetos de dimensiones mas altas estan compuestos de objetos de una dimension menor")
				text_box.queue_text("¿Interesante verdad? ¡Solo imagina las posibilidades!")
				questFailed = true
		State.ThirdDimension:
			text_box.queue_text("Te preguntarás ¿Que acaba de pasar?")
			text_box.queue_text("Lo verás luego.")
			text_box.queue_text("Diviertete un poco con esto.")
			relatedQuest = true
			
		State.ThirdDimensionQuest:
			if !questFailed:
				text_box.queue_text("Bueno ¿Tal parece que es un cuadrado común y corriente no?")
				text_box.queue_text("Lo que vas a ver a continuación bolita, te va a volar la cabeza")
				relatedQuest = true
			else:
				text_box.queue_text("¡3 Dimensiones! ¡Bienvenida bolita! o deberia decir...")
				text_box.queue_text("Como sea, mueve el MOUSE y salta con ESPACIO para avanzar")
				text_box.queue_text("Adentrate dentro del cubo y revisa...")
			
# Cada vez que el Player colisione con la bola, esta aparece en otro lugar random
func _on_red_ball_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
				
	pop.play()
	rng.randomize()
	rand = rng.randi_range(0,1)
			
	if rand == 0:
		randomPos = rng.randi_range(-12, -4)
	else:
		randomPos = rng.randi_range(4, 12)
			
	if !twoDimension:				
		red_ball.set_position(Vector3(randomPos, 0.08, 0))
	else:
		red_ball.set_position(Vector3(randomPos, 0.08, rng.randi_range(-5, 5)))
	
func _on_camera_transition_timeout():
	CameraTransition.transition_camera3D(ceilingCamera, playerCam, 3.0)
	player.mouseToggle = true

func _on_tut_but_1_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	pop_xd.play()
	Animations.play("Labyrinth_Anim_But1")	
	tutbut1.nuke()
	tutbut1.translate(Vector3(0,6,0))
	
	if tutbut2 == null:
		labyrinth.nuke()
		questCompleted = true

func _on_tut_but_2_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	pop_xd.play()
	Animations.play("Labyrinth_Anim_But2")	
	tutbut2.nuke()
	tutbut2.translate(Vector3(0,6,0))
	
	if tutbut1 == null:
		labyrinth.nuke()
		questCompleted = true

func _on_tut_but_3_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	timer.set_wait_time(1)
	timer.start()
	tutbut3.nuke()
	pop_xd.play()
	questFlag = true

func _on_tut_but_4_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	tutbut4.nuke()
	pop_xd.play()
	change_state()
	timer.emit_signal("timeout")

func _on_tut_but_5_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	tutbut5.nuke()
	pop_xd.play()
	Animations.play("pillarFall")
	fall.play()	

extends Node3D

@onready var text_box = $TextBox
@onready var expansion_sound = $World/expansionSound
@onready var pop = $World/popSound
@onready var red_ball = $redBall

# Animations
@onready var Animations = $Animations

# Player
@onready var player = $Player

# Camera
@onready var ceilingCamera = $Ceiling/Camera3D
@onready var playerCam = $"Player/Head/playerCam"

# Timer
@onready var timer = $World/Timer
@onready var camera_transition = $"Ceiling/cameraTransition"

# Tests
@onready var obstacle = $Obstacle
@onready var labyrinth = $SecondDimensionQuest/Labyrinth

# Second Dimension Quest
@onready var tutbut1 = $SecondDimensionQuest/TutBut1
@onready var tutbut2 = $SecondDimensionQuest/TutBut2


var current_state = State.Void
var twoDimension = false
var relatedQuest = false 

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
	SecondDimensionQuest,
	ThirdDimension,
	ThirdDimensionQuest,
	FourthDimension
}


func _ready():
	
	print(Input.get_mouse_mode())
	
	# Carga de dialogos para la primera dimension 
			
	text_box.queue_text("¡Hola pequeña bolita!")
	#text_box.queue_text("Vamos, intenta moverte usando las teclas WASD.")
	#text_box.queue_text("Uh oh, parece que es imposible moverse.")
	#text_box.queue_text("¡Ah! Ya se lo que pasa.")
	#text_box.queue_text("Actualmente no estamos residiendo en ninguna dimension.")
	#text_box.queue_text("¡Dejame ayudarte extendiendo nuestro espacio!")
	
func _process(_delta):
	
	#if current_state == State.SecondDimensionQuest:
		#print("lab",labyrinth)
		#print("tb1",tutbut1)
		#print("tb2",tutbut2)
	
	if Input.is_action_just_pressed("test"):
		#obstacle.set_freeze_enabled(false)
		#Animations.play("Labyrinth")
		#labyrinth.set_visible(true)
		labyrinth.nuke()
		pass
	
	# Al presionar C cambia a primera persona
	if Input.is_action_just_pressed("changeState"):
		Animations.play("blink")
		camera_transition.start()
	
	# Al presionar Esc aparece o desaparece el cursor
	if Input.is_action_just_pressed("exit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
			
	
	# Cuando no hay mas dialogos en un estado, significa que seguira la secuencia de State
	if text_box.text_queue.is_empty():
		
		if Input.is_action_just_pressed("textInteract"):
			match current_state:
				
				State.Void:
					expansion_sound.play()
					timer.set_wait_time(3)
					timer.start()
					change_state()
					
				State.FirstDimension:
					if relatedQuest:
						red_ball.set_position(Vector3(5, 0.08, 0))
						timer.set_wait_time(3)
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
				
				State.SecondDimensionQuest:
				
					if relatedQuest:
						
						Animations.play("Labyrinth")
						
						red_ball.nuke()
						
						labyrinth.set_visible(true)
						tutbut1.set_visible(true)
						tutbut2.set_visible(true)
															
						var t1 = get_tree().create_tween()
						var t2 = get_tree().create_tween()
						
						t1.tween_property(tutbut1, "scale", Vector3(1,1,1), 1).set_ease(Tween.EASE_IN_OUT)
						t2.tween_property(tutbut2, "scale", Vector3(1,1,1), 1).set_ease(Tween.EASE_IN_OUT)
											
						tutbut1.translate(Vector3(0,-6,0))
						tutbut2.translate(Vector3(0,-6,0))
						relatedQuest = false



func change_state():
	match current_state:
		State.Void: # De 0D a 1D
			current_state = State.FirstDimension
			Animations.play("extendWalls Left & Right")
		State.FirstDimension:	# De 1D a 1DQuest
			current_state = State.FirstDimensionQuest
			pass
		State.FirstDimensionQuest:	# De 1DQuest a 2D
			current_state = State.SecondDimension
			Animations.play("extendWalls Up & Down")
			pass
		State.SecondDimension:	# De 2D a 2DQuest
			current_state = State.SecondDimensionQuest
			pass
	
# Carga de dialogos
func _on_timer_timeout(): 
	match current_state:
		State.FirstDimension:
			text_box.queue_text("Y... ¡Voilá!")
			#text_box.queue_text("¿Que te parece? ¡Ahora eres libre!")
			#text_box.queue_text("¿Que tal este pequeño juego? ¡Toca la bola roja la mayor cantidad de veces!")		
			relatedQuest = true
		State.FirstDimensionQuest:
			text_box.queue_text("Que... divertido...")
			#text_box.queue_text("Ah, ¡Ya se!")
			#text_box.queue_text("Intenta agarrar la bola roja ahora")
			relatedQuest = true
		State.SecondDimension:
			text_box.queue_text("Perfecto")
			#text_box.queue_text("Ahora si podemos movernos mejor")
			#text_box.queue_text("¡Intenta ir mas rapido con SHIFT!")
			relatedQuest = true
		State.SecondDimensionQuest:
			text_box.queue_text("Te presento este espacio de 2 dimensiones ¿Ves que es facil moverse?")
			#text_box.queue_text("Pero... puedes tratar de agarrar la bola...")
			#text_box.queue_text("¿Donde esta la pelota?")
			#text_box.queue_text("¿Cambiamos de dimension?")
			relatedQuest = true
					
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
	pass # Replace with function body.


func _on_tut_but_1_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	# Ocurre Anim 1
	Animations.play("Labyrinth_Anim_But1")
	
	tutbut1.translate(Vector3(0,6,0))
	
	tutbut1.queue_free()
	
	
	if tutbut2 == null:
		
		labyrinth.nuke()
		
	

func _on_tut_but_2_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	# Ocurre Anim 2
	Animations.play("Labyrinth_Anim_But2")
	
	tutbut2.translate(Vector3(0,6,0))
	
	tutbut2.queue_free()
	
	if tutbut1 == null:
		labyrinth.nuke()
		
	
		
	

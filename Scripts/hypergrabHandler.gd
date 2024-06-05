extends Node
@onready var player = $World/Player
@onready var audio = $World/Area3D/AudioStreamPlayer
@onready var anim = $World/anim
@onready var anim2 = $World/anim2
@onready var transition = $World/Control/AnimationPlayer
@onready var timer = $World/Timer
@onready var textBox = $"../TextBox"

var jujo = false

var shapesInScene:Array[Node]
# Called when the node enters the scene tree for the first time.
func _ready():
	
	timer.set_wait_time(12)
	timer.start()
	
	player.setFreezed(true)
	transition.play("transition")
	transition.queue("camera")
	anim.play("platformsMoving")
	
	player.enable_hyper_inspection.connect(_enable_hyper_inspection) #Connect the signal that the player will emit 
	player.disable_hyper_inspection.connect(_disable_hyper_inspection)
	shapesInScene = get_tree().get_nodes_in_group("hyperShapes")

func _enable_hyper_inspection():
	for shape in shapesInScene:
		shape.colorOnInspection()

func _disable_hyper_inspection():
	for shape in shapesInScene:
		shape.colorFromScratch()

func _on_area_3d_body_exited(body):
	player.position = Vector3(-10.309,5,-0.333) 
	audio.play()

func _on_trigger_anim_body_entered(body):
	if !jujo:
		anim2.play("eyeTurn")
		jujo = true

func _on_timer_timeout():
	player.setFreezed(false)
	
	textBox.queue_text("...")
	textBox.queue_text("Parece que conseguiste la ultramano... Mira... Por nada del mundo...")
	textBox.queue_text("...")
	textBox.queue_text("¡¡Agarres una figura, presiones CTRL y muevas para cambiar su seccion transversal de 4 dimensiones!!")

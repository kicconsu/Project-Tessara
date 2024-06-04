extends Node3D

enum State{
	NONE,
	INITIAL,
	CHAMBER,
	ESCAPE,
	HYPER_ROOM,
	PUZZLE,
	HYPERGRAB
}

var level_state
@onready var player = $Player
@onready var chamber = $StartingChamber
@onready var timer = $Timer
@onready var textBox = $TextBox

var movingHypershapes
var fillerBool
var sub_state

func _ready():
	level_state = State.NONE
	_change_state()
	
	var triggerAreas = get_tree().get_nodes_in_group("TriggerArea")
	for area in triggerAreas:
		if area.change_scene_state:
			area.change_state.connect(_change_state)
	
	movingHypershapes = $HyperGrabRoom/Hypershapes.get_children()
	$HyperGrabRoom/TriggerAreas/MovementTrigger3.addTarget($HyperGrabRoom/Hypershapes/Hypershape4)
	$HyperGrabRoom/TriggerAreas/MovementTrigger2.addTarget($HyperGrabRoom/Hypershapes/Hypershape3)
	$HyperGrabRoom/TriggerAreas/MovementTrigger2.addTarget($HyperGrabRoom/Hypershapes/Hypershape5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if textBox.text_queue.is_empty() and textBox.State.FINISHED:	
			if Input.is_action_just_pressed("textInteract"):
				match level_state:
					State.INITIAL:
						textBox.text_queue.clear()
						_change_state()
	
	match level_state:
		State.CHAMBER:
			if player.target_shape != null and !fillerBool:
					fillerBool = true
					textBox.force_next_text("Un momento... ¿Qué hace eso ahí?")
	
	

func _change_state():
	match level_state:
		State.NONE:
			player.set_global_position(chamber.get_global_position() + Vector3(0,10,0))
			player.setFreezed(true)
			level_state = State.INITIAL
			_load_dialog()
		State.INITIAL:
			player.setFreezed(false)
			level_state = State.CHAMBER
		State.CHAMBER:
			level_state = State.ESCAPE
		State.ESCAPE:
			sub_state = 0
			
			timer.set_wait_time(1.5)
			timer.start()
			
			level_state = State.HYPER_ROOM
		State.HYPER_ROOM:
			sub_state = -1
			
			for shape in movingHypershapes:
				shape.set_freeze_enabled(false)
		
			level_state = State.PUZZLE
		State.PUZZLE:
			level_state = State.HYPERGRAB

# Carga de dialogos
func _load_dialog(): 
	match level_state:
		State.INITIAL:
			textBox.queue_text("Bueno... ese es nuestro tutorial... ¿Te gustó?")
			textBox.queue_text("...¿Cómo dices?")
			textBox.queue_text("¿Dónde está la cuarta dimensión? ...me temo que es muy pronto para eso.")
			textBox.queue_text("Oye, no me mires así, necesitábamos llamar la atención en la feria")
			textBox.queue_text( "Ya sé, puedes quedarte aquí en los 5 años restantes de desarrollo :D")
			textBox.queue_text("Te soltaré, ¡Nos vemos!")


func _on_timer_timeout():
	match level_state:
		State.HYPER_ROOM:
			match sub_state:
				0:
					textBox.force_next_text("Uff, eso estuvo cerca...")
					timer.set_wait_time(0.9)
				1:
					textBox.force_next_text("Menos mal que-")
					timer.set_wait_time(3)
					_change_state()
			sub_state += 1
		State.PUZZLE:
			match sub_state:
				0:
					textBox.force_next_text("Por Dios, ¿Quién programó este sistema de emergencia?")
				1: 
					textBox.force_next_text("De seguro fue Juan Diego...")
				2:
					textBox.text_queue.clear()
					textBox.hide_textbox()
					timer.stop()
			sub_state += 1

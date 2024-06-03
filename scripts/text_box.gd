extends Control

@onready var textbox_container = $TextboxContainer
@onready var start = $TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label
@onready var end = $TextboxContainer/MarginContainer/HBoxContainer/End
@onready var tween = get_tree().create_tween()
@onready var audio = $AudioStreamPlayer

const CHAR_READ_RATE = 0.04

# 3 estados del textbox

enum State{
	READY,
	READING,
	FINISHED	
}

var current_state = State.READY
var text_queue = []
var a = ""

var eventOcurring = false

func _ready():
	
	#print("Starting state to READY")
	hide_textbox()
	
func _process(_delta):
	match current_state:
		State.READY:	
			# Audio Start
			audio.play()
			
			# Si existe algo dentro de la lista, se llama display_text para que lo muestre en pantalla
			
			if text_queue.is_empty() == false:
				display_text()				
				
		State.READING:		
			
			# Al presionar Enter, omite todo el texto hasta el final
			
			if Input.is_action_just_pressed("textInteract"):
				if !eventOcurring:
					tween.kill()
					label.visible_characters = -1
					end.text = "<-"
					change_state(State.FINISHED)		
					
		State.FINISHED:
			# Audio End		
			audio.play(false)
			
			# Vuelve a cambiar el estado a Ready
			
			if Input.is_action_just_pressed("textInteract"):				
				change_state(State.READY)
				hide_textbox()		
			

# Hace que el dialogo se integre al final de la lista
func queue_text(next_text):
	text_queue.push_back(next_text)
	
func hide_textbox():
	start.text = ""
	label.text = ""
	end.text = ""
	textbox_container.hide()

func show_textbox():
	start.text = "*"
	textbox_container.show()

func display_text():
	
	# Se crea una variable de interpolacion para que se muestre gradualmente el texto
	
	tween = get_tree().create_tween()
	var next_text = text_queue.pop_front()
	label.text = next_text
	change_state(State.READING)
	show_textbox()
		
	tween.tween_property(label, "visible_characters", len(next_text), len(next_text) * CHAR_READ_RATE).from(0).finished
	tween.connect("finished", on_tween_finished)
	end.text = "..." 


func on_tween_finished():
	end.text = "v"
	change_state(State.FINISHED)

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			#print("Changing state to READY")
			pass
		State.READING:
			#print("Changing state to READING")				
			pass
		State.FINISHED:		
			#print("Changing state to FINISHED")		
			pass

class_name Trigger
extends Node3D

signal interacted()

@export var prompt_message = "Interact"
@export var prompt_action = "interact"

@export var target: Node3D
@export var destination: Vector3 = Vector3(0,0,0)
@export var rotate: Vector3 = Vector3(0,0,0)
@export var translateDuration: float
@export var rotationDuration: float

func get_prompt():	
	var key_name = ""
	for action in InputMap.action_get_events(prompt_action):
		if action is InputEventKey:
			key_name = OS.get_keycode_string(action.physical_keycode)
	return prompt_message + "\n[" + key_name +"]"
	
func interact():
	# Emite una señal a los hijos de trigger
	# Esta señal solo lo pueden conectar los hijos de Trigger, y crean la funcion on_interacted()
	interacted.emit()



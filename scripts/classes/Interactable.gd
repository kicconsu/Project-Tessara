class_name Interactable
extends StaticBody3D

@export var prompt_message = "Interact"
@export var prompt_action = "interact"


# Called when the node enters the scene tree for the first time.as
func get_prompt():
	var key_name = ""
	for action in InputMap.action_get_events(prompt_action):
		if action is InputEventKey:
			key_name = OS.get_keycode_string(action.physical_keycode)
	return prompt_message + "\n["+ key_name +"]"

func interact(body):
	print(body.name, " interacted!")

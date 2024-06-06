extends ColorRect

func _ready():
	material.set_shader_parameter("correction_mode", UpdateFilter.NumFilter)

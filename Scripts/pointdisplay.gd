extends Label

@onready var world = $"../../Root/Viewport/World"

func _process(_delta):
	self.set_text(str(world.getPoints()))

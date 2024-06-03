extends Node3D
@onready var player = $Player
@onready var text_box = $"../../TextBox"

var shapesInScene:Array[Node]
# Called when the node enters the scene tree for the first time.
func _ready():
	
	text_box.queue_text("EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE")
	
	
	player.hyper_inspection.connect(_toggle_hyper_inspection) #Connect the signal that the player will emit 
	shapesInScene = get_tree().get_nodes_in_group("hyperShapes")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _toggle_hyper_inspection():
	var enabled = player.isInspectionEnabled()
	var blue_scale_factor = 0.125 if enabled else 8.0
	player.setInspectionEnabled(not enabled)
	for shape in shapesInScene:
		var color:Vector3 = shape.getColor()
		shape.setColor(Vector3(color.x, color.y, color.z * blue_scale_factor))

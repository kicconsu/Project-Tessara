extends Node3D
@onready var player = $Player
var shapesInScene:Array[Node]
# Called when the node enters the scene tree for the first time.
func _ready():
	player.enable_hyper_inspection.connect(_enable_hyper_inspection) #Connect the signal that the player will emit 
	player.disable_hyper_inspection.connect(_disable_hyper_inspection)
	shapesInScene = get_tree().get_nodes_in_group("hyperShapes")

func _enable_hyper_inspection():
	player.setInspectionEnabled(true)
	for shape in shapesInScene:
		shape.colorOnInspection()

func _disable_hyper_inspection():
	player.setInspectionEnabled(false)
	for shape in shapesInScene:
		shape.colorFromScratch()

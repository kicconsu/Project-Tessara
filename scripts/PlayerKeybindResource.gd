class_name PlayerKeybindResource
extends Resource

const MOVE_LEFT : String = "left"
const MOVE_RIGHT : String = "right"
const MOVE_UP : String = "up"
const MOVE_DOWN : String = "down"

@export var DEFAULT_MOVE_LEFT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_RIGHT_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_UP_KEY = InputEventKey.new()
@export var DEFAULT_MOVE_DOWN_KEY = InputEventKey.new()

var move_left_key = InputEventKey.new()
var move_right_key = InputEventKey.new()
var move_up_key = InputEventKey.new()
var move_down_key = InputEventKey.new()

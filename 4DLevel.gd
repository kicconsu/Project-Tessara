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

func _ready():
	level_state = State.NONE
	self.change_state()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_state():
	match level_state:
		State.NONE:
			player.set_global_position(chamber.get_global_position() + Vector3(0,7.5,0))
			player.setFreezed(true)
			timer.set_wait_time(2)
			timer.start()
			var tween = get_tree().create_tween()
			tween.tween_property(player, "position", Vector3(0,1,0), 8).set_ease(Tween.EASE_IN_OUT)
			level_state = State.INITIAL
		State.INITIAL:
			player.setFreezed(false)

# Carga de dialogos
func _on_timer_timeout(): 
	match level_state:
		State.INITIAL:
			textBox.queue_text("Bueno... ese es nuestro tutorial... ¿Te gustó?")
			#textBox.queue_text("...¿Cómo dices?")
			#textBox.queue_text("¿Dónde está la cuarta dimensión? ...me temo que es muy pronto para eso.")
			#textBox.queue_text("Oye, no me mires así, necesitábamos llamar la atención en la feria")
			#textBox.queue_text( "Ya sé, puedes quedarte aquí en los 5 años restantes de desarrollo :D")
			#textBox.queue_text("Te soltaré, ¡Nos vemos!")
		State.CHAMBER:
			#textBox.queue_text("Un momento... ¿Qué hace eso ahí?")
			textBox.queue_text("Ay no... ¡Espera, no entres!")
		State.ESCAPE:
			textBox.queue_text("Tienes que detenerte ahora mismo, no lo entiendes...")
			#textBox.queue_text("No estamos preparados, el 4D es muy complejo...")
			#textBox.queue_text("Ya sé, ¡Toma! suerte moviendo esta figura")
			#textBox.queue_text("¡¿Qué?!...")
			#textBox.queue_text("NOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
		State.HYPER_ROOM:
			textBox.queue_text("Uff, eso estuvo cerca. Menos mal que-")
			#textBox.queue_text("Por Dios, ¿Quién programó este sistema de emergencia?")
		State.PUZZLE:
			textBox.queue_text("De seguro fue Juan Diego...")
			textBox.queue_text("No me dejas de otra, tendré que detenerte con puzzles...")
			textBox.queue_text("")

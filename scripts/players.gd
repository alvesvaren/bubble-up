extends Node2D

@onready var player = load("res://scenes/player.tscn")

var players: Array[int] = []

func process_before():
	for joypad in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(joypad, JOY_BUTTON_A) and joypad not in players:
			join_player(joypad)
		if Input.is_joy_button_pressed(joypad, JOY_BUTTON_START) and joypad in players:
			Manager.set_state.emit(Manager.DURING)
	if Input.is_action_just_pressed("kb_p1_left") and -1 not in players:
		join_player(-1)
	if Input.is_action_just_pressed("start") and -1 in players:
		Manager.set_state.emit(Manager.DURING)

func _process(delta: float) -> void:
	pass


func join_player(id) -> void:
	print("Player ", id, " joined")
	var new_player = player.instantiate()
	new_player.player_index = id
	add_child(new_player)
	players.append(id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.process_before.connect(process_before)

extends Node2D

@onready var player = load("res://scenes/player.tscn")

var players: Array[int] = []

func process_before(delta):
	for joypad in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(joypad, JOY_BUTTON_A) and joypad not in players:
			join_player(joypad)
		if Input.is_joy_button_pressed(joypad, JOY_BUTTON_START) and not $"../music/countdown".playing:
			countdown()

	for i in range(1, 3):
		if Input.is_action_just_pressed("kb_p" + str(i) + "_left") and - i not in players:
			join_player(- i)
		if Input.is_action_just_pressed("start") and - i in players and not $"../music/countdown".playing:
			countdown()

func countdown():
	$"../music".stop()
	$"../music/intro2".stop()
	$"../music/countdown".play()
	$"../map/Camera2D/countdown från 3".visible = true
	$"../map/Camera2D/countdown från 3".play("count")

func join_player(id) -> void:
	print("Player ", id, " joined")
	var new_player = player.instantiate()
	new_player.player_index = id
	add_child(new_player)
	players.append(id)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.process_before.connect(process_before)


func _on_countdown_finished() -> void:
	Manager.set_state.emit(Manager.DURING)

extends Node


enum {BEFORE, DURING, AFTER}
var state = BEFORE
var players = []
@onready var player = load("res://scenes/player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("hej")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		BEFORE:
			for joypad in Input.get_connected_joypads():
				if Input.is_joy_button_pressed(joypad, JOY_BUTTON_A) and joypad not in players:
					join_player(joypad)
				if Input.is_joy_button_pressed(joypad, JOY_BUTTON_START) and joypad in players:
					state = DURING
			if Input.is_action_just_pressed("kb_p1_left") and -1 not in players:
				join_player(-1)
			if Input.is_action_just_pressed("start") and -1 in players:
				state = DURING
		DURING:
			pass
		AFTER:
			pass


func join_player(id) -> void:
	var new_player = player.instantiate()
	new_player.player_index = id
	get_tree().root.add_child(new_player)
	players.append(id)

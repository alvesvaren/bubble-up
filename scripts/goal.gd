extends Area2D


var placement = null

func _ready() -> void:
	Manager.set_state.connect(reset)
	Manager.process_after.connect(check_restart)

func reset(state) -> void:
	if state == Manager.DURING:
		placement = []

func _on_body_entered(body: Node2D) -> void:
	if body.player_index not in placement:
		placement.append(body.player_index)
		if len(placement) == 1:
			print("Player " + str(placement[0]) + " is the winner!")
			Manager.set_state.emit(Manager.AFTER)


func check_restart(delta):
	for joypad in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(joypad, JOY_BUTTON_START):
			get_tree().reload_current_scene()
			Manager.set_state.emit(Manager.BEFORE)
	if Input.is_action_just_pressed("start"):
		get_tree().reload_current_scene()
		Manager.set_state.emit(Manager.BEFORE)

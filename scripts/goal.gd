extends Area2D


var placement = null

func _ready() -> void:
	Manager.set_state.connect(reset)

func reset(state) -> void:
	if state == Manager.DURING:
		placement = []

func _on_body_entered(body: Node2D) -> void:
	if body.player_index not in placement:
		placement.append(body.player_index)
		if len(placement) == 1:
			print("Player " + str(placement[0]) + " is the winner!")
			Manager.set_state.emit(Manager.AFTER)

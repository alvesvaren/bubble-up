extends Area2D


var placement = null

func _ready() -> void:
	Manager.process_before.connect(reset)

func reset() -> void:
	placement = []

func _on_body_entered(body: Node2D) -> void:
	if body.player_index not in placement:
		placement.append(body.player_index)
		if len(placement) == 1:
			print("Player " + str(placement[0]) + " is the winner!")

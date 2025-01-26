extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.laps += 1
		print(body.laps, "Yippi")

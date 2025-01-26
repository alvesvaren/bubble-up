extends Area2D


var players = []

@export var stream_speed = 100

func _physics_process(delta: float) -> void:
	for player in players:
		player.velocity += stream_speed * Vector2(1, 0).rotated(global_rotation)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		players.append(body)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		players.erase(body)

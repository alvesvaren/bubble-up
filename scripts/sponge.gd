extends Area2D


func _on_body_entered(body: Node2D) -> void:
	var normal: Vector2 = $RayCast2D.target_position.normalized()
	var angle = normal.angle_to_point(body.velocity)
	body.velocity = 2 * normal.rotated(- angle) * body.velocity.length()

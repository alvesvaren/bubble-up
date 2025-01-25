extends Area2D

var active = true;

func _on_body_entered(body: Node2D) -> void:
	if body is Player and active:
		active = false
		body.stun(1, global_position)
		$bubble.play("burst")
		await $bubble.animation_finished
		queue_free()

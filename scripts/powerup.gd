extends Area2D

var active = true;

func _on_body_entered(body: Node2D) -> void:
	if body is Player and active:
		active = false
		body.velocity *= 3
		$"stjärna aseprite".play("burst")
		await $"stjärna aseprite".animation_finished
		queue_free()

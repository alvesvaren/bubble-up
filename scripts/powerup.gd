extends Area2D

var active = true;

enum {SPEED, BUBBLE, SHIELD}

func _on_body_entered(body: Node2D) -> void:
	if body is Player and active:
		active = false
		match BUBBLE:
			SPEED:
				body.velocity *= 3
			BUBBLE:
				body.bubble = true
			SHIELD:
				body.start_shield()
		$"stjärna aseprite".play("burst")
		await $"stjärna aseprite".animation_finished
		queue_free()

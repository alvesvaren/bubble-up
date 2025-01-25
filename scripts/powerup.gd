extends Area2D
class_name BubbleUp

var active = true;

enum BU {SPEED, BUBBLE, SHIELD}

const choices = [BU.SPEED, BU.BUBBLE, BU.SHIELD]

func _on_body_entered(body: Player) -> void:
	if body is Player and active:
		active = false
		var choice = choices.pick_random()
		body.collect_bu.emit(choice)
		$"stjärna aseprite".play("burst")
		await $"stjärna aseprite".animation_finished
		queue_free()

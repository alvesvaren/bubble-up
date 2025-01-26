extends Area2D
class_name BubbleUp

var active = true;
@export var bubble_up_sound: PackedScene
@export var bubble_up_text: PackedScene

enum BU {SPEED, BUBBLE, SHIELD}

const choices = [BU.SPEED, BU.BUBBLE, BU.SHIELD]

func _on_body_entered(body: Player) -> void:
	if body is Player and active:
		active = false
		var choice = choices.pick_random()
		body.collect_bu.emit(choice)
		get_parent().add_child(bubble_up_sound.instantiate())
		var text = bubble_up_text.instantiate()
		text.global_position = global_position + Vector2(10, 20)
		get_parent().add_child(text)
		$"stjärna aseprite".play("burst")
		await $"stjärna aseprite".animation_finished
		visible = false
		$Timer.start()


func _on_timer_timeout() -> void:
	visible = true
	$"stjärna aseprite".play("shimmer")
	active = true

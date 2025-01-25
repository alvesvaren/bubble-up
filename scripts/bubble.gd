extends Area2D

var active = true;
var player = null;
var vel = 0;

const FLOAT_ACC = -100;

func _on_body_entered(body: Node2D) -> void:
	if body is Player and active and active and not body.shield:
		active = false
		body.caught = true
		player = body
		$Timer.start()
	elif body is not Player:
		vel = 0
		active = true
		burst()

func _physics_process(delta: float) -> void:
	if not active:
		player.global_position = global_position
		vel += FLOAT_ACC * delta
		global_position.y += delta * vel


func burst() -> void:
	if player:
		player.velocity = Vector2(0,0)
		player.caught = false
	$bubble.play("burst")
	await $bubble.animation_finished
	queue_free()

func _on_timer_timeout() -> void:
	burst()

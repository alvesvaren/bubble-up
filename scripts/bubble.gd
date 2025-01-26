extends Area2D

var active = true;
var player = null;
var vel = 0;
@onready var pos = global_position

const FLOAT_ACC = -100;
@export var pop_sound: PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body is Player and active and not body.shield_active:
		active = false
		body.caught = true
		player = body
		$Timer.start()
	elif body is not Player:
		vel = 0
		active = true
		burst()

func _physics_process(delta: float) -> void:
	if not active and player:
		player.global_position = global_position
		vel += FLOAT_ACC * delta
		global_position.y += delta * vel


func burst() -> void:
	if player:
		player.velocity = Vector2(0,0)
		player.caught = false
		player = null
	$bubble.play("burst")
	get_parent().add_child(pop_sound.instantiate())
	await $bubble.animation_finished
	visible = false
	$RespawnTimer.start()

func _on_timer_timeout() -> void:
	burst()


func _on_respawn_timer_timeout() -> void:
	global_position = pos
	visible = true
	$bubble.play("shimmer")
	active = true

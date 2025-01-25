extends CharacterBody2D

class_name Player

const SPEED = 100.0
const DRAG = 0.004
const STEER_FACTOR = 0.001

var speed_multiplier = 1.0

@export var player_index: int
@export var flap_curve: Curve

var last_flap_was_right = false
var last_flap_time = 0

var angular = 0

signal death

func stun(duration: float, pos: Vector2):
	speed_multiplier = 0
	#velocity = velocity.bounce(pos.direction_to(global_position)) * 0.2
	velocity *= 0.5
	modulate = Color.RED
	$timer.start(duration)
	await $timer.timeout
	speed_multiplier = 1
	modulate = Color.WHITE

func _ready() -> void:
	death.connect(on_death)

func on_death() -> void:
	queue_free()

func get_flap_axis():
	if player_index == -1:
		# keyboard
		return Input.get_axis("kb_p1_flap_left", "kb_p1_flap_right")
	
	return Input.get_joy_axis(player_index, JOY_AXIS_RIGHT_X)

func get_dir():
	if player_index == -1:
		# keyboard
		return Vector2(Input.get_axis("kb_p1_left", "kb_p1_right"), Input.get_axis("kb_p1_up", "kb_p1_down"))
	
	return Vector2(Input.get_joy_axis(player_index, JOY_AXIS_LEFT_X), Input.get_joy_axis(player_index, JOY_AXIS_LEFT_Y))

func flap(axis: float):    
	if abs(axis) < 0.5:
		return
	
	var current_flap_right = false
	if axis > 0.5:
		current_flap_right = true
	
	if current_flap_right == last_flap_was_right:
		# We didn't change direction
		return
		
	var current_time = Time.get_unix_time_from_system()
	
	var difference = current_time - last_flap_time
	
	var flap_multiplier = flap_curve.sample(difference)
	
	#print("difference: ", difference, "s", " duration: ", current_time - last_flap_time, "s")
	
	last_flap_time = current_time
	last_flap_was_right = current_flap_right

	velocity += Vector2.from_angle(rotation) * (SPEED * flap_multiplier) * speed_multiplier

func _physics_process(delta: float) -> void:
	velocity -= velocity.normalized() * (velocity.length() * velocity.length()) * DRAG * delta

	# Move force from "forwards" to "facing"

	move_and_slide()

func _process(delta: float) -> void:
	
	var current = get_flap_axis()
	
	var angle_difference = rotation - velocity.angle()
	angle_difference = wrapf(angle_difference, -PI, PI)
	velocity = velocity.rotated(angle_difference * STEER_FACTOR)
	
	var direction = get_dir()
	
	angular = Vector2.from_angle(rotation).angle_to(direction)
	rotate(angular * delta * 10)
	var count = $sprites.get_child_count()
	$sprites.get_children()[player_index % count].visible = true;
	
	for sprite in $sprites.get_children():
		sprite.flip_v = Vector2.from_angle(global_rotation).x < 0
		sprite.material.set_shader_parameter("hue_shift", player_index * 1.0/12)
	flap(current)

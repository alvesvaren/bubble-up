extends CharacterBody2D


const SPEED = 200.0
const DRAG = 0.002
const OPTIMAL_FLAP_MS = 0.7
const PERFECT_BONUS = 1.2
const STEER_FACTOR = 0.001

@export var player_index: int

var last_flap_was_right = false
var last_flap_time = 0

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
	
	var difference = abs(OPTIMAL_FLAP_MS - (current_time - last_flap_time))
	
	var error_ratio = clamp(difference / OPTIMAL_FLAP_MS, 0, 1)
	var flap_multiplier = PERFECT_BONUS - (PERFECT_BONUS - 1.0) * (error_ratio * error_ratio)
	
	print("difference: ", difference, "s", " duration: ", current_time - last_flap_time, "s")
	
	last_flap_time = current_time
	last_flap_was_right = current_flap_right
	
	if difference > 1.0:
		print("Too slow flap")
		return;
		

	velocity += Vector2.from_angle(rotation) * (SPEED * flap_multiplier)

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
	rotation = direction.angle()
	
	flap(current)

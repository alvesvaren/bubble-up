extends CharacterBody2D

class_name Player

const SPEED = 100.0
const DRAG = 0.004
const STEER_FACTOR = 0.001

var speed_multiplier = 1.0
var laps = 0

@export var player_index: int
@export var flap_curve: Curve
@export var bubble_scene: PackedScene
@export var spnge_bounce: PackedScene

var last_flap_was_right = false
var last_flap_time = 0

var angular = 0
var caught = false

signal death
signal collect_bu

var collected_bu = null
var shield_active = false

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
	collect_bu.connect(on_bu)

func on_death() -> void:
	queue_free()
	
func on_bu(bu: BubbleUp.BU) -> void:
	collected_bu = bu
	match bu:
		BubbleUp.BU.SPEED:
			pass
		BubbleUp.BU.BUBBLE:
			pass
		BubbleUp.BU.SHIELD:
			pass

func get_flap_axis():
	if player_index < 0:
		# keyboard
		return Input.get_axis("kb_p" + str(- player_index) + "_flap_left", "kb_p" + str(- player_index) + "_flap_right")
	
	return Input.get_joy_axis(player_index, JOY_AXIS_RIGHT_X)

func get_dir():
	if player_index < 0:
		# keyboard
		return Vector2(Input.get_axis("kb_p" + str(- player_index) + "_left", "kb_p" + str(- player_index) + "_right"), Input.get_axis("kb_p" + str(- player_index) + "_up", "kb_p" + str(- player_index) + "_down"))
	
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
	if not caught:
		velocity -= velocity.normalized() * (velocity.length() * velocity.length()) * DRAG * delta

	var collision = move_and_collide(velocity * delta, 0.08, true)
	if collision:
		var layers = PhysicsServer2D.body_get_collision_layer(collision.get_collider_rid())
		if layers & (1 << 3):
			velocity = (velocity.bounce(collision.get_normal())) * 2 + (velocity.bounce(collision.get_normal()).normalized() * 50)
			get_parent().get_parent().add_child(spnge_bounce.instantiate())
	move_and_slide()




func _process(delta: float) -> void:
	$bubble.visible = collected_bu == BubbleUp.BU.BUBBLE
	$shield.visible = shield_active
	
	var bool1 = (player_index < 0 and Input.is_action_just_pressed("kb_p" + str(- player_index) + "_use"))
	var bool2 = (player_index >= 0 and Input.is_joy_button_pressed(player_index, JOY_BUTTON_RIGHT_SHOULDER))
	
	if collected_bu != null and (bool1 or bool2):
		match collected_bu:
			BubbleUp.BU.BUBBLE:
				var new_bubble = bubble_scene.instantiate()
				new_bubble.global_position = $bubble.global_position
				get_parent().get_parent().get_node("map/bubbles").add_child(new_bubble)
			BubbleUp.BU.SPEED:
				velocity += Vector2.from_angle(rotation) * 1000
			BubbleUp.BU.SHIELD:
				start_shield()
		collected_bu = null
	if collected_bu != null:
		match collected_bu:
			BubbleUp.BU.SHIELD:
				$shieldItem.visible = true
			BubbleUp.BU.SPEED:
				$speedItem.visible = true
	else:
		$shieldItem.visible = false
		$speedItem.visible = false
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

func start_shield() -> void:
	$ShieldTimer.start()
	speed_multiplier = 1.2
	shield_active = true


func _on_shield_timer_timeout() -> void:
	shield_active = false
	speed_multiplier = 1.0

extends Camera2D


const CAUSTIC_OFFSET_SCALE = 0.1
const FIRST_PLAYER_MIN_DIST = 100
const FIRST_PLAYER_FOLLOW_SPEED = 2
const FIRST_PLAYER_OUTSIDE_SPEEDUP = 2
const ZOOM_TIME = 120

@onready var players = get_tree().root.get_node("root/players")
@export var zoom_curve: Curve
@export var target: Node2D

var first = null
var progresses = {}

var start_time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.process_during.connect(process_during)
	Manager.process_after.connect(process_after)
	Manager.set_state.connect(state_change)


func state_change(state) -> void:
	if state == Manager.BEFORE:
		$EndScreen.visible = false
	if state == Manager.DURING:
		start_time = Time.get_ticks_msec()

func process_after(delta) -> void:
	for joypad in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(joypad, JOY_BUTTON_START):
			Manager.set_state.emit(Manager.BEFORE)
	if Input.is_action_just_pressed("start"):
		Manager.set_state.emit(Manager.BEFORE)

func process_during(delta: float) -> void:
	if players.get_child_count() == 1:
		$EndScreen.visible = true
		Manager.set_state.emit(Manager.AFTER)
	elif players.get_child_count() > 1:
		var time_progress = (Time.get_ticks_msec() - start_time) / 1000.0 / ZOOM_TIME
		var zoom_sample = zoom_curve.sample(time_progress)
		zoom = Vector2(zoom_sample, zoom_sample)

func _process(delta: float) -> void:
	if players.get_child_count() > 0 and Manager.state != Manager.BEFORE:
		progresses = {}
		for child in players.get_children():
			progresses[child.name] = get_parent().get_node("CameraPath").curve.get_closest_offset(child.global_position)

		first = first_player(progresses)
		for child in players.get_children():
			if (distance_to_edge(child.global_position) < 0) and first != child.name:
				child.death.emit()
		print(first, progresses[first], target.global_position)
		target.get_parent().progress = progresses[first]
		$shader.global_position = get_screen_center_position()
		$shader.material.set_shader_parameter("offset", get_screen_center_position() * CAUSTIC_OFFSET_SCALE)
		move_towards_target(delta)

func move_towards_target(delta: float) -> void:
	var first_edge_dist = distance_to_edge(players.get_node(first).global_position)
	global_position += zoom.x * delta * max(0.1, FIRST_PLAYER_FOLLOW_SPEED - first_edge_dist / 200) * (target.global_position - global_position)
	if first_edge_dist < FIRST_PLAYER_MIN_DIST:
		global_position += zoom.x * FIRST_PLAYER_FOLLOW_SPEED * delta * max(0.1, FIRST_PLAYER_FOLLOW_SPEED - first_edge_dist / 200) * (target.global_position - global_position)

func distance_to_edge(position: Vector2) -> float:
	var distance_to_top = position.y - (get_screen_center_position().y - get_viewport_rect().size.y / 2)
	var distance_to_bottom = (get_screen_center_position().y +  get_viewport_rect().size.y / 2) - position.y
	var distance_to_left = position.x - (get_screen_center_position().x - get_viewport_rect().size.x / 2)
	var distance_to_right = (get_screen_center_position().x +  get_viewport_rect().size.x / 2) - position.x
	
	return min(distance_to_left, distance_to_right, distance_to_bottom, distance_to_top)

func first_player(progress: Dictionary) -> String:
	var best_player_name = null
	for player_name in progress:
		if not best_player_name == null:
			var best_laps = get_parent().get_parent().get_node("players/" + best_player_name).laps
			var cur_laps = get_parent().get_parent().get_node("players/" + player_name).laps
			if not best_player_name or cur_laps > best_laps or (cur_laps == best_laps and progress[player_name] > progress[best_player_name]):
				best_player_name = player_name
		else:
			best_player_name = player_name
	
	return best_player_name

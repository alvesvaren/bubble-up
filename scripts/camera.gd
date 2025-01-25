extends Camera2D


const CAUSTIC_OFFSET_SCALE = 0.1
const FIRST_PLAYER_MIN_DIST = 100
const FIRST_PLAYER_FOLLOW_SPEED = 3
const FIRST_PLAYER_OUTSIDE_SPEEDUP = 2

@onready var players = get_tree().root.get_node("root/players")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Manager.process_during.connect(process_during)
	Manager.process_after.connect(process_after)
	Manager.set_state.connect(state_change)


func state_change(state) -> void:
	if state == Manager.BEFORE:
		$RichTextLabel.visible = false

func process_after(delta) -> void:
	for joypad in Input.get_connected_joypads():
		if Input.is_joy_button_pressed(joypad, JOY_BUTTON_START):
			Manager.set_state.emit(Manager.BEFORE)
	if Input.is_action_just_pressed("start"):
		Manager.set_state.emit(Manager.BEFORE)

func process_during(delta: float) -> void:
	if players.get_child_count() == 1:
		$RichTextLabel.visible = true
		Manager.set_state.emit(Manager.AFTER)

func _process(delta: float) -> void:
	if players.get_child_count() > 0 and Manager.state != Manager.BEFORE:
		var avarage_pos = Vector2(0,0)
		var count = 0
		var progress = {}
		for child in players.get_children():
			progress[child.name] = $"../..".curve.get_closest_offset(child.global_position)
			avarage_pos += child.global_position
			count += 1

		if $"..".progress_ratio >= 0.99:
			pass
		else:
			var first = first_player(progress)
			for child in players.get_children():
				if (distance_to_edge(child.global_position) < 0) and first != child.name:
					child.death.emit()

			var first_edge_dist = distance_to_edge(players.get_node(first).global_position)
			$"..".progress += delta * max(0.1, FIRST_PLAYER_FOLLOW_SPEED - first_edge_dist / 200) * (progress[first] - $"..".progress)
			if first_edge_dist < FIRST_PLAYER_MIN_DIST:
				$"..".progress += FIRST_PLAYER_OUTSIDE_SPEEDUP * delta * max(0.1, FIRST_PLAYER_FOLLOW_SPEED - first_edge_dist / 200) * (progress[first] - $"..".progress)
			$shader.global_position = get_screen_center_position()
			$shader.material.set_shader_parameter("offset", get_screen_center_position() * CAUSTIC_OFFSET_SCALE)

func distance_to_edge(position: Vector2) -> float:
	var distance_to_top = position.y - (get_screen_center_position().y - get_viewport_rect().size.y / 2)
	var distance_to_bottom = (get_screen_center_position().y +  get_viewport_rect().size.y / 2) - position.y
	var distance_to_left = position.x - (get_screen_center_position().x - get_viewport_rect().size.x / 2)
	var distance_to_right = (get_screen_center_position().x +  get_viewport_rect().size.x / 2) - position.x
	
	return min(distance_to_left, distance_to_right, distance_to_bottom, distance_to_top)

func first_player(progress: Dictionary) -> String:
	var best_player_name = null
	for player_name in progress:
		if not best_player_name or progress[player_name] > progress[best_player_name]:
			best_player_name = player_name
	
	return best_player_name

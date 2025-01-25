extends Camera2D


const CAUSTIC_OFFSET_SCALE = 0.1
const FIRST_PLAYER_OFFSET = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Manager.state == Manager.DURING:
		var avarage_pos = Vector2(0,0)
		var count = 0
		var progress = {}
		for child in %players.get_children():
			progress[child.name] = $"../..".curve.get_closest_offset(child.global_position)
			avarage_pos += child.global_position
			count += 1

		var first = first_player(progress)
		for child in %players.get_children():
			if (distance_to_edge(child.global_position) < 0) and first != child.name:
				child.death.emit()

		var first_edge_dist = distance_to_edge(%players.get_node(first).global_position)
		$"..".progress += delta * (3.5 - first_edge_dist / 200) * (max(0, progress[first_player(progress)] - FIRST_PLAYER_OFFSET) - $"..".progress)
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

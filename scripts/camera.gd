extends Camera2D


const CAUSTIC_OFFSET_SCALE = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Manager.state == Manager.DURING:
		var avarage_pos = Vector2(0,0)
		var count = 0
		var progress = {}
		for child in $"../../../players".get_children():
			progress[child.name] = $"../..".curve.get_closest_offset(child.global_position)
			avarage_pos += child.global_position
			count += 1

		$"..".progress = progress[first_player(progress)]
		$shader.global_position = get_screen_center_position()
		$shader.material.set_shader_parameter("offset", get_screen_center_position() * CAUSTIC_OFFSET_SCALE)

func first_player(progress) -> String:
	var best = "Player"
	for player in progress:
		if progress[player] > progress[best]:
			best = player
	return best

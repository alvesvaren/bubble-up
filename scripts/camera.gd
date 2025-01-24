extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Manager.state == Manager.DURING:
		var avarage_pos = Vector2(0,0)
		var count = 0
		var progress = {}
		for child in get_parent().get_parent().get_parent().get_children():
			if child.name.find("Player") != -1:
				progress[child.name] = get_parent().get_parent().curve.get_closest_offset(child.global_position)
				avarage_pos += child.global_position
				count += 1
		global_rotation = 0
		get_parent().progress = progress[first_player(progress)]

func first_player(progress) -> String:
	var best = "Player"
	for player in progress:
		if progress[player] > progress[best]:
			best = player
	return best

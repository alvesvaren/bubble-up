extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var avarage_pos = Vector2(0,0)
	var count = 0
	for child in get_parent().get_children():
		if "Player" == child.name[0:6]:
			avarage_pos += child.global_position
			count += 1
	global_position = avarage_pos

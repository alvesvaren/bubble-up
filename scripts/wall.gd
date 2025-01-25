extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await Manager.process_during
	queue_free()

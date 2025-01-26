extends Node2D


func _on_bubble_up_animation_finished() -> void:
	queue_free()

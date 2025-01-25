extends Node

enum {BEFORE, DURING, AFTER}
var state = BEFORE
var players = []

signal set_state

signal process_before
signal process_during
signal process_after

func _set_state(new_state):
	state = new_state

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_state.connect(_set_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		BEFORE:
			process_before.emit()
		DURING:
			process_during.emit()
		AFTER:
			process_after.emit()

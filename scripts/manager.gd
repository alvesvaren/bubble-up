extends Node

enum {BEFORE, DURING, AFTER}
var state = BEFORE
var players = []

signal set_state

signal process_before
signal process_during
signal process_after

var fullscreen = false

func _set_state(new_state):
	state = new_state

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_state.connect(_set_state)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	fullscreen = not fullscreen

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(state)
	match state:
		BEFORE:
			process_before.emit(delta)
		DURING:
			process_during.emit(delta)
		AFTER:
			process_after.emit(delta)

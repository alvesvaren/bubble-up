extends AudioStreamPlayer

func _ready() -> void:
	Manager.set_state.connect(state_change)
	play()

func _on_finished() -> void:
	$intro2.play()
	print("stop")

func state_change(state) -> void:
	match state:
		Manager.BEFORE:
			$race.stop()
			play()
		Manager.DURING:
			self.stop()
			$intro2.stop()
			$race.play()

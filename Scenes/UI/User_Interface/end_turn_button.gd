extends Button

signal end_turn

func _end_turn():
	end_turn.emit()

func button_mode(mode):
	self.disabled = mode

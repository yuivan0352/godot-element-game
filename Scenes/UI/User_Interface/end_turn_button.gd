extends Button

signal end_turn

func _end_turn():
	end_turn.emit()

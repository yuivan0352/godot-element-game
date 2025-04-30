extends Button

@onready var magic_button = $"../MagicButton"

signal end_turn

func _end_turn():
	if magic_button._popped_up == true:
		magic_button._ui_mode_switch()
	end_turn.emit()

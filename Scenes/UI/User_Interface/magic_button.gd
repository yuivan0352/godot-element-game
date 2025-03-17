extends Button

signal magic_mode

func _mode_switch():
	magic_mode.emit()

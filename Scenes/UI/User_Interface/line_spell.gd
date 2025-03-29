extends Button

signal magic_line

func _mode_switch():
	magic_line.emit()

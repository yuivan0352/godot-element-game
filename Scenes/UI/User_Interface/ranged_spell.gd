extends Button

signal magic_ranged

func _mode_switch():
	magic_ranged.emit()

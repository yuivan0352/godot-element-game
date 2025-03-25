extends Button

signal magic_melee

func _mode_switch():
	magic_melee.emit()

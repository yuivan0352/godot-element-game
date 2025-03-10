extends Button

signal attack_mode

func _mode_switch():
	attack_mode.emit()

extends Button

@onready var parent_container = $".."
@onready var magic_container = $"../../MagicButtons"
signal return_to_idle

func _ui_mode_switch():
	parent_container.visible = false
	magic_container.visible = true
	return_to_idle.emit()

extends Button

@onready var parent_container = $'..'
@onready var main_container = $"../../MainButtons"
signal return_to_idle

func _return_to_main():
	parent_container.visible = false
	main_container.visible = true
	return_to_idle.emit()

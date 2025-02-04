extends CanvasLayer
class_name UserInterface

@onready var name_label = %Name

func _update_name_label(active_char):
	if name_label:
		name_label.text = active_char.char_stats.name

func _ready() -> void:
	pass

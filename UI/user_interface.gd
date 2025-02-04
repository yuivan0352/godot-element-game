extends CanvasLayer
class_name UserInterface

@onready var name_label = %Name
var active_char_stats

func _get_active_char(ac_stats):
	active_char_stats = ac_stats
	if name_label:
		name_label.text = ac_stats.name

func _ready() -> void:
	pass

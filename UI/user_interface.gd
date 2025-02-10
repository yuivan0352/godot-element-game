extends CanvasLayer
class_name UserInterface

@onready var name_label = %Name
@onready var health_bar: MarginContainer = $HealthBar
var active_char_stats
signal stats_received

func _get_active_char(ac_stats):
	active_char_stats = ac_stats
	if name_label:
		name_label.text = ac_stats.name
	health_bar._update_health(ac_stats.health)

func _ready() -> void:
	pass

extends CanvasLayer
class_name UserInterface

@onready var health_bar: MarginContainer = $HealthBar
var active_char_stats

func _get_active_char(ac_stats):
	active_char_stats = ac_stats
	health_bar._update_health(ac_stats.health, ac_stats.name)

func _ready() -> void:
	pass

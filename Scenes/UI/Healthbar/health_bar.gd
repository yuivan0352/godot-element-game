extends MarginContainer

@onready var health_label: Label = %HealthLabel
@onready var texture_bar = %TextureProgressBar
var active_char_health
var active_char_name

func _update_health(active_char):
	health_label.text = str(active_char.unit_stats.name, " - ", active_char.unit_stats.health, " / ", active_char.unit_stats.max_health)
	texture_bar.value = (float(active_char.unit_stats.health) / float(active_char.unit_stats.max_health)) * 100

extends MarginContainer

@onready var health_label: Label = %HealthLabel
@onready var texture_bar = %TextureProgressBar
var current_unit_health
var current_unit_name

func _update_health(current_unit):
	health_label.text = str(current_unit.unit_stats.name, " - ", current_unit.unit_stats.health, " / ", current_unit.unit_stats.max_health)
	texture_bar.value = (float(current_unit.unit_stats.health) / float(current_unit.unit_stats.max_health)) * 100

extends MarginContainer

@onready var health_label: Label = %HealthLabel
@onready var texture_bar = %TextureProgressBar


func _update_health(current_unit):
	if current_unit is Character:
		var current_unit_stats
		
		for stat in Global.characters_stats:
			if current_unit.unit_stats.name == stat.name:
				current_unit_stats = stat
		
		health_label.text = str(current_unit_stats.name, " - ", current_unit_stats.health, " / ", current_unit_stats.max_health)
		texture_bar.value = (float(current_unit_stats.health) / float(current_unit_stats.max_health)) * 100
	else:
		health_label.text = str(current_unit.unit_stats.name, " - ", current_unit.unit_stats.health, " / ", current_unit.unit_stats.max_health)
		texture_bar.value = (float(current_unit.unit_stats.health) / float(current_unit.unit_stats.max_health)) * 100
		

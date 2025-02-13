extends MarginContainer

@onready var health_label: Label = %HealthLabel
var active_char_health
var active_char_name

func _update_health(ac_health, ac_name):
	active_char_health = ac_health
	active_char_name = ac_name
	health_label.text = str(ac_name, " - ", active_char_health, " / ", active_char_health)

func _ready() -> void:
	pass

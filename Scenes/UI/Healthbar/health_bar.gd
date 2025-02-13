extends MarginContainer

@onready var health_label: Label = %HealthLabel
var active_char_health

func _update_health(ac_health):
	active_char_health = ac_health
	health_label.text = str(active_char_health, " ", "/", " ", active_char_health)

func _ready() -> void:
	pass

extends CanvasLayer
class_name UserInterface

@onready var health_bar: MarginContainer = $HealthBar
var active_char_stats
signal ui_element_mouse_entered
signal ui_element_mouse_exited

func _get_active_char(ac_stats):
	active_char_stats = ac_stats
	health_bar._update_health(ac_stats.health, ac_stats.name)

func _on_ui_element_mouse_entered() -> void:
	ui_element_mouse_entered.emit()

func _on_ui_element_mouse_exited() -> void:
	ui_element_mouse_exited.emit()

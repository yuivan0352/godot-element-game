extends CanvasLayer
class_name UserInterface

@onready var health_bar: MarginContainer = $HealthBar

var active_char
var active_char_stats
var turn_array
var current_turn_index

signal ui_element_mouse_entered
signal ui_element_mouse_exited
signal switch_mode(mode)

func _get_active_char(ac):
	active_char = ac
	active_char_stats = active_char.unit_stats
	health_bar._update_health(active_char_stats.health, active_char_stats.name)
	
func _switch_mode(mode : String):
	switch_mode.emit(mode)

func _on_ui_element_mouse_entered() -> void:
	ui_element_mouse_entered.emit()

func _on_ui_element_mouse_exited() -> void:
	ui_element_mouse_exited.emit()

func _on_turn_info(order: Variant, current_turn: Variant) -> void:
	turn_array = order
	current_turn_index = current_turn

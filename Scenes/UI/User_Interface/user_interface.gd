extends CanvasLayer
class_name UserInterface

@onready var health_bar: MarginContainer = $HealthBar
@onready var unit_info = $UnitInfo

var active_char
var turn_array
var current_turn_index

signal ui_element_mouse_entered
signal ui_element_mouse_exited
signal switch_mode(mode)
signal end_turn
signal end_turn_button_mode

func _get_active_char(ac):
	active_char = ac
	health_bar._update_health(active_char)
	
func _switch_mode(mode : String):
	switch_mode.emit(mode)

func _on_ui_element_mouse_entered() -> void:
	ui_element_mouse_entered.emit()

func _on_ui_element_mouse_exited() -> void:
	ui_element_mouse_exited.emit()

func _on_turn_info(order: Variant, current_turn: Variant) -> void:
	turn_array = order
	current_turn_index = current_turn
	
func _on_unit_clicked(unit):
	print("UserInterface received unit_clicked signal for:", unit.name)
	if unit_info:
		unit_info.update_info(unit)
		unit_info.visible = true
		
func _end_turn():
	end_turn.emit()
	
func _end_turn_button_mode(mode):
	end_turn_button_mode.emit(mode)

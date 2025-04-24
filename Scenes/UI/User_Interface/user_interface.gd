extends CanvasLayer
class_name UserInterface

@onready var health_bar: MarginContainer = $HealthBar
@onready var unit_info = $UnitInfo
@onready var hotbar = $Hotbar
@onready var action_icon = $ActionEcon/HBoxContainer/ActionIcon
@onready var bonus_action_icon = $ActionEcon/HBoxContainer/BonusActionIcon
@onready var movement_bar = $ActionEcon/MovementBar
@onready var mana_bar = $ActionEcon/ManaBar

var current_unit
var turn_array
var current_turn_index

signal ui_element_mouse_entered
signal ui_element_mouse_exited
signal switch_mode(mode)
signal end_turn
signal buttons_disabled

func _get_current_unit(cu):
	current_unit = cu
	health_bar._update_health(current_unit)

func _update_actions(action, bonus_action, mana, movement_speed, moved_distance):
	action_icon.value = action
	bonus_action_icon.value = bonus_action
	mana_bar.value = mana
	movement_bar.max_value = movement_speed
	movement_bar.value = moved_distance
	
func _update_mana_bar(used_mana: int):
	mana_bar.value = mana_bar.value - used_mana

func _update_movement_bar():
	movement_bar.value = movement_bar.value - 5
	
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
	
func _buttons_disabled(mode):
	var mainButtons = hotbar.get_child(0).get_child(0).get_children()
	for button in mainButtons:
		button.disabled = mode

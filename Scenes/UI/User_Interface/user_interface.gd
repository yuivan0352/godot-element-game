extends CanvasLayer
class_name UserInterface

@onready var health_bar: MarginContainer = $HealthBar
@onready var unit_info = $UnitInfo
@onready var hotbar = $Hotbar
@onready var action_icon = $ActionEcon/HBoxContainer/ActionIcon
@onready var bonus_action_icon = $ActionEcon/HBoxContainer/BonusActionIcon
@onready var movement_bar = $ActionEcon/MovementBar
@onready var mana_bar = $ActionEcon/ManaBar
@onready var magic_buttons = $MagicBar/MarginContainer/MagicButtons
@onready var potion_button = $Hotbar/MarginContainer/MainButtons/PotionButton
@onready var combat_log = $CombatLogController/CombatLog/ScrollContainer/CombatLog

var current_unit
var turn_array
var current_turn_index

signal ui_element_mouse_entered
signal ui_element_mouse_exited
signal switch_mode(mode)
signal end_turn
signal buttons_disabled
signal heal_emit

func _get_current_unit(cu):
	current_unit = cu
	health_bar._update_health(current_unit)
	if current_unit is Character:
		var current_unit_stats
			
		for stat in Global.characters_stats:
			if current_unit.unit_stats.name == stat.name:
				current_unit_stats = stat
		
		potion_button.text = str(current_unit_stats.potions)
		
	else:
		potion_button.text = str(current_unit.unit_stats.potions)

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
	
func _emit_heal():
	heal_emit.emit()
	
func _switch_mode(mode : String, spell_info: Spell):
	switch_mode.emit(mode, spell_info)

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

func _fill_spell_buttons(spell_array):
	for i in range(spell_array.size()):
		magic_buttons.get_children()[i].spell_info = spell_array[i]
		magic_buttons.get_children()[i].update_button()
		
func _add_combat_line(line: String):
	combat_log.text = combat_log.text + line + "\n"

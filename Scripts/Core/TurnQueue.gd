extends Node

class_name TurnQueue

var pc_positions : Dictionary
var enemy_positions: Dictionary

var current_unit : Unit
var prev_unit : Unit
var current_unit_stats : Stats

var turn_order: Array[Unit] = []
var turn_num = 0
var round_num = 0

@onready var user_interface = %UserInterface
@onready var overview_camera = $"../../Environment/OverviewCamera"
@onready var layer_zero = $"../../Environment/Layer0"
@onready var layer_one = $"../../Environment/Layer1"
@onready var player_chars = $"../../Combatants/Player"
@onready var enemy_chars = $"../../Combatants/Enemy"

signal current_character
signal turn_info(order, current_turn)
signal buttons_disabled

#For obelisk spawning (final level)
var elements = ["Fire","Water","Earth","Wind"]

var status_effects: Dictionary = {}

func _ready():	
	#Final Boss Level Spawn
	var enemy_units = []
	
	if Global.level - 1 == 4:
		var boss_unit = enemy_chars.spawn_2x2_enemy_center("Boss", layer_zero)
		if boss_unit:
			enemy_units.append(boss_unit)
			for unit in enemy_chars.get_children():
				if unit != boss_unit and "Obelisk" in unit.unit_stats.name:
					enemy_units.append(unit)
	else:
		enemy_units = enemy_chars.spawn_characters(1, layer_zero)

	var player_units = player_chars.spawn_characters(3, layer_zero)

	#for stat in Global.characters_stats:
		#print(stat, " : ", stat.health)
	
	for unit in player_units:
		pc_positions[unit] = layer_zero.local_to_map(unit.global_position)
	for unit in enemy_units:
		enemy_positions[unit] = layer_zero.local_to_map(unit.global_position)
	
	print(pc_positions)
	layer_zero._set_char_pos_solid(pc_positions)
	layer_zero._set_char_pos_solid(enemy_positions)
	
	turn_order.append_array(player_units)
	turn_order.append_array(enemy_units)
	turn_order.sort_custom(func (a, b): return a.initiative_roll < b.initiative_roll)
	turn_info.emit(turn_order, turn_num)
	setup_turn_order()
	
# current_unit is just a variable of the unit class
# the stats associated using current_unit.unit_stats is not the correct stats
# needs to be the globally tracked stats
func set_current_unit_stats():
	for stat in Global.characters_stats:
		if current_unit.unit_stats.name == stat.name:
			current_unit_stats = stat

func get_enemy_positions():
	return enemy_positions
func get_pc_positions():
	return pc_positions

func _change_current_unit_mode(mode : String, spell_info: Spell):
	current_unit.change_mode(mode, spell_info)
	
func _heal_current_unit():
	current_unit.heal()
	current_character.emit(current_unit)

func setup_turn_order():
	for unit in turn_order:
		if unit is Enemy:
			unit.turn_complete.connect(_play_turn)
		unit.unit_moving.connect(_transition_character_cam)
	
	current_unit = turn_order[0]
	set_current_unit_stats()
	
	if current_unit is Enemy:
		_update_combat_log(str(current_unit.unit_stats.name, "'s turn"))
		#print(current_unit.unit_stats.name, "'s turn")
	elif current_unit is Character:
		_update_combat_log(str(current_unit_stats.name, "'s turn"))
		#print(current_unit_stats.name, "'s turn")
	current_character.emit(current_unit)
	overview_camera.set_camera_position(current_unit)
	
	if current_unit is Enemy:
		buttons_disabled.emit(true)
		await get_tree().create_timer(1.5).timeout
		current_unit.take_turn()
	else:
		current_unit.spell_info.emit(current_unit.equipped_spells)

func _update_char_pos(coords):
	if current_unit is Character:
		pc_positions[current_unit] = coords
	else:
		enemy_positions[current_unit] = coords

func _transition_character_cam():
	overview_camera.track_char_cam(current_unit)

func _play_turn():
	buttons_disabled.emit(true)
	prev_unit = current_unit

	turn_num += 1
	if turn_num >= turn_order.size():
		turn_num = 0
		round_num += 1
		for unit in turn_order:
			if round_num >= 2:
				unit.unit_stats.mana += 3
				if unit.unit_stats.mana > 5:
					unit.unit_stats.mana = 5
			else:		
				unit.unit_stats.mana += round_num + 1
	turn_info.emit(turn_order, turn_num)
	
	_transition_character_cam()
	await overview_camera.tween.finished
	overview_camera.make_current()
	current_unit = turn_order[turn_num]
	
	var prev_cam = prev_unit.find_child("CharacterCamera")
	var curr_cam = current_unit.find_child("CharacterCamera")
	var cam_trans_duration = 1.0
	
	if current_unit.find_child("VisibilityNotifier").is_on_screen():
		overview_camera.transition_camera(prev_cam, curr_cam, cam_trans_duration / 2)
		await get_tree().create_timer(0.5).timeout
	else:
		overview_camera.transition_camera(prev_cam, curr_cam, cam_trans_duration)
		await get_tree().create_timer(1).timeout
	
	
	if current_unit is Character:
		overview_camera.make_current()
		current_unit.spell_info.emit(current_unit.equipped_spells)
	current_character.emit(current_unit)
	
	apply_status_effect(current_unit)

	current_unit._reset_action_econ()
	
	if current_unit is Character:
		set_current_unit_stats()
		_update_combat_log(str(current_unit_stats.name, "'s turn"))
		current_unit.update_action_econ.emit(1, 1, current_unit_stats.mana, current_unit_stats.movement_speed, current_unit_stats.movement_speed)
		_change_current_unit_mode("idle", null)
		buttons_disabled.emit(false)
	elif current_unit is Enemy:
		_update_combat_log(str(current_unit.unit_stats.name, "'s turn"))
		current_unit.update_action_econ.emit(1, 1, current_unit.unit_stats.mana, current_unit.unit_stats.movement_speed, current_unit.unit_stats.movement_speed)
		await get_tree().create_timer(1.5).timeout
		current_unit.take_turn()

func _update_combat_log(line: String):
	user_interface._add_combat_line(line)

func _on_user_interface_switch_mode(mode: Variant) -> void:
	pass # Replace with function body.

#Spawning enemy reinforcements during battle
func spawn_enemy_during_battle(enemy_name: String):
	var enemy = enemy_chars.spawn_enemy(enemy_name, layer_zero)
	
	if enemy == null:
		print("No valid spawn tile for ", enemy_name)
		return
	
	_update_combat_log(str("Enemy ", enemy_name, " has arrived on the battlefield!"))
	var tile_coords = layer_zero.local_to_map(enemy[0].global_position)
	enemy_positions[enemy[0]] = tile_coords
	layer_zero._set_char_pos_solid(enemy_positions)

	turn_order.append(enemy[0])
	enemy[0].turn_complete.connect(_play_turn)
	enemy[0].unit_moving.connect(_transition_character_cam)

#Apply status effect for X amount of turns
func apply_status_effect(unit: Unit) -> void:

	if status_effects.has(unit):
		var effects = status_effects[unit]
		for i in range(effects.size() - 1, -1, -1):
			var effect = effects[i]

			var stat_altered = effect.stat_altered 
			unit.unit_stats.set(stat_altered, effect.changed_value)

			effect.duration -= 1
			
			if effect.duration >= 1:
				if effect.original_value - effect.changed_value > 0:
					_update_combat_log(str(unit.unit_stats.name + " has " + str(effect.duration) + " turn/s left of " + effect.name))
					_update_combat_log(str(unit.unit_stats.name + " had its " + stat_altered + " reduced by " + str(effect.original_value - effect.changed_value)))
				else:
					_update_combat_log(str(unit.unit_stats.name + " has " + str(effect.duration) + " turn/s left of " + effect.name))
					_update_combat_log(str(unit.unit_stats.name + " had its " + stat_altered + " increased by " + str((-1 * (effect.original_value - effect.changed_value)))))
			else:
				unit.unit_stats.set(stat_altered, effect.original_value)
				#Make sure update movement_speed back to normal if slow
				_update_combat_log(str(effect.name + " has wore off on " + unit.unit_stats.name))
				unit.movement_limit = unit.unit_stats.movement_speed/5
				effects.remove_at(i)
				
			#Make sure update movement_speed if slow
			if stat_altered == "movement_speed":
				unit.movement_limit = unit.unit_stats.movement_speed/5
	
		if effects.size() == 0:
			status_effects.erase(unit)
		else:
			status_effects[unit] = effects

#For final level*
func check_obelisks_and_boss():
	var boss_unit = null
	var obelisk_count = 0
	
	# Locate boss and count obelisks left
	for unit in turn_order:
		if unit is Enemy and unit.unit_stats.name == "The Omnipotent Eye":
			boss_unit = unit
		elif unit is Enemy and "Obelisk" in unit.unit_stats.name:
			obelisk_count += 1
	
	#Check if boss exists and obelisk count is 0, therefore kill the boss automatically and wipe it out
	if boss_unit != null and obelisk_count == 0:
		_update_combat_log(str("All obelisks have been destroyed! The boss has no energy to take from!"))
		boss_unit.unit_stats.health = 0
		_update_combat_log(str("The boss has been slain!"))
		boss_unit.erase()
		return true
	
	return false
		

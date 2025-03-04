extends Node

class_name TurnQueue

var pc_positions : Dictionary
var enemy_positions: Dictionary

var active_char : Unit
var prev_char : Unit

var current_unit : Unit
var turn_order: Array[Unit] = []
var turn_num = 0

@onready var overview_camera = $"../../Environment/OverviewCamera"
@onready var layer_zero = $"../../Environment/Layer0"
@onready var player_chars = $"../../Combatants/Player"
@onready var enemy_chars = $"../../Combatants/Enemy"

signal active_character(stats)

func _ready():
	var player_units = player_chars.spawn_characters(3, layer_zero)
	var enemy_units = enemy_chars.spawn_characters(3, layer_zero)
	
	for unit in player_units:
		pc_positions[unit] = layer_zero.local_to_map(unit.global_position)
	
	for unit in enemy_units:
		enemy_positions[unit] = layer_zero.local_to_map(unit.global_position)
		
	layer_zero._set_char_pos_solid(pc_positions)
	layer_zero._set_char_pos_solid(enemy_positions)

	turn_order.append_array(player_units)
	turn_order.append_array(enemy_units)
	turn_order.sort_custom(func (a, b): return a.initiative_roll < b.initiative_roll)
	
	for unit in turn_order:
		print(unit.unit_stats.name)
	print()
	setup_turn_order()
	
func setup_turn_order():
	for i in range(turn_order.size()):
		current_unit = turn_order[i]
		if current_unit is Unit:
			break
		else:
			print(current_unit.unit_stats.name, "'s turn")
			turn_num += 1
	
	if current_unit is Unit:
		print(current_unit.unit_stats.name, "'s turn")
		active_char = current_unit as Unit
		active_character.emit(active_char.unit_stats)
		overview_camera.set_camera_position(active_char)

	for unit in turn_order:
		unit.turn_complete.connect(_play_turn)
		if unit is Unit:
			unit.unit_moving.connect(_transition_character_cam)

func _update_char_pos(coords):
	if current_unit is Character:
		pc_positions[current_unit] = coords
	else:
		enemy_positions[current_unit] = coords

func _transition_character_cam():
	if current_unit is Unit:
		overview_camera.track_char_cam(current_unit)

func _play_turn():
	if current_unit is Character:
		prev_char = current_unit as Character

	turn_num += 1
	
	if turn_num >= turn_order.size(): 
		turn_num = 0
		
	current_unit = turn_order[turn_num]
		
	if current_unit is Enemy:
		print(current_unit.unit_stats.name, "'s turn")
		active_char = current_unit as Enemy
		current_unit.take_turn()
		overview_camera.transition_camera(prev_char.find_child("CharacterCamera"), current_unit.find_child("CharacterCamera"), 1.0)
		overview_camera.make_current()
		
	if current_unit is Character:
		print(current_unit.unit_stats.name, "'s turn")
		active_char = current_unit as Character
		active_character.emit(active_char.unit_stats)
		overview_camera.transition_camera(prev_char.find_child("CharacterCamera"), active_char.find_child("CharacterCamera"), 1.0)
		overview_camera.make_current()

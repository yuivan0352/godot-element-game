extends Node

class_name TurnQueue

var pc_positions : Dictionary
var enemy_positions: Dictionary

var current_unit : Unit
var prev_unit : Unit

var turn_order: Array[Unit] = []
var turn_num = 0

@onready var overview_camera = $"../../Environment/OverviewCamera"
@onready var layer_zero = $"../../Environment/Layer0"
@onready var player_chars = $"../../Combatants/Player"
@onready var enemy_chars = $"../../Combatants/Enemy"

signal current_character
signal turn_info(order, current_turn)
signal buttons_disabled

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
	turn_info.emit(turn_order, turn_num)
	
	setup_turn_order()

func _change_current_unit_mode(mode : String):
	current_unit.change_mode(mode)

func setup_turn_order():
	for unit in turn_order:
		if unit is Enemy:
			unit.turn_complete.connect(_play_turn)
		unit.unit_moving.connect(_transition_character_cam)
	
	current_unit = turn_order[0]
	
	print(current_unit.unit_stats.name, "'s turn")
	current_character.emit(current_unit)
	overview_camera.set_camera_position(current_unit)
	
	if current_unit is Enemy:
		current_unit.take_turn()

func _update_char_pos(coords):
	if is_instance_valid(current_unit):
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
	turn_info.emit(turn_order, turn_num)

	current_unit = turn_order[turn_num]
	print(current_unit.unit_stats.name)
	
	var prev_cam = prev_unit.find_child("CharacterCamera")
	var curr_cam = current_unit.find_child("CharacterCamera")
	var cam_trans_duration = 1.0
	
	if current_unit.find_child("VisibilityNotifier").is_on_screen():
		overview_camera.transition_camera(prev_cam, curr_cam, cam_trans_duration / 2)
		overview_camera.set_camera_position(current_unit)
		await get_tree().create_timer(0.5).timeout
	else:
		overview_camera.transition_camera(prev_cam, curr_cam, cam_trans_duration)
		overview_camera.set_camera_position(current_unit)
		await get_tree().create_timer(1).timeout

	overview_camera.make_current()
	current_character.emit(current_unit)
	print(turn_order)

	if current_unit is Character:
		current_unit._reset_action_econ()
		current_unit.update_action_econ.emit(1, 1, current_unit.unit_stats.movement_speed, current_unit.unit_stats.movement_speed)
		buttons_disabled.emit(false)
	elif current_unit is Enemy:
		print("Processing enemy turn")
		await get_tree().create_timer(1.5).timeout
		current_unit.take_turn()


func _on_user_interface_switch_mode(mode: Variant) -> void:
	pass # Replace with function body.

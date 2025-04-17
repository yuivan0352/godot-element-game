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

signal active_character
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
	
	for unit in turn_order:
		print(unit.unit_stats.name)
	print()
	setup_turn_order()

func _change_active_char_mode(mode : String):
	if is_instance_valid(active_char):
		active_char.change_mode(mode)

func setup_turn_order():
	for i in range(turn_order.size()):
		current_unit = turn_order[i]
		if is_instance_valid(current_unit) and current_unit is Character:
			break
		else:
			if is_instance_valid(current_unit):
				print(current_unit.unit_stats.name, "'s turn")
			turn_num += 1
			turn_info.emit(turn_order, turn_num)
	
	if is_instance_valid(current_unit):
		if current_unit is Character:
			print(current_unit.unit_stats.name, "'s turn")
			active_char = current_unit as Character
			active_character.emit(active_char)
			overview_camera.set_camera_position(active_char)
		elif current_unit is Enemy:
			active_char = current_unit
			active_character.emit(active_char) 
			overview_camera.set_camera_position(active_char)
			await get_tree().create_timer(0.5).timeout
			current_unit.take_turn()
		
	for unit in turn_order:
		if is_instance_valid(unit):
			if unit is Enemy:
				unit.turn_complete.connect(_play_turn)
			elif unit is Character:
				unit.unit_moving.connect(_transition_character_cam)

func _update_char_pos(coords):
	if is_instance_valid(current_unit):
		if current_unit is Character:
			pc_positions[current_unit] = coords
		else:
			enemy_positions[current_unit] = coords

func _transition_character_cam():
	if is_instance_valid(current_unit) and current_unit is Character:
		overview_camera.track_char_cam(current_unit)

func _play_turn():
	buttons_disabled.emit(true)
	if is_instance_valid(current_unit) and current_unit is Character:
		prev_char = current_unit 

	# Advance to next unit
	turn_num += 1
	if turn_num >= turn_order.size():
		turn_num = 0
	turn_info.emit(turn_order, turn_num)

	# Skip invalid units
	var attempts = 0
	while attempts < turn_order.size():
		current_unit = turn_order[turn_num]
		if current_unit == null or not is_instance_valid(current_unit):
			turn_num += 1
			if turn_num >= turn_order.size():
				turn_num = 0
			attempts += 1
		else:
			break

	current_unit = turn_order[turn_num]

	if !is_instance_valid(current_unit):
		return
	
	# === CAMERA TRANSITION BLOCK ===
	var prev_cam = null
	var curr_cam = null
	
	if is_instance_valid(prev_char):
		prev_cam = prev_char.find_child("CharacterCamera", true, false)
	curr_cam = current_unit.find_child("CharacterCamera", true, false)

	# Always do a transition if both cameras exist
	if prev_cam and curr_cam:
		var transition_duration := 1.0
		# Optional: make faster if already on screen
		if current_unit.get_child_count() > 3 and current_unit.get_child(3).is_on_screen():
			transition_duration = 0.5

		overview_camera.transition_camera(prev_cam, curr_cam, transition_duration)
		await get_tree().create_timer(transition_duration).timeout
	else:
		# fallback snap if no cameras
		overview_camera.set_camera_position(current_unit)
		await get_tree().create_timer(0.5).timeout

	# === ACTIVE CHARACTER SETUP ===
	active_char = current_unit
	overview_camera.make_current()
	active_character.emit(active_char)

	if current_unit is Character:
		print(current_unit.unit_stats.name, "'s turn")
		current_unit._reset_action_econ()
		current_unit.update_action_econ.emit(1, 1, current_unit.unit_stats.movement_speed, current_unit.unit_stats.movement_speed)
		buttons_disabled.emit(false)
	
	elif current_unit is Enemy:
		print("Processing enemy turn")
		await get_tree().create_timer(0.5).timeout
		current_unit.take_turn()

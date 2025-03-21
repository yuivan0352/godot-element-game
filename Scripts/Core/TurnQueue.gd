extends Node
class_name TurnQueue

var pc_positions: Dictionary
var enemy_positions: Dictionary
var active_char: Unit
var prev_char: Unit
var current_unit: Unit
var turn_order: Array[Unit] = []
var turn_num = 0

@onready var overview_camera = $"../../Environment/OverviewCamera"
@onready var layer_zero = $"../../Environment/Layer0"
@onready var player_chars = $"../../Combatants/Player"
@onready var enemy_chars = $"../../Combatants/Enemy"

signal active_character
signal turn_info(order, current_turn)

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
	turn_order.sort_custom(func(a, b): return a.initiative_roll < b.initiative_roll)

	# Debug - print turn order
	print("Initial turn order:")
	for unit in turn_order:
		print(unit.unit_stats.name, " (", "Character" if unit is Character else "Enemy", ")")
	print()

	turn_info.emit(turn_order, turn_num)
	setup_turn_connections()
	start_first_turn()

func _change_active_char_mode(mode: String):
	if active_char is Character:
		active_char.change_mode(mode)

# Set up signal connections first
func setup_turn_connections():
	for unit in turn_order:
		unit.turn_complete.connect(_play_turn)	
		if unit is Character:
			unit.unit_moving.connect(_transition_character_cam)

func start_first_turn():
	current_unit = turn_order[turn_num]
	print("Starting first turn: ", current_unit.unit_stats.name)

	await get_tree().create_timer(0.5).timeout # Small delay before starting

	if current_unit is Character:
		active_char = current_unit
		active_character.emit(active_char)
		overview_camera.set_camera_position(active_char)
	elif current_unit is Enemy:
		active_char = current_unit
		active_character.emit(active_char) 
		overview_camera.set_camera_position(active_char)
		await get_tree().create_timer(0.5).timeout # Pause before executing enemy action
		current_unit.take_turn()

func _update_char_pos(coords):
	if current_unit is Character:
		pc_positions[current_unit] = coords
	else:
		enemy_positions[current_unit] = coords

func _transition_character_cam():
	if current_unit is Unit:
		overview_camera.track_char_cam(current_unit)

func _play_turn():
	print("Turn completed, moving to next unit")

	prev_char = current_unit
	turn_num += 1
	
	if turn_num >= turn_order.size():
		turn_num = 0
		print("--- Round complete, starting new round ---")
	
	turn_info.emit(turn_order, turn_num)

	# Get new current unit
	current_unit = turn_order[turn_num]
	current_unit._reset_action_econ()

	print("Next turn: ", current_unit.unit_stats.name, " (", "Character" if current_unit is Character else "Enemy", ")")

	if current_unit is Enemy:
		print("Processing enemy turn")
		active_char = current_unit
		active_character.emit(active_char)

		# Camera transition delay
		if prev_char and prev_char.find_child("CharacterCamera"):
			overview_camera.transition_camera(
				prev_char.find_child("CharacterCamera"), 
				current_unit.find_child("CharacterCamera"), 
				1.0
			)
			await get_tree().create_timer(1.0).timeout # Ensure transition completes
		else:
			overview_camera.set_camera_position(current_unit)
		
		overview_camera.make_current()
		
		await get_tree().create_timer(0.5).timeout # Short delay before enemy action
		current_unit.take_turn()
		
		# Set new active character
		active_char = current_unit
		overview_camera.make_current()
		active_character.emit(active_char)

	# Handle character turn
	elif current_unit is Character:
		print("Processing character turn")
		
		# Camera transition delay
		if prev_char and prev_char.find_child("CharacterCamera"):
			var transition_time = 0.5 if current_unit.get_child(3).is_on_screen() else 1.0
			overview_camera.transition_camera(
				prev_char.find_child("CharacterCamera"), 
				current_unit.find_child("CharacterCamera"), 
				transition_time
			)
			active_char = null
			await get_tree().create_timer(transition_time).timeout
		else:
			overview_camera.set_camera_position(current_unit)
		
		# Set new active character
		active_char = current_unit
		await get_tree().create_timer(0.3).timeout # Short delay before UI update
		overview_camera.make_current()
		active_character.emit(active_char)

extends Unit
class_name Character

var mode : String = "idle"
@onready var path = $Path
@onready var clickable_area = $Sprite/clickableArea

var in_ui_element: bool

signal unit_clicked(unit)
signal update_action_econ(action, bonus_action, movement_speed)

func _ui_element_mouse_entered():
	in_ui_element = true
	path._on_ui_element_mouse_entered()
	
func _ui_element_mouse_exited():
	in_ui_element = false
	path._on_ui_element_mouse_exited()
	
func change_mode(input_mode: String):
	if mode == input_mode:
		mode = "idle"
	else:
		mode = input_mode

func _reset_action_econ():
	super._reset_action_econ()
	mode = "idle"
	
func _attack_action(attack_type_array):
	var mouse_tile = tile_layer_zero.local_to_map(get_global_mouse_position())
	if actions > 0:
		if turn_queue.enemy_positions.find_key(mouse_tile) != null and attack_type_array.has(mouse_tile):
			turn_queue.enemy_positions.find_key(mouse_tile).unit_stats.health -= rng.randi_range(1, 6)
			print(turn_queue.enemy_positions.find_key(mouse_tile).unit_stats.name, ": ", turn_queue.enemy_positions.find_key(mouse_tile).unit_stats.health, "/", turn_queue.enemy_positions.find_key(mouse_tile).unit_stats.max_health)
			if turn_queue.enemy_positions.find_key(mouse_tile).unit_stats.health <= 0:
				turn_queue.enemy_positions.find_key(mouse_tile).queue_free()
				turn_queue.enemy_positions.erase(turn_queue.enemy_positions.find_key(mouse_tile))
				turn_queue.turn_order.erase(turn_queue.enemy_positions.find_key(mouse_tile))
				tile_layer_zero._unsolid_coords(mouse_tile)
				_update_adj_tiles()
		actions -= 1
		update_action_econ.emit(0, 1, unit_stats.movement_speed, (movement_limit - moved_distance) * 5)
	else:
		return

func _input(event):
	if self == turn_queue.current_unit:
		match mode:
			"idle":
				if !in_ui_element:
					if event.is_action_pressed("interact"):
						if !is_moving:
							current_id_path = astar_grid.get_id_path(
								tile_layer_zero.local_to_map(global_position),
								tile_layer_zero.local_to_map(get_global_mouse_position())
							).slice(1, movement_limit - moved_distance + 1)
						elif is_moving:
							return
							
						if !current_id_path.is_empty():
							tile_layer_zero._unsolid_coords(tile_layer_zero.local_to_map(global_position))
							unit_moving.emit()
							mode = "moving"
					else:
						return
			"moving":
				if event.is_action_pressed("stop_move"):
					if is_moving:
						current_id_path = current_id_path.slice(0, 1)
					unit_still.emit()
					mode = "idle"
			"attack", "magic_melee":
				if event.is_action_pressed("interact"):
					_attack_action(adjacent_tiles)
			"magic_ranged":
				if event.is_action_pressed("interact"):
					_attack_action(circle_tiles)
			"magic_line":
				if event.is_action_pressed("interact"):
					_attack_action(line_tiles)

func move_towards_target(_delta):
	super.move_towards_target(_delta)
	overview_camera.set_camera_position(self)
	overview_camera.make_current()
	unit_still.emit()

func _physics_process(_delta):
	if self == turn_queue.current_unit:
		if !in_ui_element:
			var mouse_pos = get_global_mouse_position()
			var tile_position = tile_layer_zero.local_to_map(mouse_pos)
			var grid_size = Vector2i(16, 16)
			
			if tile_position.x >= 0 and tile_position.y >= 0 and tile_position.x < grid_size.x and tile_position.y < grid_size.y:
				var char_tile_pos = tile_layer_zero.local_to_map(global_position)
				if tile_position != char_tile_pos:
					if !is_moving:
						hover_id_path = astar_grid.get_id_path(
							tile_layer_zero.local_to_map(global_position),
							tile_position
						)
						hover_id_path = hover_id_path.slice(1, hover_id_path.size() - 1)
			
		move_towards_target(_delta)

func _on_area_clicked():
	if turn_queue.current_unit.mode == "idle":
		emit_signal("unit_clicked", self)

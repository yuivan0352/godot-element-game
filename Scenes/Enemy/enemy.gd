extends Unit
class_name Enemy

func _input(event):
	pass
	
func take_turn():
	if self == turn_queue.active_char:
		var random_tile = get_random_target_position()
			
		current_id_path = astar_grid.get_id_path(
			tile_layer_zero.local_to_map(global_position),
			tile_layer_zero.local_to_map(random_tile)
		).slice(1, movement_limit - moved_distance + 1)
					
		if !current_id_path.is_empty():
			tile_layer_zero._unsolid_coords(tile_layer_zero.local_to_map(global_position))
			unit_moving.emit()
		else:
			print("No valid path found.")
	
func _physics_process(_delta):
	if self == turn_queue.active_char:
		enemy_move_towards_target(_delta)

func get_random_target_position() -> Vector2:
	var tile_map_size = tile_layer_zero.get_used_rect().size
	var max_x = tile_map_size.x - 1
	var max_y = tile_map_size.y - 1
	
	for attempt in range(10):
		var tile_position = Vector2i(randi() % (max_x + 1), randi() % randi() % (max_y + 1))
		
		var tile_data = tile_layer_zero.get_cell_tile_data(tile_position) 
		if tile_data and tile_data.get_custom_data("walkable"):
			print("Valid target tile: ", tile_position)
			return tile_layer_zero.map_to_local(tile_position)
		
	return global_position

func enemy_move_towards_target(_delta):
	if current_id_path.is_empty():
		print("Current ID path is empty. No movement.")
		return
	
	if not is_moving:
		target_position = tile_layer_zero.map_to_local(current_id_path.front())
		is_moving = true
		print("Starting movement towards target position: ", target_position)
	
	global_position = global_position.move_toward(target_position, 1)  # Adjust speed as necessary
	
	# Debugging output for current position and target position
	print("Current Position: ", global_position)
	print("Target Position: ", target_position)
	print("Is Moving: ", is_moving)

	# Use a distance threshold to check if the unit has reached the target
	if global_position.distance_to(target_position) < 1: 
		print("Reached target position: ", target_position)
		current_id_path.pop_front()
		moved_distance += 1
		
		if not current_id_path.is_empty():
			target_position = tile_layer_zero.map_to_local(current_id_path.front())
			print("Moving to next target position: ", target_position)
		else:
			is_moving = false
			tile_layer_zero._solid_coords(tile_layer_zero.local_to_map(global_position))
			turn_queue._update_char_pos(tile_layer_zero.local_to_map(global_position))

			if moved_distance == movement_limit:
				moved_distance = 0
				print("Movement limit reached. Emitting turn complete.")
				turn_complete.emit()
			else:
				overview_camera.enabled = true
				overview_camera.set_camera_position(self)
				overview_camera.make_current()
				unit_still.emit()
	else:
		print("Still moving towards target. Distance remaining: ", global_position.distance_to(target_position))

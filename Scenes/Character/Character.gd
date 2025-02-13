extends Unit
class_name Character

func _input(event):
	if self == turn_queue.active_char:
		if event.is_action_pressed("move"):
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
		elif event.is_action_pressed("stop_move"):
			if is_moving:
				current_id_path = current_id_path.slice(0, 1)
			unit_still.emit()
		else:
			return

func _physics_process(_delta):
	if self == turn_queue.active_char:
		var tile_position = tile_layer_zero.local_to_map(get_global_mouse_position())
		
		if !is_moving:
			hover_id_path = astar_grid.get_id_path(
				tile_layer_zero.local_to_map(global_position),
				tile_position
			)
			hover_id_path = hover_id_path.slice(1, hover_id_path.size() - 1)
		
		if current_id_path.is_empty():
			return
		
		if get_child(2).is_current():
			if is_moving == false:
				target_position = tile_layer_zero.map_to_local(current_id_path.front())
				is_moving = true
			
			global_position = global_position.move_toward(target_position, 1)
			
			if global_position == target_position:
				current_id_path.pop_front()
				moved_distance += 1
					
				if current_id_path.is_empty():
					is_moving = false
					tile_layer_zero._solid_coords(tile_layer_zero.local_to_map(global_position))
					turn_queue._update_char_pos(tile_layer_zero.local_to_map(global_position))
					if (moved_distance == movement_limit):
						moved_distance = 0
						turn_complete.emit()
					else:
						overview_camera.enabled = true
						overview_camera.set_camera_position(self)
						overview_camera.make_current()
						unit_still.emit()
				else:
					target_position = tile_layer_zero.map_to_local(current_id_path.front())

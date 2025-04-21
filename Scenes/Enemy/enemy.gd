extends Unit
class_name Enemy
var tile_size = 16  
var enemies = [] 

func _ready():
	super._ready()  
	
func _input(event):
	pass
	
func find_closest_player() -> Node:
	var closest_player = null
	var closest_distance = INF 
		
	for player in turn_queue.pc_positions.keys():
		var tile_position = turn_queue.pc_positions[player]
		var global_player_position = Vector2(tile_position) * tile_size
		var distance = global_position.distance_to(global_player_position)
		if distance < closest_distance:            
			closest_distance = distance
			closest_player = player  
	return closest_player
func is_tile_walkable(tile_position: Vector2i) -> bool:
	var tile_data = tile_layer_zero.get_cell_tile_data(tile_position)
	
	if tile_data and tile_data.get_custom_data("walkable"):
		# Check if tile is occupied by an enemy
		for enemy in turn_queue.enemy_positions.keys():
			if turn_queue.enemy_positions[enemy] == tile_position:
				return false
		
		# Check if tile is occupied by a player
		for player in turn_queue.pc_positions.keys():
			if turn_queue.pc_positions[player] == tile_position:
				return false
		
		return true	
		
	print("Tile not walkable: ", tile_position)
	return false
	
func find_adjacent_walkable_tile(player_tile_pos: Vector2i) -> Vector2i:
	var adjacent_tiles = [
		player_tile_pos + Vector2i(-1, 0), 
		player_tile_pos + Vector2i(1, 0),   
		player_tile_pos + Vector2i(0, -1), 
		player_tile_pos + Vector2i(0, 1),   
		player_tile_pos + Vector2i(-1, -1), 
		player_tile_pos + Vector2i(1, -1), 
		player_tile_pos + Vector2i(-1, 1), 
		player_tile_pos + Vector2i(1, 1)   
	]
	
	for tile in adjacent_tiles:
		if is_tile_walkable(tile):
			return tile
			
	return Vector2i(-1, -1)
	
func is_adjacent_to_closest_player(enemy_tile_pos: Vector2i, closest_player_tile_pos: Vector2i) -> bool:
	var adjacent_tiles = [
		closest_player_tile_pos + Vector2i(-1, 0),
		closest_player_tile_pos + Vector2i(1, 0),  
		closest_player_tile_pos + Vector2i(0, -1),  
		closest_player_tile_pos + Vector2i(0, 1),   
		closest_player_tile_pos + Vector2i(-1, -1), 
		closest_player_tile_pos + Vector2i(1, -1),  
		closest_player_tile_pos + Vector2i(-1, 1),  
		closest_player_tile_pos + Vector2i(1, 1)   
	]
	return enemy_tile_pos in adjacent_tiles
	
func take_turn():
	if self == turn_queue.active_char:
		var closest_player = find_closest_player()
		if closest_player == null:
			print("No closest player found.")
			return
		var player_tile_pos = turn_queue.pc_positions[closest_player]
		var enemy_tile_pos = tile_layer_zero.local_to_map(global_position)
		
		var target_tile_pos = find_adjacent_walkable_tile(player_tile_pos)
		var path_found = false
		
		if target_tile_pos != Vector2i(-1, -1):
			current_id_path = astar_grid.get_id_path(
				enemy_tile_pos,
				target_tile_pos
			).slice(1, movement_limit - moved_distance + 1)
			
			if !current_id_path.is_empty():
				path_found = true
		else:
			for adj_tile in [
				player_tile_pos + Vector2i(-1,0),
				player_tile_pos + Vector2i(1,0),
				player_tile_pos + Vector2i(0,-1),
				player_tile_pos + Vector2i(0,1)
			]:
				if is_tile_walkable(adj_tile):
					current_id_path = astar_grid.get_id_path(enemy_tile_pos, adj_tile).slice(1, movement_limit - moved_distance + 1)
					if !current_id_path.is_empty():
						path_found = true
						break
		if path_found:
			tile_layer_zero._unsolid_coords(enemy_tile_pos)
			is_moving = true
			unit_moving.emit()
		else:
			print("No valid paths available, ending turn")
			turn_complete.emit()
			
func move_towards_target(_delta):
	if current_id_path.is_empty():
		print("Current ID path is empty. No movement.")
		return
	
	var target_position = tile_layer_zero.map_to_local(current_id_path.front())
	global_position = global_position.move_toward(target_position, 1)  # Adjust speed as necessary
	if global_position.distance_to(target_position) < 1: 
		current_id_path.pop_front()
		moved_distance += 1
		
		if not current_id_path.is_empty():
			target_position = tile_layer_zero.map_to_local(current_id_path.front())
		else:
			is_moving = false
			tile_layer_zero._solid_coords(tile_layer_zero.local_to_map(global_position))
			turn_queue._update_char_pos(tile_layer_zero.local_to_map(global_position))
			if moved_distance == movement_limit:
				moved_distance = 0
				print("Movement limit reached.")
				turn_complete.emit()
				is_moving = false
			else:
				overview_camera.enabled = true
				overview_camera.make_current()
				unit_still.emit()
			check_and_end_turn()
			
func _physics_process(_delta):
	if self == turn_queue.active_char and is_moving:
		move_towards_target(_delta)
 
func check_and_end_turn():
	var closest_player = find_closest_player()
	if closest_player:
		var player_tile_pos = turn_queue.pc_positions[closest_player]
		var enemy_tile_pos = tile_layer_zero.local_to_map(global_position)

		if is_adjacent_to_closest_player(enemy_tile_pos, player_tile_pos):
			EnemyAttacks.perform_melee_attack(self, player_tile_pos, turn_queue, tile_layer_zero)
		else:
			EnemyAttacks.perform_ranged_attack(self, player_tile_pos, turn_queue, tile_layer_zero)
			
	is_moving = false
	turn_complete.emit()
	print("End turn")

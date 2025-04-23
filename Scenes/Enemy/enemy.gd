extends Unit
class_name Enemy

var tile_size = 16  
var enemies = [] 
var enemy_tile_pos: Vector2i
	
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
	
func find_adjacent_walkable_tile(player: Character) -> Vector2i:
	if player.adjacent_tiles.has(enemy_tile_pos):
		return enemy_tile_pos
		
	for tile in player.adjacent_tiles:
		if is_tile_walkable(tile):
			return tile
			
	return Vector2i(-1, -1)
	
func is_adjacent_to_closest_player(enemy_tile_pos: Vector2i, player: Character) -> bool:	
	return enemy_tile_pos in player.adjacent_tiles
	
func take_turn():
	if self == turn_queue.current_unit:
		var closest_player = find_closest_player()
		print("closest player: ", closest_player.unit_stats.name)
		if closest_player == null:
			print("No closest player found.")
			return

		enemy_tile_pos = tile_layer_zero.local_to_map(global_position)
		
		var target_tile_pos = find_adjacent_walkable_tile(closest_player)
		print(target_tile_pos)
		var path_found = false
		
		if target_tile_pos != Vector2i(-1, -1):
			current_id_path = astar_grid.get_id_path(
				enemy_tile_pos,
				target_tile_pos
			).slice(1, movement_limit - moved_distance + 1)
			print(current_id_path)
			
			for i in range(current_id_path.size()):
				if closest_player.adjacent_tiles.has(current_id_path[i]):
					current_id_path = current_id_path.slice(0, i + 1)
					break
			
			if !current_id_path.is_empty():
				path_found = true

		if path_found:
			tile_layer_zero._unsolid_coords(enemy_tile_pos)
			unit_moving.emit()
		else:
			if target_tile_pos != enemy_tile_pos:
				print("No valid paths available, ending turn")
				turn_complete.emit()
			else:
				check_and_end_turn()
			
func move_towards_target(_delta):
	if (super.move_towards_target(_delta)):
		check_and_end_turn()

func _physics_process(_delta):
	if self == turn_queue.current_unit:
		move_towards_target(_delta)
 
func check_and_end_turn():
	var closest_player = find_closest_player()
	if closest_player:
		var player_tile_pos = turn_queue.pc_positions[closest_player]
		enemy_tile_pos = tile_layer_zero.local_to_map(global_position)

		if is_adjacent_to_closest_player(enemy_tile_pos, closest_player):
			EnemyAttacks.perform_melee_attack(self, player_tile_pos, turn_queue, tile_layer_zero)
		else:
			EnemyAttacks.perform_ranged_attack(self, player_tile_pos, turn_queue, tile_layer_zero)
			
	#await get_tree().create_timer(2.0).timeout
	turn_complete.emit()
	print("End turn")

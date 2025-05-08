extends Unit
class_name Enemy
var tile_size = 16  
var enemies = [] 
var enemy_tile_pos: Vector2i
@export var enemy_attacks : Node  
var behavior_randomness = 0.2  
	
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
		
		for enemy in turn_queue.enemy_positions.keys():
			if turn_queue.enemy_positions[enemy] == tile_position:
				return false
		
		for player in turn_queue.pc_positions.keys():
			if turn_queue.pc_positions[player] == tile_position:
				return false
		return true
	return false
	
func find_adjacent_walkable_tile(player: Character) -> Vector2i:
	enemy_tile_pos = tile_layer_zero.local_to_map(global_position)
	
	if player.adjacent_tiles.has(enemy_tile_pos):
		return enemy_tile_pos
		
	var walkable_adjacent_tiles = []
	for tile in player.adjacent_tiles:
		if is_tile_walkable(tile):
			walkable_adjacent_tiles.append(tile)
	
	if walkable_adjacent_tiles.size() > 0:
		walkable_adjacent_tiles.shuffle()
		return walkable_adjacent_tiles[0]
			
	return Vector2i(-1, -1)
	
func is_adjacent_to_closest_player(enemy_tile_pos: Vector2i, player: Character) -> bool:	
	return enemy_tile_pos in player.adjacent_tiles
	
func get_best_defensive_tile(enemy_tile: Vector2i, player_tile: Vector2i, max_move_distance: int) -> Vector2i:
	var best_tile = Vector2i(-1, -1)
	var max_distance = 0
	
	for x in range(-max_move_distance, max_move_distance + 1):
		for y in range(-max_move_distance, max_move_distance + 1):
			if abs(x) + abs(y) > max_move_distance:
				continue  
				
			var test_tile = enemy_tile + Vector2i(x, y)
			if not is_tile_walkable(test_tile):
				continue
				
			var dist_to_player = test_tile.distance_to(player_tile)
			if dist_to_player > max_distance:
				max_distance = dist_to_player
				best_tile = test_tile
	
	return best_tile

func take_turn():
	if self == turn_queue.current_unit:
		rng.randomize()  
		var closest_player = find_closest_player()
		
		if closest_player == null:
			print("No closest player found.")
			overview_camera.set_camera_position(self)
			overview_camera.make_current()
			turn_complete.emit()
			return
		
		#Boss does not move, therefore it only executes moves
		if turn_queue.current_unit.unit_stats.enemy_class == "Boss":
			check_and_end_turn()
			
		enemy_tile_pos = tile_layer_zero.local_to_map(global_position)
		var player_tile_pos = turn_queue.pc_positions[closest_player]
		var current_distance = enemy_tile_pos.distance_to(player_tile_pos)
		var do_random_behavior = rng.randf() < behavior_randomness
		
		if turn_queue.current_unit.unit_stats.enemy_class == "Ranged" or turn_queue.current_unit.unit_stats.enemy_class == "Spellcaster" or turn_queue.current_unit.unit_stats.health <= turn_queue.current_unit.unit_stats.max_health/3:
			var optimal_distance = 4  
			var best_tile = Vector2i(-1, -1)
			var best_score = -INF
			
			for x in range(-movement_limit, movement_limit + 1):
				for y in range(-movement_limit, movement_limit + 1):
					if abs(x) + abs(y) > movement_limit:
						continue  
						
					var test_tile = enemy_tile_pos + Vector2i(x, y)
					if not is_tile_walkable(test_tile):
						continue
						
					var dist_to_player = test_tile.distance_to(player_tile_pos)
					var dist_from_optimal = abs(dist_to_player - optimal_distance)
					var dist_from_current = test_tile.distance_to(enemy_tile_pos)
					
					# sets a score based on how close to optimal distance and how little movement required
					var score = (10 - dist_from_optimal) * 10 - dist_from_current
					
					# if too close to player, prioritize getting farther
					if current_distance <= 2 and dist_to_player > current_distance:
						score += 50
					
					if score > best_score:
						best_score = score
						best_tile = test_tile
			
			# If no good tile was found, try to find the farthest tile from the player
			if best_tile == Vector2i(-1, -1):
				best_tile = get_best_defensive_tile(enemy_tile_pos, player_tile_pos, movement_limit)
			
			if best_tile != Vector2i(-1, -1):
				current_id_path = astar_grid.get_id_path(enemy_tile_pos, best_tile).slice(1, movement_limit - moved_distance + 1)
				if !current_id_path.is_empty():
					tile_layer_zero._unsolid_coords(enemy_tile_pos)
					unit_moving.emit()
					return
			
			check_and_end_turn()
			
		elif turn_queue.current_unit.unit_stats.enemy_class == "Melee":

			var target_tile_pos = find_adjacent_walkable_tile(closest_player)
			var path_found = false
			
			if target_tile_pos != Vector2i(-1, -1):
				current_id_path = astar_grid.get_id_path(
					enemy_tile_pos,
					target_tile_pos
				).slice(1, movement_limit - moved_distance + 1)
				
				for i in range(current_id_path.size()):
					if closest_player.adjacent_tiles.has(current_id_path[i]):
						current_id_path = current_id_path.slice(0, i + 1)
						break
				
				if !current_id_path.is_empty():
					path_found = true
			
			if path_found:
				tile_layer_zero._unsolid_coords(enemy_tile_pos)
				unit_moving.emit()
				return
			
			# can't find closest path we'll still try to move as close as possible
			var best_distance = INF
			var best_tile = Vector2i(-1, -1)
			
			for x in range(-movement_limit, movement_limit + 1):
				for y in range(-movement_limit, movement_limit + 1):
					if abs(x) + abs(y) > movement_limit:
						continue
						
					var test_tile = enemy_tile_pos + Vector2i(x, y)
					if not is_tile_walkable(test_tile):
						continue
						
					var dist_to_player = test_tile.distance_to(player_tile_pos)
					if dist_to_player < best_distance:
						best_distance = dist_to_player
						best_tile = test_tile
			
			if best_tile != Vector2i(-1, -1) and best_tile != enemy_tile_pos:
				current_id_path = astar_grid.get_id_path(enemy_tile_pos, best_tile).slice(1, movement_limit - moved_distance + 1)
				if !current_id_path.is_empty():
					tile_layer_zero._unsolid_coords(enemy_tile_pos)
					unit_moving.emit()
					return
			
			check_and_end_turn()
		
		else:
			print("No enemy class for the stats")
			
func move_towards_target(_delta):
	if super.move_towards_target(_delta): 
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
			enemy_moves.use_melee_move(self, player_tile_pos)
		else:
			enemy_moves.use_ranged_move(self)
	else:
		# All players are dead
		print("No target found for attack, ending turn")
		overview_camera.set_camera_position(self)
		overview_camera.make_current()
		turn_complete.emit()
	
	moved_distance = 0
	current_id_path = []

func _on_turn_complete() -> void:
	pass 

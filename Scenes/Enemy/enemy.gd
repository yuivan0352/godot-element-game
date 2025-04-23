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
		
		# If enemy class is Ranged/Spellcaster (keeps distance and uses ranged or magic attacks)
		# Also if any enemy is at 1/3 of it's health or lower (including melee), it will start to run and use ranged attacks
		if turn_queue.current_unit.unit_stats.enemy_class == "Ranged" or turn_queue.current_unit.unit_stats.enemy_class == "Spellcaster" or turn_queue.current_unit.unit_stats.health <= turn_queue.current_unit.unit_stats.max_health/3:
=		var closest_player = find_closest_player()
		print("closest player: ", closest_player.unit_stats.name)
		if closest_player == null:
			print("No closest player found.")
			overview_camera.set_camera_position(self)
			overview_camera.make_current()
			turn_complete.emit()
			return

			enemy_tile_pos = tile_layer_zero.local_to_map(global_position)
			var player_tile_pos = turn_queue.pc_positions[closest_player]
			var distance_to_player = enemy_tile_pos.distance_to(player_tile_pos)

			var best_tile = Vector2i(-1, -1)
			var best_score = -INF

			for x in range(-movement_limit, movement_limit + 1):
				for y in range(-movement_limit, movement_limit + 1):
					var test_tile = enemy_tile_pos + Vector2i(x, y)
					if not is_tile_walkable(test_tile):
						continue

					var dist_to_player = test_tile.distance_to(player_tile_pos)
					var dist_from_current = test_tile.distance_to(enemy_tile_pos)

					# Try to stay between 3-5 tiles from player (ideal range)
					if dist_to_player >= 3 and dist_to_player <= 5:
						# Score based on being in range and not moving too far from current
						var score = 100 - dist_from_current
						if score > best_score:
							best_score = score
							best_tile = test_tile

					# If player is too close (≤ 1), prioritize getting farther away
					elif distance_to_player <= 1 and dist_to_player > distance_to_player:
						var score = dist_to_player * 10 - dist_from_current
						if score > best_score:
							best_score = score
							best_tile = test_tile

			if best_tile != Vector2i(-1, -1):
				current_id_path = astar_grid.get_id_path(enemy_tile_pos, best_tile).slice(1, movement_limit - moved_distance + 1)
				if !current_id_path.is_empty():
					tile_layer_zero._unsolid_coords(enemy_tile_pos)
					unit_moving.emit()
					return

			print("No optimal tile found, ending turn.")
			check_and_end_turn()
			# If enemy class is Melee (close ranged attacks) at above 1/3 of it's max health
		elif turn_queue.current_unit.unit_stats.enemy_class == "Melee":	
			var closest_player = find_closest_player()
			print("closest player: ", closest_player.unit_stats.name)
			if closest_player == null:
				print("No closest player found.")
				return
			enemy_tile_pos = tile_layer_zero.local_to_map(global_position)
		
			var target_tile_pos = find_adjacent_walkable_tile(closest_player)
			var path_found = false
			
			if target_tile_pos != Vector2i(-1, -1):
				current_id_path = astar_grid.get_id_path(
					enemy_tile_pos,
					target_tile_pos
				).slice(1, movement_limit - moved_distance + 1)
				
				if !current_id_path.is_empty():
					path_found = true
		var target_tile_pos = find_adjacent_walkable_tile(closest_player)
		print(target_tile_pos)
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
			
			print(current_id_path)
			if !current_id_path.is_empty():
				path_found = true

		if path_found:
			tile_layer_zero._unsolid_coords(enemy_tile_pos)
			unit_moving.emit()
		else:
			if target_tile_pos != enemy_tile_pos:
				print("No valid paths available, ending turn")
				overview_camera.set_camera_position(self)
				overview_camera.make_current()
				turn_complete.emit()
			else:
				for tile in closest_player.adjacent_tiles:
					if is_tile_walkable(tile):
						current_id_path = astar_grid.get_id_path(enemy_tile_pos, tile).slice(1, movement_limit - moved_distance + 1)
						if !current_id_path.is_empty():
							path_found = true
							break
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
		
		var attack_performed = false
		if is_adjacent_to_closest_player(enemy_tile_pos, closest_player):
			EnemyAttacks.regular_melee_attack(self, player_tile_pos, turn_queue, tile_layer_zero)
			attack_performed = true
		elif turn_queue.current_unit.unit_stats.enemy_class != "Spellcaster":
			attack_performed = true
			EnemyAttacks.regular_ranged_attack(self, circle_tiles, turn_queue, tile_layer_zero)
		elif turn_queue.current_unit.unit_stats.enemy_class == "Spellcaster":
			attack_performed = true			
			EnemyAttacks.regular_magic_attack(self, circle_tiles, turn_queue, tile_layer_zero)
	#delay for attack
	await get_tree().create_timer(0.5).timeout
	
	moved_distance = 0
	current_id_path = []
	
	turn_complete.emit()
	print("End turn")

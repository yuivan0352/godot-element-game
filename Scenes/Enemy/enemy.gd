extends Unit
class_name Enemy

var tile_size = 16  
var enemies = []  # Make sure this list is populated with all enemies


func _ready():
	super._ready()  

func _input(event):
	pass

func find_closest_player() -> Node:
	var closest_player = null
	var closest_distance = INF 
	
	print("Starting distance: ", closest_distance)
	
	# Iterate through player character positions to find the closest one
	for player in turn_queue.pc_positions.keys():
		var tile_position = turn_queue.pc_positions[player]
		var global_player_position = Vector2(tile_position) * tile_size
		print("Raw Player Position: ", tile_position)

		# Calculate the distance using the global player position
		var distance = global_position.distance_to(global_player_position)
		print("Checking player: ", player.unit_stats.name, " at ", global_player_position, " Distance: ", distance)

		if distance < closest_distance:            
			print("Found closer player. Old distance: ", closest_distance, ", New distance: ", distance)
			closest_distance = distance
			closest_player = player  # Store the player instance
			print("New closest player set: ", player.unit_stats.name)
	
	print("After loop - closest_player is null? ", closest_player == null)    
	print("After loop - closest_player type: ", typeof(closest_player))    
	print("Final closest_distance: ", closest_distance)

	return closest_player

# Function to check if a tile is walkable
func is_tile_walkable(tile_position: Vector2i) -> bool:
	var tile_data = tile_layer_zero.get_cell_tile_data(tile_position)
	
	if tile_data and tile_data.get_custom_data("walkable"):
		for enemy in turn_queue.enemy_positions.keys():
			if turn_queue.enemy_positions[enemy] == tile_position:
				print("Tile occupied by enemy: ", tile_position)
				return false
		return true	
		
	print("Tile not walkable: ", tile_position)
	return false

# Find the closest walkable tile adjacent to the player
func find_adjacent_walkable_tile(player_tile_pos: Vector2i) -> Vector2i:
	# Check the tiles around the player (8 adjacent tiles)
	var adjacent_tiles = [
		player_tile_pos + Vector2i(-1, 0),  # Left
		player_tile_pos + Vector2i(1, 0),   # Right
		player_tile_pos + Vector2i(0, -1),  # Top
		player_tile_pos + Vector2i(0, 1),   # Bottom
		player_tile_pos + Vector2i(-1, -1), # Top-left
		player_tile_pos + Vector2i(1, -1),  # Top-right
		player_tile_pos + Vector2i(-1, 1),  # Bottom-left
		player_tile_pos + Vector2i(1, 1)    # Bottom-right
	]

	return player_tile_pos  # Return player's own position if no adjacent tiles are walkable

# Function to check if the tile is adjacent to the closest player
func is_adjacent_to_closest_player(enemy_tile_pos: Vector2i, closest_player_tile_pos: Vector2i) -> bool:
	var adjacent_tiles = [
		closest_player_tile_pos + Vector2i(-1, 0),  # Left
		closest_player_tile_pos + Vector2i(1, 0),   # Right
		closest_player_tile_pos + Vector2i(0, -1),  # Top
		closest_player_tile_pos + Vector2i(0, 1),   # Bottom
		closest_player_tile_pos + Vector2i(-1, -1), # Top-left
		closest_player_tile_pos + Vector2i(1, -1),  # Top-right
		closest_player_tile_pos + Vector2i(-1, 1),  # Bottom-left
		closest_player_tile_pos + Vector2i(1, 1)    # Bottom-right
	]
	return enemy_tile_pos in adjacent_tiles

# Take the enemy's turn
func take_turn():
	if self == turn_queue.active_char:
		# Find the closest player
		var closest_player = find_closest_player()
		if closest_player == null:
			print("No closest player found.")
			return

		var player_tile_pos = turn_queue.pc_positions[closest_player]
		var enemy_tile_pos = tile_layer_zero.local_to_map(global_position)
		print("Converted global position to tile position: ", enemy_tile_pos)
		
		# Find an adjacent walkable tile near the player
		var target_tile_pos = find_adjacent_walkable_tile(player_tile_pos)
		print("Movement limit: ", movement_limit, " Moved distance: ", moved_distance)
		var path_found = false
		
		# Perform pathfinding to the closest walkable tile near the player
		current_id_path = astar_grid.get_id_path(
			enemy_tile_pos,
			target_tile_pos
		).slice(1, movement_limit - moved_distance + 1)

		# Debugging the pathfinding result
		if !current_id_path.is_empty():
			print("Path found: ", current_id_path)
			# Valid path found, start moving
			path_found = true
		else:
			print("No valid path found, attempting alternate adjacent tiles...")
			for adj_tile in [
				player_tile_pos + Vector2i(-1,0),
				player_tile_pos + Vector2i(1,0),
				player_tile_pos + Vector2i(0,-1),
				player_tile_pos + Vector2i(0,1)
			]:
				if is_tile_walkable(adj_tile):
					current_id_path = astar_grid.get_id_path(enemy_tile_pos, adj_tile).slice(1, movement_limit - moved_distance + 1)
					if !current_id_path.is_empty():
						print("Alternate path found to ", adj_tile)
						path_found = true
						break
		if path_found:
			tile_layer_zero._unsolid_coords(enemy_tile_pos)
			is_moving = true
			unit_moving.emit()
		else:
			print("No valid paths available, ending turn")
			turn_complete.emit()
# Move the enemy smoothly towards the next position on the path
func move_towards_target(_delta):
	if current_id_path.is_empty():
		print("Current ID path is empty. No movement.")
		return
	
	var target_position = tile_layer_zero.map_to_local(current_id_path.front())

	# Move towards the target position
	global_position = global_position.move_toward(target_position, 1)  # Adjust speed as necessary
	print("Moving towards target: ", target_position)

	# Check if the unit has reached the target
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
				is_moving = false
			else:
				overview_camera.enabled = true
				overview_camera.set_camera_position(self)
				overview_camera.make_current()
				unit_still.emit()

			# Check if we should end the turn
			check_and_end_turn()

# Process movement in the _physics_process
func _physics_process(_delta):
	if self == turn_queue.active_char and is_moving:
		print("Moving towards target: ", is_moving)
		move_towards_target(_delta)

func attack_player(player):
	if player != null:
		var damage = rng.randi_range(1,6)
		player.unit_stats.health -= damage
		print("Attacked player: ", player.unit_stats.name, " for ", damage, " damage. Remaining health: ", player.unit_stats.health)
# End the enemy's turn if it moves adjacent to the closest player
func check_and_end_turn():
	var closest_player = find_closest_player()
	if closest_player:
		var player_tile_pos = turn_queue.pc_positions[closest_player]
		var enemy_tile_pos = tile_layer_zero.local_to_map(global_position)
		if is_adjacent_to_closest_player(enemy_tile_pos, player_tile_pos):
			print("Enemy is adjacent to player!")
			attack_player(closest_player)
			is_moving = false
			turn_complete.emit()
			print("Enemy moved adjacent to closest player, ending turn.")

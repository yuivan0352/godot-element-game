extends Node

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func regular_melee_attack(attacker, adjacent_tiles: Vector2i, turn_queue, tile_layer_zero):
	var player = turn_queue.pc_positions.find_key(adjacent_tiles)
	if player != null:
		var line = draw_attack_line(attacker, player)
		await get_tree().create_timer(1.0).timeout  
		var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brawns)
		player.unit_stats.health -= damage
		print(attacker.unit_stats.name, " is adjacent to player!")
		print("Enemy attacked ", player.unit_stats.name, " for ", damage, " damage!")
		print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")
		if player.unit_stats.health <= 0:
			print(player.unit_stats.name, " has been defeated!")
			turn_queue.pc_positions.erase(turn_queue.pc_positions.find_key(adjacent_tiles))
			player.queue_free()
			tile_layer_zero._unsolid_coords(adjacent_tiles)
			
		line.queue_free()
		return true
	return false
			
#
func regular_ranged_attack(attacker, circle_tiles: Array, turn_queue, tile_layer_zero):
	for tile in circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null:
			var line = draw_attack_line(attacker, player)
			await get_tree().create_timer(1.0).timeout 
			var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains)
			player.unit_stats.health -= damage
			print(attacker.unit_stats.name, " is attacking!")
			print("Player is within range! Attacking ", player.unit_stats.name, " for ", damage, " damage!")
			print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")

			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				player.queue_free()
				tile_layer_zero._unsolid_coords(tile)

			line.queue_free()
			return true
	return false

func regular_magic_attack(attacker, circle_tiles: Array, turn_queue, tile_layer_zero) -> bool:
	var hit_anyone = false
			
	for tile in circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null:
			var line = draw_attack_line(attacker, player)
			await get_tree().create_timer(1.0).timeout 
			var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment)
			player.unit_stats.health -= damage
			print(attacker.unit_stats.name, " is attacking!")
			print("Player is within range! Attacking ", player.unit_stats.name, " for ", damage, " damage!")
			print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")

			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				player.queue_free()
				tile_layer_zero._unsolid_coords(tile)

			hit_anyone = true

			await get_tree().create_timer(0.4).timeout
			line.queue_free()

	return hit_anyone

func draw_attack_line(attacker: Node2D, target: Node2D) -> Line2D:
	var line = Line2D.new()
	line.width = 1
	line.z_index = 100
	line.default_color = Color(0,0,0,0.2)
	line.add_point(attacker.global_position)
	line.add_point(target.global_position)
	add_child(line)
	return line
	
func _on_line_timer_timeout(line: Line2D, timer: Timer) -> void:
	if line:
		line.queue_free()
	if timer:
		timer.queue_free()

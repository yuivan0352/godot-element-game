extends Node

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func perform_melee_attack(attacker, target_tile: Vector2i, turn_queue, tile_layer_zero):
	var player = turn_queue.pc_positions.find_key(target_tile)
	if player != null:
		var damage = rng.randi_range(1, 6)
		player.unit_stats.health -= damage
		print("Enemy is adjacent to player!")
		print("Enemy attacked ", player.unit_stats.name, " for ", damage, " damage!")
		print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")
		if player.unit_stats.health <= 0:
			print(player.unit_stats.name, " has been defeated!")
			turn_queue.pc_positions.erase(player)
			turn_queue.turn_order.erase(player)
			player.queue_free()
			tile_layer_zero._unsolid_coords(target_tile)
		return true
	return false

func perform_ranged_attack(attacker, target_tile: Vector2i, turn_queue, tile_layer_zero):
	if attacker.circle_tiles.has(target_tile):
		var player = turn_queue.pc_positions.find_key(target_tile)
		if player != null:
			var damage = rng.randi_range(1, 6)
			player.unit_stats.health -= damage
			print("Player is within range! Attacking ", player.unit_stats.name, " for ", damage, " damage!")
			print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")
			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				turn_queue.turn_order.erase(player)
				player.queue_free()
				tile_layer_zero._unsolid_coords(target_tile)
			return true
	return false

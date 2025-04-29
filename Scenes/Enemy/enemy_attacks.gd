extends Node

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func perform_melee_attack(attacker, target_tile: Vector2i, turn_queue, tile_layer_zero):
	var player = turn_queue.pc_positions.find_key(target_tile)
	var attack_roll = rng.randi_range(1, 20)
	print("Enemy is adjacent to player!")
	if player != null:
		if attack_roll >= player.unit_stats.armor_class:
			var damage = rng.randi_range(1, 6)
			player.unit_stats.health -= damage
			print(attacker.unit_stats.name, " rolled a ", attack_roll, " and attacked ", player.unit_stats.name, " for ", damage, " damage!")
			print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")
			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				turn_queue.turn_order.erase(player)
				player.queue_free()
				tile_layer_zero._unsolid_coords(target_tile)
			return true
		else:
			print(attacker.unit_stats.name, " rolled a ", attack_roll, " and missed their attack!")
	return false

func perform_ranged_attack(attacker, target_tile: Vector2i, turn_queue, tile_layer_zero):
	if attacker.circle_tiles.has(target_tile):
		var player = turn_queue.pc_positions.find_key(target_tile)
		var attack_roll = rng.randi_range(1, 20)
		print("Player is within range!")
		if attack_roll >= player.unit_stats.armor_class:
			if player != null:
				var damage = rng.randi_range(1, 6)
				player.unit_stats.health -= damage
				print(attacker.unit_stats.name, " rolled a ", attack_roll, " and attacked ", player.unit_stats.name, " for ", damage, " damage!")
				print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")
				if player.unit_stats.health <= 0:
					print(player.unit_stats.name, " has been defeated!")
					turn_queue.pc_positions.erase(player)
					turn_queue.turn_order.erase(player)
					player.queue_free()
					tile_layer_zero._unsolid_coords(target_tile)
				return true
		else:
			print(attacker.unit_stats.name, " rolled a ", attack_roll, " and missed their attack!")
	return false

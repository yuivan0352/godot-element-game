extends Unit

var unit_moves = {
	#Put most important move to least important
	"Warrior": ["iron_defense","cleave", "slash", "bow_shot"],
	"Mage": ["mass_healing", "healing_spell","magic_missles","fire_bolt", "slash"],
	"Archer": ["multi_shot","bow_shot", "slash"],
	"Slime": ["slash"],
}

var available_moves = []

func _ready() -> void:
	rng.randomize()

func use_melee_move(attacker):
	var unit_name = attacker.unit_stats.name 
	available_moves = unit_moves.get(unit_name, []) 
	for move in available_moves:
		var move_used = false
		match move:
			"cleave":
				move_used = await(cleave(attacker, attacker.turn_queue, tile_layer_zero))
			"slash":
				move_used = await(slash(attacker, attacker.turn_queue, tile_layer_zero))
			
		if move_used:
			print(move, " has been used")
			break

	await get_tree().create_timer(1.5).timeout
	attacker.turn_complete.emit()		
			
func use_ranged_move(attacker):
	var unit_name = attacker.unit_stats.name 
	available_moves = unit_moves.get(unit_name, [])
	for move in available_moves:
		var move_used = false
		match move:
			"magic_missles":
				move_used = await(magic_missles(attacker, attacker.turn_queue, tile_layer_zero, 1))
			"fire_bolt":
				move_used = await(fire_bolt(attacker, attacker.turn_queue, tile_layer_zero))
			"bow_shot":
				move_used = await(bow_shot(attacker, attacker.turn_queue, tile_layer_zero))
			"healing_spell":
				move_used = await(healing_spell(attacker, attacker.turn_queue, tile_layer_zero, 1))
			"mass_healing":
				move_used = await(mass_healing(attacker, attacker.turn_queue, tile_layer_zero, 2))
			"multi_shot":
				move_used = await(multi_shot(attacker, attacker.turn_queue, tile_layer_zero, 1))
				
		if move_used:
			print(move, " has been used")
			break
		
	await get_tree().create_timer(1.5).timeout
	attacker.turn_complete.emit()

#Single melee basic attack 
func slash(attacker, turn_queue, tile_layer_zero) -> bool:
	for tile in attacker.adjacent_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
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
				turn_queue.pc_positions.erase(player)
				turn_queue.turn_order.erase(player)
				player.queue_free()

			line.queue_free()
			return true
	return false
	
#Attacks all players adjacent to the enemy in a circle
func cleave(attacker, turn_queue, tile_layer_zero) -> bool:
	var hit_anyone = false
	var players = 0
	for tile in attacker.adjacent_tiles:
		if turn_queue.pc_positions.find_key(tile):
			players += 1
	
	if players > 1:
		for tile in attacker.adjacent_tiles:
			var player = turn_queue.pc_positions.find_key(tile)
			if player != null:
				var line = draw_attack_line(attacker, player)
				await get_tree().create_timer(1.5).timeout
				var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brawns)
				player.unit_stats.health -= damage
				print(attacker.unit_stats.name, " is attacking!")
				print("Player is within range! Attacking ", player.unit_stats.name, " for ", damage, " damage!")
				print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")

				if player.unit_stats.health <= 0:
					print(player.unit_stats.name, " has been defeated!")
					turn_queue.pc_positions.erase(player)
					turn_queue.turn_order.erase(player)
					player.queue_free()

				hit_anyone = true
				line.queue_free()

	return hit_anyone

#Single target normal ranged attack
func bow_shot(attacker, turn_queue, tile_layer_zero) -> bool:
	for tile in attacker.circle_tiles:
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
				turn_queue.turn_order.erase(player)
				player.queue_free()

			line.queue_free()
			return true
	return false
	
#Attacks all within the radius
func magic_missles(attacker, turn_queue, tile_layer_zero, mana_cost) -> bool:
	var hit_anyone = false
	var multiple_targets = []
	#checks if attacker has mana to use this for mana_cost
	if attacker.unit_stats.mana >= mana_cost:
		
		for tile in attacker.circle_tiles:
			var ally = turn_queue.enemy_positions.find_key(tile)
			if ally != null and ally.unit_stats.health <= ally.unit_stats.max_health/2:
				multiple_targets.append(ally)
				
		if multiple_targets.size() >= 2:
			for tile in attacker.circle_tiles:
				var player = turn_queue.pc_positions.find_key(tile)
				if player != null:
					var line = draw_attack_line(attacker, player)
					await get_tree().create_timer(1.5).timeout
					var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment)
					player.unit_stats.health -= damage
					print(attacker.unit_stats.name, " is attacking!")
					print("Player is within range! Attacking ", player.unit_stats.name, " for ", damage, " damage!")
					print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")
					attacker.unit_stats.mana -= mana_cost
					
					if player.unit_stats.health <= 0:
						print(player.unit_stats.name, " has been defeated!")
						turn_queue.pc_positions.erase(player)
						turn_queue.turn_order.erase(player)
						player.queue_free()

					hit_anyone = true
					line.queue_free()
		else:
			return hit_anyone
	else:
		print("No mana for magic_missles")
		print(attacker.unit_stats.mana, " mana left")
		return hit_anyone
			
	return hit_anyone

#Attacks all within the radius
func multi_shot(attacker, turn_queue, tile_layer_zero, mana_cost) -> bool:
	var hit_anyone = false
	var multiple_targets = []

	#checks if attacker has mana to use this for mana_cost
	if attacker.unit_stats.mana >= mana_cost:
		
		for tile in attacker.circle_tiles:
			var ally = turn_queue.enemy_positions.find_key(tile)
			if ally != null and ally.unit_stats.health <= ally.unit_stats.max_health/2:
				multiple_targets.append(ally)
				
		if multiple_targets.size() >= 2:
			for tile in attacker.circle_tiles:
				var player = turn_queue.pc_positions.find_key(tile)
				if player != null:
					var line = draw_attack_line(attacker, player)
					await get_tree().create_timer(1.5).timeout
					var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains)
					player.unit_stats.health -= damage
					print(attacker.unit_stats.name, " is attacking!")
					print("Player is within range! Attacking ", player.unit_stats.name, " for ", damage, " damage!")
					print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")
					attacker.unit_stats.mana -= mana_cost
					
					if player.unit_stats.health <= 0:
						print(player.unit_stats.name, " has been defeated!")
						turn_queue.pc_positions.erase(player)
						turn_queue.turn_order.erase(player)
						player.queue_free()

					hit_anyone = true
					line.queue_free()
		else:
			return hit_anyone
	else:
		print("No mana for multishot")
		print(attacker.unit_stats.mana, " mana left")
		return hit_anyone
			
	return hit_anyone
#Basic single target magic attack
func fire_bolt(attacker, turn_queue, tile_layer_zero) -> bool:
	for tile in attacker.circle_tiles:
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
				turn_queue.turn_order.erase(player)
				player.queue_free()

			line.queue_free()
			return true
	return false
	
#Heals 1 in it's radius (can include self)
func healing_spell(attacker, turn_queue, tile_layer_zero, mana_cost) -> bool:
	if attacker.unit_stats.mana >= mana_cost:
		for tile in attacker.circle_tiles:
			var ally = turn_queue.enemy_positions.find_key(tile)
			if ally != null and ally.unit_stats.health <= ally.unit_stats.max_health/2:
				var line = draw_attack_line(attacker, ally)
				await get_tree().create_timer(1.0).timeout
				var healing_health = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment)
				#Make sure it heals up to max hp and no more
				if ally.unit_stats.health + healing_health > ally.unit_stats.max_health:
					var health_healed_to_max = (ally.unit_stats.health + healing_health) - ally.unit_stats.max_health
					healing_health = healing_health - health_healed_to_max
					ally.unit_stats.health = ally.unit_stats.max_health
				else:
					ally.unit_stats.health += healing_health
					
				print(attacker.unit_stats.name, " is healing!")
				print("Healing ", ally.unit_stats.name, " for ", healing_health, " health!")
				print(ally.unit_stats.name, " has " + str(ally.unit_stats.health), " HP left")
				attacker.unit_stats.mana -= mana_cost

				line.queue_free()
				return true
	return false

#Heals 2 or more allies in it's radius (can include self)
func mass_healing(attacker, turn_queue, tile_layer_zero, mana_cost) -> bool:
	var healed = false
	var valid_targets = []
	
	if attacker.unit_stats.mana >= mana_cost:

		for tile in attacker.circle_tiles:
			var ally = turn_queue.enemy_positions.find_key(tile)
			if ally != null and ally.unit_stats.health <= ally.unit_stats.max_health/2:
				valid_targets.append(ally)
				
		if valid_targets.size() >= 2:
			for tile in attacker.circle_tiles:
				var ally = turn_queue.enemy_positions.find_key(tile)
				if ally != null and ally.unit_stats.health <= ally.unit_stats.max_health/2:
					var line = draw_attack_line(attacker, ally)
					await get_tree().create_timer(1.0).timeout
					var healing_health = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment)
					#Make sure it heals up to max hp and no more
					if ally.unit_stats.health + healing_health > ally.unit_stats.max_health:
						var health_healed_to_max = (ally.unit_stats.health + healing_health) - ally.unit_stats.max_health
						healing_health = healing_health - health_healed_to_max
						ally.unit_stats.health = ally.unit_stats.max_health
					else:
						ally.unit_stats.health += healing_health
						
					print(attacker.unit_stats.name, " is healing!")
					print("Healing ", ally.unit_stats.name, " for ", healing_health, " health!")
					print(ally.unit_stats.name, " has " + str(ally.unit_stats.health), " HP left")
					attacker.unit_stats.mana -= mana_cost

					healed = true
					line.queue_free()
		else:
			return healed
			
	else:
		print("No mana for mass_healing")
		print(attacker.unit_stats.mana, " mana left")
		return healed
			
	return healed

func iron_defense(attacker, turn_queue, tile_layer_zero, mana_cost) -> bool:
	if attacker.unit_stats.mana >= mana_cost:
		await get_tree().create_timer(1.0).timeout

		var armor = 1
		attacker.unit_stats.armor += armor

		print(attacker.unit_stats.name, " used Iron Defense!")
		print("Defense increased by ", armor)
		print("Current armor: ", attacker.unit_stats.armor)

		return true
	else:
		return false

	
func draw_attack_line(attacker: Node2D, target: Node2D) -> Line2D:
	var line = Line2D.new()
	line.width = 1
	line.z_index = 100
	line.default_color = Color(0, 0, 0, 0.2)
	line.add_point(attacker.global_position)
	line.add_point(target.global_position)
	add_child(line)
	return line

func _on_line_timer_timeout(line: Line2D, timer: Timer) -> void:
	if line:
		line.queue_free()
	if timer:
		timer.queue_free()

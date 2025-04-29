extends Unit

var unit_moves = {
	#Put most important move to least important
	"Warrior": ["Iron Defense","Cleave", "Slash", "Arrow Shot"],
	"Mage": ["Mass Healing", "Healing Spell","Mage Armor","Magic Missles","Fire Bolt", "Necrotic Touch", "Unarmed Strike"],
	"Archer": ["Multi-Shot","Arrow Shot", "Stab"],
	"Slime": ["Pounce"],
	"King Slime": ["Royal Reproduction", "Pounce"]
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
			"Iron Defense":
				move_used = await(iron_defense(attacker, attacker.turn_queue, 2))
			"Necrotic Touch":
				move_used = await(necrotic_touch(attacker, attacker.turn_queue, 1))
			"Cleave":
				move_used = await(cleave(attacker, attacker.turn_queue))
			"Slash":
				move_used = await(slash(attacker, attacker.turn_queue))
			#same as slash, but we call the move (for mage enemy)
			"Unarmed Strike":
				move_used = await(slash(attacker, attacker.turn_queue))
			#same as slash, but we call the move pounce (for slime enemy)
			"Pounce":
				move_used = await(slash(attacker, attacker.turn_queue))
			#same as slash, but we call the move stab (for archer enemy)
			"Stab":
				move_used = await(slash(attacker, attacker.turn_queue))
							
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
			"Iron Defense":
				move_used = await(iron_defense(attacker, attacker.turn_queue, 2))
			"Healing Spell":
				move_used = await(healing_spell(attacker, attacker.turn_queue, 1))
			"Mass Healing":
				move_used = await(mass_healing(attacker, attacker.turn_queue, 2))
			#Iron defense, but for spellcasters
			"Mage Armor":
				move_used = await(iron_defense(attacker, attacker.turn_queue, 1))
			"Magic Missiles":
				move_used = await(magic_missles(attacker, attacker.turn_queue, 1))
			"Multi-Shot":
				move_used = await(multi_shot(attacker, attacker.turn_queue, 1))
			"Royal Reproduction":
				move_used = await(call_reinforcements(attacker, attacker.turn_queue, "Slime", 2))
			"Fire Bolt":
				move_used = await(fire_bolt(attacker, attacker.turn_queue))
			"Arrow Shot":
				move_used = await(bow_shot(attacker, attacker.turn_queue))
				
		if move_used:
			print(move, " has been used")
			break
		
	await get_tree().create_timer(1.5).timeout
	attacker.turn_complete.emit()
	
#Single melee basic attack 
func slash(attacker, turn_queue) -> bool:
	for tile in attacker.adjacent_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null:
			var line = draw_attack_line(attacker, player)
			await get_tree().create_timer(1.0).timeout
			var damage = (rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains)) - rng.randi_range(1, player.unit_stats.armor_class)
			
			if damage > 0:
				player.unit_stats.health -= damage
			else:
				damage = 0
				
			print(attacker.unit_stats.name, " is adjacent to player!")
			print("Player's armor class: ", player.unit_stats.armor_class)
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
func cleave(attacker, turn_queue) -> bool:
	var hit_anyone = false
	var players = 0
	
	for tile in attacker.adjacent_tiles:
		if turn_queue.enemy_positions.find_key(tile):
			players += 1
	
	if players > 1:
		for tile in attacker.adjacent_tiles:
			var player = turn_queue.pc_positions.find_key(tile)
			if player != null:
				var line = draw_attack_line(attacker, player)
				await get_tree().create_timer(1.5).timeout
				var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brawns)
				
				if damage > 0:
					player.unit_stats.health -= damage
				else:
					damage = 0
				
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
func bow_shot(attacker, turn_queue) -> bool:
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null:
			var line = draw_attack_line(attacker, player)
			await get_tree().create_timer(1.0).timeout
			var damage = (rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains)) - rng.randi_range(1, player.unit_stats.armor_class)
			
			if damage > 0:
				player.unit_stats.health -= damage
			else:
				damage = 0
				
			print(attacker.unit_stats.name, " is attacking!")
			print("Player is within range! Attacking ", player.unit_stats.name, " for ", damage, " damage!")
			print("Player's armor class: ", player.unit_stats.armor_class)
			print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")

			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				turn_queue.turn_order.erase(player)
				player.queue_free()

			line.queue_free()
			return true
	return false

#Single melee basic attack 
func necrotic_touch(attacker, turn_queue, mana_cost) -> bool:
	
	if attacker.unit_stats.mana >= mana_cost:
		
		for tile in attacker.adjacent_tiles:
			var player = turn_queue.pc_positions.find_key(tile)
			if player != null:
				var line = draw_attack_line(attacker, player)
				await get_tree().create_timer(1.0).timeout
				var damage = (rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment))
				
				if damage > 0:
					player.unit_stats.health -= damage
				else:
					damage = 0
					
				print(attacker.unit_stats.name, " is adjacent to player!")
				print("Player's armor class: ", player.unit_stats.armor_class)
				print("Enemy attacked ", player.unit_stats.name, " for ", damage, " damage!")
				print(player.unit_stats.name, " has " + str(player.unit_stats.health), " HP left")
				attacker.unit_stats.mana -= mana_cost

				if player.unit_stats.health <= 0:
					print(player.unit_stats.name, " has been defeated!")
					turn_queue.pc_positions.erase(player)
					turn_queue.turn_order.erase(player)
					player.queue_free()

				line.queue_free()
				return true
	return false
	
#Attacks all within the radius
func magic_missles(attacker, turn_queue, mana_cost) -> bool:
	var hit_anyone = false
	var multiple_targets = []
	#checks if attacker has mana to use this for mana_cost
	if attacker.unit_stats.mana >= mana_cost:
		
		for tile in attacker.circle_tiles:
			var ally = turn_queue.pc_positions.find_key(tile)
			if ally != null:
				multiple_targets.append(ally)
				
		if multiple_targets.size() >= 2:
			attacker.unit_stats.mana -= mana_cost
			for tile in attacker.circle_tiles:
				var player = turn_queue.pc_positions.find_key(tile)
				if player != null:
					var line = draw_attack_line(attacker, player)
					await get_tree().create_timer(1.5).timeout
					var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment)
					
					if damage > 0:
						player.unit_stats.health -= damage
					else:
						damage = 0
						
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
		else:
			return hit_anyone
	else:
		print("No mana for magic_missles")
		print(attacker.unit_stats.mana, " mana left")
		return hit_anyone
			
	return hit_anyone

#Attacks all within the radius
func multi_shot(attacker, turn_queue, mana_cost) -> bool:
	var hit_anyone = false
	var multiple_targets = []

	#checks if attacker has mana to use this for mana_cost
	if attacker.unit_stats.mana >= mana_cost:
		
		for tile in attacker.circle_tiles:
			var ally = turn_queue.pc_positions.find_key(tile)
			if ally != null:
				multiple_targets.append(ally)
				
		if multiple_targets.size() >= 2:
			attacker.unit_stats.mana -= mana_cost
			for tile in attacker.circle_tiles:
				var player = turn_queue.pc_positions.find_key(tile)
				if player != null:
					var line = draw_attack_line(attacker, player)
					await get_tree().create_timer(1.5).timeout
					var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains)
					
					if damage > 0:
						player.unit_stats.health -= damage
					else:
						damage = 0
						
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
		else:
			return hit_anyone
	else:
		print("No mana for multishot")
		print(attacker.unit_stats.mana, " mana left")
		return hit_anyone
			
	return hit_anyone
#Basic single target magic attack
func fire_bolt(attacker, turn_queue) -> bool:
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null:
			var line = draw_attack_line(attacker, player)
			await get_tree().create_timer(1.0).timeout
			var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains)
			
			if damage > 0:
				player.unit_stats.health -= damage
			else:
				damage = 0
				
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
	
func healing_spell(attacker, turn_queue, mana_cost) -> bool:
	if attacker.unit_stats.mana < mana_cost:
		return false
	
	for tile in attacker.circle_tiles:
		var ally = turn_queue.enemy_positions.find_key(tile)
		if ally != null and ally.unit_stats.health < ally.unit_stats.max_health / 2:
			var line = draw_attack_line(attacker, ally)
			await get_tree().create_timer(1.0).timeout
			
			var healing_health = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment)
			ally.unit_stats.health = min(ally.unit_stats.health + healing_health, ally.unit_stats.max_health)
			
			print(attacker.unit_stats.name, " is healing!")
			print("Healing ", ally.unit_stats.name, " for ", healing_health, " health!")
			print(ally.unit_stats.name, " has " + str(ally.unit_stats.health), " HP left")
			attacker.unit_stats.mana -= mana_cost
			
			line.queue_free()
			return true

	return false

#Heals 2 or more allies in it's radius (can include self)
func mass_healing(attacker, turn_queue, mana_cost) -> bool:
	var healed = false
	var valid_targets = []
	
	if attacker.unit_stats.mana >= mana_cost:

		for tile in attacker.circle_tiles:
			var ally = turn_queue.enemy_positions.find_key(tile)
			if ally != null and ally.unit_stats.health <= ally.unit_stats.max_health/2:
				valid_targets.append(ally)
				
		if valid_targets.size() >= 2:
			attacker.unit_stats.mana -= mana_cost
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

					healed = true
					line.queue_free()
		else:
			return healed
			
	else:
		print("No mana for mass_healing")
		print(attacker.unit_stats.mana, " mana left")
		return healed
			
	return healed

#increases armor_class of attacker (can only be used once per unit)
func iron_defense(attacker, turn_queue, mana_cost) -> bool:
	if attacker.unit_stats.mana >= mana_cost and attacker.unit_stats.used_iron_defense == false:
		if attacker.unit_stats.health <= attacker.unit_stats.max_health/2:
			await get_tree().create_timer(1.0).timeout

			var armor = 2
			attacker.unit_stats.armor_class += armor

			print(attacker.unit_stats.name, " used Iron Defense!")
			print("Defense increased by ", armor)
			print("Current armor: ", attacker.unit_stats.armor_class)
			attacker.unit_stats.used_iron_defense = true
			attacker.unit_stats.mana -= mana_cost
			
			return true
		else:
			return false
	else:
		return false

#spawns in enemies during the game (enemy abilities to call reinforcements)
func call_reinforcements(attacker, turn_queue, enemy_name, mana_cost):
	if attacker.unit_stats.mana >= mana_cost:
		attacker.unit_stats.mana -= mana_cost
		turn_queue.spawn_enemy_during_battle(enemy_name)
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

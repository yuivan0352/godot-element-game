extends Unit

var unit_moves = {
	#Put most important move to least important
	"Warrior": ["Iron Defense","Cleave", "Slash", "Arrow Shot"],
	"Mage": ["Mass Healing", "Healing Spell","Mage Armor","Magic Missles","Fire Bolt", "Necrotic Touch", "Unarmed Strike"],
	"Archer": ["Multi-Shot","Piercing Shot","Arrow Shot", "Stab"],
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
		var roll = rng.randi_range(1, 20)
		match move:
			"Iron Defense":
				move_used = await(iron_defense(attacker, attacker.turn_queue, 2, roll))
			"Mage Armor":
				move_used = await(iron_defense(attacker, attacker.turn_queue, 1, roll))
			"Necrotic Touch":
				move_used = await(necrotic_touch(attacker, attacker.turn_queue, 1, roll))
			"Cleave":
				move_used = await(cleave(attacker, attacker.turn_queue, roll))
			"Slash":
				move_used = await(slash(attacker, attacker.turn_queue, roll))
			"Unarmed Strike":
				move_used = await(slash(attacker, attacker.turn_queue, roll))
			"Pounce":
				move_used = await(slash(attacker, attacker.turn_queue, roll))
			"Stab":
				move_used = await(slash(attacker, attacker.turn_queue, roll))
							
		if move_used:
			print(move, " has been used (roll: ", roll, ")")
			break

	await get_tree().create_timer(1.5).timeout
	attacker.turn_complete.emit()

func use_ranged_move(attacker):
	var unit_name = attacker.unit_stats.name 
	available_moves = unit_moves.get(unit_name, [])
	for move in available_moves:
		var move_used = false
		var roll = rng.randi_range(1, 20)
		match move:
			"Iron Defense":
				move_used = await(iron_defense(attacker, attacker.turn_queue, 2, roll))
			"Healing Spell":
				move_used = await(healing_spell(attacker, attacker.turn_queue, 1, roll))
			"Mass Healing":
				move_used = await(mass_healing(attacker, attacker.turn_queue, 2, roll))
			"Mage Armor":
				move_used = await(iron_defense(attacker, attacker.turn_queue, 1, roll))
			"Magic Missiles":
				move_used = await(magic_missles(attacker, attacker.turn_queue, 2))
			"Multi-Shot":
				move_used = await(multi_shot(attacker, attacker.turn_queue, 2))
			"Royal Reproduction":
				move_used = await(call_reinforcements(attacker, attacker.turn_queue, "Slime", 2))
			"Fire Bolt":
				move_used = await(fire_bolt(attacker, attacker.turn_queue, roll))
			"Piercing Shot":
				move_used = await(piercing_shot(attacker, attacker.turn_queue, 1, roll))
			"Arrow Shot":
				move_used = await(arrow_shot(attacker, attacker.turn_queue, roll))
				
		if move_used:
			print(move, " has been used (roll: ", roll, ")")
			break
		
	await get_tree().create_timer(1.5).timeout
	attacker.turn_complete.emit()

#Single melee basic attack 
func slash(attacker, turn_queue, roll) -> bool:
	attacker._update_adj_tiles()
	
	for tile in attacker.adjacent_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null and roll >= player.unit_stats.armor_class:
			var line = draw_attack_line(attacker, player)
			await get_tree().create_timer(1.0).timeout
			var damage = (rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains)) - rng.randi_range(1, player.unit_stats.armor_class)
			
			if damage > 0:
				player.unit_stats.health -= damage
			else:
				damage = 0
				
			print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)

			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				turn_queue.turn_order.erase(player)
				player.queue_free()

			line.queue_free()
			return true
	return false
	
#Attacks all players adjacent to the enemy in a circle
func cleave(attacker, turn_queue, roll) -> bool:
	attacker._update_adj_tiles()
	
	var hit_anyone = false
	var players = 0
	
	for tile in attacker.adjacent_tiles:
		if turn_queue.enemy_positions.find_key(tile):
			players += 1
	
	if players > 1:
		for tile in attacker.adjacent_tiles:
			var player = turn_queue.pc_positions.find_key(tile)
			if player != null and roll >= player.unit_stats.armor_class:
				var line = draw_attack_line(attacker, player)
				await get_tree().create_timer(1.5).timeout
				var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brawns)
				
				if damage > 0:
					player.unit_stats.health -= damage
				else:
					damage = 0
				
				print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)

				if player.unit_stats.health <= 0:
					print(player.unit_stats.name, " has been defeated!")
					turn_queue.pc_positions.erase(player)
					turn_queue.turn_order.erase(player)
					player.queue_free()

				hit_anyone = true
				line.queue_free()

	return hit_anyone

#Single target normal ranged attack
func arrow_shot(attacker, turn_queue, roll) -> bool:
	attacker._update_circle_tiles(5)
	
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null and roll >= player.unit_stats.armor_class:
			var line = draw_attack_line(attacker, player)
			await get_tree().create_timer(1.0).timeout
			var damage = (rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains)) 
			
			if damage > 0:
				player.unit_stats.health -= damage
			else:
				damage = 0
				
			print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)


			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				turn_queue.turn_order.erase(player)
				player.queue_free()

			line.queue_free()
			return true
	return false

#Ignores armor class for shot
func piercing_shot(attacker, turn_queue, mana_cost, roll) -> bool:
	attacker._update_circle_tiles(5)
	
	if attacker.unit_stats.mana < mana_cost:
		return false
		
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null and roll >= player.unit_stats.armor_class:
			var line = draw_attack_line(attacker, player)
			await get_tree().create_timer(1.0).timeout
			var damage = (rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains))
			
			if damage > 0:
				player.unit_stats.health -= damage
			else:
				damage = 0
				
			print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)

			attacker.unit_stats.mana -= mana_cost
			
			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				turn_queue.turn_order.erase(player)
				player.queue_free()

			line.queue_free()
			return true
	return false
	
#Single melee basic attack 
func necrotic_touch(attacker, turn_queue, mana_cost, roll) -> bool:
	attacker._update_adj_tiles()
	
	if attacker.unit_stats.mana >= mana_cost:
		
		for tile in attacker.adjacent_tiles:
			var player = turn_queue.pc_positions.find_key(tile)
			if player != null and roll >= player.unit_stats.armor_class:
				var line = draw_attack_line(attacker, player)
				await get_tree().create_timer(1.0).timeout
				var damage = (rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment))
				
				if damage > 0:
					player.unit_stats.health -= damage
				else:
					damage = 0
					
				print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)

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
	attacker._update_circle_tiles(5)
	
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
				var roll = rng.randi_range(1,20)
				if player != null and roll >= player.unit_stats.armor_class:
					var line = draw_attack_line(attacker, player)
					await get_tree().create_timer(1.5).timeout
					var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment)
					
					if damage > 0:
						player.unit_stats.health -= damage
					else:
						damage = 0
						
					print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)
					
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
	attacker._update_circle_tiles(5)
	
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
				var roll = rng.randi_range(1,20)
				if player != null and roll >= player.unit_stats.armor_class:
					var line = draw_attack_line(attacker, player)
					await get_tree().create_timer(1.5).timeout
					var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains)
					
					if damage > 0:
						player.unit_stats.health -= damage
					else:
						damage = 0
						
					print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)
					
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
func fire_bolt(attacker, turn_queue, roll) -> bool:
	attacker._update_circle_tiles(5)
	
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null and roll >= player.unit_stats.armor_class:
			var line = draw_attack_line(attacker, player)
			await get_tree().create_timer(1.0).timeout
			var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brains)
			
			if damage > 0:
				player.unit_stats.health -= damage
			else:
				damage = 0
				
			print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)

			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				turn_queue.turn_order.erase(player)
				player.queue_free()

			line.queue_free()
			return true
	return false
	
func healing_spell(attacker, turn_queue, mana_cost, roll) -> bool:
	attacker._update_circle_tiles(5)
	
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
func mass_healing(attacker, turn_queue, mana_cost, roll) -> bool:
	attacker._update_circle_tiles(5)
	
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
func iron_defense(attacker, turn_queue, mana_cost, roll) -> bool:
	if attacker.unit_stats.mana >= mana_cost and attacker.unit_stats.used_iron_defense == false:
		if attacker.unit_stats.health <= attacker.unit_stats.max_health/2:
			await get_tree().create_timer(1.0).timeout
			
			var armor = rng.randi_range(1,5)
			print(attacker.unit_stats.name, " increased his armor class by ", armor)
			print("Current armor class: ", attacker.unit_stats.armor_class)
			attacker.unit_stats.used_iron_defense = true
			attacker.unit_stats.mana -= mana_cost
			
			return true
		else:
			return false
	else:
		return false

#spawns in enemies during the game (enemy abilities to call reinforcements)
func call_reinforcements(attacker, turn_queue, enemy_name, mana_cost):
	var roll = rng.randi_range(1,20)
	
	if attacker.unit_stats.mana >= mana_cost:
		if roll >= 10:
			attacker.unit_stats.mana -= mana_cost
			turn_queue.spawn_enemy_during_battle(enemy_name)
			return true
		else:
			print(attacker.unit_stats.name, " failed to call reinforcements to battle")
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

extends Unit

var elements = ["Fire","Water","Earth","Wind"]

const Slash = preload("res://Scenes/Attack Effects/slash_effect.tscn")
const Buff = preload("res://Scenes/Attack Effects/buff.tscn")
const Curse = preload("res://Scenes/Attack Effects/curse.tscn")
const Explosion = preload("res://Scenes/Attack Effects/explosion.tscn")
const Beam = preload("res://Scenes/Attack Effects/beam.tscn")
const Heal = preload("res://Scenes/Attack Effects/heal.tscn")
const Reinforcement = preload("res://Scenes/Attack Effects/reinforcement.tscn")
const Magic_Melee = preload("res://Scenes/Attack Effects/magic_melee.tscn")


var unit_moves = {
	#Put most important move to least important
	"Warrior": ["Iron Defense","Arrow Shot","Cleave","Slash"],
	"Mage": ["Mass Healing", "Healing Spell","Aura Missile", "Necrotic Touch", "Unarmed Strike"],
	"Archer": ["Multi-Shot","Piercing Shot","Arrow Shot", "Stab"],
	"Slime": ["Slimy Steps","Pounce"],
	"Crocodile": ["Vicious Bite","Pounce"],
	"Spider": ["Sticky Webbing", "Poisonous Bite"],
	"Devil": ["Mass Explosion","Fire Bolt","Scratch"],
	"Scorpion": ["Poisonous Sting"],
	"Snake": ["Poisonous Bite", "Poison Spit"],
	"Skeleton Warrior": ["Hardened Bones","Slash"],
	"Slime Monster": ["Slimy Steps","Pounce"],
	"King Slime": ["Royal Reproduction", "Pounce"],
	"Cultist": ["Healing Spell","Hex", "Fire Bolt"],
	"The Omnipotent Eye": ["Obelisk Restoration","Boss Shout"]
}

var available_moves = []

func _ready() -> void:
	#Initalizes all elementals + obelisks into the unit_moves list
	for element in elements:
		var obelisk_name = element + " Obelisk"
		var elemental_name = element + " Elemental"
		var blast_name = element + " Blast"
		var melee_name = element + " Punch"
		unit_moves[obelisk_name] = ["Elemental Summoning", element + " Beam"]
		unit_moves[elemental_name] = [blast_name, melee_name]
		
	rng.randomize()

func max_mana(attacker):
	if attacker.unit_stats.mana > 5:
		attacker.unit_stats.mana = 5
		
func use_melee_move(attacker, target_tile):
	var unit_name = attacker.unit_stats.name 
	available_moves = unit_moves.get(unit_name, [])
	for move in available_moves:
		var move_used = false
		var roll = rng.randi_range(1, 20)
		match move:
			"Obelisk Restoration":
				move_used = await(obelisk_restoration(attacker, attacker.turn_queue, 4, roll))
			"Elemental Summoning":
				#Summons specific elemental for specific obelisk with that element
				for element in elements:
					if attacker.unit_stats.name.findn(element) != -1:
						move_used = await(call_reinforcements(attacker, attacker.turn_queue, element + " Elemental", 5, roll))
			"Iron Defense":
				move_used = await(self_buff("Iron Defense", attacker, attacker.turn_queue,"armor_class",5,-2,2,roll))	
			"Hardened Bones":
				move_used = await(self_buff("Hardened Bones", attacker, attacker.turn_queue,"armor_class",5,-2,2,roll))	
			"Necrotic Touch":
				move_used = await(magic_melee(attacker, target_tile, attacker.turn_queue, 2, roll))
			"Cleave":
				move_used = await(cleave(attacker, attacker.turn_queue, roll))
			"Vicious Bite":
				move_used = await(basic_melee(attacker, target_tile, attacker.turn_queue, 3, 5, 4, roll))
			"Scratch":
				move_used = await(basic_melee(attacker, target_tile, attacker.turn_queue, 1, 3, 0, roll))
			"Unarmed Strike":
				move_used = await(basic_melee(attacker, target_tile, attacker.turn_queue, 0, 1, 0, roll))
			"Pounce":
				move_used = await(basic_melee(attacker, target_tile, attacker.turn_queue, 1, 2, 0, roll))
			"Poisonous Bite":
				move_used = await(poison_melee(attacker, target_tile, attacker.turn_queue, roll))
			"Poisonous Sting":
				move_used = await(poison_melee(attacker, target_tile, attacker.turn_queue, roll))
			"Stab":
				move_used = await(basic_melee(attacker, target_tile, attacker.turn_queue, 1, 2, 0, roll))
			"Slash":
				move_used = await(basic_melee(attacker, target_tile, attacker.turn_queue, 1, 3, 0, roll))
			"Water Punch":
				move_used = await(magic_melee(attacker, target_tile, attacker.turn_queue, 2, roll))
			"Fire Punch":
				move_used = await(magic_melee(attacker, target_tile, attacker.turn_queue, 2, roll))
			"Rock Punch":
				move_used = await(magic_melee(attacker, target_tile, attacker.turn_queue, 2, roll))
			"Wind Punch":
				move_used = await(magic_melee(attacker, target_tile, attacker.turn_queue, 2, roll))			
			"Boss Shout":
				move_used = await(boss_dialogue())
				
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
			"Obelisk Restoration":
				move_used = await(obelisk_restoration(attacker, attacker.turn_queue, 4, roll))
			"Elemental Summoning":
				#Summons specific elemental for specific obelisk with that element
				for element in elements:
					if attacker.unit_stats.name.findn(element) != -1:
						move_used = await(call_reinforcements(attacker, attacker.turn_queue, element + " Elemental", 2, roll))
			"Slimy Steps":
				move_used = await(self_buff("Slimy Steps", attacker, attacker.turn_queue,"movement_speed",5,-5,2,roll))
			"Iron Defense":
				move_used = await(self_buff("Iron Defense", attacker, attacker.turn_queue,"armor_class",4,-2,2,roll))
			"Water Blast":
				move_used = await(magic_ranged(attacker, attacker.turn_queue, 2, roll))
			"Fire Blast":
				move_used = await(magic_ranged(attacker, attacker.turn_queue, 2, roll))
			"Rock Blast":
				move_used = await(magic_ranged(attacker, attacker.turn_queue, 2, roll))
			"Wind Blast":
				move_used = await(magic_ranged(attacker, attacker.turn_queue, 2, roll))
			"Water Beam":
				move_used = await(magic_ranged(attacker, attacker.turn_queue, 0, roll))
			"Fire Beam":
				move_used = await(magic_ranged(attacker, attacker.turn_queue, 0, roll))
			"Rock Beam":
				move_used = await(magic_ranged(attacker, attacker.turn_queue, 0, roll))
			"Wind Beam":
				move_used = await(magic_ranged(attacker, attacker.turn_queue, 0, roll))
			"Hex":
				move_used = await(hex_ranged(attacker,attacker.turn_queue, 5, roll))
			"Sticky Webbing":
				move_used = await(slow_ranged(attacker, attacker.turn_queue, "Enweb", roll))
			"Healing Spell":
				move_used = await(healing_spell(attacker, attacker.turn_queue, 3, roll))
			"Mass Healing":
				move_used = await(mass_healing(attacker, attacker.turn_queue, 4, roll))
			"Mass Explosion":
				move_used = await(magic_missiles(attacker, attacker.turn_queue, 3))
			"Multi-Shot":
				move_used = await(multi_shot(attacker, attacker.turn_queue, 2))
			"Royal Reproduction":
				move_used = await(call_reinforcements(attacker, attacker.turn_queue, "Slime", 2, roll))
			"Poison Spit":
				move_used = await(poison_ranged(attacker, attacker.turn_queue, roll))
			"Aura Missile":
				move_used = await(magic_ranged(attacker, attacker.turn_queue, 0, roll))
			"Fire Bolt":
				move_used = await(magic_ranged(attacker, attacker.turn_queue, 0, roll))
			"Piercing Shot":
				move_used = await(piercing_shot(attacker, attacker.turn_queue, 1, roll))
			"Arrow Shot":
				move_used = await(arrow_shot(attacker, attacker.turn_queue, roll))
			"Boss Shout":
				move_used = await(boss_dialogue())
		if move_used:
			print(move, " has been used (roll: ", roll, ")")
			break
		else:
			continue
			
	await get_tree().create_timer(1.5).timeout
	attacker.turn_complete.emit()

func boss_dialogue():
	var boss_lines = [
		"YOU WILL NOT BEAT ME AS LONG AS MY OBELISKS STAND! I AM IMMORTAL!",
		"YOUR ATTACKS ARE FUTILE! THE OBELISKS GRANT ME UNENDING POWER!",
		"AS LONG AS THE OBELISKS STAND, I CANNOT FALL!",
		"YOU DARE CHALLENGE ME? FOOLS!",
		"MY POWER IS BEYOND YOUR UNDERSTANDING!"
	]

	var evil_laughs = [
		"MUHAHAHAHA!",
		"FOOLISH MORTALS!",
		"YOUR END DRAWS NEAR!",
		"IS THAT ALL YOU’VE GOT?",
		"I FEED ON YOUR HOPELESSNESS!"
	]

	var chosen_line = boss_lines[randi() % boss_lines.size()]
	var chosen_laugh = evil_laughs[randi() % evil_laughs.size()]

	print(chosen_line)
	await get_tree().create_timer(0.5).timeout
	print(chosen_laugh)
	return true


func check_status_effect(attacker, player, turn_queue, status_name):
	if not turn_queue.status_effects.has(player):
		return true
		
	for effect in turn_queue.status_effects[player]:
		if effect.name == status_name:
			return false 
			
func apply_status_effect(attacker, player, turn_queue: TurnQueue, status_name: String, stat_reduction: int, stat_altered: String, turns: int) -> bool:

	var status_effect = {
		"name": status_name,
		"duration": turns,
		"stat_altered": stat_altered,
		"stat_reduction": stat_reduction,
		"original_value": player.unit_stats.get(stat_altered),
		"changed_value": player.unit_stats.get(stat_altered) - stat_reduction
	}
	
	check_status_effect(attacker, player, turn_queue, status_name)
	
	if not turn_queue.status_effects.has(player):
		turn_queue.status_effects[player] = []

	turn_queue.status_effects[player].append(status_effect)
	
	if(attacker.unit_stats.name == player.unit_stats.name):
		print(attacker.unit_stats.name, " uses ", status_name, " for ", turns, " turns.")
	else:
		print(attacker.unit_stats.name, " applies ", status_name, " to ", player.unit_stats.name, " for ", turns, " turns.")
		
	return true

#Single melee basic attack 
func basic_melee(attacker, target_tile, turn_queue, min_damage: int, max_damage: int, mana_cost: int, roll) -> bool:
	
	if attacker.unit_stats.mana < mana_cost:
		return false
	
	var player = turn_queue.pc_positions.find_key(target_tile)
	if player != null:
		
		max_mana(attacker)
		attacker.unit_stats.mana -= mana_cost
	
		max_mana(attacker)
		
		if roll >= player.unit_stats.armor_class - (attacker.unit_stats.brawns - player.unit_stats.brawns):
			var line = draw_attack_line(attacker, player)
			
			var slash = Slash.instantiate()
			get_tree().current_scene.add_child(slash)
			slash.global_position = player.global_position
			slash.rotation = (player.global_position - attacker.global_position).angle()
		
			await get_tree().create_timer(1.0).timeout
			var damage = (rng.randi_range(min_damage, max_damage) + rng.randi_range(1, attacker.unit_stats.brawns))
			
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
		else:
			print(attacker.unit_stats.name, " missed")
			return true

	return false
	
#Attacks all players adjacent to the enemy in a circle
func cleave(attacker, turn_queue, roll) -> bool:

	var hit_anyone = false
	var players = 0
	
	for tile in attacker.adjacent_tiles:
		if turn_queue.enemy_positions.find_key(tile):
			players += 1
	
	if players > 1:
		for tile in attacker.adjacent_tiles:
			var player = turn_queue.pc_positions.find_key(tile)
			if player != null:
				if roll >= player.unit_stats.armor_class - (attacker.unit_stats.brawns - player.unit_stats.brawns):
					var line = draw_attack_line(attacker, player)
					
					var slash = Slash.instantiate()
					get_tree().current_scene.add_child(slash)
					slash.global_position = player.global_position
					slash.rotation = (player.global_position - attacker.global_position).angle()
		
		
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
				else:
					print(attacker.unit_stats.name + " missed " + player.unit_stats.name)
					
	return hit_anyone

#Single target normal ranged attack
func arrow_shot(attacker, turn_queue, roll) -> bool:
	attacker._update_circle_tiles(4)
	
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null:
			if roll >= player.unit_stats.armor_class - (attacker.unit_stats.brains - player.unit_stats.brains):
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
			else:
				print(attacker.unit_stats.name, " missed")
				return true
		else:
			return false
	return false

#Ignores armor class for shot
func piercing_shot(attacker, turn_queue, mana_cost, roll) -> bool:
	attacker._update_circle_tiles(4)
	
	if attacker.unit_stats.mana < mana_cost:
		return false
		
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		
		if player != null:
			max_mana(attacker)
			attacker.unit_stats.mana -= mana_cost
			max_mana(attacker)
			
			if roll >= player.unit_stats.armor_class - (attacker.unit_stats.brains - player.unit_stats.brains):
				var line = draw_attack_line(attacker, player)
				await get_tree().create_timer(1.0).timeout
				var damage = (rng.randi_range(2, 4) + rng.randi_range(1, attacker.unit_stats.brains))
				
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
			else:
				print(attacker.unit_stats.name, " missed")
				return true
	return false
	
#Single melee basic attack 
func magic_melee(attacker, target_tile, turn_queue, mana_cost, roll) -> bool:
	
	if attacker.unit_stats.mana < mana_cost:
		return false
		
	var player = turn_queue.pc_positions.find_key(target_tile)
	
	if player != null:
		max_mana(attacker)
		attacker.unit_stats.mana -= mana_cost
		max_mana(attacker)
		
		if roll >= player.unit_stats.armor_class - (attacker.unit_stats.bewitchment - player.unit_stats.bewitchment) :
			var line = draw_attack_line(attacker, player)
			
			var magic_melee = Magic_Melee.instantiate()
			get_tree().current_scene.add_child(magic_melee)
			magic_melee.global_position = player.global_position
			magic_melee.rotation = (player.global_position - attacker.global_position).angle()
			
			await get_tree().create_timer(1.0).timeout
			var damage = (rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment))
			
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
		else:
			print(attacker.unit_stats.name, " missed ", player.unit_stats.name)
			return true
			
	return false
	
#Attacks all within the radius
func magic_missiles(attacker, turn_queue, mana_cost) -> bool:
	attacker._update_circle_tiles(4)
	
	var hit_anyone = false
	var multiple_targets = []
	#checks if attacker has mana to use this for mana_cost
	if attacker.unit_stats.mana < mana_cost:
		return hit_anyone
		
	for tile in attacker.circle_tiles:
		var ally = turn_queue.pc_positions.find_key(tile)
		if ally != null:
			multiple_targets.append(ally)
			
	if multiple_targets.size() >= 2:
		
		max_mana(attacker)
		attacker.unit_stats.mana -= mana_cost
		max_mana(attacker)
		
		for tile in attacker.circle_tiles:
			var player = turn_queue.pc_positions.find_key(tile)
			var roll = rng.randi_range(1,20)
			
			if player != null:
				if roll >= player.unit_stats.armor_class - (attacker.unit_stats.bewitchment - player.unit_stats.bewitchment):
					var line = draw_attack_line(attacker, player)
					
					var explosion = Explosion.instantiate()
					get_tree().current_scene.add_child(explosion)
					explosion.global_position = player.global_position
			
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
					print(attacker.unit_stats.name, " missed ", player.unit_stats.name)
	else:
		return hit_anyone
			
	return hit_anyone

#Attacks all within the radius
func multi_shot(attacker, turn_queue, mana_cost) -> bool:
	attacker._update_circle_tiles(4)
	
	var hit_anyone = false
	var multiple_targets = []

	#checks if attacker has mana to use this for mana_cost
	if attacker.unit_stats.mana < mana_cost:
		return hit_anyone
		
	for tile in attacker.circle_tiles:
		var ally = turn_queue.pc_positions.find_key(tile)
		if ally != null:
			multiple_targets.append(ally)
			
	if multiple_targets.size() >= 2:
		
		max_mana(attacker)
		attacker.unit_stats.mana -= mana_cost
		max_mana(attacker)
		
		for tile in attacker.circle_tiles:
			var player = turn_queue.pc_positions.find_key(tile)
			var roll = rng.randi_range(1,20)
			if player != null:
				if roll >= player.unit_stats.armor_class - (attacker.unit_stats.brains - player.unit_stats.brains):
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
					print(attacker.unit_stats.name, " missed ", player.unit_stats.name)
	else:
		return hit_anyone
			
	return hit_anyone
	
#Basic single target magic attack
func magic_ranged(attacker, turn_queue, mana_cost, roll) -> bool:
	attacker._update_circle_tiles(4)
	
	if attacker.unit_stats.mana < mana_cost:
		return false
	
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null:
			
			max_mana(attacker)
			attacker.unit_stats.mana -= mana_cost
			max_mana(attacker)
			
			if roll >= player.unit_stats.armor_class - (attacker.unit_stats.bewitchment - player.unit_stats.bewitchment):
				var line = draw_attack_line(attacker, player)
				
				var beam = Beam.instantiate()
				get_tree().current_scene.add_child(beam)
				beam.global_position = player.global_position
				beam.rotation = (player.global_position - attacker.global_position).angle()
				
				await get_tree().create_timer(1.0).timeout
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

				line.queue_free()
				return true
			else:
				print(attacker.unit_stats.name, " missed ", player.unit_stats.name)
				return true
	return false

#Ranged attack that applies poison
func poison_ranged(attacker, turn_queue, roll) -> bool:
	attacker._update_circle_tiles(4)
	
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null:
			if roll >= player.unit_stats.armor_class - (attacker.unit_stats.brawns - player.unit_stats.brawns):
				var line = draw_attack_line(attacker, player)
				await get_tree().create_timer(1.0).timeout
				var damage = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment)
				
				player.unit_stats.health -= damage	
				print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)
				
				#Apply poison effect if you get the roll
				var poison_roll = rng.randi_range(1,20)
				if poison_roll >= player.unit_stats.armor_class:
					var poison_dmg = rng.randi_range(1, 2)
					player.unit_stats.health -= poison_dmg
					print(player.unit_stats.name + " is inflicted with poison and takes an extra " + str(poison_dmg) + " dmg!")
				else:
					print("Poison is not inflicted (", poison_roll, "/20)")
					
				if player.unit_stats.health <= 0:
					print(player.unit_stats.name, " has been defeated!")
					turn_queue.pc_positions.erase(player)
					turn_queue.turn_order.erase(player)
					player.queue_free()

				line.queue_free()
				return true
			else:
				print(attacker.unit_stats.name, " missed ", player.unit_stats.name)
				return true
	return false
	
#Melee attack that applies poison
func poison_melee(attacker, target_tile, turn_queue, roll) -> bool:
	var player = turn_queue.pc_positions.find_key(target_tile)
	if player != null:
		if roll >= player.unit_stats.armor_class - (attacker.unit_stats.brawns - player.unit_stats.brawns):
			var line = draw_attack_line(attacker, player)
			
			var slash = Slash.instantiate()
			get_tree().current_scene.add_child(slash)
			slash.global_position = player.global_position
			slash.rotation = (player.global_position - attacker.global_position).angle()
					
			await get_tree().create_timer(1.0).timeout
			var damage = (rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brawns))
			
			player.unit_stats.health -= damage					
			print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)
			
			#Apply poison effect if you get the roll
			var poison_roll = rng.randi_range(1,20)
			if poison_roll >= player.unit_stats.armor_class:
				var poison_dmg = rng.randi_range(1, 2)
				player.unit_stats.health -= poison_dmg
				print(player.unit_stats.name + " is inflicted with poison and takes an extra " + str(poison_dmg) + " dmg!")
			else:
				print("Poison is not inflicted (", poison_roll, "/20)")
				
			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				turn_queue.turn_order.erase(player)
				player.queue_free()

			line.queue_free()
			return true
		else:
			print(attacker.unit_stats.name, " missed")
			return true

	return false

func hex_ranged(attacker, turn_queue, mana_cost, roll) -> bool:
	attacker._update_circle_tiles(4)
	
	if attacker.unit_stats.mana < mana_cost:
		return false
	
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null:
			
			var hex_curses = ["Hex: Brawns", "Hex: Brains", "Hex: Bewitchment"]
			
			for hex in hex_curses:
				if !check_status_effect(attacker,player,turn_queue,hex):
					return false
			
			max_mana(attacker)
			attacker.unit_stats.mana -= mana_cost
			max_mana(attacker)
			
			if roll >= player.unit_stats.armor_class - (attacker.unit_stats.bewitchment - player.unit_stats.bewitchment):
				
				var line = draw_attack_line(attacker, player)
				
				var curse = Curse.instantiate()
				get_tree().current_scene.add_child(curse)
				curse.global_position = player.global_position
					
				await get_tree().create_timer(1.0).timeout
				
				var affectable_stats = ["brains", "brawns", "bewitchment"]
				
				var stat_affected = affectable_stats[randi() % affectable_stats.size()]
			
				apply_status_effect(attacker,player,turn_queue,"Hex: " + stat_affected.capitalize(), 1,stat_affected,3)
				print(player.unit_stats.name + " is cursed and has their " + stat_affected.capitalize() + " stat lowered!")
				line.queue_free()
				return true
			else:
				print(attacker.unit_stats.name, " missed ", player.unit_stats.name)
				return true
	return false

#Applies slow
func slow_ranged(attacker, turn_queue, status_effect, roll) -> bool:
	attacker._update_circle_tiles(4)
	
	for tile in attacker.circle_tiles:
		var player = turn_queue.pc_positions.find_key(tile)
		if player != null:
			
			if !check_status_effect(attacker,player,turn_queue,status_effect):
				return false
				
			if roll >= player.unit_stats.armor_class:
				var line = draw_attack_line(attacker, player)
				await get_tree().create_timer(1.0).timeout
								
				#Apply slow effect if you get the roll
				print(player.unit_stats.name + " is inflicted with slow")
				apply_status_effect(attacker,player,turn_queue,status_effect,5,"movement_speed",3)
				line.queue_free()
				return true
			else:
				print(attacker.unit_stats.name, " missed ", player.unit_stats.name)
				return true
	return false

#Single melee basic attack 
func slow_melee(attacker, target_tile, turn_queue, status_effect, roll) -> bool:
	
	var player = turn_queue.pc_positions.find_key(target_tile)
	if player != null:
		
		if !check_status_effect(attacker,player,turn_queue,status_effect):
			return false
		
		if roll >= player.unit_stats.armor_class:
			var line = draw_attack_line(attacker, player)
			
			var slash = Slash.instantiate()
			get_tree().current_scene.add_child(slash)
			slash.global_position = player.global_position
			slash.rotation = (player.global_position - attacker.global_position).angle()
			
			await get_tree().create_timer(1.0).timeout
			var damage = (rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.brawns))
			
			player.unit_stats.health -= damage

			print(attacker.unit_stats.name, " rolled a ", roll, " and did ", damage, " to ", player.unit_stats.name, ": ", player.unit_stats.health, "/", player.unit_stats.max_health)
			
			#Apply slow effect if you get the roll
			var slow_roll = rng.randi_range(1,20)
			if slow_roll >= player.unit_stats.armor_class:
				print(player.unit_stats.name + " is inflicted with slow")
				apply_status_effect(attacker,player,turn_queue,status_effect,5,"movement_speed",3)
			else:
				print("Enweb is not inflicted (", slow_roll, "/20)")
			
			line.queue_free()
			return true
		else:
			print(attacker.unit_stats.name, " missed")
			return true

	return false
	
func healing_spell(attacker, turn_queue, mana_cost, roll) -> bool:
	attacker._update_circle_tiles(5)
	
	if attacker.unit_stats.mana < mana_cost:
		return false
	
	for tile in attacker.circle_tiles:
		var ally = turn_queue.enemy_positions.find_key(tile)
		if ally != null:
			if ally.unit_stats.health < ally.unit_stats.max_health / 2:
				
				max_mana(attacker)
				attacker.unit_stats.mana -= mana_cost
				max_mana(attacker)
				
				if roll >= ally.unit_stats.armor_class/2:
					var line = draw_attack_line(attacker, ally)
					
					var heal = Heal.instantiate()
					get_tree().current_scene.add_child(heal)
					heal.global_position = attacker.global_position
					
					await get_tree().create_timer(1.0).timeout
					
					var healing_health = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment)
					ally.unit_stats.health = min(ally.unit_stats.health + healing_health, ally.unit_stats.max_health)
					
					print(attacker.unit_stats.name, " is healing!")
					print("Healing ", ally.unit_stats.name, " for ", healing_health, " health!")
					print(ally.unit_stats.name, " has " + str(ally.unit_stats.health), " HP left")
					
					line.queue_free()
					return true
				else:
					print(attacker.unit_stats.name, " couldn't heal " , ally.unit_stats.name)
					return true	
	return false

#Heals 2 or more allies in it's radius (can include self)
func mass_healing(attacker, turn_queue, mana_cost, roll) -> bool:
	attacker._update_circle_tiles(5)
	
	var healed = false
	var valid_targets = []
	
	if attacker.unit_stats.mana < mana_cost:
		return healed

	for tile in attacker.circle_tiles:
		var ally = turn_queue.enemy_positions.find_key(tile)
		if ally != null and ally.unit_stats.health <= ally.unit_stats.max_health/2:
			valid_targets.append(ally)
			
	if valid_targets.size() >= 2:
		max_mana(attacker)
		attacker.unit_stats.mana -= mana_cost
		max_mana(attacker)
		
		for tile in attacker.circle_tiles:
			var ally = turn_queue.enemy_positions.find_key(tile)
			
			if ally != null:
				if ally.unit_stats.health <= ally.unit_stats.max_health/2:
					if roll >= ally.unit_stats.armor_class/2:
						var line = draw_attack_line(attacker, ally)
						
						var heal = Heal.instantiate()
						get_tree().current_scene.add_child(heal)
						heal.global_position = attacker.global_position
					
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
						print(attacker.unit_stats.name, " couldn't heal " , ally.unit_stats.name)
	else:
		return healed
			
	return healed

#Heals 2 or more allies in it's radius (can include self)
func obelisk_restoration(attacker, turn_queue, mana_cost, roll) -> bool:
	attacker._update_circle_tiles(50)
	
	var healed = false
	var valid_targets = []
	
	if attacker.unit_stats.mana < mana_cost:
		return healed

	for tile in attacker.circle_tiles:
		var ally = turn_queue.enemy_positions.find_key(tile)
		#checks for allies with name Obelisk so it can heal them.
		for element in elements:
			if ally != null and ally.unit_stats.health <= ally.unit_stats.max_health/4 and (ally.unit_stats.name == element + " Obelisk"):
				valid_targets.append(ally)
				
	if valid_targets.size() >= 2:
		
		max_mana(attacker)
		attacker.unit_stats.mana -= mana_cost
		max_mana(attacker)
		
		for tile in attacker.circle_tiles:
			var ally = turn_queue.enemy_positions.find_key(tile)
			
			for element in elements:
				if ally != null and ally.unit_stats.health <= ally.unit_stats.max_health/4 and (ally.unit_stats.name == element + " Obelisk"):
					if roll >= ally.unit_stats.armor_class/2:
						var line = draw_attack_line(attacker, ally)
						
						var heal = Heal.instantiate()
						get_tree().current_scene.add_child(heal)
						heal.global_position = attacker.global_position
						
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
						print(attacker.unit_stats.name, " couldn't heal " , ally.unit_stats.name)
	else:
		return healed
			
	return healed

func self_buff(buff_name: String, attacker, turn_queue, stat_affected, mana_cost:int, stat_change: int, num_of_turns: int, roll):
	if attacker.unit_stats.mana < mana_cost or attacker.unit_stats.used_self_buff == true:
		return false
	
	if !check_status_effect(attacker,attacker,turn_queue,buff_name):
		return false
	
	print("Before taking away mana: " + str(attacker.unit_stats.mana))
	
	attacker.unit_stats.mana -= mana_cost
	
	print("After taking away mana: " + str(attacker.unit_stats.mana))
	
	if roll >= attacker.unit_stats.armor_class:
		
		var buff = Buff.instantiate()
		get_tree().current_scene.add_child(buff)
		buff.global_position = attacker.global_position
			
		await get_tree().create_timer(1.0).timeout		
		# -1 to add instead of subtracting
		apply_status_effect(attacker,attacker,turn_queue,buff_name,stat_change,stat_affected,num_of_turns)
		attacker.unit_stats.used_self_buff = true
		return true
	else:
		print(attacker.unit_stats.name, " missed")
		return true

#spawns in enemies during the game (enemy abilities to call reinforcements)
func call_reinforcements(attacker, turn_queue, enemy_name, mana_cost, roll):
	if attacker.unit_stats.mana < mana_cost:
		return false
	
	max_mana(attacker)
	attacker.unit_stats.mana -= mana_cost
	max_mana(attacker)
	
	if roll >= attacker.unit_stats.armor_class:
		
		var reinforcement = Reinforcement.instantiate()
		get_tree().current_scene.add_child(reinforcement)
		reinforcement.global_position = attacker.global_position
		
		turn_queue.spawn_enemy_during_battle(enemy_name)
		return true
	else:
		print(attacker.unit_stats.name, " failed to call reinforcements into battle")
		return true

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

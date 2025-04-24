extends Unit


# Define unit moves by class
var unit_moves = {
	"Warrior": ["bow_shot", "slash"],
	"Mage": ["magic_missles", "slash"],
	"Archer": ["bow_shot", "slash"],
	"Slime": ["bow_shot", "slash"]
}

# List to store available moves for the unit
var available_moves = []


func _ready() -> void:
	rng.randomize()


func use_melee_move(attacker):
		
	var unit_name = attacker.unit_stats.name 
	available_moves = unit_moves.get(unit_name, []) 
	for move in available_moves:
		var move_used = false
		match move:
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
			"bow_shot":
				move_used = await(bow_shot(attacker, attacker.turn_queue, tile_layer_zero))
			"magic_missles":
				move_used = await(magic_missles(attacker, attacker.turn_queue, tile_layer_zero))
			
		if move_used:
			print(move, " has been used")
			break
		
	
	await get_tree().create_timer(1.5).timeout
	attacker.turn_complete.emit()

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
				turn_queue.pc_positions.erase(turn_queue.pc_positions.find_key(tile))
				player.queue_free()
				tile_layer_zero._unsolid_coords(tile)

			line.queue_free()
			return true
	return false

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
				player.queue_free()
				tile_layer_zero._unsolid_coords(tile)

			line.queue_free()
			return true
	return false

func magic_missles(attacker, turn_queue, tile_layer_zero) -> bool:
	var hit_anyone = false
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

			if player.unit_stats.health <= 0:
				print(player.unit_stats.name, " has been defeated!")
				turn_queue.pc_positions.erase(player)
				player.queue_free()
				tile_layer_zero._unsolid_coords(tile)

			hit_anyone = true
			line.queue_free()

	return hit_anyone

func healing_spell(attacker, circle_tiles: Array, turn_queue, tile_layer_zero) -> bool:
	for tile in circle_tiles:
		var ally = turn_queue.enemy_positions.find_key(tile)
		if ally != null:
			var line = draw_attack_line(attacker, ally)
			await get_tree().create_timer(1.0).timeout
			var healing_health = rng.randi_range(1, 3) + rng.randi_range(1, attacker.unit_stats.bewitchment)
			ally.unit_stats.health += healing_health
			print(attacker.unit_stats.name, " is healing!")
			print("Healing ", ally.unit_stats.name, " for ", healing_health, " health!")
			print(ally.unit_stats.name, " has " + str(ally.unit_stats.health), " HP left")

			line.queue_free()
			return true
	return false

# Draw attack line function
func draw_attack_line(attacker: Node2D, target: Node2D) -> Line2D:
	var line = Line2D.new()
	line.width = 1
	line.z_index = 100
	line.default_color = Color(0, 0, 0, 0.2)
	line.add_point(attacker.global_position)
	line.add_point(target.global_position)
	add_child(line)
	return line

# Timer to clear the attack line
func _on_line_timer_timeout(line: Line2D, timer: Timer) -> void:
	if line:
		line.queue_free()
	if timer:
		timer.queue_free()

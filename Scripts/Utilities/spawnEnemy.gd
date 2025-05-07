extends Node2D

# Preload enemy scenes and stat files
var enemy_scenes: Dictionary = {

	"Warrior": preload("res://Scenes/Enemy/EnemyWarrior.tscn"),
	"Archer": preload("res://Scenes/Enemy/EnemyArcher.tscn"),
	"Mage": preload("res://Scenes/Enemy/EnemyMage.tscn"),
	#"Crocodile": preload("res://Scenes/Enemy/Crocodile.tscn"),
	#"Cultist": preload("res://Scenes/Enemy/Cultist.tscn"),
	#"King Slime": preload("res://Scenes/Enemy/EnemyKingSlime.tscn"),
	#"Snake": preload("res://Scenes/Enemy/EnemySnake.tscn"),
	#"Hungershroom": preload("res://Scenes/Enemy/Hungershroom.tscn"),
	#"Scorpion": preload("res://Scenes/Enemy/Scorpion.tscn"),
	#"Skeleton Warrior": preload("res://Scenes/Enemy/SkeletonWarrior.tscn"),
	#"Slime Monster": preload("res://Scenes/Enemy/SlimeMonster.tscn"),
	#"Spider": preload("res://Scenes/Enemy/Spider.tscn")

	
}

var enemy_stats: Dictionary = {
	
	"Warrior": preload("res://Resources/Stats/Enemies/EnemyWarrior.tres"),
	"Archer": preload("res://Resources/Stats/Enemies/EnemyArcher.tres"),
	"Mage": preload("res://Resources/Stats/Enemies/EnemyMage.tres"),
	#"Crocodile": preload("res://Resources/Stats/Enemies/Crocodile.tres"),
	#"Cultist": preload("res://Resources/Stats/Enemies/Cultist.tres"),
	#"Devil": preload("res://Resources/Stats/Enemies/Devil.tres"),
	#"King Slime": preload("res://Resources/Stats/Enemies/EnemyKingSlime.tres"),
	#"Snake": preload("res://Resources/Stats/Enemies/EnemySnake.tres"),
	#"Hungershroom": preload("res://Resources/Stats/Enemies/Hungershroom.tres"),
	#"Scorpion": preload("res://Resources/Stats/Enemies/Scorpion.tres"),
	#"Skeleton Warrior": preload("res://Resources/Stats/Enemies/SkeletonWarrior.tres"),
	#"Slime Monster": preload("res://Resources/Stats/Enemies/SlimeMonster.tres"),
	#"Spider": preload("res://Resources/Stats/Enemies/Spider.tres")
}

var reinforcement_enemy_scenes: Dictionary = {
	"Slime": preload("res://Scenes/Enemy/EnemySlime.tscn"),
	
	"Water Elemental": preload("res://Scenes/Enemy/WaterElemental.tscn"),
	"Fire Elemental": preload("res://Scenes/Enemy/FireElemental.tscn"),
	"Earth Elemental": preload("res://Scenes/Enemy/EarthElemental.tscn"),
	"Wind Elemental": preload("res://Scenes/Enemy/WindElemental.tscn"),
	
	"Water Obelisk": preload("res://Scenes/Enemy/WaterObelisk.tscn"),
	"Fire Obelisk": preload("res://Scenes/Enemy/FireObelisk.tscn"),
	"Earth Obelisk": preload("res://Scenes/Enemy/EarthObelisk.tscn"),
	"Wind Obelisk": preload("res://Scenes/Enemy/WindObelisk.tscn")
}

var reinforcement_enemy_stats: Dictionary = {
	"Slime": preload("res://Resources/Stats/Enemies/EnemySlime.tres"),
	
	"Water Elemental": preload("res://Resources/Stats/Enemies/WaterElemental.tres"),
	"Fire Elemental": preload("res://Resources/Stats/Enemies/FireElemental.tres"),
	"Earth Elemental": preload("res://Resources/Stats/Enemies/EarthElemental.tres"),
	"Wind Elemental": preload("res://Resources/Stats/Enemies/WindElemental.tres"),
 
	"Water Obelisk": preload("res://Resources/Stats/Enemies/WaterObelisk.tres"),
	"Fire Obelisk": preload("res://Resources/Stats/Enemies/FireObelisk.tres"),
	"Earth Obelisk": preload("res://Resources/Stats/Enemies/EarthObelisk.tres"),
	"Wind Obelisk": preload("res://Resources/Stats/Enemies/WindObelisk.tres")
}

var boss_enemy_scenes: Dictionary = {
	"Boss": preload("res://Scenes/Enemy/EnemyBoss.tscn")
}

var boss_enemy_stats: Dictionary = {
	"Boss": preload("res://Resources/Stats/Enemies/EnemyBoss.tres")
}




@onready var player_chars: Node2D = $"../Player"
@onready var user_interface = %UserInterface
var positions = {}
var tile_size = 16
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
func get_enemy_positions() -> Dictionary:
	return positions
func spawn_characters(count: int, layer: TileMapLayer) -> Array[Enemy]:
	var spawned_characters: Array[Enemy] = []
	var attempts = 0
	while spawned_characters.size() < count and attempts < count * 10:
		var character = spawn_character(layer)
		if character:
			spawned_characters.append(character)
		attempts += 1
	return spawned_characters

func spawn_character(layer: TileMapLayer) -> Enemy:
	var tile_position = Vector2i(randi() % tile_size*min(Global.level,2), randi() % tile_size*min(2,Global.level-1))
	var tile_data = layer.get_cell_tile_data(tile_position)

	if tile_data and tile_data.get_custom_data("walkable") and !positions.has(tile_position) and !player_chars.positions.has(tile_position):
		var position = Vector2(tile_position) * tile_size + Vector2(tile_size / 2, tile_size / 2)
		
		var enemy_type = get_random_enemy_type()

		var char_instance = enemy_scenes[enemy_type].instantiate()
		var stats = enemy_stats[enemy_type].duplicate()
		
		char_instance.unit_stats = stats
		char_instance.global_position = position
		add_child(char_instance)
		
		positions[layer.local_to_map(char_instance.global_position)] = char_instance
		char_instance.update_action_econ.connect(user_interface._update_actions)
		
		return char_instance
	
	return null 
	
#Can spawn enemies when the battle already started (used for moves like calling for reinforcements)
func spawn_specific_enemy(enemy_type: String, layer: TileMapLayer) -> Enemy:
	var attempts = 0
	while attempts < 20:
		var tile_position = Vector2i(rng.randi() % tile_size, rng.randi() % tile_size)
		var tile_data = layer.get_cell_tile_data(tile_position)

		if tile_data and tile_data.get_custom_data("walkable") and !positions.has(tile_position) and !player_chars.positions.has(tile_position):
			var position = Vector2(tile_position) * tile_size + Vector2(tile_size / 2, tile_size / 2)
			
			var char_instance = reinforcement_enemy_scenes[enemy_type].instantiate()
			var stats = reinforcement_enemy_stats[enemy_type].duplicate()
			
			char_instance.unit_stats = stats
			char_instance.global_position = position
			add_child(char_instance)

			var map_pos = layer.local_to_map(char_instance.global_position)
			positions[map_pos] = char_instance
			char_instance.update_action_econ.connect(user_interface._update_actions)

			return char_instance
		attempts += 1
	
	return null

func get_random_enemy_type() -> String:
	var enemy_keys = enemy_scenes.keys()
	return enemy_keys[rng.randi_range(0, enemy_keys.size() - 1)]

func spawn_2x2_enemy_center(enemy_type: String, layer: TileMapLayer) -> Enemy:
	var map_size = layer.get_used_rect().size
	var center = layer.get_used_rect().position + map_size / 2
	var top_left = Vector2i(center) - Vector2i(1, 1)  # Adjust to top-left of 2x2 area
	var tile_positions = [
		top_left,                  # Top-left
		top_left + Vector2i(1, 0), # Top-right
		top_left + Vector2i(0, 1), # Bottom-left
		top_left + Vector2i(1, 1), # Bottom-right
	]
	var can_spawn = true
	for pos in tile_positions:
		var tile_data = layer.get_cell_tile_data(pos)
		if !tile_data or !tile_data.get_custom_data("walkable") or positions.has(pos) or player_chars.positions.has(pos):
			can_spawn = false
			break
	if can_spawn:
		# Spawn the boss in the bottom-right
		var char_instance = boss_enemy_scenes[enemy_type].instantiate()
		var stats = boss_enemy_stats[enemy_type].duplicate()
		char_instance.unit_stats = stats
		# Place boss at bottom-right of 2x2 block
		var world_position = Vector2(top_left + Vector2i(1, 1)) * tile_size + Vector2(tile_size / 2, tile_size / 2)
		char_instance.global_position = world_position
		add_child(char_instance)
		
		# Spawn placeholders in the remaining 3 tiles to fill the 2x2 grid
		var placeholder_positions = [
			tile_positions[0], # Top-left
			tile_positions[1], # Top-right
			tile_positions[2], # Bottom-left
		]
		
		var placeholders = []
		for i in range(3):
			var placeholder = boss_enemy_scenes["Placeholder"].instantiate()
			var placeholder_stats = boss_enemy_stats["Placeholder"].duplicate()
			placeholder.unit_stats = placeholder_stats
			
			# Set position for the placeholder
			var pos = placeholder_positions[i]
			var placeholder_world_pos = Vector2(pos) * tile_size + Vector2(tile_size / 2, tile_size / 2)
			placeholder.global_position = placeholder_world_pos
			
			# Make placeholder invisible but with collision
			placeholder.visible = false
			
			add_child(placeholder)
			placeholders.append(placeholder)
			
			# Register the placeholder in positions dictionary
			positions[pos] = placeholder
		
		# Register the boss in positions dictionary
		positions[tile_positions[3]] = char_instance
		
		# Connect signals
		char_instance.update_action_econ.connect(user_interface._update_actions)
		
		# Spawn obelisks around the boss in cardinal directions
		var boss_map_pos = layer.local_to_map(char_instance.global_position)
		
		# Define cardinal directions and obelisk types
		var obelisk_placements = {
			"north": {"offset": Vector2i(-1, -5), "type": "Water Obelisk"},
			"south": {"offset": Vector2i(0, 5), "type": "Fire Obelisk"},
			"east": {"offset": Vector2i(5, 0), "type": "Wind Obelisk"},
			"west": {"offset": Vector2i(-5, 0), "type": "Earth Obelisk"}
		}
		
		# Spawn an obelisk in each direction
		for direction in obelisk_placements:
			var target_pos = boss_map_pos + obelisk_placements[direction]["offset"]
			var obelisk_type = obelisk_placements[direction]["type"]
			var obelisk_spawned = false
			
			# Check if the position is valid
			var tile_data = layer.get_cell_tile_data(target_pos)
			if tile_data and tile_data.get_custom_data("walkable") and !positions.has(target_pos) and !player_chars.positions.has(target_pos):
				# Spawn obelisk at exact position
				var obelisk_position = Vector2(target_pos) * tile_size + Vector2(tile_size / 2, tile_size / 2)
				var obelisk_instance = reinforcement_enemy_scenes[obelisk_type].instantiate()
				var obelisk_stats = reinforcement_enemy_stats[obelisk_type].duplicate()
				
				obelisk_instance.unit_stats = obelisk_stats
				obelisk_instance.global_position = obelisk_position
				add_child(obelisk_instance)
				
				positions[target_pos] = obelisk_instance
				obelisk_instance.update_action_econ.connect(user_interface._update_actions)
				obelisk_spawned = true
			else:
				# Try nearby positions if exact position isn't available
				for offset_x in range(-1, 2):
					for offset_y in range(-1, 2):
						if offset_x == 0 and offset_y == 0:
							continue
						
						var alternate_pos = target_pos + Vector2i(offset_x, offset_y)
						tile_data = layer.get_cell_tile_data(alternate_pos)
						if tile_data and tile_data.get_custom_data("walkable") and !positions.has(alternate_pos) and !player_chars.positions.has(alternate_pos):
							# Spawn obelisk at alternate position
							var obelisk_position = Vector2(alternate_pos) * tile_size + Vector2(tile_size / 2, tile_size / 2)
							var obelisk_instance = reinforcement_enemy_scenes[obelisk_type].instantiate()
							var obelisk_stats = reinforcement_enemy_stats[obelisk_type].duplicate()
							
							obelisk_instance.unit_stats = obelisk_stats
							obelisk_instance.global_position = obelisk_position
							add_child(obelisk_instance)
							
							positions[alternate_pos] = obelisk_instance
							obelisk_instance.update_action_econ.connect(user_interface._update_actions)
							obelisk_spawned = true
							break
					if obelisk_spawned:
						break
		
		return char_instance
	return null

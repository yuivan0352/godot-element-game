extends Node2D

# Preload enemy scenes and stat files
var enemy_scenes: Dictionary = {
	"Warrior": preload("res://Scenes/Enemy/EnemyWarrior.tscn"),
	"Archer": preload("res://Scenes/Enemy/EnemyArcher.tscn"),
	"Mage": preload("res://Scenes/Enemy/EnemyMage.tscn"),
	"King Slime": preload("res://Scenes/Enemy/EnemyKingSlime.tscn"),
}

var enemy_stats: Dictionary = {
	"Warrior": preload("res://Resources/Stats/Enemies/EnemyWarrior.tres"),
	"Archer": preload("res://Resources/Stats/Enemies/EnemyArcher.tres"),
	"Mage": preload("res://Resources/Stats/Enemies/EnemyMage.tres"),
	"King Slime": preload("res://Resources/Stats/Enemies/EnemyKingSlime.tres"),
}

var reinforcement_enemy_scenes: Dictionary = {
	"Slime": preload("res://Scenes/Enemy/EnemySlime.tscn"),
	"Elemental": preload("res://Scenes/Enemy/EnemyElemental.tscn")
}

var reinforcement_enemy_stats: Dictionary = {
	"Slime": preload("res://Resources/Stats/Enemies/EnemySlime.tres"),
	"Elemental": preload("res://Resources/Stats/Enemies/EnemyElemental.tres")
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
	var tile_position = Vector2i(randi() % tile_size, randi() % tile_size)
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
		top_left,
		top_left + Vector2i(1, 0),
		top_left + Vector2i(0, 1),
		top_left + Vector2i(1, 1),
	]

	var can_spawn = true
	for pos in tile_positions:
		var tile_data = layer.get_cell_tile_data(pos)
		if !tile_data or !tile_data.get_custom_data("walkable") or positions.has(pos) or player_chars.positions.has(pos):
			can_spawn = false
			break

	if can_spawn:
		var char_instance = boss_enemy_scenes[enemy_type].instantiate()
		var stats = boss_enemy_stats[enemy_type].duplicate()
		char_instance.unit_stats = stats

		# Place in center of 2x2 block
		var world_position = Vector2(top_left) * tile_size + Vector2(tile_size, tile_size)
		char_instance.global_position = world_position
		add_child(char_instance)

		for pos in tile_positions:
			positions[pos] = char_instance

		char_instance.update_action_econ.connect(user_interface._update_actions)
		return char_instance

	return null

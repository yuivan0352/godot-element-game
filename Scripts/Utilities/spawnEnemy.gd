extends Node2D

# Preload enemy scenes and stat files
var enemy_scenes: Dictionary = {
	"Warrior": preload("res://Scenes/Enemy/EnemyWarrior.tscn"),
	"Archer": preload("res://Scenes/Enemy/EnemyArcher.tscn"),
	"Mage": preload("res://Scenes/Enemy/EnemyMage.tscn"),
	"King Slime": preload("res://Scenes/Enemy/EnemyKingSlime.tscn"),
	"Slime": preload("res://Scenes/Enemy/EnemySlime.tscn")
}

var enemy_stats: Dictionary = {
	"Warrior": preload("res://Resources/Stats/Enemies/EnemyWarrior.tres"),
	"Archer": preload("res://Resources/Stats/Enemies/EnemyArcher.tres"),
	"Mage": preload("res://Resources/Stats/Enemies/EnemyMage.tres"),
	"King Slime": preload("res://Resources/Stats/Enemies/EnemyKingSlime.tres"),
	"Slime": preload("res://Resources/Stats/Enemies/EnemySlime.tres")
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
			
			var char_instance = enemy_scenes[enemy_type].instantiate()
			var stats = enemy_stats[enemy_type].duplicate()
			
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

extends Node2D

# Preload enemy scenes and stat files
var enemy_scenes: Dictionary = {
	"warrior": preload("res://Scenes/Enemy/EnemyWarrior.tscn"),
	"archer": preload("res://Scenes/Enemy/EnemyArcher.tscn"),
	"mage": preload("res://Scenes/Enemy/EnemyMage.tscn")
}

var enemy_stats: Dictionary = {
	"warrior": preload("res://Resources/Stats/Enemies/EnemyWarrior.tres"),
	"archer": preload("res://Resources/Stats/Enemies/EnemyArcher.tres"),
	"mage": preload("res://Resources/Stats/Enemies/EnemyMage.tres")
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
			character.unit_stats.name = str("Enemy", spawned_characters.size())
			spawned_characters.append(character)
		attempts += 1
	return spawned_characters

func spawn_character(layer: TileMapLayer) -> Enemy:
	var tile_position
	if Global.level == 1 or Global.level == 4:
		tile_position = Vector2i(randi() % tile_size, randi() % tile_size)
	else:
		tile_position = Vector2i(randi() % tile_size * 2, randi() % tile_size * 2)
		
	var tile_data = layer.get_cell_tile_data(tile_position)

	if tile_data and tile_data.get_custom_data("walkable") and !positions.has(tile_position) and !player_chars.positions.has(tile_position):
		var position = Vector2(tile_position) * tile_size + Vector2(tile_size / 2, tile_size / 2)
		
		# Get a random enemy type
		var enemy_type = get_random_enemy_type()

		# Instantiate and assign stats
		var char_instance = enemy_scenes[enemy_type].instantiate()
		var stats = enemy_stats[enemy_type].duplicate()
		
		char_instance.unit_stats = stats
		char_instance.global_position = position
		add_child(char_instance)
		
		positions[layer.local_to_map(char_instance.global_position)] = char_instance
		char_instance.update_action_econ.connect(user_interface._update_actions)
		
		return char_instance
	
	return null  # Avoid infinite recursion

func get_random_enemy_type() -> String:
	var enemy_keys = enemy_scenes.keys()
	return enemy_keys[rng.randi_range(0, enemy_keys.size() - 1)]

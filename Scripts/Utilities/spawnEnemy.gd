extends Node2D

# Preload enemy scenes and stat files
var enemy_scenes: Dictionary = {
	"Warrior": preload("res://Scenes/Enemy/EnemyWarrior.tscn"),
	"Archer": preload("res://Scenes/Enemy/EnemyArcher.tscn"),
	"Mage": preload("res://Scenes/Enemy/EnemyMage.tscn"),
	"Crocodile": preload("res://Scenes/Enemy/Crocodile.tscn"),
	"Cultist": preload("res://Scenes/Enemy/Cultist.tscn"),
	"King Slime": preload("res://Scenes/Enemy/EnemyKingSlime.tscn"),
	"Snake": preload("res://Scenes/Enemy/EnemySnake.tscn"),
	"Hungershroom": preload("res://Scenes/Enemy/Hungershroom.tscn"),
	"Scorpion": preload("res://Scenes/Enemy/Scorpion.tscn"),
	"Skeleton Warrior": preload("res://Scenes/Enemy/SkeletonWarrior.tscn"),
	"Slime Monster": preload("res://Scenes/Enemy/SlimeMonster.tscn"),
	"Spider": preload("res://Scenes/Enemy/Spider.tscn")

}

var enemy_stats: Dictionary = {
	"Warrior": preload("res://Resources/Stats/Enemies/EnemyWarrior.tres"),
	"Archer": preload("res://Resources/Stats/Enemies/EnemyArcher.tres"),
	"Mage": preload("res://Resources/Stats/Enemies/EnemyMage.tres"),
	"Crocodile": preload("res://Resources/Stats/Enemies/Crocodile.tres"),
	"Cultist": preload("res://Resources/Stats/Enemies/Cultist.tres"),
	"Devil": preload("res://Resources/Stats/Enemies/Devil.tres"),
	"King Slime": preload("res://Resources/Stats/Enemies/EnemyKingSlime.tres"),
	"Snake": preload("res://Resources/Stats/Enemies/EnemySnake.tres"),
	"Hungershroom": preload("res://Resources/Stats/Enemies/Hungershroom.tres"),
	"Scorpion": preload("res://Resources/Stats/Enemies/Scorpion.tres"),
	"Skeleton Warrior": preload("res://Resources/Stats/Enemies/SkeletonWarrior.tres"),
	"Slime Monster": preload("res://Resources/Stats/Enemies/SlimeMonster.tres"),
	"Spider": preload("res://Resources/Stats/Enemies/Spider.tres")
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
	"Boss": preload("res://Scenes/Enemy/EnemyBoss.tscn"),
	"Placeholder": preload("res://Scenes/Enemy/Placeholder.tscn")
}

var boss_enemy_stats: Dictionary = {
	"Boss": preload("res://Resources/Stats/Enemies/EnemyBoss.tres"),
	"Placeholder": preload("res://Resources/Stats/Enemies/Placeholder.tres")
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
	
func spawn_specific_enemy(enemy_name: String, layer: TileMapLayer) -> Enemy:
	var max_attempts = 20 
	var attempts = 0
	var tile_position: Vector2i
	var tile_data
	var char_instance: Enemy
	
	while attempts < max_attempts:
		tile_position = Vector2i(randi() % tile_size * min(Global.level, 2), randi() % tile_size * min(2, Global.level - 1))
		tile_data = layer.get_cell_tile_data(tile_position)
		
		if tile_data and tile_data.get_custom_data("walkable") and !positions.has(tile_position) and !player_chars.positions.has(tile_position):
			var position = Vector2(tile_position) * tile_size + Vector2(tile_size / 2, tile_size / 2)
			var stats
			
			if enemy_name == "Boss":
				char_instance = boss_enemy_scenes[enemy_name].instantiate()
				stats = boss_enemy_stats[enemy_name].duplicate()
			else:
				char_instance = reinforcement_enemy_scenes[enemy_name].instantiate()
				stats = reinforcement_enemy_stats[enemy_name].duplicate()
				
			char_instance.unit_stats = stats
			char_instance.global_position = position
			add_child(char_instance)
				
			positions[layer.local_to_map(char_instance.global_position)] = char_instance
			char_instance.update_action_econ.connect(user_interface._update_actions)
			
			return char_instance  
		
		attempts += 1 

	return null

func spawn_enemy(enemy_name: String, layer: TileMapLayer) -> Array[Enemy]:
	var spawned_characters: Array[Enemy] = []
	var character = spawn_specific_enemy(enemy_name, layer)
	
	if character:
		spawned_characters.append(character)

	return spawned_characters


func get_random_enemy_type() -> String:
	var enemy_keys = enemy_scenes.keys()
	return enemy_keys[rng.randi_range(0, enemy_keys.size() - 1)]

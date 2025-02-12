extends Node2D

var enemy = preload("res://Enemy/Enemy.tscn")
var tile_size = 16 
var enemy_spawned = 10
var enemy_spawned_tiles = {}

func _ready():
	for i in range(enemy_spawned):    
		spawn(Vector2i(randi() % tile_size, randi() % tile_size))
# 16x16 tile map spawned within boundaries

func spawn(tile_position: Vector2i):
	if not enemy_spawned_tiles.has(tile_position):
		var enemy_position = Vector2(tile_position.x, tile_position.y) * tile_size + Vector2(tile_size / 2, tile_size / 2)
		var instance = enemy.instantiate()
		instance.position = enemy_position
		add_child(instance)
		enemy_spawned_tiles[tile_position] = true
	else:
		spawn(Vector2i(randi() % tile_size, randi() % tile_size))
	# try again to randomize spawn at a unoccupied tile

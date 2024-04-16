extends Node2D

@onready var player = $"../Player"
@onready var tile_map = $"../TileMap"

func _process(_delta):
	queue_redraw()

func _draw():
	if player.current_point_path.is_empty():
		for i in player.test_point_path.size():
			tile_map.set_cell(1, player.test_point_path[i], 2, Vector2i(4, 2), 0)
	else:
		for i in player.current_point_path.size():
			tile_map.set_cell(1, player.current_point_path[i], 2, Vector2i(4, 2), 0)

extends Node2D

@onready var character = get_parent()
@onready var tile_map = $"../../../TileMap"

func _process(_delta):
	if get_parent() == get_parent().get_parent().active_char:
		queue_redraw()

func _draw():
	if character.current_point_path.is_empty():
		for i in character.hover_id_path.size():
			## set_cell(layer, location, which tilemap, which tile, alternative tile?)
			if i < character.movement_limit - character.moved_distance:
				tile_map.set_cell(1, character.hover_id_path[i], 2, Vector2i(4, 2), 0)
			else:
				tile_map.set_cell(1, character.hover_id_path[i], 3, Vector2i(4, 2), 0)
	else:
		for i in character.current_id_path.size():
			tile_map.set_cell(1, character.current_id_path[i], 2, Vector2i(4, 2), 0)

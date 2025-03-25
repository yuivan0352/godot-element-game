extends Node2D

@onready var character = $".."
var path_set: bool = false
var in_ui_element: bool = false

func _process(_delta):
	if character == character.turn_queue.active_char:
		queue_redraw()

func _draw():
	match character.mode:
		"idle":
			if !path_set:
				if !in_ui_element:
					for i in character.hover_id_path.size():
						if i < character.movement_limit - character.moved_distance:
							character.tile_layer_one.set_cell(character.hover_id_path[i], 2, Vector2i(4, 2), 0)
						else:
							character.tile_layer_one.set_cell(character.hover_id_path[i], 3, Vector2i(4, 2), 0)
		"moving":
			for i in character.current_id_path.size():
				character.tile_layer_one.set_cell(character.current_id_path[i], 2, Vector2i(4,2), 0)
		"attack", "magic_melee":
			for tile in character.adjacent_tiles:
				if tile != character.tile_layer_one.local_to_map(get_global_mouse_position()):
					if !character.tile_layer_zero.astar_grid.is_point_solid(tile) and tile.x >= 0 and tile.y >= 0:
						character.tile_layer_one.set_cell(tile, 2, Vector2i(4, 2), 0)
		"magic_ranged":
			for tile in character.circle_tiles:
				if tile != character.tile_layer_one.local_to_map(get_global_mouse_position()):
					if !character.tile_layer_zero.astar_grid.is_point_solid(tile) and tile.x >= 0 and tile.y >= 0:
						character.tile_layer_one.set_cell(tile, 2, Vector2i(4, 2), 0)
		"magic_line":
			for tile in character.line_tiles:
				if tile != character.tile_layer_one.local_to_map(get_global_mouse_position()):
					if !character.tile_layer_zero.astar_grid.is_point_solid(tile) and tile.x >= 0 and tile.y >= 0:
						character.tile_layer_one.set_cell(tile, 2, Vector2i(4, 2), 0)

func _on_character_unit_moving():
	path_set = true

func _on_character_unit_still():
	path_set = false
	character.mode = "idle"

func _on_ui_element_mouse_entered():
	in_ui_element = true

func _on_ui_element_mouse_exited():
	in_ui_element = false

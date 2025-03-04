extends Node2D

@onready var character = $".."
var path_set: bool = false
var in_ui_element: bool = false

func _process(_delta):
	if character == character.turn_queue.active_char:
		queue_redraw()

func _draw():
	if !path_set:
		if !in_ui_element:
			for i in character.hover_id_path.size():
				if i < character.movement_limit - character.moved_distance:
					character.tile_layer_one.set_cell(character.hover_id_path[i], 2, Vector2i(4, 2), 0)
				else:
					character.tile_layer_one.set_cell(character.hover_id_path[i], 3, Vector2i(4, 2), 0)
	else:
		for i in character.current_id_path.size():
			character.tile_layer_one.set_cell(character.current_id_path[i], 2, Vector2i(4,2), 0)

func _on_character_unit_moving():
	path_set = true

func _on_character_unit_still():
	path_set = false

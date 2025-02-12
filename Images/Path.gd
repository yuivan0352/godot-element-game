extends Node2D

@onready var character = get_parent()
var path_set: bool

func _process(_delta):
	if get_parent() == get_parent().get_parent().active_char:
		queue_redraw()

func _draw():
	if !path_set:
		for i in character.hover_id_path.size():
			if i < character.movement_limit - character.moved_distance:
				character.tile_layer_one.set_cell(character.hover_id_path[i], 2, Vector2i(4, 2), 0)
			else:
				character.tile_layer_one.set_cell(character.hover_id_path[i], 3, Vector2i(4, 2), 0)
	else:
		for i in character.current_id_path.size():
			character.tile_layer_one.set_cell(character.current_id_path[i], 2, Vector2i(4,2), 0)

func _on_character_char_moving():
	path_set = true

func _on_character_movement_stopped() -> void:
	path_set = false

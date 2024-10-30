extends TileMapLayer

var dictionary = {}
@onready var turn_queue = $"../TurnQueue"
@onready var layer_one = $"../Layer1"
var in_movement_range : bool = false

func _ready():
	for x in get_used_rect().size.x:
		for y in get_used_rect().size.y:
			var tile = Vector2i(
				x + get_used_rect().position.x,
				y + get_used_rect().position.y
			)		
			dictionary[str(tile)] = {
				"Tile Type": "Normal"
			}

func _process(_delta):
	var tile_position = local_to_map(get_global_mouse_position())

	if (turn_queue.active_char.hover_id_path.size() < turn_queue.active_char.movement_limit - turn_queue.active_char.moved_distance):
		in_movement_range = true

	for x in get_used_rect().size.x:
		for y in get_used_rect().size.y:
			var tile = Vector2i(
				x + get_used_rect().position.x,
				y + get_used_rect().position.y
			)
			layer_one.erase_cell(tile)

	if dictionary.has(str(tile_position)):
		if get_cell_tile_data(tile_position).get_custom_data("walkable") == false || turn_queue.char_positions.find_key(tile_position) != null:
			layer_one.set_cell(tile_position, 3, Vector2i(2, 3), 0)
		else:
			if (in_movement_range):
				layer_one.set_cell(tile_position, 2, Vector2i(3, 3), 0)
			else:
				layer_one.set_cell(tile_position, 3, Vector2i(3, 3), 0)
			in_movement_range = false

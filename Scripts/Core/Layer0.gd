extends TileMapLayer

var dictionary = {}
@onready var turn_queue = $"../../Services/TurnQueue"
@onready var layer_one = $"../Layer1"
var in_movement_range : bool = false
var in_ui_element: bool
var astar_grid: AStarGrid2D

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	for x in get_used_rect().size.x:
		for y in get_used_rect().size.y:
			var tile = Vector2i(
				x + get_used_rect().position.x,
				y + get_used_rect().position.y
			)	
			dictionary[str(tile)] = null

			var tile_data = get_cell_tile_data(tile)
			
			if tile_data == null or !tile_data.get_custom_data("walkable"):
				astar_grid.set_point_solid(tile, true)

func _set_char_pos_solid(char_positions):
	for key in char_positions:
		astar_grid.set_point_solid(char_positions[key])
		
func _unsolid_coords(coords):
	astar_grid.set_point_solid(coords, false)

func _solid_coords(coords):
	astar_grid.set_point_solid(coords, true)
	
func _on_ui_element_mouse_entered():
	in_ui_element = true

func _on_ui_element_mouse_exited():
	in_ui_element = false

func _process(_delta):
	var tile_position = local_to_map(get_global_mouse_position())

	# checks if the current active_char exists and is of Character class
	if (turn_queue.active_char != null and turn_queue.active_char is Character):
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
		if !in_ui_element:
			if get_cell_tile_data(tile_position).get_custom_data("walkable") == false or turn_queue.pc_positions.find_key(tile_position) != null or turn_queue.enemy_positions.find_key(tile_position) != null:
				layer_one.set_cell(tile_position, 3, Vector2i(2, 3), 0)
			else:
				if turn_queue.active_char != null:
					match turn_queue.active_char.mode:
						"idle":
							if (in_movement_range):
								layer_one.set_cell(tile_position, 2, Vector2i(3, 3), 0)
							else:
								layer_one.set_cell(tile_position, 3, Vector2i(3, 3), 0)
							in_movement_range = false
						"attack", "magic_melee", "magic_ranged", "magic_line":
							layer_one.set_cell(tile_position, 2, Vector2i(4, 3), 0)

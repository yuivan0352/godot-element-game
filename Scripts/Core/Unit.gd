extends Node2D

class_name Unit

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var hover_id_path: PackedVector2Array
var target_position: Vector2
var is_moving: bool
var movement_limit: int
var moved_distance: int
var initiative_roll: int
var rng = RandomNumberGenerator.new()
var adjacent_tiles: Array[Vector2i]
var circle_tiles: Array[Vector2i]
var line_tiles: Array[Vector2i]
var actions: int

@onready var tile_layer_zero = $"../../../Environment/Layer0"
@onready var tile_layer_one = $"../../../Environment/Layer1"
@onready var overview_camera = $"../../../Environment/OverviewCamera"
@onready var turn_queue = $"../../../Services/TurnQueue"
@onready var character_camera = $CharacterCamera
@export var unit_stats: Stats


signal turn_complete
signal unit_still
signal unit_moving

func _ready():
	if tile_layer_zero:
		astar_grid = tile_layer_zero.astar_grid
		@warning_ignore("integer_division")
		movement_limit = unit_stats.movement_speed / 5
		initiative_roll = rng.randi_range(1, 20) + unit_stats.brawns
		actions = 1
		_update_adj_tiles()
		_update_circle_tiles()
		_update_line_tiles()

func _update_adj_tiles():
	adjacent_tiles = []
	var tile_position = tile_layer_zero.local_to_map(global_position)
	adjacent_tiles.append_array(tile_layer_zero.get_surrounding_cells(tile_position))
	adjacent_tiles.append(tile_position + Vector2i.UP + Vector2i.RIGHT)
	adjacent_tiles.append(tile_position + Vector2i.UP + Vector2i.LEFT)
	adjacent_tiles.append(tile_position + Vector2i.DOWN + Vector2i.RIGHT)
	adjacent_tiles.append(tile_position + Vector2i.DOWN + Vector2i.LEFT)

func _in_circle_range(center: Vector2i, tile: Vector2i, radius: float):
	var dx = center.x - tile.x
	var dy = center.y - tile.y
	var distance_squared = (dx*dx) + (dy*dy)
	return distance_squared <= radius*radius

func _update_circle_tiles():
	circle_tiles = []
	var tile_position = tile_layer_zero.local_to_map(global_position)

	var top = ceil(tile_position.y - 5)
	var bottom  = floor(tile_position.y + 5)
	var left = ceil(tile_position.x - 5)
	var right = floor(tile_position.x + 5)

	for y in range(top, bottom + 1):
		for x in range(left, right + 1):
			var tile = Vector2i(x, y)
			if _in_circle_range(tile_position, tile, 5.5):
				circle_tiles.append(tile)

func _update_line_tiles():
	line_tiles = []
	var tile_position = tile_layer_zero.local_to_map(global_position)
	line_tiles.append_array(tile_layer_zero.get_surrounding_cells(tile_position))
	for i in range(1, 5):
		line_tiles.append(line_tiles[0] + (Vector2i.RIGHT * i))
		line_tiles.append(line_tiles[1] + (Vector2i.DOWN * i))
		line_tiles.append(line_tiles[2] + (Vector2i.LEFT * i))
		line_tiles.append(line_tiles[3] + (Vector2i.UP * i))

func _reset_action_econ():
	actions = 1
	
func move_towards_target(_delta):
	if current_id_path.is_empty():
		return
		
	if character_camera.is_current():
		if is_moving == false:
			target_position = tile_layer_zero.map_to_local(current_id_path.front())
			is_moving = true
		
		global_position = global_position.move_toward(target_position, 1)
		
		if global_position == target_position:
			current_id_path.pop_front()
			moved_distance += 1
					
			if current_id_path.is_empty() == false:
				target_position = tile_layer_zero.map_to_local(current_id_path.front())
			else:
				is_moving = false
				tile_layer_zero._solid_coords(tile_layer_zero.local_to_map(global_position))
				turn_queue._update_char_pos(tile_layer_zero.local_to_map(global_position))
				_update_adj_tiles()
				_update_circle_tiles()
				_update_line_tiles()
				if (moved_distance == movement_limit):
					moved_distance = 0
					turn_complete.emit()
				else:
					overview_camera.enabled = true
					overview_camera.set_camera_position(self)
					overview_camera.make_current()
					unit_still.emit()

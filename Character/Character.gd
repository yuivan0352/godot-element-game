extends Node2D

class_name Character

@onready var tile_layer_zero = $"../../Layer0"
@onready var tile_layer_one = $"../../Layer1"
@onready var overview_camera = $"../../OverviewCamera"
@export var char_stats: Stats
var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var hover_id_path: PackedVector2Array
var target_position: Vector2
var is_moving: bool
var is_active_char: bool
var movement_limit: int
var moved_distance: int
var initiative_roll: int
var rng = RandomNumberGenerator.new()
signal turn_complete
signal char_still
signal char_moving

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_layer_zero.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	@warning_ignore("integer_division")
	movement_limit = char_stats.movement_speed / 5
	initiative_roll = rng.randi_range(1, 20) + char_stats.brawns
	
	for x in tile_layer_zero.get_used_rect().size.x:
		for y in tile_layer_zero.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_layer_zero.get_used_rect().position.x,
				y + tile_layer_zero.get_used_rect().position.y
			)
			
			var tile_data = tile_layer_zero.get_cell_tile_data(tile_position)
			
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position, true)

func _set_char_pos_solid():
	for key in get_parent().char_positions:
		astar_grid.set_point_solid(get_parent().char_positions[key])
		
func _unsolid_coords(coords):
	astar_grid.set_point_solid(coords, false)

func _solid_coords(coords):
	astar_grid.set_point_solid(coords, true)

func _input(event):
	if self == get_parent().active_char:
		if event.is_action_pressed("move"):
			if !is_moving:
				current_id_path = astar_grid.get_id_path(
					tile_layer_zero.local_to_map(global_position),
					tile_layer_zero.local_to_map(get_global_mouse_position())
				).slice(1, movement_limit - moved_distance + 1)
			elif is_moving:
				return
				
			if !current_id_path.is_empty():
				get_parent()._unsolid_coords(tile_layer_zero.local_to_map(global_position))
				char_moving.emit()
		elif event.is_action_pressed("stop_move"):
			if is_moving:
				current_id_path = current_id_path.slice(0, 1)
			char_still.emit()
		else:
			return

func _physics_process(_delta):
	if self == get_parent().active_char:
		var tile_position = tile_layer_zero.local_to_map(get_global_mouse_position())
		
		if !is_moving:
			hover_id_path = astar_grid.get_id_path(
				tile_layer_zero.local_to_map(global_position),
				tile_position
			)
			hover_id_path = hover_id_path.slice(1, hover_id_path.size() - 1)
		
		if current_id_path.is_empty():
			return
		
		if get_child(2).is_current():
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
					get_parent()._solid_coords(tile_layer_zero.local_to_map(global_position))
					get_parent()._update_char_pos(tile_layer_zero.local_to_map(global_position))
					if (moved_distance == movement_limit):
						moved_distance = 0
						turn_complete.emit()
					else:
						overview_camera.enabled = true
						overview_camera.set_camera_position(self)
						overview_camera.make_current()
						char_still.emit()

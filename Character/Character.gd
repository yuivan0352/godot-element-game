extends Node2D

class_name Character

@onready var tile_map = $"../../TileMap"
@onready var overview_camera = $"../../OverviewCamera"
@export var char_stats : Stats
var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var current_point_path: PackedVector2Array
var hover_id_path: PackedVector2Array
var target_position: Vector2
var is_moving: bool
var is_active_char: bool
var movement_limit : int
var moved_distance : int
signal turn_complete
signal char_moving

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	movement_limit = char_stats.movement_speed / 5
	
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)
			
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)

func _input(event):
	if self == get_parent().active_char:
		if event.is_action_pressed("move") == true:
			var id_path
			
			if !is_moving:
				id_path = astar_grid.get_id_path(
					tile_map.local_to_map(global_position), 
					tile_map.local_to_map(get_global_mouse_position())
				).slice(1, movement_limit - moved_distance + 1)
			elif is_moving:
				return
				
			char_moving.emit()
			
			if id_path.is_empty() == false:
				current_id_path = id_path
		elif event.is_action_pressed("stop_move") == true:
			if is_moving:
				current_id_path = current_id_path.slice(0, 1)
		else:
			return

func _physics_process(_delta):
	if self == get_parent().active_char:
		var tile_position = tile_map.local_to_map(get_global_mouse_position())
		
		if is_moving == false:
			hover_id_path = astar_grid.get_id_path(
				tile_map.local_to_map(global_position), 
				tile_position
			)
			hover_id_path = hover_id_path.slice(1, hover_id_path.size() - 1)
		
		if current_id_path.is_empty():
			return
		
		if get_child(2).is_current():
			if is_moving == false:
				target_position = tile_map.map_to_local(current_id_path.front())
				is_moving = true
			
			global_position = global_position.move_toward(target_position, 1)
			
			if global_position == target_position:
				current_id_path.pop_front()
				moved_distance += 1
					
				if current_id_path.is_empty() == false:
					target_position = tile_map.map_to_local(current_id_path.front())
				else:
					is_moving = false
					if (moved_distance == movement_limit):
						moved_distance = 0
						turn_complete.emit()
					else:
						overview_camera.enabled = true
						overview_camera.set_camera_position(self)
						overview_camera.make_current()

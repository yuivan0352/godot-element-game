extends Node2D

class_name TurnQueue

var char_positions : Dictionary
var character = preload("res://Character/Character.tscn")
var active_char : Character
var prev_char : Character
@onready var overview_camera = $"../OverviewCamera"
@onready var layer_zero = $"../Layer0"
signal active_character(char_stats)

func _ready():
	for i in range(3):
		_spawn_chars(Vector2i(randi() % 16, randi() % 16))

	var characters = get_children()
	characters.sort_custom(func (a, b): return a.initiative_roll < b.initiative_roll)
	for i in characters.size():
		move_child(characters[i], i)
	active_char = get_child(0)
	active_character.emit(active_char.char_stats)
	overview_camera.set_camera_position(active_char)
	for i in characters.size():
		char_positions[characters[i]] = layer_zero.local_to_map(characters[i].global_position)
		characters[i].turn_complete.connect(_play_turn)
		characters[i].char_moving.connect(_transition_character_cam)
	layer_zero._set_char_pos_solid(char_positions)
	
func _spawn_chars(tile_position: Vector2i):
	var tile_data = layer_zero.get_cell_tile_data(tile_position)
	if !char_positions.has(tile_position) or tile_data == null or tile_data.get_custom_data("walkable") == false:
		var position = Vector2(tile_position.x, tile_position.y) * 16 + Vector2(8,8)
		var char_instance = character.instantiate()
		char_instance.global_position = position
		add_child(char_instance)
		char_positions[char_instance] = layer_zero.local_to_map(char_instance.global_position)
	else:
		_spawn_chars(Vector2i(randi() % 16, randi() % 16))

func _update_char_pos(coords):
	char_positions[active_char] = coords

func _transition_character_cam():
	overview_camera.track_char_cam(active_char)

func _play_turn():
	var new_index = (active_char.get_index() + 1) % get_child_count()
	prev_char = active_char
	active_char = get_child(new_index)
	active_character.emit(active_char.char_stats)
	overview_camera.transition_camera(prev_char.find_child("CharacterCamera"), active_char.find_child("CharacterCamera"), 1.0)
	overview_camera.make_current()

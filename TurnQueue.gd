extends Node

class_name TurnQueue

var char_positions : Dictionary
var character = preload("res://Character/Character.tscn")
var active_char : Character
var prev_char : Character
@onready var overview_camera = $"../../Environment/OverviewCamera"
@onready var layer_zero = $"../../Environment/Layer0"
@onready var player_chars = $"../../Combatants/Player"
@export var ui: UserInterface
var turn_order = []
var turn_num = 0
signal active_character(char_stats)

func _ready():
	for i in range(3):
		_spawn_chars(Vector2i(randi() % 16, randi() % 16))

	turn_order.sort_custom(func (a, b): return a.initiative_roll < b.initiative_roll)
	active_char = turn_order[turn_num]
	active_character.emit(active_char.char_stats)
	overview_camera.set_camera_position(active_char)
	for i in turn_order.size():
		char_positions[turn_order[i]] = layer_zero.local_to_map(turn_order[i].global_position)
		turn_order[i].turn_complete.connect(_play_turn)
		turn_order[i].char_moving.connect(_transition_character_cam)
	layer_zero._set_char_pos_solid(char_positions)
	
func _spawn_chars(tile_position: Vector2i):
	var tile_data = layer_zero.get_cell_tile_data(tile_position)
	if  tile_data != null:
		if tile_data.get_custom_data("walkable") and !char_positions.has(tile_position):
			var position = Vector2(tile_position.x, tile_position.y) * 16 + Vector2(8,8)
			var char_instance = character.instantiate()
			char_instance.global_position = position
			player_chars.add_child(char_instance)
			char_positions[char_instance] = layer_zero.local_to_map(char_instance.global_position)
			turn_order.append(char_instance)
		else:
			_spawn_chars(Vector2i(randi() % 16, randi() % 16))

func _update_char_pos(coords):
	char_positions[active_char] = coords

func _transition_character_cam():
	overview_camera.track_char_cam(active_char)

func _play_turn():
	prev_char = active_char
	turn_num += 1
	if turn_num >= turn_order.size(): 
		turn_num = 0
	active_char = turn_order[turn_num]
	active_character.emit(active_char.char_stats)
	overview_camera.transition_camera(prev_char.find_child("CharacterCamera"), active_char.find_child("CharacterCamera"), 1.0)
	overview_camera.make_current()

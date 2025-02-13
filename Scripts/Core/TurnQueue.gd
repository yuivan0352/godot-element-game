extends Node

class_name TurnQueue

var pc_positions : Dictionary
var enemy_positions: Dictionary
var character = preload("res://Scenes/Character/Character.tscn")
var enemy = preload("res://Scenes/Character/Character.tscn")
var active_char : Character
var prev_char : Character
@onready var overview_camera = $"../../Environment/OverviewCamera"
@onready var layer_zero = $"../../Environment/Layer0"
@onready var player_chars = $"../../Combatants/Player"
@onready var enemy_chars = $"../../Combatants/Enemy"
@export var ui: UserInterface
var tile_size = 16 
var enemy_spawned = 10
var turn_order = []
var turn_num = 0
signal active_character(char_stats)

func _ready():
	for i in range(3):
		_spawn_chars(Vector2i(randi() % tile_size, randi() % tile_size), "Player")
	
	for i in range(enemy_spawned):
		_spawn_chars(Vector2i(randi() % tile_size, randi() % tile_size), "Enemy")

	turn_order.sort_custom(func (a, b): return a.initiative_roll < b.initiative_roll)
	active_char = turn_order[turn_num]
	active_character.emit(active_char.char_stats)
	overview_camera.set_camera_position(active_char)
	for i in turn_order.size():
		pc_positions[turn_order[i]] = layer_zero.local_to_map(turn_order[i].global_position)
		turn_order[i].turn_complete.connect(_play_turn)
		turn_order[i].char_moving.connect(_transition_character_cam)
	layer_zero._set_char_pos_solid(pc_positions)
	
func _spawn_chars(tile_position: Vector2i, type: String):
	var tile_data = layer_zero.get_cell_tile_data(tile_position)
	if  tile_data != null:
		if tile_data.get_custom_data("walkable") and (!pc_positions.has(tile_position) or !enemy_positions.has(tile_position)):
			var position = Vector2(tile_position.x, tile_position.y) * tile_size + Vector2(tile_size / 2, tile_size / 2)
			match type:
				"Player":
					var char_instance = character.instantiate()
					char_instance.global_position = position
					player_chars.add_child(char_instance)
					pc_positions[char_instance] = layer_zero.local_to_map(char_instance.global_position)
					turn_order.append(char_instance)
				"Enemy":
					var enemy_instance = enemy.instantiate()
					enemy_instance.global_position = position
					enemy_chars.add_child(enemy_instance)
					enemy_positions[enemy_instance] = layer_zero.local_to_map(enemy_instance.global_position)
		else:
			_spawn_chars(Vector2i(randi() % tile_size, randi() % tile_size), type)

func _update_char_pos(coords):
	pc_positions[active_char] = coords

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

extends Node2D

var Arius = preload("res://Scenes/Character/Classes/Arius.tscn")
var Brylla = preload("res://Scenes/Character/Classes/Brylla.tscn")
var Pyrrha = preload("res://Scenes/Character/Classes/Pyrrha.tscn")
var Quorral = preload("res://Scenes/Character/Classes/Quorral.tscn")
var characters = [Arius, Brylla, Pyrrha, Quorral]
@onready var enemy_chars: Node2D = $"../Enemy"
@onready var user_interface = %UserInterface
var positions = {}
var tile_size = 16

func spawn_characters(count: int, layer: TileMapLayer) -> Array[Character]:
	var spawned_characters: Array[Character] = []
	
	for i in range(count):
		var character = spawn_character(layer)
		if character:
			spawned_characters.append(character)
			
	return spawned_characters

func spawn_character(layer: TileMapLayer) -> Character:
	var tile_position = Vector2i(randi() % tile_size, randi() % tile_size)
	var tile_data = layer.get_cell_tile_data(tile_position)
	
	if tile_data and tile_data.get_custom_data("walkable") and !positions.has(tile_position) and !enemy_chars.positions.has(tile_position):
		var position = Vector2(tile_position) * tile_size + Vector2(tile_size / 2, tile_size / 2)
		var char_instance = characters[randi() % 4].instantiate()
		
		char_instance.global_position = position
		add_child(char_instance)
		positions[layer.local_to_map(char_instance.global_position)] = char_instance
		user_interface.ui_element_mouse_entered.connect(char_instance._ui_element_mouse_entered)
		user_interface.ui_element_mouse_exited.connect(char_instance._ui_element_mouse_exited)
		
		char_instance.unit_clicked.connect(user_interface._on_unit_clicked)
		char_instance.update_action_econ.connect(user_interface._update_actions)
		char_instance.update_movement.connect(user_interface._update_movement_bar)
		
		return char_instance
	
	return spawn_character(layer)

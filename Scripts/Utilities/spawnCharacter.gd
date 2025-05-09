extends Node2D

var selected_characters = []
@onready var enemy_chars: Node2D = $"../Enemy"
@onready var user_interface = %UserInterface
var positions = {}
var tile_size = 16

func _ready() -> void:
	selected_characters = Global.selected_characters
	
func spawn_characters(count: int, layer: TileMapLayer) -> Array[Character]:
	var spawned_characters: Array[Character] = []
			
	# spawn the characters
	for character in selected_characters:
		var character_instance = spawn_character(layer, character)
		if character:
			spawned_characters.append(character_instance)
			
	return spawned_characters

func spawn_character(layer: TileMapLayer, character_scene) -> Character:
	var tile_position
	if Global.level == 1 or Global.level == 4:
		tile_position = Vector2i(randi() % tile_size, randi() % tile_size)
	else:
		tile_position = Vector2i(randi() % tile_size * 2, randi() % tile_size * 2)
	var tile_data = layer.get_cell_tile_data(tile_position)
	
	if tile_data and tile_data.get_custom_data("walkable") and !positions.has(tile_position) and !enemy_chars.positions.has(tile_position):
		var position = Vector2(tile_position) * tile_size + Vector2(tile_size / 2, tile_size / 2)
		var char_instance = character_scene.instantiate()

		char_instance.global_position = position
		add_child(char_instance)
		positions[layer.local_to_map(char_instance.global_position)] = char_instance
		user_interface.ui_element_mouse_entered.connect(char_instance._ui_element_mouse_entered)
		user_interface.ui_element_mouse_exited.connect(char_instance._ui_element_mouse_exited)

		char_instance.unit_clicked.connect(user_interface._on_unit_clicked)
		char_instance.update_action_econ.connect(user_interface._update_actions)
		char_instance.spell_info.connect(user_interface._fill_spell_buttons)

		return char_instance
	return spawn_character(layer, character_scene)

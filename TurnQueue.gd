extends Node2D

class_name TurnQueue

var active_char : Character
var prev_char : Character
@onready var overview_camera = $"../OverviewCamera"

func _ready():
	var characters = get_children()
	characters.sort_custom(func (a, b): return a.initiative_roll < b.initiative_roll)
	for i in characters.size():
		move_child(characters[i], i);
	active_char = get_child(0)
	overview_camera.set_camera_position(active_char)
	for i in characters.size():
		characters[i].turn_complete.connect(_play_turn)
		characters[i].char_moving.connect(_transition_character_cam)

func _transition_character_cam():
	overview_camera.track_char_cam(active_char)

func _play_turn():
	var new_index = (active_char.get_index() + 1) % get_child_count()
	prev_char = active_char
	active_char = get_child(new_index)
	overview_camera.transition_camera(prev_char.find_child("CharacterCamera"), active_char.find_child("CharacterCamera"), 1.0)
	overview_camera.make_current()

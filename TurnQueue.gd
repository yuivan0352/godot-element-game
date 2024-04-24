extends Node2D

class_name TurnQueue

var active_char : Character

func _ready():
	var characters = get_children()
	active_char = get_child(0)
	for i in characters.size():
		characters[i].turn_complete.connect(_play_turn)

func _play_turn():
	var new_index = (active_char.get_index() + 1) % get_child_count()
	active_char = get_child(new_index)
	active_char.find_child("Camera2D").make_current()

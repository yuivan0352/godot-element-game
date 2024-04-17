extends Node2D

class_name TurnQueue

var active_char

func _ready():
	active_char = get_child(0)
	

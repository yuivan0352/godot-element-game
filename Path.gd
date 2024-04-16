extends Node2D

@onready var player = $"../Player"

func _process(_delta):
	queue_redraw()

func _draw():
	if player.current_point_path.is_empty():
		draw_polyline(player.test_point_path, Color.RED)
	else:
		draw_polyline(player.current_point_path, Color.RED)
		

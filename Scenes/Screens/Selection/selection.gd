extends Control

func _ready() -> void:
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Screens/Lobby/Lobby.tscn")

extends Control

func _ready():
	pass
	
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Screens/Selection/Selection.tscn")
	
func _on_selection_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Screens/Selection/Selection.tscn")

func _on_options_button_pressed() -> void:
	pass # Replace with function body.

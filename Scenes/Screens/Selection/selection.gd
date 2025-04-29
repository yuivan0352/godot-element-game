extends Control

var Arius = preload("res://Scenes/Character/Classes/Arius.tscn")
var Brylla = preload("res://Scenes/Character/Classes/Brylla.tscn")
var Pyrrha = preload("res://Scenes/Character/Classes/Pyrrha.tscn")
var Quorral = preload("res://Scenes/Character/Classes/Quorral.tscn")
var selected_characters = []

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Screens/Start/Start.tscn")

func _on_go_button_pressed() -> void:
	SignalBus.selected_characters = selected_characters
	print("set characters, ", selected_characters)
	get_tree().change_scene_to_file("res://Scenes/Game/World.tscn")

func toggle_select(character):
	if character in selected_characters:
		selected_characters.erase(character)
		return false
	else:
		selected_characters.append(character)
		return true

func _on_arius_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Arius in selected_characters or selected_characters.size() < 3:
			var is_selected = toggle_select(Arius)
			$Team/Arius.modulate = Color(1.2, 1.2, 1.2) if is_selected else Color(1.0, 1.0, 1.0)
			$Team/Arius.statMenu.visible = true if is_selected else false
		else:
			# don't let user select more than 3, display popup or something
			pass

func _on_brylla_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Brylla in selected_characters or selected_characters.size() < 3:
			var is_selected = toggle_select(Brylla)
			$Team/Brylla.modulate = Color(1.2, 1.2, 1.2) if is_selected else Color(1.0, 1.0, 1.0)
			$Team/Brylla.statMenu.visible = true if is_selected else false

func _on_pyrrha_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Pyrrha in selected_characters or selected_characters.size() < 3:
			var is_selected = toggle_select(Pyrrha)
			$Team/Pyrrha.modulate = Color(1.2, 1.2, 1.2) if is_selected else Color(1.0, 1.0, 1.0)
			$Team/Pyrrha.statMenu.visible = true if is_selected else false


func _on_quorral_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Quorral in selected_characters or selected_characters.size() < 3:
			var is_selected = toggle_select(Quorral)
			$Team/Quorral.modulate = Color(1.2, 1.2, 1.2) if is_selected else Color(1.0, 1.0, 1.0)
			$Team/Quorral.statMenu.visible = true if is_selected else false

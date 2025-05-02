extends Control

var Arius = preload("res://Scenes/Character/Classes/Arius.tscn")
var Brylla = preload("res://Scenes/Character/Classes/Brylla.tscn")
var Pyrrha = preload("res://Scenes/Character/Classes/Pyrrha.tscn")
var Quorral = preload("res://Scenes/Character/Classes/Quorral.tscn")

var AriusStat
var BryllaStat
var PyrrhaStat
var QuorralStat

var selected_characters = []
var characters_stats = []

func _ready():
	if $Team/Arius:
		AriusStat = $Team/Arius.characterStat
	if $Team/Brylla:
		BryllaStat = $Team/Brylla.characterStat
	if $Team/Pyrrha:
		PyrrhaStat = $Team/Pyrrha.characterStat
	if $Team/Quorral:
		QuorralStat = $Team/Quorral.characterStat

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Screens/Start/Start.tscn")

func _on_go_button_pressed() -> void:
	if selected_characters.size() == 3:
		Global.selected_characters = selected_characters
		Global.characters_stats = characters_stats
		print("set characters, ", selected_characters)
		get_tree().change_scene_to_file("res://Scenes/Game/World.tscn")

func toggle_select(character, characterStat):
	if character in selected_characters:
		selected_characters.erase(character)
		characters_stats.erase(characterStat)
		return false
	else:
		selected_characters.append(character)
		characters_stats.append(characterStat)
		return true

func _on_arius_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Arius in selected_characters or selected_characters.size() < 3:
			var is_selected = toggle_select(Arius, AriusStat)
			$Team/Arius.modulate = Color(1.2, 1.2, 1.2) if is_selected else Color(1.0, 1.0, 1.0)
			$Team/Arius.statMenu.visible = true if is_selected else false
		else:
			# don't let user select more than 3, display popup or something
			pass

func _on_brylla_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Brylla in selected_characters or selected_characters.size() < 3:
			var is_selected = toggle_select(Brylla, BryllaStat)
			$Team/Brylla.modulate = Color(1.2, 1.2, 1.2) if is_selected else Color(1.0, 1.0, 1.0)
			$Team/Brylla.statMenu.visible = true if is_selected else false

func _on_pyrrha_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Pyrrha in selected_characters or selected_characters.size() < 3:
			var is_selected = toggle_select(Pyrrha, PyrrhaStat)
			$Team/Pyrrha.modulate = Color(1.2, 1.2, 1.2) if is_selected else Color(1.0, 1.0, 1.0)
			$Team/Pyrrha.statMenu.visible = true if is_selected else false


func _on_quorral_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Quorral in selected_characters or selected_characters.size() < 3:
			var is_selected = toggle_select(Quorral, QuorralStat)
			$Team/Quorral.modulate = Color(1.2, 1.2, 1.2) if is_selected else Color(1.0, 1.0, 1.0)
			$Team/Quorral.statMenu.visible = true if is_selected else false


func _on_arius_stat_ready() -> void:
	print("hello")

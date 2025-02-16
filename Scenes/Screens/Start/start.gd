extends Control

func _ready():
	$"Buttons Container"/StartButton.grab_focus()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Screens/Lobby/Lobby.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

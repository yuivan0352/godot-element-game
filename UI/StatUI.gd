extends Control

@onready var healthBar = $CharacterHealthBar

func _on_character_update_characterhealth(health):
	print(health)
	healthBar.value = health

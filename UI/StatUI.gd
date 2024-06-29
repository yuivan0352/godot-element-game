extends Control

@onready var healthBar = $CharacterHealthBar
var health

func _on_character_update_characterhealth(health):
	#print(health)
	#healthBar.value = health
	pass
	
func _on_turn_queue_char(active_char):
	health = active_char.char_stats.health
	print(health)
	healthBar.value = health

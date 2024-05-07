extends Control

@onready var character_stats : Character = 
@onready var label = $Label

func _ready():
	var max_health = character_stats.char_stats.get_health()
	var health = max_health
	
	if label != null:
		label.text = str(health) + "/" + str(max_health)


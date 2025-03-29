extends Area2D

@onready var sprite = $"../Sprite"
@onready var parent = get_parent()
signal area_clicked(parent)

func _on_mouse_entered():
	sprite.modulate = Color(0.9, 0.9, 0.9, 1) 

func _on_mouse_exited():
	sprite.modulate = Color(1, 1, 1, 1)
	
func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("interact"):
		emit_signal("area_clicked", parent)
	

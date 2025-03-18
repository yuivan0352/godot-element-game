extends Unit
class_name Enemy

var has_taken_turn: bool = false
var path_set: bool

func _input(event):

func _on_unit_moving() -> void:
	path_set = true

func _on_unit_still() -> void:
	path_set = false

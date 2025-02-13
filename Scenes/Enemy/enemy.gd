extends Unit
class_name Enemy

var has_taken_turn: bool = false
var path_set: bool

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if !has_taken_turn and self == turn_queue.active_char:
		has_taken_turn = true
		print("Enemy completing turn")
		turn_complete.emit()

func _on_unit_moving() -> void:
	path_set = true

func _on_unit_still() -> void:
	path_set = false

extends VBoxContainer

@onready var brainsSubtractButton = $Brains/Subtract
@onready var brawnsSubtractButton = $Brawns/Subtract
@onready var bewitchmentSubtractButton = $Bewitchment/Subtract
@onready var subtractButtons = [brainsSubtractButton, brawnsSubtractButton, bewitchmentSubtractButton]

var reallocate: int
var points: int

func checkReallocate():
	return reallocate > 0

func _ready() -> void:
	if get_tree().current_scene.name == "Selection":
		reallocate = 3
		points = 3
	if get_tree().current_scene.name == "Upgrade":
		reallocate = 0
		points = 1

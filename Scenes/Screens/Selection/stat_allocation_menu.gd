extends VBoxContainer

@onready var brainsSubtractButton = $Brains/Subtract
@onready var brawnsSubtractButton = $Brawns/Subtract
@onready var bewitchmentSubtractButton = $Bewitchment/Subtract
@onready var subtractButtons = [brainsSubtractButton, brawnsSubtractButton, bewitchmentSubtractButton]

var reallocate: int = 3
var points: int = 3

func checkReallocate():
	return reallocate > 0

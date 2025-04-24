extends Panel

@export var statName: String
@onready var characterSlot = $"../../.."
@onready var statDifferenceLabel = $StatDifferenceLabel
var trackAllocation: int = 0

func _on_subtract_pressed() -> void:
	characterSlot.characterStat[statName] -= 1
	trackAllocation -= 1
	update_difference_label()

func _on_add_pressed() -> void:
	characterSlot.characterStat[statName] += 1
	trackAllocation += 1
	update_difference_label()

func update_difference_label() -> void:
	if trackAllocation == 0:
		statDifferenceLabel.text = ""
	elif trackAllocation > 0:
		statDifferenceLabel.text = "+" + str(trackAllocation)
	else:
		statDifferenceLabel.text = str(trackAllocation)

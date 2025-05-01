extends Panel

@export var statName: String
@onready var characterSlot = $"../../.."
@onready var statDifferenceLabel = $StatDifferenceLabel
@onready var statMenu = $".."
@onready var addButton = $Add
@onready var subtractButton = $Subtract

var trackAllocation: int = 0

signal stat_changed (name, count)

func _ready() -> void:
	statDifferenceLabel.text = "+" + str(trackAllocation)

func _on_subtract_pressed() -> void:
	if characterSlot.characterStat[statName] > 0:
		if trackAllocation <= 0:
			if statMenu.checkReallocate():
				characterSlot.characterStat[statName] -= 1
				statMenu.reallocate -= 1
				statMenu.points += 1
				trackAllocation -= 1
				update_stats(false) # false factor to signify subtract
				update_difference_label()
				stat_changed.emit(statName, trackAllocation)
		else:
			if statMenu.points < 6:
				characterSlot.characterStat[statName] -= 1
				statMenu.points += 1
				trackAllocation -= 1
				update_stats(false) # false factor to signify subtract
				update_difference_label()
				stat_changed.emit(statName, trackAllocation)
		update_subtractButton()
	print("================")
	print("points: ", statMenu.points)
	print("reallocate: ", statMenu.reallocate)

func _on_add_pressed() -> void:
	if trackAllocation < 0 and statMenu.points > 0:
		characterSlot.characterStat[statName] += 1
		statMenu.reallocate += 1
		statMenu.points -= 1
		trackAllocation += 1
		update_stats(true) # true factor to signify addition
		update_difference_label()
		stat_changed.emit(statName, trackAllocation)
	else:
		if statMenu.points > 0 and trackAllocation < 3:
			characterSlot.characterStat[statName] += 1
			statMenu.points -= 1
			trackAllocation += 1
			update_stats(true) # true factor to signify addition
			update_difference_label()
			stat_changed.emit(statName, trackAllocation)
	update_addButton()
			
	print("================")
	print("points: ", statMenu.points)
	print("reallocate: ", statMenu.reallocate)

func update_addButton() -> void:
	if get_tree().current_scene.name == "Selection":
		if trackAllocation == 3:
			addButton.disabled = true
		if trackAllocation > -3:
			subtractButton.disabled = false
	
func update_subtractButton() -> void:
	if get_tree().current_scene.name == "Selection":
		if trackAllocation < 3:
			addButton.disabled = false
		if trackAllocation == -3:
			subtractButton.disabled = true

func update_difference_label() -> void:
	if trackAllocation >= 0:
		statDifferenceLabel.text = "+" + str(trackAllocation)
	else:
		statDifferenceLabel.text = str(trackAllocation)

func update_stats(factor) -> void:
	if factor: # addition
		# placeholder stat changes for now
		if statName == "brawns":
			characterSlot.characterStat.armor_class += 1
		if statName == "brains":
			characterSlot.characterStat.health += 1
		if statName == "bewitchment":
			characterSlot.characterStat.mana += 1
	else: # subtraction
		if statName == "brawns":
			characterSlot.characterStat.armor_class -= 1
		if statName == "brains":
			characterSlot.characterStat.health -= 1
		if statName == "bewitchment":
			characterSlot.characterStat.mana -= 1
		

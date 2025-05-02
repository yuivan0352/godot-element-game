extends VBoxContainer

@onready var characterSlot = $"../.."
@onready var healthLabel = $Health
@onready var brainsLabel = $Brains
@onready var brawnsLabel = $Brawns
@onready var bewitchmentLabel = $Bewitchment
@onready var manaLabel = $Mana
@onready var armorLabel = $Armor
@onready var movementLabel = $Movement

var characterStat
var allocations = {
	"health": 0,
	"mana": 0,
	"armor": 0,
	"movement": 0
}

func _ready() -> void:
	if get_tree().current_scene.name == "Selection":
		characterStat = characterSlot.characterStat
	else:
		for stat in Global.characters_stats:
			if characterSlot.characterStat.name == stat.name:
				characterStat = stat
	
	update_stats()

func _on_stat_changed(stat_name: String, allocation_value: int) -> void:
	allocations[stat_name] = allocation_value
	update_stats()
	
func update_stats() -> void:
	if characterStat:
		healthLabel.text = "Health: " + str(characterStat.health)
		brainsLabel.text = "Brains: " + str(characterStat.brains)
		brawnsLabel.text = "Brawns: " + str(characterStat.brawns)
		bewitchmentLabel.text = "Bewitchment: " + str(characterStat.bewitchment)
		manaLabel.text = "Mana: " + str(characterStat.mana)
		armorLabel.text = "Armor: " + str(characterStat.armor_class)
		movementLabel.text = "Movement: " + str(characterStat.movement_speed)

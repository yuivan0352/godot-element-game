extends VBoxContainer

@onready var characterSlot = $"../.."
@onready var healthLabel = $Health
@onready var brainsLabel = $Brains
@onready var brawnsLabel = $Brawns
@onready var bewitchmentLabel = $Bewitchment
@onready var manaLabel = $Mana
@onready var armorLabel = $Armor
@onready var movementLabel = $Movement

var allocations = {
	"health": 0,
	"mana": 0,
	"armor": 0,
	"movement": 0
}

func _ready() -> void:
	update_stats()

func _on_stat_changed(stat_name: String, allocation_value: int) -> void:
	allocations[stat_name] = allocation_value
	update_stats()
	
func update_stats() -> void:
	if characterSlot.characterStat:
		healthLabel.text = "Health: " + str(characterSlot.characterStat.health)
		brainsLabel.text = "Brains: " + str(characterSlot.characterStat.brains)
		brawnsLabel.text = "Brawns: " + str(characterSlot.characterStat.brawns)
		bewitchmentLabel.text = "Bewitchment: " + str(characterSlot.characterStat.bewitchment)
		manaLabel.text = "Mana: " + str(characterSlot.characterStat.mana)
		armorLabel.text = "Armor: " + str(characterSlot.characterStat.armor_class)
		movementLabel.text = "Movement: " + str(characterSlot.characterStat.movement_speed)

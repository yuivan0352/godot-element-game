extends Resource

class_name Spell

enum TYPE {MELEE, RANGED, LINE}
enum DICE_TYPE {D4, D6, D8, D10, D12, D20}
var dice_type_nums: Dictionary = {
	DICE_TYPE.D4: 4, 
	DICE_TYPE.D6: 6, 
	DICE_TYPE.D8: 8, 
	DICE_TYPE.D10: 10, 
	DICE_TYPE.D12: 12, 
	DICE_TYPE.D20: 20
}
enum ELEMENTAL_TYPE {FIRE, WATER, AIR, EARTH}
@export var spell_type : TYPE
@export var spell_name: String
@export var range: int
@export var dice_count: int
@export var dice_type: DICE_TYPE
@export var elemental_type: ELEMENTAL_TYPE
var rng = RandomNumberGenerator.new()
var damage: int = calculate_damage()

func calculate_damage() -> int:
	return dice_count * rng.randi_range(1, dice_type_nums.get(dice_type))

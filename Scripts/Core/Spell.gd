extends Resource

class_name Spell

enum RANGE_TYPE {MELEE, RANGED, LINE}
enum TYPE {DAMAGE, BUFF, DEBUFF}
enum DICE_TYPE {D4, D6, D8, D10, D12, D20}
var dice_type_nums: Dictionary = {
	DICE_TYPE.D4: 4, 
	DICE_TYPE.D6: 6, 
	DICE_TYPE.D8: 8, 
	DICE_TYPE.D10: 10, 
	DICE_TYPE.D12: 12, 
	DICE_TYPE.D20: 20
}
enum ELEMENTAL_TYPE {Fire, Water, Air, Earth}
@export var spell_range_type : RANGE_TYPE
@export var spell_type: TYPE
@export var spell_name: String
@export var range: int
@export var dice_count: int
@export var dice_type: DICE_TYPE
@export var elemental_type: ELEMENTAL_TYPE
@export var mana_cost: int
@export var action_cost: int
@export var bonus_action_cost: int
@export var button_texture: Texture2D

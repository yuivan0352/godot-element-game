extends Node

class_name Spell

enum TYPE {MELEE, RANGED, LINE}
@export var spell_type : TYPE
var range: int
var damage: int
var spell_name: String

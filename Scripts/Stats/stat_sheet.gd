extends Resource

class_name Stats

@export var name : String
@export var health : int
@export var max_health : int
@export var mana :  int
@export var armor_class : int
@export var movement_speed : int
@export var brains : int
@export var brawns : int
@export var bewitchment : int
@export var potions: int

#enemy-exclusive stat [Melee, Ranged, Boss]
@export var enemy_class: String

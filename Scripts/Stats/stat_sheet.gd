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

#Enemy exclusive stats
@export var enemy_class : String
@export var used_iron_defense: bool = false

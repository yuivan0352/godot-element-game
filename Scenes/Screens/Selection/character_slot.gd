extends Panel

@export var characterPath: String
@export var characterTexture: CompressedTexture2D
@export var characterStat: Resource

@onready var statMenu = $StatsMenu
@onready var brainsSubtractButton = $StatsMenu/StatAllocationMenu/Brains/Subtract
@onready var brawnsSubtractButton = $StatsMenu/StatAllocationMenu/Brawns/Subtract
@onready var bewitchmentSubtractButton =  $StatsMenu/StatAllocationMenu/Bewitchment/Subtract
@onready var subtractButtons = [brainsSubtractButton, brawnsSubtractButton, bewitchmentSubtractButton]

func _ready():
	$TextureRect.texture = characterTexture
	if get_tree().current_scene.name == "Selection":
		statMenu.visible = false
	if get_tree().current_scene.name == "Upgrade":
		statMenu.visible = true

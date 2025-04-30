extends Panel

@export var characterPath: String
@export var characterTexture: CompressedTexture2D
@export var characterStat: Resource

@onready var statMenu = $StatsMenu

func _ready():
	$TextureRect.texture = characterTexture
	statMenu.visible = false

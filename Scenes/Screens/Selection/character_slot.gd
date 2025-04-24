extends Panel

@export var characterPath: String
@export var characterTexture: CompressedTexture2D
@export var characterStat: Resource

func _ready():
	$TextureRect.texture = characterTexture

extends TextureButton

@onready var combat_log_control = $"../.."
@onready var button_sprite = $Sprite2D

var _up_anchor_offset = -200
var _down_anchor_offset = 0
var _target_anchor_offset : float = _up_anchor_offset
var _popped_up = true

func expand_combat_log():
	if !_popped_up:
		_target_anchor_offset = _up_anchor_offset
	else:
		_target_anchor_offset = _down_anchor_offset
	button_sprite.flip_h = !button_sprite.flip_h
	_popped_up = !_popped_up

func _process(delta: float) -> void:
	combat_log_control.offset_top = lerp(combat_log_control.offset_top, _target_anchor_offset, 0.2)
	pass

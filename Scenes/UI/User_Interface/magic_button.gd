extends Button

@onready var parent_container = $".."
@onready var magic_container = $"../../../../MagicBar/MarginContainer/MagicButtons"
@onready var magic_bar = $"../../../../MagicBar"

var _up_anchor_offset = -304.0
var _down_anchor_offset = -80.0
var _target_anchor_offset : float = _down_anchor_offset
var _popped_up = false

func _ui_mode_switch():
	if !_popped_up:
		magic_container.visible = true
		magic_bar.visible = true
		_target_anchor_offset = _up_anchor_offset
	else:
		magic_container.visible = false
		_target_anchor_offset = _down_anchor_offset
	_popped_up = !_popped_up

func _process(delta: float) -> void:
	magic_bar.offset_top = lerp(magic_bar.offset_top, _target_anchor_offset, 0.2)
	if is_equal_approx(magic_bar.offset_top, _down_anchor_offset):
		magic_bar.visible = false
	pass

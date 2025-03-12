extends Control

@export var user_interface_path: NodePath
@onready var user_interface = get_node(user_interface_path)
@onready var current_sprite = $HBoxContainer/CurrentSprite
@onready var previous_sprite = $HBoxContainer/PreviousSprite1
@onready var future_sprite = $HBoxContainer/FutureSprite1
@onready var unit_info = $"../UnitInfo"

# fixed sizes for sprites
@export var current_sprite_size: Vector2 = Vector2(64, 64)
@export var side_sprite_size: Vector2 = Vector2(48, 48)
@export var reference_unit_size: Vector2 = Vector2(16, 16) # reference scale to ensure consistent scaling

var previous_unit
var current_unit
var future_unit

const NORMAL_CURRENT = Color(1.0, 1.0, 1.0, 1.0)
const NORMAL_SIDE = Color(0.7, 0.7, 0.7, 0.8)
const HOVER_CURRENT = Color(1.1, 1.1, 1.1, 1.0)
const HOVER_SIDE = Color(0.9, 0.9, 0.9, 1.0)

func _ready() -> void:
	if not user_interface:
		push_error("TurnScroll: UserInterface reference not set!")
		return
	
	setup_sprites()
	call_deferred("update_turn_display")
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if unit_info and unit_info.visible:
			var click_pos = get_global_mouse_position()
			var unit_info_rect = Rect2(unit_info.global_position, unit_info.size)
			
			if not unit_info_rect.has_point(click_pos):
				var on_sprite = false
				for sprite in [current_sprite, previous_sprite, future_sprite]:
					if sprite.visible:
						var sprite_rect = Rect2(sprite.global_position, sprite.size)
						if sprite_rect.has_point(click_pos):
							on_sprite = true
							break
				
				if not on_sprite:
					unit_info.visible = false
	
func _process(_delta):
	update_turn_display()

# configure sprites with fixed sizes
func setup_sprites():
	for sprite_node in [current_sprite, previous_sprite, future_sprite]:
		if sprite_node:
			sprite_node.expand = true
			sprite_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
			if sprite_node == current_sprite:
				sprite_node.custom_minimum_size = current_sprite_size
			else:
				sprite_node.custom_minimum_size = side_sprite_size
				sprite_node.modulate = Color(0.7, 0.7, 0.7, 0.8)

func update_turn_display():
	if not user_interface or not user_interface.turn_array or user_interface.turn_array.size() == 0:
		return
	
	var current_index = user_interface.current_turn_index
	var array_size = user_interface.turn_array.size()
	
	current_unit = get_unit_at_index(current_index)
	update_sprite_texture(current_sprite, current_index)
	
	var prev_index = (current_index - 1 + array_size) % array_size
	previous_unit = get_unit_at_index(prev_index)
	update_sprite_texture(previous_sprite, prev_index)
	
	var next_index = (current_index + 1) % array_size
	future_unit = get_unit_at_index(next_index)
	update_sprite_texture(future_sprite, next_index)

func get_unit_at_index(index):
	if index >= 0 and index < user_interface.turn_array.size():
		return user_interface.turn_array[index]
	return null

func update_sprite_texture(sprite_node, unit_index):
	if unit_index >= 0 and unit_index < user_interface.turn_array.size():
		var unit = user_interface.turn_array[unit_index]
		
		if unit and unit.has_node("Sprite"): # just to doubly check, every unit WILL have a sprite.
			var unit_sprite = unit.get_node("Sprite")
			
			if unit_sprite and unit_sprite.texture:
				sprite_node.texture = unit_sprite.texture
				
				# applys scale correction if needed
				if unit_sprite.texture:
					adjust_sprite_scale(sprite_node, unit_sprite)
				
				sprite_node.visible = true
				return
	
	sprite_node.visible = false

# do no think we will need these once we have actual sprites, with correct aspect ratios and all that
# here for now as we are using random sprites
func adjust_sprite_scale(display_sprite, source_sprite):
	if display_sprite == current_sprite:
		display_sprite.custom_minimum_size = current_sprite_size
	else:
		display_sprite.custom_minimum_size = side_sprite_size
	
	if source_sprite is Sprite2D and source_sprite.region_enabled:
		display_sprite.expand = true
	else:
		display_sprite.expand = true
		display_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func display_unit_info(unit):
	if unit_info and unit:
		unit_info.visible = true
		
		if unit_info.has_method("update_info"):
			unit_info.update_info(unit)
		else:
			push_error("UnitInfo panel doesn't have an update_info method!")

func _on_previous_sprite_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Previous sprite clicked! Unit: ", previous_unit.name if previous_unit else "None")
		display_unit_info(previous_unit)

func _on_current_sprite_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Current sprite clicked! Unit: ", current_unit.name if current_unit else "None")
		display_unit_info(current_unit)
	
func _on_future_sprite_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Future sprite clicked! Unit: ", future_unit.name if future_unit else "None")
		display_unit_info(future_unit)

func _on_previous_sprite_mouse_entered() -> void:
	previous_sprite.modulate = HOVER_SIDE

func _on_previous_sprite_mouse_exited() -> void:
	previous_sprite.modulate = NORMAL_SIDE

func _on_current_sprite_mouse_entered() -> void:
	current_sprite.modulate = HOVER_CURRENT

func _on_current_sprite_mouse_exited() -> void:
	current_sprite.modulate = NORMAL_CURRENT

func _on_future_sprite_mouse_entered() -> void:
	future_sprite.modulate = HOVER_SIDE

func _on_future_sprite_mouse_exited() -> void:
	future_sprite.modulate = NORMAL_SIDE

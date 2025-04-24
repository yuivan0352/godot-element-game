extends Panel

@onready var unit_name = $UnitName
@onready var unit_stats = $UnitStats
@onready var unit_sprite = $UnitSprite

var current_unit = null
var is_dragging = false
var drag_start_position = Vector2()

func _ready():
	if unit_sprite:
		unit_sprite.expand = true
		unit_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		unit_sprite.custom_minimum_size = Vector2(64, 64)
	
	visible = false
	
func put_within_bounds():
	var viewport_size = get_viewport_rect().size
	
	var new_position = position
	
	new_position.x = max(0, new_position.x) # left
	new_position.y = max(0, new_position.y) # top
	new_position.x = min(viewport_size.x - size.x, new_position.x) # right
	new_position.y = min(viewport_size.y - size.y, new_position.y) # bottom
	
	position = new_position

func update_info(unit):
	if not unit:
		visible = false
		return
	
	current_unit = unit
	visible = true
	
	if unit_name:
		if unit.unit_stats and unit.unit_stats.name:
			unit_name.text = unit.unit_stats.name
		else:
			unit_name.text = unit.name
	
	if unit_sprite and unit.has_node("Sprite"):
		var sprite_display = unit.get_node("Sprite")
		if sprite_display and sprite_display.texture:
			unit_sprite.texture = sprite_display.texture
	
	update_stats(unit)
	call_deferred("ensure_within_bounds")


func update_stats(unit):
	if not unit or not unit.unit_stats:
		return
		
	var stats = unit.unit_stats
	
	for child in unit_stats.get_children():
		child.queue_free()
	
	create_stat_label("Health", stats.health)
	create_stat_label("Armor Class", stats.armor_class)
	create_stat_label("Movement Speed", stats.movement_speed)
	create_stat_label("Brains", stats.brains)
	create_stat_label("Brawns", stats.brawns)
	create_stat_label("Bewitchment", stats.bewitchment)

func create_stat_label(stat_name, value):
	var label = Label.new()
	label.text = stat_name + ": " + str(value)
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	unit_stats.add_child(label)

func close():
	visible = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_position = event.position
			else:
				is_dragging = false
	
	elif event is InputEventMouseMotion and is_dragging:
		position += event.position - drag_start_position
		
		put_within_bounds()
	
	elif event is InputEventMouseMotion and is_dragging:
		position += event.position - drag_start_position

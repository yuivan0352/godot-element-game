extends Panel

@onready var unit_name = $UnitName
@onready var unit_sprite = $SpriteContainer/UnitSprite

@onready var healthLabel = $UnitStats/Health
@onready var manaLabel = $UnitStats/Mana
@onready var armorLabel = $UnitStats/Armor
@onready var movementLabel = $UnitStats/Movement

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
	
	unit_name.text = unit.unit_stats.name
	
	if unit_sprite and unit.has_node("Sprite"):
		var sprite_display = unit.get_node("Sprite")
		if sprite_display and sprite_display.texture:
			unit_sprite.texture = sprite_display.texture
	
	update_stats(unit)
	call_deferred("ensure_within_bounds")


func update_stats(unit):
	var stats
	
	for stat in Global.characters_stats:
		if unit.unit_stats.name == stat.name:
			stats = stat
	
	healthLabel.text = "Health: " + str(stats.health)
	manaLabel.text = "Mana: " + str(stats.mana)
	armorLabel.text = "Armor: " + str(stats.armor_class)
	movementLabel.text = "Movement: " + str(stats.movement_speed)

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

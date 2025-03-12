extends Panel

@onready var unit_name = $UnitName
@onready var unit_stats = $UnitStats
@onready var unit_sprite = $UnitSprite

var current_unit = null

func _ready():
	# Configure sprite display to maintain aspect ratio
	if unit_sprite:
		unit_sprite.expand = true
		unit_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Set a reasonable fixed size for the sprite
		unit_sprite.custom_minimum_size = Vector2(64, 64)
	
	# Hide the panel by default
	visible = false

# Update the panel with the specific unit's information
func update_info(unit):
	if not unit:
		visible = false
		return
	
	current_unit = unit
	visible = true
	
	# Update unit name
	if unit_name:
		if unit.unit_stats and unit.unit_stats.name:
			unit_name.text = unit.unit_stats.name
		else:
			unit_name.text = unit.name
	
	# Update unit sprite
	if unit_sprite and unit.has_node("Sprite"):
		var sprite_display = unit.get_node("Sprite")
		if sprite_display and sprite_display.texture:
			unit_sprite.texture = sprite_display.texture
	
	# Create/update stats labels
	update_stats(unit)

# Update all the stats based on the unit's stats object
func update_stats(unit):
	if not unit or not unit.unit_stats:
		return
		
	var stats = unit.unit_stats
	
	# Clear previous labels
	for child in unit_stats.get_children():
		child.queue_free()
	
	# Create new labels for each stat
	create_stat_label("Health", stats.health)
	create_stat_label("Armor Class", stats.armor_class)
	create_stat_label("Movement Speed", stats.movement_speed)
	create_stat_label("Brains", stats.brains)
	create_stat_label("Brawns", stats.brawns)
	create_stat_label("Bewitchment", stats.bewitchment)

# Create a label for a stat
func create_stat_label(stat_name, value):
	var label = Label.new()
	label.text = stat_name + ": " + str(value)
	
	# Optional styling for the label
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Add to container
	unit_stats.add_child(label)

# Optional: Method to close the panel
func close():
	visible = false

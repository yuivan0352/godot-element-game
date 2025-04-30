extends Unit
class_name Character

var mode : String = "idle"
@onready var path = $Path
@onready var clickable_area = $Sprite/clickableArea

var in_ui_element: bool
var current_spell: Spell
var possible_spells: Array[Spell]

signal unit_clicked(unit)
signal spell_info(spell_array)

func _ready() -> void:
	super._ready()
	var spell_resource_path = "res://Resources/Spells/" + str(Spell.ELEMENTAL_TYPE.find_key(unit_elements[0]))
	var spell_dir = DirAccess.open(spell_resource_path)
	if spell_resource_path:
		spell_dir.list_dir_begin()
		var spell_resource = spell_dir.get_next()
		while spell_resource != "":
			possible_spells.append(load(spell_resource_path + "/" + spell_resource))
			spell_resource = spell_dir.get_next()
	for spell in possible_spells:
		equipped_spells.append(spell)

func _ui_element_mouse_entered():
	in_ui_element = true
	path._on_ui_element_mouse_entered()
	
func _ui_element_mouse_exited():
	in_ui_element = false
	path._on_ui_element_mouse_exited()
	
func change_mode(input_mode: String, spell_info: Spell):
	if mode == input_mode and spell_info == null:
		mode = "idle"
		current_spell = null
	else:
		mode = input_mode
		current_spell = spell_info
		if current_spell != null:
			match current_spell.spell_range_type:
				Spell.RANGE_TYPE.RANGED:
					_update_circle_tiles(current_spell.range)
				Spell.RANGE_TYPE.LINE:
					_update_line_tiles(current_spell.range)

func _reset_action_econ():
	super._reset_action_econ()
	mode = "idle"
	
func _attack_action(attack_type_array):
	var mouse_tile = tile_layer_zero.local_to_map(get_global_mouse_position())
	var target_unit = turn_queue.enemy_positions.find_key(mouse_tile)
	var damage = 0
	if actions > 0:
		if target_unit != null and attack_type_array.has(mouse_tile):
			var attack_roll = rng.randi_range(1, 20)
			if attack_roll >= target_unit.unit_stats.armor_class:
				if mode == "magic":
					damage = current_spell.damage
				else:
					damage = rng.randi_range(1, 6)
				target_unit.unit_stats.health -= damage
				print(unit_stats.name, " rolled a ", attack_roll, " and did ", damage, " to ", target_unit.unit_stats.name, ": ", target_unit.unit_stats.health, "/", target_unit.unit_stats.max_health)
				if target_unit.unit_stats.health <= 0:
					turn_queue.enemy_positions.erase(target_unit)
					turn_queue.turn_order.erase(target_unit)
					target_unit.queue_free()
					tile_layer_zero._unsolid_coords(mouse_tile)
					_update_adj_tiles()
			else:
				print(unit_stats.name, " rolled a ", attack_roll, " and missed their attack!")
		if mode == "magic":
			actions -= current_spell.action_cost
		else:
			actions -= 1
		update_action_econ.emit(0, 1, unit_stats.mana, unit_stats.movement_speed, (movement_limit - moved_distance) * 5)
		mode = "idle"
	else:
		mode = "idle"
		return

func _input(event):
	if self == turn_queue.current_unit and !in_ui_element:
		match mode:
			"idle":
				if event.is_action_pressed("interact"):
					if !is_moving:
						current_id_path = astar_grid.get_id_path(
							tile_layer_zero.local_to_map(global_position),
							tile_layer_zero.local_to_map(get_global_mouse_position())
						).slice(1, movement_limit - moved_distance + 1)
					elif is_moving:
						return
						
					if !current_id_path.is_empty():
						tile_layer_zero._unsolid_coords(tile_layer_zero.local_to_map(global_position))
						unit_moving.emit()
						mode = "moving"
				else:
					return
			"moving":
				if event.is_action_pressed("stop_move"):
					if is_moving:
						current_id_path = current_id_path.slice(0, 1)
					unit_still.emit()
					mode = "idle"
			"attack":
				if event.is_action_pressed("interact"):
					_attack_action(adjacent_tiles)
			"magic":
				if event.is_action_pressed("interact"):
					unit_stats.mana -= current_spell.mana_cost
					if current_spell.spell_type == Spell.TYPE.DAMAGE:
						match current_spell.spell_range_type:
							Spell.RANGE_TYPE.RANGED:
								_attack_action(circle_tiles)
							Spell.RANGE_TYPE.LINE:
								_attack_action(circle_tiles)

func move_towards_target(_delta):
	if super.move_towards_target(_delta):
		overview_camera.set_camera_position(self)
		find_child("CharacterCamera").enabled = false
		overview_camera.make_current()
		unit_still.emit()

func _physics_process(_delta):
	if self == turn_queue.current_unit:
		if !in_ui_element:
			var mouse_pos = get_global_mouse_position()
			var tile_position = tile_layer_zero.local_to_map(mouse_pos)
			var grid_size = Vector2i(16, 16)
			
			if tile_position.x >= 0 and tile_position.y >= 0 and tile_position.x < grid_size.x and tile_position.y < grid_size.y:
				var char_tile_pos = tile_layer_zero.local_to_map(global_position)
				if tile_position != char_tile_pos:
					if !is_moving:
						hover_id_path = astar_grid.get_id_path(
							tile_layer_zero.local_to_map(global_position),
							tile_position
						)
						hover_id_path = hover_id_path.slice(1, hover_id_path.size() - 1)
			
		move_towards_target(_delta)

func _on_area_clicked():
	if turn_queue.current_unit.mode == "idle":
		emit_signal("unit_clicked", self)

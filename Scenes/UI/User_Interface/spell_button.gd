extends Button

var spell_info: Spell
signal spell_info_pass(mode, spell_range, spell_damage)

func update_button():
	icon = spell_info.button_texture

func on_spell_press():
	spell_info_pass.emit("magic", spell_info)

extends HBoxContainer

func _ready() -> void:
	var children = get_children()
	var selectedCharacterPaths = []
	
	for character in SignalBus.selected_characters:
		selectedCharacterPaths.append(character.resource_path)
	
	print("selectedCharacters: ", selectedCharacterPaths)
	print("========================================")
	for child in children:
		child.visible = false
		for buttons in child.subtractButtons:
			buttons.disabled = true
		if child.characterPath in selectedCharacterPaths:
			print("child path: ", child.characterPath)
			
			child.visible = true

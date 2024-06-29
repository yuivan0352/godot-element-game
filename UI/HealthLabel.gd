extends Label

#@onready var active_char = get_node("../../../StatLayer")
var char

func _on_active_char(active_char):
	char = active_char
	print(char)

func _ready():
	print(char)
	#if self != null:
		#self.text = "cock" + "/" + "penis"
	#$Character.connect("health_changed", update)
	pass
	
func update():
	self
	#if self != null:
		#self.text = "cock" + "/" + "penis"

	

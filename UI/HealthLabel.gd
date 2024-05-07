extends Label

#var active_char : Character = get_parent()

func _ready():
	print(get_parent().get_parent().get_parent().get_parent().active_char)
	#if self != null:
		#self.text = "cock" + "/" + "penis"
	#$Character.connect("health_changed", update)
	
func _process(delta):
	print(get_parent().get_parent().get_parent().get_parent().active_char)
	
func update():
	self
	#if self != null:
		#self.text = "cock" + "/" + "penis"

	

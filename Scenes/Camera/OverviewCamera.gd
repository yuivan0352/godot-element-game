extends Camera2D

@export var speed = 20
var transitioning: bool = false
var inputX : int
var inputY : int
var tween : Tween

func track_char_cam(character: Unit):
	#print("track_char_cam called")
	if (character.get_child(3).is_on_screen()):
		#print("Character on screen, transitioning 0.5")
		transition_camera(self, character.find_child("CharacterCamera"), 0.5)
	else:
		#print("Character off screen, transitioning 1.0")
		transition_camera(self, character.find_child("CharacterCamera"), 1.0)

func set_camera_position(target: Unit):
	global_position = target.global_position

func transition_camera(from: Camera2D, to: Camera2D, duration: float):
	#print("transition_camera called with duration:", duration)
	if transitioning: 
		#print("Already transitioning, returning")
		return
	zoom = from.zoom
	offset = from.offset
	light_mask = from.light_mask
	
	global_transform = from.global_transform
	
	if from != self:
		from.enabled = true
	make_current()
	transitioning = true
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_transform", to.global_transform, duration).from(global_transform)
	tween.tween_property(self, "zoom", to.zoom, duration).from(zoom)
	tween.tween_property(self, "offset", to.offset, duration).from(offset)
	await tween.finished
	
	if from != self:
		from.enabled = false
	if from != self && to != self:
		to.enabled = false
	if from == self && to != self:
		to.enabled = true
	to.make_current()
	transitioning = false

func _process(delta):
	if !transitioning:
		inputX = int(Input.is_action_pressed("cam_right")) - int(Input.is_action_pressed("cam_left"))
		inputY = int(Input.is_action_pressed("cam_down")) - int(Input.is_action_pressed("cam_up"))
		
		if (position.x >= 144 && inputX > 0):
			position.x = 144
		elif (position.x <= 112 && inputX < 0):
			position.x = 112
		else:
			position.x = lerp(position.x, position.x + inputX * speed, speed * delta)
			
		if (position.y >= 192 && inputY > 0):
			position.y = 192
		elif (position.y <= 32 && inputY < 0):
			position.y = 32
		else:
			position.y = lerp(position.y, position.y + inputY * speed, speed * delta)

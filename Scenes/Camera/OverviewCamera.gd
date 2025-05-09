extends Camera2D

@export var speed = 20
var transitioning: bool = false
var inputX : int
var inputY : int
var tween : Tween
var movementLeftLimit = 112
var movementTopLimit = 56
var movementBottomLimit
var movementRightLimit

func _ready() -> void:
	_update_camera_limits()

func track_char_cam(character: Unit):
	if (character.find_child("VisibilityNotifier").is_on_screen()):
		transition_camera(self, character.find_child("CharacterCamera"), 0.5)
	else:
		transition_camera(self, character.find_child("CharacterCamera"), 1.0)
		
func _update_camera_limits():
	if Global.level - 1 == 1 or Global.level - 1 == 4:
		movementBottomLimit = 200
		movementRightLimit = 144
		limit_bottom = 272
		limit_right = 272
	elif Global.level - 1 == 2:
		movementBottomLimit = 200
		movementRightLimit = 392
		limit_bottom = 272
		limit_right = 544
	elif Global.level - 1 == 3:
		movementBottomLimit = 456
		movementRightLimit = 400
		limit_bottom = 528
		limit_right = 528

func set_camera_position(target: Unit):
	self.global_position = target.global_position
	if global_position.x > movementRightLimit:
		self.global_position.x = movementRightLimit
	elif global_position.x < movementLeftLimit:
		self.global_position.x = movementLeftLimit
	if global_position.y > movementBottomLimit:
		self.global_position.y = movementBottomLimit
	elif global_position.y < movementTopLimit:
		self.global_position.y = movementTopLimit

func transition_camera(from: Camera2D, to: Camera2D, duration: float):
	if transitioning: 
		print("Already transitioning, returning")
		return
		
	zoom = from.zoom
	offset = from.offset
	light_mask = from.light_mask
	
	global_transform = from.global_transform
	
	if from != self:
		from.enabled = true
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
	# zooms out 
	#self.zoom = Vector2(3,3)
	
	if !transitioning:
		inputX = int(Input.is_action_pressed("cam_right")) - int(Input.is_action_pressed("cam_left"))
		inputY = int(Input.is_action_pressed("cam_down")) - int(Input.is_action_pressed("cam_up"))
			
		if (position.x >= movementRightLimit && inputX >= 0):
			position.x = movementRightLimit
		elif (position.x <= movementLeftLimit && inputX <= 0):
			position.x = movementLeftLimit
		else:
			position.x = lerp(position.x, position.x + inputX * speed, speed * delta)
			
		if (position.y >= movementBottomLimit && inputY >= 0):
			position.y = movementBottomLimit
		elif (position.y <= movementTopLimit && inputY <= 0):
			position.y = movementTopLimit
		else:
			position.y = lerp(position.y, position.y + inputY * speed, speed * delta)

	if transitioning and Input.is_action_pressed("stop_move"):
		tween.stop()
		transitioning = false;

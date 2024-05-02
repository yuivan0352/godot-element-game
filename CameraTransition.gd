extends Node2D

@export var speed = 20
@onready var camera : Camera2D = $OverviewCamera
var transitioning: bool = false
var inputX : int
var inputY : int
var char_moving : bool = false
var tween : Tween

func track_char_cam(char: Character):
	char_moving = true
	transition_camera(camera, char.find_child("CharacterCamera"))

func set_camera_position(target: Character):
	global_position = target.global_position

func transition_camera(from: Camera2D, to: Camera2D, duration: float = 1.0):
	if transitioning: return
	camera.zoom = from.zoom
	camera.offset = from.offset
	camera.light_mask = from.light_mask
	
	camera.global_transform = from.global_transform
	
	camera.make_current()
	transitioning = true
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(camera, "global_transform", to.global_transform, duration).from(camera.global_transform)
	tween.tween_property(camera, "zoom", to.zoom, duration).from(camera.zoom)
	tween.tween_property(camera, "offset", to.offset, duration).from(camera.offset)
	await tween.finished
	
	to.make_current()
	transitioning = false

func _process(delta):
	if transitioning == false && char_moving == false:
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
		
		print(global_position)

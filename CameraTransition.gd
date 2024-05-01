extends Node2D

@onready var camera : Camera2D = $OverviewCamera
var transitioning: bool = false
var tween : Tween

func _ready():
	camera.enabled = false
	
func switch_camera(from: Camera2D, to: Camera2D):
	from.enabled = false
	to.enabled = true
	
func transition_camera(from: Camera2D, to: Camera2D, duration: float = 1.0):
	if transitioning: return
	camera.zoom = from.zoom
	camera.offset = from.offset
	camera.light_mask = from.light_mask
	
	camera.global_transform = from.global_transform
	
	camera.enabled = true
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
	
	to.enabled = true
	to.make_current()
	transitioning = false

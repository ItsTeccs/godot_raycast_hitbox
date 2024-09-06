extends Node3D

@onready var spring_arm: SpringArm3D = get_node("RootOffset/SpringArm3D")
@onready var camera: Camera3D = get_node("RootOffset/SpringArm3D/Camera3D")

@onready var cam_ray = camera.get_node("RayCast3D")

@export_category("Camera Configuration")
## How fast the camera responds to changes in pitch, yaw, and zoom.
@export var change_acceleration := 15.0
@export var aim_acceleration := 2.5

@export_group("Pitch")
## The minimum pitch rotation of the camera.
@export var pitch_minimum := - 90.0
## The minimum pitch rotation of the camera.
@export var pitch_maximum := 90.0
## How sensitive pitch is to changes in mouse movement.
@export var pitch_sensitivity := 0.07

@export_group("Yaw")
## How sensitive yaw is to changes in mouse movement.
@export var yaw_sensitivity := 0.07

@export_group("Zoom")
## How far the camera is away from the player character at default zoom level.
@export var default_spring_length := 5.0

# The live value of the camera's zoom ratio
var _zoom_factor := 1.0
# override ratio to set zoom to if override is true
var _zoom_override := 1.0

## Zoom ratio min
@export var zoom_min := 0.7
## zoom ratio max
@export var zoom_max := 2.0

## Determines if the camera will re-calculate its own zoom each frame
@export var override := false

# The target value the live value is lerped to
var target_zoom: float = default_spring_length * _zoom_factor
var yaw := 0.0
var pitch := 0.0
var fov := 75
var targetFov := fov

func set_zoom_override(zoom_override: float):
	_zoom_override = zoom_override

func override_zoom(toggle: bool):
	override = toggle

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
		
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * yaw_sensitivity
		pitch -= event.relative.y * pitch_sensitivity
	elif event is InputEventMouseButton and !override:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_factor -= 0.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_factor += 0.1
		
		_zoom_factor = clamp(_zoom_factor, zoom_min, zoom_max)

func _process(delta):
	pass

func _physics_process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return

	if override:
		target_zoom = default_spring_length * _zoom_override
	else:
		target_zoom = default_spring_length * _zoom_factor
		
	pitch = clamp(pitch, pitch_minimum, pitch_maximum)
	rotation_degrees.y = lerp(rotation_degrees.y, yaw, change_acceleration * delta)
	spring_arm.rotation_degrees.x = lerp(spring_arm.rotation_degrees.x, pitch, change_acceleration * delta)
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom, change_acceleration * delta)

func get_camera() -> Camera3D:
	return camera

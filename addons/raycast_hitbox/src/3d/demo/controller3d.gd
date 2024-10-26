extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO

var _attack_anim_names: Array[String] = ["Heavy1", "Heavy2", "HeavySpin"]
var _turn_accel := 5.0
var _attack_index := 0
var _attacking := false
var _camera: Node3D
var _armature: Node3D
var _anim_tree: AnimationTree = null
var _detector: RayCastHitDetector3D
var _last_attack_finished_msec := 0
var _reset_attack_time := 3

## Sample custom hit response method
## result arg is a dictionary of the RayCast result from successful hits.
func _on_hit(result: Dictionary):
	print_debug("Hit Entity: " + result.collider.name)

## Sample custom hit filtering method
## Return true for hits that should be registered by the _detector.
## result arg is a dictionary of the RayCast result from the hit.
func filter_hits(result: Dictionary) -> bool:
	if result.collider.is_in_group("red") or result.collider.is_in_group("blue"):
		return true
	else:
		return false

func _ready():
	_armature = $Armature	
	_camera = $OverShoulderCamera
	_detector =  $RayCastHitDetector
	_detector.set_custom_filter(filter_hits)
	_detector.hit.connect(_on_hit)
	_detector.add_exclusion(self)
	
	_anim_tree = $AnimationTree
	_anim_tree.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	var base_anim_name := anim_name.replace("MeleeLib/", "")
	if _attack_anim_names.find(base_anim_name) != -1 and _attacking:
		_last_attack_finished_msec = Time.get_ticks_msec()
		_attack_index = (_attack_index + 1) % _attack_anim_names.size()
		_attacking = false
		_detector.end()

func _unhandled_input(event: InputEvent) -> void:
	if _anim_tree:
		if Input.is_action_pressed("attack") and not _attacking:
			_attacking = true
			_anim_tree.set("parameters/Transition/transition_request", "MeleeLib-" + _attack_anim_names[_attack_index])
			_detector.begin()

		if not _attacking:
			if velocity == Vector3.ZERO:
				_anim_tree.set("parameters/Transition/transition_request", "MeleeLib-HeavyIdle")
			else:
				_anim_tree.set("parameters/Transition/transition_request", "MeleeLib-HeavyWalking")
					
func _physics_process(delta):
	var direction = Vector3.ZERO

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	var h_axis = Input.get_axis("move_left", "move_right")
	var y_axis = Input.get_axis("move_forward", "move_backward") 
	direction =	(_camera.basis * -Vector3(h_axis, 0, y_axis)).normalized()

	_armature.rotation.y = lerp_angle(_armature.rotation.y, _camera.rotation.y, _turn_accel * delta)
	velocity = direction * speed
	
	if (Time.get_ticks_msec() - _last_attack_finished_msec) >= _reset_attack_time * 1000 \
	and not _attacking and _attack_index != 0:	
		_attack_index = 0 
	
	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y = velocity.y - (fall_acceleration * delta)

	move_and_slide()

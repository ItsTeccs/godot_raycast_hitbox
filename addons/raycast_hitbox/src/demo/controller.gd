extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO
var anim_tree: AnimationTree = null
var detector: RayCastHitDetector

var attack_anim_names: Array[String] = ["Heavy1", "Heavy2", "HeavySpin"]
var _attack_index := 0
var _attacking := false
var camera: Node3D

## Sample custom hit response method
## result arg is a dictionary of the RayCast result from successful hits.
func _on_hit(result: Dictionary):
	print_debug("Hit Entity: " + result.collider.name)

## Sample custom hit filtering method
## Return true for hits that should be registered by the detector.
## result arg is a dictionary of the RayCast result from the hit.
func filter_hits(result: Dictionary) -> bool:
	if result.collider.is_in_group("red") or result.collider.is_in_group("blue"):
		return true
	else:
		return false

func _ready():
	camera = $OverShoulderCamera
	detector =  $RayCastHitDetector
	detector.set_custom_filter(filter_hits)
	detector.hit.connect(_on_hit)
	detector.add_exclusion(self)
	
	anim_tree = $AnimationTree
	anim_tree.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String) -> void:
	if attack_anim_names.find(anim_name.replace("MeleeLib/", "")) != -1:
		anim_tree.set("parameters/Transition/transition_request", "MeleeLib-HeavyIdle")
		_attacking = false
		detector.end()

func _physics_process(delta):
	var direction = Vector3.ZERO

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	var h_axis = Input.get_axis("move_left", "move_right")
	var y_axis = Input.get_axis("move_forward", "move_backward") 
	direction =	(camera.basis * -Vector3(h_axis, 0, y_axis)).normalized()
		
	velocity = direction * speed
	if anim_tree:
		if Input.is_action_pressed("attack") and not _attacking:
			_attacking = true
			anim_tree.set("parameters/Transition/transition_request", "MeleeLib-" + attack_anim_names[_attack_index])
			_attack_index = (_attack_index + 1) % attack_anim_names.size()
			detector.begin()


		if not _attacking:
			if velocity == Vector3.ZERO:
				anim_tree.set("parameters/Transition/transition_request", "MeleeLib-HeavyIdle")
			else:
				anim_tree.set("parameters/Transition/transition_request", "MeleeLib-HeavyWalking")
	
	
	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y = velocity.y - (fall_acceleration * delta)


	move_and_slide()

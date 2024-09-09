extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO

var camera: Node3D

func _on_hit(result: Dictionary):
	print_debug("hit!")

func _ready():
	camera = $OverShoulderCamera
	var detector: RayCastHitDetector = $StaticBody3D/Orb/RayCastHitDetector
	detector.hit.connect(_on_hit)
	detector.add_exclusion(self)
	detector.begin()

func _physics_process(delta):
	var direction = Vector3.ZERO

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	var h_axis = Input.get_axis("move_left", "move_right")
	var y_axis = Input.get_axis("move_forward", "move_backward") 
	direction =	(camera.basis * -Vector3(h_axis, 0, y_axis)).normalized()
		
	velocity = direction * speed
	
	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		velocity.y = velocity.y - (fall_acceleration * delta)

	move_and_slide()

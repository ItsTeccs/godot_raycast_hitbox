extends Node2D

var _detector: RayCastHitDetector2D

## Sample custom hit response method
## result arg is a dictionary of the RayCast result from successful hits.
func _on_hit(result: Dictionary):
	print_debug("Hit Entity: " + result.collider.name)
	result.collider.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_detector = $RayCastHitDetector2D	
	_detector.hit.connect(_on_hit)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("clicked")
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_detector.begin()
			MOUSE_BUTTON_RIGHT:
				_detector.end()


func _physics_process(delta: float) -> void:
	position = get_global_mouse_position()

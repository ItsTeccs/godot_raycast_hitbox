extends Node3D

class_name RayCastHitDetector

@export_group("Debug Settings")
## Toggles debug drawing of RayCastHitPoints each frame.
@export var debug_draw := false
## How long each line segment should exist for after generation.
@export var segment_lifetime := 1.0

# line segments for debug draw 
var _debug_lines: Array[ImmediateMesh]
var _line_creation_times: Dictionary

var ray_nodes: Dictionary
# Positions of each hit point on the last frame
var _last_position: Dictionary

var _exclusion_RIDs: Array[RID]

func draw_debug_line() -> void:
	# Precheck to remove any expired segments
	for line_segment in _debug_lines:
		if Time.get_ticks_msec() - _line_creation_times[line_segment] >= segment_lifetime:
			_debug_lines.erase(line_segment)
			line_segment.queue_free()
			
	# Some mesh logic here..

func get_exclusions() -> Array[RID]:
	return _exclusion_RIDs

func add_exclusion(exclude: CollisionObject3D) -> void:
	if _exclusion_RIDs.find(exclude.get_rid()) == -1:
		_exclusion_RIDs.append(exclude.get_rid())

func remove_exclusion(exclude: CollisionObject3D) -> void:
	_exclusion_RIDs.erase(exclude.get_rid())

func get_hit_point(s: String) -> RayCastHitPoint:
	return ray_nodes[s] if ray_nodes.has(s) else null

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is RayCastHitPoint:
			ray_nodes[child.name] = child
			_last_position[child.name] = child.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var keys = ray_nodes.keys()
	for key in keys:
		var node = ray_nodes[key]
		var space_state = get_world_3d().direct_space_state
		# use global coordinates, not local to node
		var origin = node.global_position
		var end = _last_position[node]
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		#	query.exclude = _exclusion_RIDs
		query.hit_from_inside = true
		query.exclude = _exclusion_RIDs
		query.collide_with_areas = true
		query.collide_with_bodies = true
		
		var result = space_state.intersect_ray(query)		
		if result:
			print_debug(result)

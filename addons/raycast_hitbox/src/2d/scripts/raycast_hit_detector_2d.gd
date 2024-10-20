extends Node2D

class_name RayCastHitDetector2D

@export_group("Debug Settings")
## Toggles debug drawing of RayCastHitPoints each frame.
@export var debug_draw := false

@export_group("Detection Settings")
@export var hit_points: Array[RayCastHitPoint2D]
## Mask for collision layers the RayCastHitPoints will collide with.
@export_flags_3d_physics var ray_collision_mask = 1
@export var segment_lifetime := 1.0

## Emitted when a hit is detected by a RayCastHitPoint.
signal hit

var _detecting := false
var _hit_entities := []
var _exclusion_RIDs: Array[RID]
var hit_point_data: Dictionary
var _default_custom_filter_method = func(result: Dictionary) -> bool: return true
var _custom_filter_method: Callable = func(result: Dictionary) -> bool: return true

## Sets a custom filter method that is checked against colliding entities.
##
## If a collision fails this custom heuristic the <NAME> signal will not be called.
##
## To reset the custom filter to default, set the filter to null.
##
## result: Dictionary The raycast result information for collision with this entity.
##
## bool: Whether this passes the check for an entity to register a valid collision against.
func set_custom_filter(foo: Callable) -> void:
	if not foo:
		_custom_filter_method = _default_custom_filter_method
	else:
		_custom_filter_method = foo

func get_exclusions() -> Array[RID]:
	return _exclusion_RIDs

func add_exclusion(exclude: CollisionObject3D) -> void:
	if _exclusion_RIDs.find(exclude.get_rid()) == -1:
		_exclusion_RIDs.append(exclude.get_rid())

func remove_exclusion(exclude: CollisionObject3D) -> void:
	_exclusion_RIDs.erase(exclude.get_rid())

func get_hit_point_data(point_name: String) -> RayCastHitPoint2D:
	return hit_point_data[point_name] if hit_point_data.has(point_name) else null

func add_point(point: RayCastHitPoint2D) -> void:
	assert(!hit_point_data.has(point.name), "Attempted to add two hit points with the same name!")
	var default_data: Dictionary = {
		"points": {},
		"node": null
	}
	hit_point_data[point.name] = default_data
	hit_point_data[point.name].points[point.global_position] = Time.get_ticks_msec()
	hit_point_data[point.name].node = point

func begin() -> void:
	_hit_entities.clear()
	_detecting = true

func end() -> void:
	_detecting = false

func remove_point(point: RayCastHitPoint2D) -> void:
	assert(hit_point_data.has(point.name), "Attempted to remove point that doesn't exist!")
	hit_point_data.erase(point.name)

func _ready():
	for child in hit_points:
		if child is RayCastHitPoint2D:
			add_point(child)
			if debug_draw:
				# Add a default Line2D if there is no custom line set.
				if !child.debug_mesh:
					child.debug_mesh = Line2D.new()
					child.add_child(child.debug_mesh)
				else:
					if child.debug_mesh.get_parent() != child:
						push_warning("Line2D is not a direct child of RayCastHitPoint2D")


func _draw_debug_mesh(data: Dictionary) -> void:
	var node = data.node as RayCastHitPoint2D
	var points = data.points
	var line2d: Line2D = node.debug_mesh
	line2d.clear_points()

	for i in range(1, points.keys().size() - 1):
		var point: Vector2 = data.points.keys()[i] - node.global_position
		# for j in 2:
		#	line2d.add_point(point)
		line2d.add_point(point)

func _physics_process(delta: float) -> void:
	# If mesh or detection does not need to be updated, return immediately.
	if not _detecting and !debug_draw:
		return

	var keys = hit_point_data.keys()
	for key in keys:
		var data: Dictionary = hit_point_data[key]
		var node: RayCastHitPoint2D = data.node as RayCastHitPoint2D

		for point in data.points.keys():
			if Time.get_ticks_msec() - data.points[point] >= segment_lifetime * 1000:
				data.points.erase(point) 

		if debug_draw and !data.points.keys().is_empty():
			_draw_debug_mesh(data)

		if _detecting:
			var space_state := get_world_2d().direct_space_state

			var origin = data.points.keys().back() if !data.points.is_empty() else null
			var end = node.global_position
			data.points[end] = Time.get_ticks_msec()
			if origin:
				var query = PhysicsRayQueryParameters2D.create(origin, end)
				query.hit_from_inside = true
				query.exclude = _exclusion_RIDs
				query.collision_mask = ray_collision_mask
				query.collide_with_areas = true
				query.collide_with_bodies = true
				var result = space_state.intersect_ray(query)		
				if result and _custom_filter_method.call(result) and (_hit_entities.find(result.collider) == -1):
					_hit_entities.append(result.collider)
					# update to handle multiple intersections later

					hit.emit(result)

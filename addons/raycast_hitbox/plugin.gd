@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	# Add the new type with a name, a parent type, a script and an icon.

	# Adding 3D nodes
	add_custom_type("RayCastHitDetector3D", "Node3D",  \
	preload("res://addons/raycast_hitbox/src/3d/scripts/raycast_hit_detector_3d.gd"), preload("res://addons/raycast_hitbox/src/assets/raycast_hit_detector_3d_icon.svg"))

	add_custom_type("RayCastHitPoint3D", "Node3D",  \
	preload("res://addons/raycast_hitbox/src/3d/scripts/raycast_hit_point_3d.gd"), preload("res://addons/raycast_hitbox/src/assets/raycast_hit_point_3d_icon.svg"))

	# Adding 2D Nodes
	add_custom_type("RayCastHitDetector3D", "Node3D",  \
	preload("res://addons/raycast_hitbox/src/2d/scripts/raycast_hit_detector_2d.gd"), preload("res://addons/raycast_hitbox/src/assets/raycast_hit_detector_2d_icon.svg"))

	add_custom_type("RayCastHitPoint3D", "Node3D",  \
	preload("res://addons/raycast_hitbox/src/2d/scripts/raycast_hit_point_2d.gd"), preload("res://addons/raycast_hitbox/src/assets/raycast_hit_point_2d_icon.svg"))

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Always remember to remove it from the engine when deactivated.
	remove_custom_type("RayCastHitDetector3D")
	remove_custom_type("RayCastHitPoint3D")
	remove_custom_type("RayCastHitDetector2D")
	remove_custom_type("RayCastHitPoint2D")

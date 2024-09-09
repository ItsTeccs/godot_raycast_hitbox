@tool
extends EditorPlugin


func _enter_tree():
	# Initialization of the plugin goes here.
	# Add the new type with a name, a parent type, a script and an icon.
	add_custom_type("RayCastHitDetector", "Node3D",  \
	preload("res://addons/raycast_hitbox/src/script/raycast_hit_detector.gd"), preload("res://addons/raycast_hitbox/src/assets/raycast_hit_detector_icon.png"))

	add_custom_type("RayCastHitPoint", "Node3D",  \
	preload("res://addons/raycast_hitbox/src/script/raycast_hit_detector.gd"), preload("res://addons/raycast_hitbox/src/assets/raycast_hit_point_icon.png"))

func _exit_tree():
	# Clean-up of the plugin goes here.
	# Always remember to remove it from the engine when deactivated.
	remove_custom_type("RayCastHitDetector")
	remove_custom_type("RayCastHitPoint")

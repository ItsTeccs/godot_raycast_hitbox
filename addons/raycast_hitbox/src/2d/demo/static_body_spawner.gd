extends Node

var _demo_rectangle := preload("res://addons/raycast_hitbox/src/2d/demo/demo_rectangle.tscn")
var _spawn_delay := 1
var _last_spawn_at := Time.get_ticks_msec()

func _spawn_rect():
	var new_rect = _demo_rectangle.instantiate()
	var world = get_parent()
	world.add_child.call_deferred(new_rect)

func _ready():
	_spawn_rect()
	_last_spawn_at = Time.get_ticks_msec()

func _process(delta: float) -> void:
	var demo_rectangle = get_node_or_null("../StaticBody2D")
	if not demo_rectangle and (Time.get_ticks_msec() - _last_spawn_at) >= _spawn_delay * 1000:
		_spawn_rect()
		_last_spawn_at = Time.get_ticks_msec()

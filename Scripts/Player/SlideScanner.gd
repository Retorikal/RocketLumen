extends Node2D

class_name SlideScanner

## The smallest possible scan extend size if it's not zero
@export var minimum_extension_length: float

@onready var slide_scanner: Area2D = $SlideScanner
@onready var slide_scanner_shape: CollisionShape2D = $SlideScanner/CollisionShape2D
@onready var corn_scanner: RayCast2D = $CornerScanner
@onready var original_width = slide_scanner_shape.shape.size.x

func set_scan_distance(projected_dpos: Vector2) -> void:
	var tangent_dpos: float
	
	if projected_dpos != Vector2.ZERO:
		var forward = Vector2.RIGHT.rotated(global_rotation)
		tangent_dpos = max(projected_dpos.project(forward).length(), minimum_extension_length)
		print("SlideScanner:set_scan_distance", forward, tangent_dpos)
	else:
		tangent_dpos = 0

	corn_scanner.target_position = Vector2(tangent_dpos, 0)
	slide_scanner_shape.shape.size.x = original_width + tangent_dpos
	slide_scanner_shape.position.x = tangent_dpos / 2

	pass

func is_on_sliding_terrain():
	return slide_scanner.get_overlapping_bodies().size() > 0

func is_facing_corner():
	if corn_scanner.is_colliding():
		return true
	return false

func corner_collision_point():
	return corn_scanner.get_collision_point()

func get_wall_snap_shift():
	# var offset = corn_scanner.transform.look
	return corn_scanner.get_collision_point() - corn_scanner.global_position

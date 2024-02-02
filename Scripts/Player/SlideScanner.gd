extends Node2D

class_name SlideScanner

@onready var slide_scanner: Area2D = $SlideScanner
@onready var corn_scanner: RayCast2D = $CornerScanner

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
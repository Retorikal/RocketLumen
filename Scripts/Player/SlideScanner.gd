extends Node2D

class_name SlideScanner

@onready var head_scanner: RayCast2D = $HeadScanner
@onready var tail_scanner: RayCast2D = $TailScanner
@onready var corn_scanner: RayCast2D = $CornerScanner

func is_on_sliding_terrain():
	return head_scanner.is_colliding()||tail_scanner.is_colliding()

func is_facing_corner():
	if corn_scanner.is_colliding():
		print("Corner scanner -;", corn_scanner.global_rotation_degrees, "collide at", corn_scanner.get_collision_point())
		return true
	return false

func corner_collision_point():
	return corn_scanner.get_collision_point()
extends Node2D

@export var rocket: PackedScene
@export var sibling_hitbox_specifier: String = "Hitbox"

@onready var parent = get_parent()
@onready var wielder_hitbox: CollisionObject2D = parent.get_node(sibling_hitbox_specifier)
# Builtin functions

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	# Mouse in viewport coordinates.
	if event.is_action_pressed("launch"):
		var heading = (global_position - get_global_mouse_position()).angle()
		launch_rocket(heading)

# Custom functions

func launch_rocket(heading):
	var new_rocket: Rocket = rocket.instantiate()
	new_rocket.global_position = global_position
	new_rocket.rotation = heading
	new_rocket.owner_hurtbox = wielder_hitbox
	new_rocket.launcher_velocity = parent.velocity
	get_tree().root.add_child(new_rocket)
	pass

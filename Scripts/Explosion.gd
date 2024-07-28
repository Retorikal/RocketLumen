extends Node2D

@export var blow_force: float = 100

@onready var particle: GPUParticles2D = $ExplodeParticles

var particle_parent: Node2D
# Interface
# - apply_force(Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	particle_parent = get_tree().get_nodes_in_group("ObscuredParticle")[0]

	remove_child(particle)
	particle_parent.add_child(particle)
	particle.emitting = true
	particle.global_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_hitbox_body_entered(body: Node2D):
	if body.has_method("apply_force"):
		var direction = (body.global_position - global_position).normalized()
		print("Explosion:_on_hitbox_body_entered", body.global_position, global_position)
		body.apply_force(direction * blow_force)

func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.

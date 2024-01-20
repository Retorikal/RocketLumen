extends Node2D

@export var blow_force: float = 100

@onready var particles: GPUParticles2D = $Particles

# Interface
# - apply_force(Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	particles.emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_gpu_particles_2d_finished():
	queue_free()
	pass # Replace with function body.

func _on_hitbox_body_entered(body: Node2D):
	print("Launching:", body)
	if body.has_method("apply_force"):
		var direction = (body.position - position).normalized()
		body.apply_force(direction * blow_force)

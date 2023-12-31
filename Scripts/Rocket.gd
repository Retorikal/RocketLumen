extends RigidBody2D

class_name Rocket

@onready var trails: CPUParticles2D = $ParticleTrails
@onready var body_sprite: Polygon2D = $BodySprite
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: CollisionShape2D = $Hurtbox
@export var base_velocity = 100
@export var payload: PackedScene
# @export var primed = false
var owner_hitbox: Node
var primed_selfhit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# primed = false
	pass # Replace with function body.

func _physics_process(delta):
	rotation = linear_velocity.angle()

func _on_tree_entered():
	linear_velocity = Vector2.LEFT.rotated(rotation) * base_velocity
	pass # Replace with function body.

func _on_exit_area(area: Area2D):
	if area == owner_hitbox:
		primed_selfhit = true

func _on_hit_body(body: Node2D):
	print("body hit", body)
	detonate()
	pass # Replace with function body.

func _on_hit_area(area: Area2D):
	print("collider hit", area)
	if area == owner_hitbox and not primed_selfhit:
		return
	detonate()

func detach(node: Node):
	remove_child(node)
	get_tree().root.add_child(node)

func detonate():
	print("boom")
	trails.emitting = false
	set_deferred("freeze", true)
	body_sprite.set_deferred("visible", false)
	hurtbox.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout
	queue_free()

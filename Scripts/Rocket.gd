extends RigidBody2D

class_name Rocket

@onready var trails: CPUParticles2D = $ParticleTrails
@onready var body_sprite: Polygon2D = $BodySprite
@onready var hurtbox: CollisionShape2D = $Hurtbox
@onready var forecast: RayCast2D = $Forecast

@export var base_velocity = 2000
@export var max_lifetime = 1.5
@export var launcher_velocity = Vector2(0, 0)
@export var payload_template: PackedScene
# @export var primed = false
var owner_hurtbox: Node
var primed_selfhit = false
var lifetime: float = 0
var exploded = false

# Called when the node enters the scene tree for the first time.
func _ready():
	linear_velocity = (Vector2.LEFT.rotated(rotation) * base_velocity) + launcher_velocity

func _physics_process(delta):
	lifetime += delta
	forecast.target_position = Vector2(linear_velocity.length() * delta * 1.5, 0)

	if forecast.is_colliding():
		detonate(forecast.get_collision_point())
	if lifetime >= max_lifetime and not exploded:
		detonate(global_position)
	rotation = linear_velocity.angle()

func _on_exit_area(area: Area2D):
	if area == owner_hurtbox:
		primed_selfhit = true

func detach(node: Node):
	remove_child(node)
	get_tree().root.add_child(node)

func detonate(location: Vector2):
	if exploded:
		return

	exploded = true
	trails.emitting = false
	set_deferred("freeze", true)
	body_sprite.set_deferred("visible", false)
	hurtbox.set_deferred("disabled", true)

	var payload: Node2D = payload_template.instantiate()
	payload.position = location
	get_tree().root.call_deferred("add_child", payload)

	await get_tree().create_timer(1.0).timeout
	queue_free()

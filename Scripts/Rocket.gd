extends RigidBody2D

class_name Rocket

@onready var trails: CPUParticles2D = $ParticleTrails
@onready var body_sprite: Polygon2D = $BodySprite
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: CollisionShape2D = $Hurtbox
@onready var head_pt: Marker2D = $Head
@onready var tail_pt: Marker2D = $Tail
@onready var space_state = get_world_2d().direct_space_state
@onready var last_tail_pos: Vector2 = head_pt.global_position

@export var base_velocity = 2000
@export var max_lifetime = 1.5
@export var launcher_velocity = Vector2(0, 0)
@export var payload: PackedScene
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
	if lifetime >= max_lifetime and not exploded:
		detonate()
	rotation = linear_velocity.angle()
	last_tail_pos = tail_pt.global_position
	pass

func _on_exit_area(area: Area2D):
	if area == owner_hurtbox:
		primed_selfhit = true

func _on_hit_body(body: Node2D):
	detonate()

func _on_hit_area(area: Area2D):
	if area == owner_hurtbox and not primed_selfhit:
		return
	detonate()

func detach(node: Node):
	remove_child(node)
	get_tree().root.add_child(node)

func detonate():
	if exploded:
		return

	exploded = true
	print("boom")
	trails.emitting = false
	set_deferred("freeze", true)
	body_sprite.set_deferred("visible", false)
	hurtbox.set_deferred("disabled", true)

	var head_pos = head_pt.global_position
	var query = PhysicsRayQueryParameters2D.create(last_tail_pos, head_pos)
	var result = space_state.intersect_ray(query)

	var marker: Node2D = payload.instantiate()
	if len(result) > 0:
		marker.set_deferred("position", result.position)
	else:
		marker.set_deferred("position", global_position)
	
	get_tree().root.call_deferred("add_child", marker)
	pass

	await get_tree().create_timer(1.0).timeout
	queue_free()

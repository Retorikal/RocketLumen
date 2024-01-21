extends CharacterBody2D

class_name Player

enum Grounding {GROUNDED, AIRBONE, LAUNCHED, SLIDING}
 
# --------- VARIABLES ---------- #

@export_category("Player Properties") # You can tweak these changes according to your likings
@export var move_speed: float = 400
@export var slide_speed: float = 600
@export var jump_force: float = 600
@export var global_gravity_mul: float = 1
@export var mass: float = 1
@export var max_jump_count: int = 2
@export var max_coyote_time: float = 0.1

var just_launched: bool = false
var coyote_time: float = max_coyote_time
var jump_count: int = max_jump_count

@export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)
@export var double_jump := false

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var grounding: Grounding = Grounding.GROUNDED

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles
@onready var slide_scanner: RayCast2D = $SlideScanner

# --------- BUILT-IN FUNCTIONS ---------- #

func _process(_delta):
	# Calling functions
	movement(_delta)
	player_animations()
	flip_player()

func _physics_process(_delta):
	# Update grounding

	pass

# --------- CUSTOM FUNCTIONS ---------- #

func move_gravity(_delta):
	var accel = gravity * _delta *global_gravity_mul
	velocity.y += accel

# <-- Player Movement Code -->
func movement(_delta):
	match grounding:
		Grounding.GROUNDED:
			coyote_time = max_coyote_time
			jump_count = max_jump_count
			velocity = Vector2(Input.get_axis("a", "d") * move_speed, velocity.y)

			if !is_on_floor():
				grounding = Grounding.AIRBONE

		Grounding.SLIDING:
			pass

		Grounding.AIRBONE:
			move_gravity(_delta)
			coyote_time -= _delta
			velocity = Vector2(Input.get_axis("a", "d") * move_speed, velocity.y)

			if is_on_floor():
				grounding = Grounding.GROUNDED

		Grounding.LAUNCHED:
			move_gravity(_delta)

			# TODO: Grounding instantly becomes true if launched from ground

			if just_launched:
				just_launched = false
			else:
				if is_on_ceiling()||is_on_wall():
					grounding = Grounding.AIRBONE
				elif is_on_floor():
					grounding = Grounding.GROUNDED

	move_and_slide()

# Player jump
func jump():
	# # AudioManager.jump_sfx.play()
	jump_tween()
	grounding = Grounding.AIRBONE
	velocity.y = - jump_force

func slide():
	if Input.is_action_pressed("slide"):
		pass
		
# Handle Player Animations
func player_animations():
	particle_trails.emitting = false

	if is_on_floor():
		if abs(velocity.x) > 0:
			particle_trails.emitting = true
			player_sprite.play("Walk", 1.5)
		else:
			player_sprite.play("Idle")
	else:
		player_sprite.play("Jump")

# Flip player sprite based on X velocity
func flip_player():
	if velocity.x < 0:
		player_sprite.flip_h = true
		slide_scanner.scale = Vector2(-1, 1)
	elif velocity.x > 0:
		player_sprite.flip_h = false
		slide_scanner.scale = Vector2(1, 1)

# Tween Animations
func death_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	global_position = spawn_point.global_position
	await get_tree().create_timer(0.3).timeout
	# # AudioManager.respawn_sfx.play()
	respawn_tween()

func respawn_tween():
	var tween = create_tween()
	tween.stop()
	tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)

func jump_tween():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.7, 1.4), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func apply_force(force: Vector2):
	grounding = Grounding.LAUNCHED
	just_launched = true
	var launched_vector = force / mass
	velocity = launched_vector
	pass

# --------- SIGNALS ---------- #

# Reset the player's position to the current level spawn point if collided with any trap
# This should be put in hazard, not player
func _on_collision_body_entered(_body):
	if _body.is_in_group("Traps"):
		# # AudioManager.death_sfx.play()
		death_particles.emitting = true
		death_tween()

func _input(event):
	if event.is_action_pressed("jump")&&grounding != Grounding.LAUNCHED:
		if !double_jump:
			if is_on_floor() or coyote_time >= 0:
				jump()
		elif double_jump:
			if jump_count > 0:
				jump()
				jump_count -= 1

	# Mouse in viewport coordinates.
	# print(event)
	# if &&slide_scanner.is_colliding():
	# 	print(slide_scanner.get_collision_point())

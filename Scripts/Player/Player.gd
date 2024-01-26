extends CharacterBody2D

class_name Player

enum Grounding {GROUNDED, AIRBONE, LAUNCHED, SLIDING}
enum SlideDir {FACE_0, FACE_90, FACE_180, FACE_270}
const PI_2 = PI / 2

# --------- VARIABLES ---------- #

@export_category("Player Properties") # You can tweak these changes according to your likings
@export var move_speed: float = 400
@export var airbone_control: float = 100
@export var slide_speed: float = 600
@export var jump_force: float = 600
@export var global_gravity_mul: float = 1
@export var mass: float = 1
@export var max_extra_jump_count: int = 1
@export var max_coyote_time: float = 0.1

var just_launched: bool = false
var just_stopped_sliding: bool = false
var coyote_time: float = max_coyote_time
var extra_jump_count: int = max_extra_jump_count
var slide_orient: SlideDir = SlideDir.FACE_0

@export_category("Toggle Functions") # Double jump feature is disable by default (Can be toggled from inspector)

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var grounding: Grounding = Grounding.GROUNDED

@onready var player_sprite = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles
@onready var slide_scanner: SlideScanner = $SlideScanner
@onready var shape: CollisionShape2D = $PlayerShape
@onready var scatterer: StardustScatterer = $SlideScanner/StardustScatterer

# --------- BUILT-IN FUNCTIONS ---------- #

func _process(_delta):
	# Calling functions
	pass
	player_animations()

func _physics_process(_delta):
	# Update grounding

	movement(_delta)
	pass

# --------- CUSTOM FUNCTIONS ---------- #

func move_gravity(_delta):
	var accel = gravity * _delta *global_gravity_mul
	velocity.y += accel

# <-- Player Movement Code -->
func movement(_delta):
	var ctrl_slide = Input.is_action_pressed("slide")
	var can_slide = ctrl_slide && slide_scanner.is_on_sliding_terrain()

	match grounding:
		Grounding.GROUNDED:
			coyote_time = max_coyote_time
			extra_jump_count = max_extra_jump_count
			velocity = Vector2(Input.get_axis("a", "d") * move_speed, velocity.y)
			handle_jump()

			if !is_on_floor():
				grounding = Grounding.AIRBONE

		Grounding.SLIDING:
			handle_jump()
			
			if !can_slide:
				if is_on_floor():
					grounding = Grounding.GROUNDED
				else:
					grounding = Grounding.LAUNCHED

		Grounding.AIRBONE:
			move_gravity(_delta)
			coyote_time -= _delta
			velocity = Vector2(Input.get_axis("a", "d") * move_speed, velocity.y)
			handle_jump()

			if is_on_floor():
				grounding = Grounding.GROUNDED

		Grounding.LAUNCHED:
			velocity += Vector2(Input.get_axis("a", "d") * airbone_control, 0)
			move_gravity(_delta)

			# TODO: Grounding instantly becomes true if launched from ground

			if just_launched:
				just_launched = false
			else:
				if is_on_ceiling()||is_on_wall():
					grounding = Grounding.AIRBONE
				elif is_on_floor():
					grounding = Grounding.GROUNDED

	if ctrl_slide:
		if slide_scanner.is_facing_corner():
			motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
			latch_wall()
			grounding = Grounding.SLIDING
		
		elif slide_scanner.is_on_sliding_terrain():
			motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
			grounding = Grounding.SLIDING
		
	if grounding == Grounding.SLIDING&&(is_on_wall() || is_on_floor() || is_on_ceiling()):
		scatterer.scattering = true

	if grounding != Grounding.SLIDING:
		scatterer.scattering = false
		motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		if velocity.x != 0:
			flip_player(velocity.x > 0)
		slide_orient = SlideDir.FACE_0
		rotation = 0

	if just_stopped_sliding&&!slide_scanner.is_on_sliding_terrain():
		just_stopped_sliding = false
		# Snap to slide location

	move_and_slide()

func handle_jump():
	if Input.is_action_pressed("jump"):
		if grounding == Grounding.GROUNDED or coyote_time >= 0:
			jump()

		elif extra_jump_count > 0:
			jump()
			extra_jump_count -= 1

# Player jump
func jump():
	# # AudioManager.jump_sfx.play()
	jump_tween()
	grounding = Grounding.AIRBONE
	velocity.y = - jump_force

func latch_wall():
	var collision_point = slide_scanner.corner_collision_point()
	var facing_mul = (-1 if !player_sprite.flip_h else 1)

	position += collision_point - slide_scanner.global_position

	# If latching from air, determine direction based on flight direction
	if grounding == Grounding.AIRBONE||grounding == Grounding.LAUNCHED:
		if velocity.y > 0:
			flip_player(player_sprite.flip_h)
			facing_mul = - facing_mul
			slide_orient = SlideDir.FACE_270
		else:
			slide_orient = SlideDir.FACE_90
	else:
		slide_orient = ((slide_orient + 1) % 4) as SlideDir
	
	rotation = facing_mul * PI_2 * slide_orient
	var basevec = Vector2(velocity.length()* -facing_mul, 0)
	velocity = basevec.rotated(rotation)

	print(rad_to_deg(rotation), " - ", basevec, " - ", velocity)

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
func flip_player(facing_right: bool):
	if facing_right:
		player_sprite.flip_h = false
		slide_scanner.scale = Vector2(1, 1)
	else:
		player_sprite.flip_h = true
		slide_scanner.scale = Vector2(-1, 1)

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
	if grounding == Grounding.SLIDING:
		just_stopped_sliding = true

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


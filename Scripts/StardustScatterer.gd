extends Area2D

class_name StardustScatterer

@export var scatterer: GPUParticles2D
@export var scattering: bool

@onready var cell_poly: ConvexPolygonShape2D = ConvexPolygonShape2D.new()

var coll_shape: CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: This method can't handle multiple shape yet
	for child in get_children():
		if child is CollisionShape2D:
			coll_shape = child
			return
	pass # Replace with function body.

func _physics_process(delta):
	if scattering:
		var areas = get_overlapping_bodies()
		for area in areas:
			var potential_chunk = area.get_parent()
			if potential_chunk is Chunk:
				subs_colliding_tiles_at_chunk(potential_chunk)

func subs_colliding_tiles_at_chunk(chunk: Chunk):
	if (coll_shape == null):
		return

	var rect = coll_shape.shape.get_rect()
	var tl = chunk.invis_hazard.local_to_map(rect.position + chunk.to_local(coll_shape.global_position))
	var br = chunk.invis_hazard.local_to_map(rect.end + chunk.to_local(coll_shape.global_position))

	# Iterate for all cell in chunk, then check if it is revealable

	var must_draw_dust = false
	for x in range(tl.x, br.x + 1):
		for y in range(tl.y, br.y + 1):
			var map_pos = Vector2i(x, y)
			var data = chunk.invis_hazard.get_cell_tile_data(0, map_pos)

			if data != null:
				var global_tile = chunk.map_to_global(map_pos)
				var tf = Transform2D(0, global_tile)
				var local_cell_pcl = data.get_collision_polygon_points(0, 0)
				cell_poly.set_point_cloud(local_cell_pcl)
				if cell_poly.collide(tf, coll_shape.shape, global_transform):
					chunk.substitute_cell(Vector2i(x, y))
					must_draw_dust = true

func draw_dust():

	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

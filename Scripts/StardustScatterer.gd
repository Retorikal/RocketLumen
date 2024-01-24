extends Area2D

@export var solid_tilemap: TileMap
@export var hazard_tilemap: TileMap

@onready var shape: CollisionShape2D = $Area
@onready var cell_area: Area2D = $CellPolygonHolder
@onready var cell_area_shape: CollisionPolygon2D = $CellPolygonHolder/CollisionPolygon

# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.

func _input(event):
	if Input.is_key_pressed(KEY_C):
		print("Checking tilemap..")
		get_colliding_tiles()

func get_colliding_tiles():
	var rect = shape.shape.get_rect()
	var tl = hazard_tilemap.local_to_map(rect.position + shape.global_position)
	var br = hazard_tilemap.local_to_map(rect.end + shape.global_position)

	var poly_shape = CollisionPolygon2D.new()

	for x in range(tl.x, br.x + 1):
		for y in range(tl.y, br.y + 1):
			var map_pos = Vector2i(x, y)
			var data = hazard_tilemap.get_cell_tile_data(0, map_pos)

			if data != null:
				var global_tile = hazard_tilemap.to_global(hazard_tilemap.map_to_local(map_pos))
				var tf = Transform2D(0, - global_tile)
				var local_cell_pcl = data.get_collision_polygon_points(0, 0)
				var global_cell_pcl = local_cell_pcl * tf
				
				# TODO Register the global_cell_pcl to a polygon and check its overlap against this area2d

			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

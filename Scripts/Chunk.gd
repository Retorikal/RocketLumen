extends Node2D

class_name Chunk

@export var invis_hazard: TileMap
@export var solid_ground: TileMap
@export var solid_substitute_atlas_idx: Vector2i
@export var solid_tileset_source_id: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func map_to_global(pos: Vector2i):
	return invis_hazard.to_global(invis_hazard.map_to_local(pos))

func substitute_cell(pos: Vector2i):
	invis_hazard.set_cell(0, pos, -1)
	solid_ground.set_cell(0, pos, solid_tileset_source_id, solid_substitute_atlas_idx)
	pass
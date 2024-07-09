extends Node2D

class_name Chunk

signal border_passed(terrain_pos: Vector2i, border_id: Direction)

@export var invis_hazard: TileMap
@export var solid_ground: TileMap
@export var solid_substitute_atlas_idx: Vector2i
@export var solid_tileset_source_id: int

@export var terrain_id: Vector2i

enum Direction {TOP, LEFT, RIGHT, BOTTOM}

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

func _on_body_enter_top(_area: Node2D) -> void:
	emit_signal("border_passed", terrain_id, Direction.TOP)
	pass # Replace with function body.

func _on_body_enter_bottom(_area: Node2D) -> void:
	emit_signal("border_passed", terrain_id, Direction.BOTTOM)
	pass # Replace with function body.

func _on_body_enter_left(_area: Node2D) -> void:
	emit_signal("border_passed", terrain_id, Direction.LEFT)
	pass # Replace with function body.

func _on_body_enter_right(_area: Node2D) -> void:
	emit_signal("border_passed", terrain_id, Direction.RIGHT)
	pass # Replace with function body.
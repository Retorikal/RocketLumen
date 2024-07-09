extends Node2D

@export var tracked_entity: Node2D
@export var seed_tile: Chunk

@export var rand_tile: Array[PackedScene]
@export var tile_distance: int

var tile_list: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_list = {Vector2i(0, 0): seed_tile}
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_level_chunk_border_passed(terrain_pos: Vector2i, border_id: Chunk.Direction) -> void:
	var new_terrain_id: Vector2i = terrain_pos

	if border_id == Chunk.Direction.TOP:
		new_terrain_id += Vector2i.UP
	elif border_id == Chunk.Direction.BOTTOM:
		new_terrain_id += Vector2i.DOWN
	elif border_id == Chunk.Direction.LEFT:
		new_terrain_id += Vector2i.LEFT
	elif border_id == Chunk.Direction.RIGHT:
		new_terrain_id += Vector2i.RIGHT

	var new_terrain_pos = new_terrain_id * tile_distance

	if not tile_list.has(new_terrain_id):
		print("TerrainGenerator:_on_level_chunk_border_passed creating at", new_terrain_pos)
		var new_chunk: Chunk = rand_tile[0].instantiate()
		tile_list[new_terrain_id] = new_chunk
		new_chunk.terrain_id = new_terrain_id
		new_chunk.position = new_terrain_pos
		# new_chunk.call_deferred("connect", "border_passed", _on_level_chunk_border_passed)
		new_chunk.connect("border_passed", _on_level_chunk_border_passed)
		call_deferred("add_child", new_chunk)

	pass # Replace with function body.

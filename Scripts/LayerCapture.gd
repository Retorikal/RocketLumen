extends SubViewport

@export var world_2d_source: Viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	world_2d = world_2d_source.world_2d
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

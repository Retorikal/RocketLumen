extends GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_toggle_revealing(revealing: bool) -> void:
	emitting = revealing

func _on_player_state_changed(prev: Player.Grounding, next: Player.Grounding) -> void:
	pass # Replace with function body.

extends TextureRect



func _physics_process(delta: float) -> void:
	var color: Color = Color.from_hsv(0.163, 0.953, Weather.current_efficiency, 1.0)
	self_modulate = color

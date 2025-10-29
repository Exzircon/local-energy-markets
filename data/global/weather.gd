extends Node

@export_category("Weather")
@export var day_length: float = 72.0 #Day length in seconds
@export var sun_curve: Curve



var current_efficiency: float = 1.0
var current_time_percent: float = 0.2



func _physics_process(delta: float) -> void:
	current_time_percent += delta / day_length
	if current_time_percent > 1.0: current_time_percent = 0.0
	current_efficiency = 1.0 * sun_curve.sample(current_time_percent)

extends Node
## Global Node for controlling time of day and weather
## Mainly used for calculating solar power efficiency

@export_category("Weather")
##Day length in seconds
@export var day_length: float = 24.0
##Curve for sunlight efficienty throughout one day, does not take into account time of year
@export var sun_curve: Curve

##Current efficiency of solar panels, accessed by buildings to know how much their solar panels should produce
var current_efficiency: float = 1.0

## The current time, 
var current_time: float = 0.0

func _physics_process(delta: float) -> void:
	update_time(delta)
	current_efficiency = 1.0 * sun_curve.sample(current_time)


## Function for updating the current time of day
func update_time(delta: float) -> void:
	current_time += delta / day_length * sun_curve.max_domain
	if current_time > sun_curve.max_domain: current_time = 0.0

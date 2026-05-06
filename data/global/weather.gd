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

func _ready() -> void:
	TickEngine.tick.connect(tick)
	#print("Physics: ", Engine.physics_ticks_per_second)

func tick(stage: Enums.TickStage) -> void:
	match stage:
		Enums.TickStage.ENVIROMENT:
			update_time()

func update_time() -> void:
	current_time += 1.0 / Engine.physics_ticks_per_second
	if current_time > day_length:
		current_time = 0.0
	current_efficiency = sun_curve.sample(current_time)
	#print("Time:", current_time, " --- Efficiency: ", current_efficiency)

func predict_efficiency(ticks: int) -> float:
	var total_eff: float = 0.0
	var predict_time: float = current_time
	for i in range(ticks):
		predict_time += 1.0 / Engine.physics_ticks_per_second
		if predict_time > day_length:
			predict_time = 0.0
		total_eff += sun_curve.sample(predict_time)
	return total_eff

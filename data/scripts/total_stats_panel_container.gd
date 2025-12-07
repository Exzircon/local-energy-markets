extends PanelContainer
@onready var name_label: Label = $StatsVBoxContainer/NameLabel
@onready var consumption_label: Label = $StatsVBoxContainer/ConsumptionLabel
@onready var production_label: Label = $StatsVBoxContainer/ProductionLabel
@onready var power_delta_label: Label = $StatsVBoxContainer/PowerDeltaLabel
@onready var battery_bar: ProgressBar = $StatsVBoxContainer/BatteryBar
@onready var battery_label: Label = $StatsVBoxContainer/BatteryLabel
@onready var time_label: Label = $StatsVBoxContainer/TimeLabel

var total_consumption: float = 0.0
var total_generation: float = 0.0
var total_delta: float = 0.0
var total_battery_capacity: float = 0.0
var total_power: float = 0.0
var total_battery_percent: float = 0.0

var low_color: Color = Color.RED
var mid_color: Color = Color.YELLOW
var high_color: Color = Color.GREEN

var current_time: float = 0.0

func _physics_process(_delta: float) -> void:
	current_time += _delta
	calculate_total_stats()
	consumption_label.text = "Consumption: " + str("%0.2f" % total_consumption)
	production_label.text = "Production: " + str("%0.2f" % total_generation)
	power_delta_label.text = "Power Delta: " + str("%0.2f" % total_delta)
	battery_label.text = str("%0.2f" % total_power) + " | " + str("%0.2f" % total_battery_capacity)
	battery_bar.value = total_battery_percent * 100
	_update_progress_bar_color(total_battery_percent)
	time_label.text = "Time: " + str("%0.2f" % current_time) + " hours"


func calculate_total_stats() -> void:
	total_consumption = 0.0
	total_generation = 0.0
	total_delta = 0.0
	total_battery_capacity = 0.0
	total_battery_percent = 0.0
	total_power = 0.0
	for building in PowerManager.buildings:
		total_consumption += building.consumption
		total_generation += building.generation
		total_delta += building.power_delta
		total_battery_capacity += building.capacity
		total_power += building.current_power
	total_battery_percent = total_power / total_battery_capacity



func _update_progress_bar_color(percent: float) -> void:
	percent = percent * 2
	var color: Color = Color.RED
	if percent > 1.0:
		color = mid_color.lerp(high_color, percent - 1.0)
	else:
		color = low_color.lerp(mid_color, percent)
	battery_bar.get("theme_override_styles/fill").bg_color = color

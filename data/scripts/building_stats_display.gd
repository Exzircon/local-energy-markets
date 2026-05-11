extends PanelContainer
@onready var name_label: Label = $StatsVBoxContainer/NameLabel
@onready var production_label: Label = $StatsVBoxContainer/ProductionLabel
@onready var consumption_label: Label = $StatsVBoxContainer/ConsumptionLabel
@onready var battery_label: Label = $StatsVBoxContainer/BatteryLabel
@onready var battery_bar: ProgressBar = $StatsVBoxContainer/BatteryBar


var building: Building

var low_color: Color = Color.RED
var mid_color: Color = Color.YELLOW
var high_color: Color = Color.GREEN



func _physics_process(_delta: float) -> void:
	if not building: return
	consumption_label.text = "Consumption: " + str("%0.2f" % building.consumption)
	production_label.text = "Production: " + str("%0.2f" % building.production)
	#battery_label.text = str("%0.2f" % building.power) + " | " + str("%0.2f" % building.capacity)
	#battery_bar.value = building.power / building.capacity * 100
	_update_progress_bar_color(building.power / building.capacity * 100)


func display_stats(agent: Building) -> void:
	print("Displaying stats of: ", agent.name)
	if agent is Building: building = agent
	else: return
	show()
	name_label.text = agent.name


func _update_progress_bar_color(percent: float) -> void:
	percent = percent * 2
	var color: Color = Color.RED
	if percent > 1.0:
		color = mid_color.lerp(high_color, percent - 1.0)
	else:
		color = low_color.lerp(mid_color, percent)
	battery_bar.get("theme_override_styles/fill").bg_color = color

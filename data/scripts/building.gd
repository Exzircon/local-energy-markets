extends Sprite2D
class_name Building

@export_category("Building Stats")
@export var consumption: float = 10.0
@export var generation: float = 0.0:
	get():
		return num_solar_panels * 5.0 * Weather.current_efficiency + generation
@export var num_solar_panels: int = 0
var power_delta: float:
	get():
		return generation - consumption

#TODO: Add Battery functionality to houses
@export var capacity_MWh: float = 100.0
var capacity: float = capacity_MWh * Engine.physics_ticks_per_second
var current_power: float = 0.0
var battery_percentage: float:
	get():
		return current_power / capacity
@export var battery_efficiency: float = 0.99 #TODO: Add functionality
@export var battery_discharge_rate: float = 10.0
@onready var battery_sprite: Sprite2D = $BatterySprite
@export var power_share_treshold: float = 0.3
@export var power_deficit_treshold: float = 0.1
var power_excess: float:
	get():
		return current_power - capacity * power_share_treshold
var power_state: PowerStates:
	get():
		if battery_percentage > power_share_treshold: return PowerStates.EXCESS
		elif battery_percentage < power_deficit_treshold: return PowerStates.DEFICIT
		return PowerStates.BALANCED
var max_shares: int = 2
var current_shares: Array[Building] = []
enum PowerStates {DEFICIT, BALANCED, EXCESS}


@export_group("Misc")
@export var randomize_consumption: bool = true

var external_power: float = 0.0

var satisfaction: float:
	get():
		return generation / consumption

@export_group("Colors")
@export var low_color: Color = Color.RED
@export var mid_color: Color = Color.YELLOW
@export var high_color: Color = Color.GREEN

#region Child Nodes
@onready var panel_container: PanelContainer = $PanelContainer
@onready var name_label: Label = $PanelContainer/VBoxContainer/NameLabel
@onready var consumption_label: Label = $PanelContainer/VBoxContainer/ConsumptionLabel
@onready var production_label: Label = $PanelContainer/VBoxContainer/ProductionLabel
@onready var external_power_label: Label = $PanelContainer/VBoxContainer/ExternalPowerLabel

@onready var hover_area: Area2D = $HoverArea
@onready var collision_shape_2d: CollisionShape2D = $HoverArea/CollisionShape2D
#endregion

func _init() -> void:
	num_solar_panels = randi_range(0, 4)

func _ready() -> void:
	PowerManager.add_to_power_tracker(self)
	#battery_sprite.hide()
	name_label.text = name
	hover_area.connect("mouse_entered", mouse_entered)
	hover_area.connect("mouse_exited", mouse_exited)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	current_power = clampf(current_power + power_delta, 0, capacity)
	current_shares = []
	
	_update_color(self, satisfaction)
	_update_color(battery_sprite, battery_percentage*2)
	_update_labels()



func _update_labels() -> void:
	consumption_label.text = "Con: " + str("%0.2f" % consumption)
	production_label.text = "Prod: " + str("%0.2f" % generation)
	external_power_label.text = "Battery: " + str("%0.2f" % current_power) + "MW"

func mouse_entered() -> void:
	panel_container.show()
	battery_sprite.show()

func mouse_exited() -> void:
	panel_container.hide()
	battery_sprite.hide()

func _update_color(agent: Node2D, percent: float) -> void:
	if satisfaction > 1.0:
		agent.self_modulate = mid_color.lerp(high_color, percent - 1.0)
	else:
		agent.self_modulate = low_color.lerp(mid_color, percent)

func _update_color_old() -> void:
	if satisfaction > 1.0:
		self_modulate = mid_color.lerp(high_color, satisfaction - 1.0)
	else:
		self_modulate = low_color.lerp(mid_color, satisfaction)

func send_power(where: Building, amount: float) -> float:
	if current_shares.size() > max_shares: return 0
	current_shares.append(where)
	if power_excess < amount:
		current_power -= power_excess
		return power_excess
	current_power -= amount
	return amount

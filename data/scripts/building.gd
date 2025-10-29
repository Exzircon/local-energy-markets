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
		var external: float = 0
		for agent in sending_to:
			external -= agent.consumption - agent.generation
		for agent in recieving_from:
			external += consumption - generation
		return generation - consumption + external

#TODO: Add Battery functionality to houses
@export var capacity_MWh: float = 200.0
var capacity: float = capacity_MWh * Engine.physics_ticks_per_second
var current_power: float = capacity * 0.8
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
@onready var provide_sprite: Sprite2D = $ProvideSprite



@export_group("Misc")
@export var randomize_consumption: bool = true

#var external_power: float = 0.0
var sending_to: Array[Building] = []
var recieving_from: Array[Building] = []



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

var new_reciever_this_frame: bool = false


func _init() -> void:
	num_solar_panels = randi_range(0, 4)

func _ready() -> void:
	PowerManager.buildings.append(self)
	#battery_sprite.hide()
	name_label.text = name
	hover_area.connect("mouse_entered", mouse_entered)
	hover_area.connect("mouse_exited", mouse_exited)


func _physics_process(delta: float) -> void:
	current_power = clampf(current_power + power_delta, 0, capacity)
	if current_power < capacity * power_deficit_treshold:
		PowerManager.request_power(self)
		
	if current_power < capacity * power_share_treshold and not new_reciever_this_frame:
		for reciever in sending_to:
			PowerManager.break_connection(reciever, self, "Not enough excess power | " + str(new_reciever_this_frame))
	new_reciever_this_frame = false
	
	_update_provide_sprite()
	
	_update_color(self, satisfaction)
	_update_color(battery_sprite, battery_percentage*2)
	_update_labels()

func _update_labels() -> void:
	consumption_label.text = str("%0.2f" % generation) + " / " + str("%0.2f" % consumption)
	production_label.text = "Delta: " + str("%0.2f" % power_delta)
	external_power_label.text = "Battery: " + str("%0.2f" % current_power) + "MW"

func mouse_entered() -> void:
	panel_container.show()
	#battery_sprite.show()

func mouse_exited() -> void:
	panel_container.hide()
	#battery_sprite.hide()

func _update_color(agent: Node2D, percent: float) -> void:
	if satisfaction > 1.0:
		agent.self_modulate = mid_color.lerp(high_color, percent - 1.0)
	else:
		agent.self_modulate = low_color.lerp(mid_color, percent)

func remove_connection(agent: Building) -> void:
	if agent in sending_to:
		var idx = sending_to.find(agent)
		sending_to.remove_at(idx)
	if agent in recieving_from:
		var idx = recieving_from.find(agent)
		recieving_from.remove_at(idx)


func willing_to_provide_power(agent: Building, r_percent: float = 1.0) -> bool:
	if len(recieving_from) > 0: return false
	if len(sending_to) >= 3: return false
	var target: float = (consumption - agent.power_delta * r_percent) * 10 
	for reciever in sending_to:
		target += reciever.power_delta * 10
	if current_power - capacity * power_share_treshold < target: return false
	new_reciever_this_frame = true
	return true

func _update_provide_sprite() -> void:
	
	if current_power - capacity * power_share_treshold > 0:
		provide_sprite.self_modulate = Color.GREEN
	elif current_power - capacity * power_deficit_treshold >= -0.5 :
		provide_sprite.self_modulate = Color.YELLOW
	else:
		provide_sprite.self_modulate = Color.RED
	
	
	
	

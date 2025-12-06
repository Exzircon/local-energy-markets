extends Sprite2D
class_name Building
##Class for generic buildings, with all the power options needed to simulate an energy market



@export_category("Building Stats")

#region Power General
## How much power the building consumes, contains a flat value if no dataset has been loaded
## Default power consumption curve is not yet implemented
@export var consumption: float = 10.0: 
	get():
		if using_curve:
			return consumption_curve.sample_baked(consumption_idx)
		return consumption

## How much power the building produces, contains a flat value for constant genereation,
##   also returns solar_power scaled with current weather efficiency.
@export var generation: float = 0.0:
	get():
		return solar_power * Weather.current_efficiency + generation
## Peak solar power production
@export var solar_power: float = 0

##Chance to randomize solar power production
@export_range(0.0, 1.0, 0.05) var randomize_solar_power_chance: float = 0.0
@export var rand_solar_power_min: float = 40.0
@export var rand_solar_power_max: float = 120.0

##Balance between consumption and production, including external sources
var power_delta: float: 
	get():
		var external: float = 0
		for agent in sending_to:
			external -= agent.consumption - agent.generation
		for agent in recieving_from:
			external += consumption - generation
		return generation - consumption + external

## Consumption curve is loaded from .csv file provided by map, if it exists
var consumption_csv: String
var consumption_array: Array[float] = []
var consumption_curve: Curve = Curve.new()
var consumption_idx: float = 0.0
var using_curve: bool = false

#endregion


#region Battery
@export_group("Battery")
@export var capacity_MWh: float = 200.0 #TODO: Make consistent with day length (WEATHER node)
## How much power the building can hold
var capacity: float = capacity_MWh * Engine.physics_ticks_per_second
## Current amount of power stored, starts 80% full
var current_power: float = capacity * 0.8
var battery_percentage: float:
	get():
		return current_power / capacity

## Treshold for the minimum amount of power the building needs stored before it's willing to share
## Any current connections are terminated if capacity falls below treshold  
@export var power_share_treshold: float = 0.3
## Treshhold for when the building requests power from the power manager
@export var power_deficit_treshold: float = 0.1
var power_excess: float:
	get():
		return current_power - capacity * power_share_treshold

#Not implemented / outside of scope
#@export var battery_efficiency: float = 0.99 #TODO: Not implemented / outside of scope
#@export var battery_discharge_rate: float = 10.0 #TODO: Not implemented / outside of scope
#endregion

##Wether  or not the mouse is currently hovering the building
var mouse_inside: bool = false 

##Max amount of buildings this building can donate to
@export var max_donation_connections: int = 5
var sending_to: Array[Building] = []
var recieving_from: Array[Building] = []

var satisfaction: float:
	get():
		return generation / consumption

## Colors used to depict energy values
@export_group("Colors")
@export var low_color: Color = Color.RED
@export var mid_color: Color = Color.YELLOW
@export var high_color: Color = Color.GREEN

#region Child Nodes
@onready var panel_container: PanelContainer = $PanelContainer
@onready var name_label: Label = $PanelContainer/VBoxContainer/NameLabel
@onready var consumption_label: Label = $PanelContainer/VBoxContainer/ConsumptionLabel
@onready var power_delta_label: Label = $PanelContainer/VBoxContainer/ProductionLabel
@onready var external_power_label: Label = $PanelContainer/VBoxContainer/ExternalPowerLabel

@onready var hover_area: Area2D = $HoverArea
@onready var collision_shape_2d: CollisionShape2D = $HoverArea/CollisionShape2D

@onready var provide_sprite: Sprite2D = $ProvideSprite
@onready var battery_sprite: Sprite2D = $BatterySprite
#endregion



func _ready() -> void:
	if randf() < randomize_solar_power_chance:
		solar_power = randf_range(rand_solar_power_min, rand_solar_power_max)
		
	PowerManager.buildings.append(self) ## Subscribes itself to the power manager
	name_label.text = name #Updates it's own name label, only needs to be run once
	hover_area.connect("mouse_entered", mouse_entered)
	hover_area.connect("mouse_exited", mouse_exited)
	
	#Loads consumption curve if a match is found in res://dataset/
	if get_consumption_curve():
		load_consumption_curve()
	


func _physics_process(delta: float) -> void:
	if using_curve: update_consumption(delta)
	current_power = clampf(current_power + power_delta, 0, capacity)
	
	#If building is in power deficit, requests power from the power manager
	if current_power < capacity * power_deficit_treshold:
		PowerManager.request_power(self)
	#If building falls below treshold, stop sending power to other buildings
	elif current_power < capacity * power_share_treshold: #and not new_reciever_this_frame:
		for reciever in sending_to:
			PowerManager.break_connection(reciever, self)

	_update_provide_sprite()
	_update_color(self, satisfaction)
	_update_color(battery_sprite, battery_percentage*2)
	_update_labels()

## Updates labels shown when hovering building
func _update_labels() -> void:
	consumption_label.text = str("%0.2f" % generation) + " / " + str("%0.2f" % consumption)
	power_delta_label.text = "Delta: " + str("%0.2f" % power_delta)
	external_power_label.text = "Battery: " + str("%0.2f" % current_power) + "MW"


func mouse_entered() -> void:
	panel_container.show()
	mouse_inside = true
	#battery_sprite.show()

func mouse_exited() -> void:
	panel_container.hide()
	mouse_inside = false
	#battery_sprite.hide()

##Function for updating the color of a sprite to match with the satisfaciton level.
## Satisfaction can be more than 1.0 if a building is producing more power then it needs
func _update_color(agent: Node2D, percent: float) -> void:
	if satisfaction > 1.0:
		agent.self_modulate = mid_color.lerp(high_color, percent - 1.0)
	else:
		agent.self_modulate = low_color.lerp(mid_color, percent)

##Removes a connection to an external building, either reciver or sender
func remove_connection(agent: Building) -> void:
	if agent in sending_to:
		var idx = sending_to.find(agent)
		sending_to.remove_at(idx)
	if agent in recieving_from:
		var idx = recieving_from.find(agent)
		recieving_from.remove_at(idx)

## Function to see if this building is willing to provide power to another.
## Only returns true if it has enough capacity to share for 10 physics frames or more
func willing_to_provide_power(agent: Building, r_percent: float = 1.0) -> bool:
	if len(recieving_from) > 0: return false #If building is recieving power, it is never willing to send it
	if len(sending_to) >= max_donation_connections: return false
	var target: float = (consumption - agent.power_delta * r_percent) * 10 
	for reciever in sending_to: #Makes sure it has enough power for buildings it has already promised power to
		target += reciever.power_delta * 10
	if current_power - capacity * power_share_treshold < target: return false
	#new_reciever_this_frame = true
	return true

## Function for updating the color of the providor sprite
func _update_provide_sprite() -> void:
	if current_power - capacity * power_share_treshold > 0:
		provide_sprite.self_modulate = Color.GREEN
	elif current_power - capacity * power_deficit_treshold >= -0.5 :
		provide_sprite.self_modulate = Color.YELLOW
	else:
		provide_sprite.self_modulate = Color.RED

## Loads the consumption curve from loaded from get_consumption_curve()
func load_consumption_curve() -> void:
	if not consumption_csv: return
	var file := FileAccess.open(consumption_csv, FileAccess.READ)
	var values: Array[float] = []
	while !file.eof_reached():
		var csv : PackedStringArray = file.get_csv_line(";")
		if csv.size() < 3: 	continue
		var read_value = csv[1].to_float()
		if read_value > 0.0: #Ignore values that are empty, as this is missing data
			values.append(read_value)
	consumption_array = values
	file.close()
	#print("MAX: ", values.max())
	if len(values) == 0: #Error handling
		push_warning("Len of Values == 0: ", name)
		return
	consumption_curve.max_value = values.max()
	consumption_curve.max_domain = values.size()
	#print(consumption_curve.max_domain, " | ", values.size())
	for i in range(len(values)):
		consumption_curve.add_point(Vector2(i,values[i]))
	consumption_curve.bake()
	using_curve = true

##Gets the matching consumption curve from the map
func get_consumption_curve() -> bool:
	var csv = PowerManager.map.get_matching_csv(name)
	if csv is String:
		consumption_csv = csv
		return true
	return false

## Progresses the index of where to read from the consumption curve.
func update_consumption(delta: float) -> void:
	consumption_idx += delta / Weather.day_length * Weather.sun_curve.max_domain
	if consumption_idx > consumption_curve.max_domain:
		consumption_idx = 0


## Update building stat display through the SignalBus when building is clicked on
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and mouse_inside:
			SignalBus.emit_signal("display_stats", self)

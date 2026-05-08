extends Sprite2D
class_name Building
##Class for generic buildings, with all the power options needed to simulate an energy market

@export_category("Building Stats")
@export var production: float = 15.0: #Production in Watt
	get():
		if production_array:
			return production_array[production_idx] * peak_PV_power * (1.0-system_loss_percent) / Engine.physics_ticks_per_second #The production array contains the total power (in Watt) produced in that hour. Divifing by Engine.physics_ticks_per_second gives us the value approperate for our simulation resolution.
		else:
			return production
@export var consumption: float = 2222.22 / Engine.physics_ticks_per_second: ##W/h
	get():
		if consumption_array:
			return consumption_array[consumption_idx] / Engine.physics_ticks_per_second
		else:
			return consumption
var power: float = 5.0 					#Current power in Watt
@export var capacity: float = 10.0 		#Battery capacity in Watt

## How many attempts at splitting the power trade the building has before giving up
@export var contract_tries: int = 3

var contracts: Array[Contract] = [] ## Array for holding all contracts the building is part of

var money_earned: float = 0.0
var money_spent: float = 0.0

@export_category("External Data")
#@export_subgroup("Consumption", "consumption_")
@export_file("*.csv") var consumption_csv: String
@export var consumption_column_index: int
var consumption_array : Array[float]
var consumption_idx: int = 1
var consumption_tick_counter: float = 0.0

@export_subgroup("Production", "production_")
@export_file("*.csv") var production_csv: String
@export var production_column_index: int
var production_array: Array[float]
var production_idx: int = 1
var production_tick_counter: float = 0.0
@export var peak_PV_power: float = 1.0
@export_range(0.0, 1.0, 0.01) var system_loss_percent: float = 0.20 ##System power loss percentage (as float between 0.0 and 1.0)


#region Other variables
##Wether  or not the mouse is currently hovering the building
var mouse_inside: bool = false 

## Colors used to depict energy values
@export_group("Colors")
@export var low_color: Color = Color.RED
@export var mid_color: Color = Color.YELLOW
@export var high_color: Color = Color.GREEN

@onready var panel_container: PanelContainer = $PanelContainer
@onready var name_label: Label = $PanelContainer/VBoxContainer/NameLabel
@onready var consumption_label: Label = $PanelContainer/VBoxContainer/ConsumptionLabel
@onready var power_delta_label: Label = $PanelContainer/VBoxContainer/ProductionLabel
@onready var external_power_label: Label = $PanelContainer/VBoxContainer/ExternalPowerLabel
@onready var contracts_label: Label = $PanelContainer/VBoxContainer/ContractsLabel

@onready var hover_area: Area2D = $HoverArea
@onready var collision_shape_2d: CollisionShape2D = $HoverArea/CollisionShape2D

@onready var provide_sprite: Sprite2D = $ProvideSprite
@onready var battery_sprite: Sprite2D = $BatterySprite
#endregion



func _ready() -> void:
	if consumption_csv: load_consumption_csv() #If a dataset has been provided, use said dataset
	if production_csv: load_production_csv()
	name_label.text = name #Updates it's own name label, only needs to be run once
	hover_area.connect("mouse_entered", mouse_entered)
	hover_area.connect("mouse_exited", mouse_exited)
	#TickEngine.tick.connect(tick)
	TickEngine.tick_internal_power.connect(internal_power)
	TickEngine.tick_deficit_power.connect(trade_power)
	TickEngine.tick_trade_power.connect(deficit_power)
	TickEngine.tick_excess_power.connect(excess_power)
	



func _physics_process(_delta: float) -> void:
	_update_labels()

func internal_power() -> void:
	update_consumption()
	update_produciton()
	power += production - consumption
	var power_saved: float = min(production, consumption)
	Stats.money_saved += power_saved * PowerMarket.buy_price
	Stats.power_produced += production
	Stats.power_consumed += consumption

func trade_power() -> void:
	#IGNORE: Contracts should be ticked here, not buildings
	return

func deficit_power() -> void:
	if power > 0: return
	_set_color(-1.0)
	for i in range(1, contract_tries+1):
		if not ContractNegotiator.request_contract(self, -power/i): continue
		if power > 0: return
	if power > 0: return
	##If not enough could be bought from local market. Get power from power company
	Stats.power_from_pc -= power
	money_spent += power * PowerMarket.buy_price
	Stats.money_spent += power * PowerMarket.buy_price
	power = 0.0

func excess_power() -> void:
	#TODO: If building has excess power, 
	#	either store in battery or sell to energy provider. (Plusskunde)
	if not power > 0: return
	_set_color(1.0)
	Stats.power_sold += power
	money_earned += power * PowerMarket.sell_price
	Stats.money_earned += power * PowerMarket.sell_price
	power = 0.0




func _set_color(amount: float) -> void:
	var color_low: Color = Color.from_hsv(0.4, 0.5, 0.7, 1.0)
	var color_neutral: Color = Color.from_hsv(0.12, 0.7, 1.0, 1.0)
	var color_high: Color = Color.from_hsv(1, 0.5, 0.7, 1.0)
	
	if amount > 0.0: self_modulate = color_high
	elif amount < 0.0: self_modulate = color_low
	else: self_modulate = color_neutral
	
	
	#self_modulate = Color.from_hsv(0.4, 0.5, 0.7, 1.0)



## Updates labels shown when hovering building
func _update_labels() -> void:
	consumption_label.text = "P/C: " + str("%0.2f" % production) + " / " + str("%0.2f" % consumption)
	power_delta_label.text = "Power: " + str("%0.2f" % power)
	#external_power_label.text = 
	contracts_label.text = "Contracts: " + str(len(contracts))
	
	#consumption_label.text = str("%0.2f" % generation) + " / " + str("%0.2f" % consumption)
	#power_delta_label.text = "Delta: " + str("%0.2f" % power_delta)
	#external_power_label.text = "Battery: " + str("%0.2f" % current_power) + "MW"


func mouse_entered() -> void:
	panel_container.show()
	mouse_inside = true
	#battery_sprite.show()

func mouse_exited() -> void:
	panel_container.hide()
	mouse_inside = false
	#battery_sprite.hide()

## Update building stat display through the SignalBus when building is clicked on
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed and mouse_inside:
			SignalBus.emit_signal("display_stats", self)


func terminate_contract(contract: Contract) -> void:
	for i in range(len(contracts)):
		if contracts[i] == contract:
			contracts.remove_at(i)
			return


func load_consumption_csv() -> void:
	if not consumption_csv: return
	var file := FileAccess.open(consumption_csv, FileAccess.READ)
	var values: Array[float] = []
	while !file.eof_reached():
		var line: PackedStringArray = file.get_csv_line(";")
		if line.size() < 3: continue
		if line[consumption_column_index].is_valid_float():
			values.append(line[consumption_column_index].to_float()*1000)#*1000 to change from kWh to Wh
	file.close()
	if len(values) == 0: #Error Handling
		push_error("Len of Values == 0: ", name)
		return
	consumption_array = values
	#print("VALUES: ", values)
	
func update_consumption() -> void:
	consumption_tick_counter += 1.0 / Engine.physics_ticks_per_second
	if consumption_tick_counter > 1.0:
		consumption_tick_counter -= 1.0
		consumption_idx += 1
		if consumption_idx >= len(consumption_array):
			consumption_idx = 0

func load_production_csv() -> void:
	if not production_csv: return
	var file := FileAccess.open(production_csv, FileAccess.READ)
	var values: Array[float] = []
	while !file.eof_reached():
		var line: PackedStringArray = file.get_csv_line(",")
		if line.size() < 3: continue
		#print(production_column_index, line, " valid? -> ", line[production_column_index].is_valid_float())
		if line[production_column_index].is_valid_float():
			values.append(line[production_column_index].to_float())
	file.close()
	if len(values) == 0: #Error Handling
		push_error("Len of Values == 0: ", name)
		return
	production_array = values
	#print(production_array)

func update_produciton() -> void:
	production_tick_counter += 1.0 / Engine.physics_ticks_per_second
	if production_tick_counter > 1.0:
		production_tick_counter -= 1.0
		production_idx += 1
		if production_idx >= len(production_array):
			production_idx = 0

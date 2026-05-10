extends PanelContainer
@onready var simulated_time_label: Label = $StatsVBoxContainer/SimulatedTimeLabel

@onready var time_right_label: Label = $StatsVBoxContainer/TimeContainer/TimeRightLabel
@onready var power_consumed_right_label: Label = $StatsVBoxContainer/PowerConsumedContainer/PowerConsumedRightLabel
@onready var power_produced_right_label: Label = $StatsVBoxContainer/PowerProducedContainer/PowerProducedRightLabel
@onready var power_traded_right_label: Label = $StatsVBoxContainer/PowerTradedContainer/PowerTradedRightLabel
@onready var power_bought_right_label: Label = $StatsVBoxContainer/PowerBoughtContainer/PowerBoughtRightLabel
@onready var power_lost_right_label: Label = $StatsVBoxContainer/PowerLostContainer/PowerLostRightLabel
@onready var power_sold_right_label: Label = $StatsVBoxContainer/PowerSoldContainer/powerSoldRightLabel

#Batteries
@onready var battery_capacity_right_label: Label = $StatsVBoxContainer/BatteryCapacityContainer/BatteryCapacityRightLabel
@onready var battery_power_right_label: Label = $StatsVBoxContainer/BatteryPowerContainer/BatteryPowerRightLabel
@onready var battery_separator: HSeparator = $StatsVBoxContainer/HSeparator
@onready var battery_capacity_container: HBoxContainer = $StatsVBoxContainer/BatteryCapacityContainer
@onready var battery_power_container: HBoxContainer = $StatsVBoxContainer/BatteryPowerContainer

@onready var solar_panel_efficiency_right_label: Label = $StatsVBoxContainer/SolarPanelEfficiencyContainer/SolarPanelEfficiencyRightLabel

@onready var money_earned_right_label: Label = $StatsVBoxContainer/MoneyEarnedContainer/MoneyEarnedRightLabel
@onready var money_saved_right_label: Label = $StatsVBoxContainer/MoneySavedContainer/MoneySavedRightLabel
@onready var money_spent_right_label: Label = $StatsVBoxContainer/MoneySpentContainer/MoneySpentRightLabel
@onready var money_total_saved_right_label: Label = $StatsVBoxContainer/MoneyTotalSavedContainer/MoneyTotalSavedRightLabel

@onready var spot_price_right_label: Label = $StatsVBoxContainer/SpotPriceContainer/SpotPriceRightLabel
@onready var sell_price_right_label: Label = $StatsVBoxContainer/SellPriceContainer/SellPriceRightLabel
@onready var surcharge_right_label: Label = $StatsVBoxContainer/SurchargeContainer/SurchargeRightLabel

var low_color: Color = Color.RED
var mid_color: Color = Color.YELLOW
var high_color: Color = Color.GREEN



func _physics_process(_delta: float) -> void:
	#time_left_label.text = "Simulated Time: " + str("%0.2f" % Stats.time) + "h"
	simulated_time_label.text = Stats.format_time(Stats.time, false)
	time_right_label.text = str("%0.2f" % (Time.get_ticks_msec()/1000.0)) + "s"
	power_consumed_right_label.text = Stats.format_num(Stats.power_consumed/1000, " ") +" kW"
	power_produced_right_label.text = Stats.format_num(Stats.power_produced/1000, " ") +" kW"
	power_traded_right_label.text = Stats.format_num(Stats.power_traded_locally/1000, " ") + " kW"
	power_bought_right_label.text = Stats.format_num(Stats.power_from_pc/1000, " ") + " kW"
	power_lost_right_label.text = Stats.format_num(Stats.power_lost_locally/1000, " ") + " kW"
	power_sold_right_label.text = Stats.format_num(Stats.power_sold/1000, " ") +" kW"
	
	#Batteries
	if len(Stats.batteries) == 0:
		battery_separator.hide()
		battery_capacity_container.hide()
		battery_power_container.hide()
	else:
		battery_separator.show()
		battery_capacity_container.show()
		battery_power_container.show()
	battery_capacity_right_label.text = Stats.format_num(Stats.battery_capacity/1000, " ") + " kW"
	battery_power_right_label.text = Stats.format_num(Stats.battery_power/1000, " ") + " kW"
	
	solar_panel_efficiency_right_label.text = str("%0.2f" % (Settings.degregation_factor * 100.0)) + "%"
	
	money_earned_right_label.text = Stats.format_num(Stats.money_earned/100, " ") + " kr"
	money_saved_right_label.text = Stats.format_num(Stats.money_saved/100, " ") + " kr"
	money_total_saved_right_label.text = Stats.format_num((Stats.money_saved+Stats.money_earned)/100, " ") + " kr"
	money_spent_right_label.text = Stats.format_num(-Stats.money_spent/100, " ") + " kr"
	
	spot_price_right_label.text = str("%0.6f" % (PowerMarket.buy_price*1000)) + " øre/kWh"
	sell_price_right_label.text = str("%0.6f" % (PowerMarket.sell_price*1000)) + " øre/kWh"
	surcharge_right_label.text = str("%0.2f" % (PowerMarket.surcharge*1000)) + " øre/kWh"

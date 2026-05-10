extends Node

var average_price_per_month: Array = [97.25, 125.51, 71.11, 81.93, 93.42, 80.00, 103.29, 105.40, 87.67, 87.03, 117.53, 103.28] ##øre/kWh for NO2 med mva. for 2025. Hentet fra https://www.fortum.com/no/strom/strompriser/historiske-strompriser

var hourly_prices: Array = [] ## Spotprice for buying power for the entire year of 2025, at an hourly resolution.

var price_index: int = 0

## Ticks in a month: 43200
## Ticks in an hour: 60 / Engine.physics_ticks_per_second
var ticks_per_index: int = Engine.physics_ticks_per_second
var tick_counter: int = 0

var buy_price: float = 0.0 ## Øre/Wh

## How much the power comapany takes when you sell your excess power to them. So when selling you would get Spotpris - surcharge øre/kWh. The amount varies greatly. Have found as low as 2.0 øre/kWh to 5.49 øre/kWh. 
var surcharge: float = 0.00549 # øre/Wh 

var sell_price: float:
	get():
		return max(buy_price - surcharge, 0.0)


func _ready() -> void:
	TickEngine.tick_enviroment.connect(update)
	hourly_prices = load_hourly_prices_from_csv()

func update() -> void:
	tick_counter += 1
	if tick_counter > ticks_per_index:
		price_index += 1
		if price_index >= len(hourly_prices):
			price_index = 0
		tick_counter = 0
	var inflation: float = 1.04 ** int(Stats.time / 8760) #TODO: Account for inflation
	buy_price = hourly_prices[price_index] * inflation
	#buy_price = 0.151


	#1,51 kr/kWt CurrPrice
	#151,00 øre/kWt			=0,151 øre/Wt
	#5,49 øre/kWh Påslag	=0.00549


func load_hourly_prices_from_csv() -> Array:
	var file: FileAccess = FileAccess.open("res://dataset/PowerPrices/NO2_prices_2025.csv", FileAccess.READ) #Prices for each date in øre/Wh
	var prices: Array = []
	while !file.eof_reached():
		var line: PackedStringArray = file.get_csv_line(";")
		if len(line) <= 1: continue
		prices.append(float(line[2])) #Append price to array as øre/Wh
		#TODO: Checking if higher prices lead to more money saved
	file.close()
	return prices

extends Node
#	Power Consumed
#	Power Generated
#	Local Power Sent Through the PowerNet
#	Power saved from local energy transfer
#	Power lost through power transfer inefficiency

#TODO: Make sure all stats here make sense to track
#TODO: Add all stats to a display tracker.

## Power traded to other buildings in the local network
var power_traded_locally: float = 0.0

## Power bought from power companies
var power_from_pc: float = 0.0

## Power loss incurred when sending power locally
var power_lost_locally: float = 0.0

## Power sold to power power companies, through methods such as "Plusskunde"
var power_sold: float = 0.0

## Money earned from selling power to power companies
var money_earned: float = 0.0

## Money saved from using locally available power
var money_saved: float = 0.0

## Money spent to buy power from power network companies
var money_spent: float = 0.0

var power_produced: float = 0.0 ##Total amount of power (in Watt) produced

var power_consumed: float = 0.0 ##Total amount of power (in Watt) consumed

var time: float = 0.0 ## Current time in hours since simulation start

var counter: int = 0


func _ready() -> void:
	TickEngine.tick_enviroment.connect(auto_update)
	#print("Format: ", format_num(1123456789.123456789))
	

func auto_update() -> void:
	time += 1.0 / Engine.physics_ticks_per_second
	#if counter == 1: return
	#if power_from_pc >= 1600000:
	#	print_stats()
	#	counter = 1
	#return
	if counter >= Engine.physics_ticks_per_second * 24:
		counter = 0
		print_stats()
	else:
		counter += 1
	if time > 8760.0: ## Stops the simulation after a year (8760 hours)
		get_tree().quit()
	



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print_stats()

func print_stats() -> void:
	print("")
	print("--=== Global Stats ===--") # Weird tabulation below results in easy to read print in output console
	print("Time: ", str("%0.2f" % time))
	print("Power Consumed:			", format_num(power_consumed), " Watts")
	print("Power Produced:			", format_num(power_produced), " Watts")
	print("Power Traded Locally:			", format_num(power_traded_locally), " Watts")
	print("Power From Power Company:		", format_num(power_from_pc), " Watts")
	print("Power Lost Locally:				", format_num(power_lost_locally), " Watts")
	print("Power Sold To Power Company:	", format_num(power_sold), " Watts")
	print("Money Earned:					", format_num(money_earned/100), "kr")
	print("Money Saved:					", format_num(money_saved/100), "kr")
	print("Money Spent:					", format_num(-money_spent/100), "kr")
	print("  -=-  ")
	print("Current Spot Price: ", PowerMarket.buy_price, " øre/wH")
	print("Current Sell Price: ", PowerMarket.sell_price, " øre/wH")

	
func format_num(num: float, deci: int = 2, delimiter: String = "_") -> String:
	
	var input: String = str("%0.2f" % num)
	var output: String = ""
	
	var delimiter_index: int = input.find(".")
	var left: String = input.left(delimiter_index)
	var right: String = input.right(len(input)-delimiter_index-1)
	left = left.reverse()
	var str_arr: Array[String] = []
	for i in range(ceil(len(left) / 3.0)):
		str_arr.append(left.substr(i*3, 3))
	
	for i in range(len(str_arr)):
		output += str_arr[i]
		if not i == len(str_arr)-1:
			output += delimiter
	output = output.reverse() + "." +right
	return output

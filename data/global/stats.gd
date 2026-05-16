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

## Total of money_saved and money_earned
var money_saved_total: float:
	get():
		return money_earned + money_saved

## Money spent to buy power from power network companies
var money_spent: float = 0.0

var power_produced: float = 0.0 ##Total amount of power (in Watt) produced

var power_consumed: float = 0.0 ##Total amount of power (in Watt) consumed

var time: float = 0.0 ## Current time in hours since simulation start

var counter: int = 0

var batteries: Array[Battery] = []
var battery_capacity: float:
	get():
		var capacity: float = 0.0
		for battery in batteries:
			capacity += battery.capacity
		return capacity
var battery_power: float:
	get():
		var power: float = 0.0
		for battery in batteries:
			power += battery.power
		return power


var produced_this_year: float = 0.0
var current_year: int = 0





func _ready() -> void:
	TickEngine.tick_enviroment.connect(auto_update)
	#print("Format: ", format_num(1123456789.123456789))

		
	

func auto_update() -> void:
	time += 1.0 / Engine.physics_ticks_per_second
	if current_year < int(time / 8760.0):
		current_year += 1
		print("Year ", current_year, " - exported: ",  format_num(produced_this_year), "watts")
		produced_this_year = 0.0
		#print(produced_this_year)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print_stats()

func print_stats() -> void:
	
	print("")
	print("--=== Global Stats ===--") # Weird tabulation below results in easy to read print in output console
	print(format_time(time))
	print("Simulated Time: ", str("%0.2f" % time), "h --- Real Time: ", str("%0.2f" % (Time.get_ticks_msec()/1000.0)),"s")
	print("Power Consumed:					", format_num(power_consumed), " Watts")
	print("Power Produced:					", format_num(power_produced), " Watts")
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
	print("  -=-  ")
	print("Inflation: ", Settings.inflation)
	print("System Loss: ", Settings.base_system_loss, " + (", Settings.degregation_speed_year_one, " + ", Settings.degregation_speed, " ^ years-1)")
	print("Trading Enabled: ", Settings.viritual_island)


func format_num(num: float, delimiter: String = "_", deci: int = 2) -> String:
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

func format_time(time_in: float, short_form: bool = false) -> String:
	#1 Year = 8760 hours
	#1 Month = 720 hours
	#1 Day = 24 hours

	#Remove minutes and convert time to int
	var minutes: int = int((time_in - floorf(time_in)) * 60)
	@warning_ignore("shadowed_variable")
	var time: int = int(time_in)
	@warning_ignore("integer_division")
	var years:int = time / 8760
	time = time % 8760
	@warning_ignore("integer_division")
	var months:int = time / 720
	time = time % 720
	@warning_ignore("integer_division")
	var days:int = time / 24
	time = time % 24

	var time_string: String = ""
	if not short_form:
		time_string += str(years) + " Years - "
		time_string += "%02d" % months + " Months - "
		time_string += "%02d" % days + " Days - "
		time_string += "%02d" % time + " Hours - "
		time_string += "%02d" % minutes + " Minutes"
	else:
		time_string += str(years) + " Y - "
		time_string += "%02d" % months + " M - "
		time_string += "%02d" % days + " D - "
		time_string += "%02d" % time + " h - "
		time_string += "%02d" % minutes + " m"
	return time_string

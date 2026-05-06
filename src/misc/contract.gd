extends Resource
class_name Contract
## Description goes here

var provider: Building
var consumer: Building

var duration: int
var time: int = 0

var amount: float = 0.0 #How much power should be sent each tick
var efficiency: float = 1.0 #Should never be over 1.0
var price: float = 0.2


#Efficiency calc: amount / efficiency

#TODO: Add efficiency


func _init() -> void:
	TickEngine.tick_trade_power.connect(trade_power)



func trade_power() -> void:
	if not provider.power >= amount/efficiency:
		print("Error: provider doesn't have enough power to facilitate power trade")
		terminate()
		return
	provider.power -= amount/efficiency
	consumer.power += amount
	Stats.power_traded_locally += amount
	Stats.power_lost_locally += amount/efficiency - amount
	Stats.money_saved += amount * (PowerMarket.buy_price - price)
	time += 1
	if time >= duration: terminate()

func terminate() -> void:
	provider.terminate_contract(self)
	consumer.terminate_contract(self)
	
	

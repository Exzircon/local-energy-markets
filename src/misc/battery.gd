extends Resource
class_name Battery

@export var capacity: float
var power: float = capacity * 0.5
var percentage: float:
	get():
		return power / capacity

@export var transfer_rate: float = 10000
@export var efficiency: float = 0.8
@export var passive_drain: float = 0.0


func _init() -> void:
	TickEngine.tick_cleanup.connect(logging)
	TickEngine.tick_enviroment.connect(do_passive_drain)
	Stats.batteries.append(self)

func charge(amount: float) -> float:
	var max_store: float = minf(transfer_rate, capacity - power) 	#Post Efficiency Loss
	var to_store: float = minf(amount, max_store/efficiency) 		#Pre Efficiency Loss
	power += to_store * efficiency 									#Post Efficiency Loss
	#print("POWER: ", power, " --- to_store:", to_store * efficiency, " - amount: ", amount)
	##TODO: Calculate value of stored power / the value of storing power
	return to_store

func discharge(amount: float) -> float:
	var to_send = minf(amount, minf(transfer_rate, power))
	power -= to_send
	Stats.money_saved += to_send * PowerMarket.buy_price
	return to_send

func do_passive_drain() -> void:
	#Usual passive drain lies around 1-3% a month for an energized system
	# This function gets ticked each 1 minute of simulated time
	# loss_per_tick = passive_drain / 30 	/24		/60 = passive_drain / 43200
	#				  /month		 / day	/hour	/minute
	power = power * (1 - (passive_drain / 43200))

func logging() -> void:
	return
	print("Power: ", power)

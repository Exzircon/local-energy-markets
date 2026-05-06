extends Node
## TickEngine: Every physics process send out a series of signals as a tick.
## 60 ticks = 1 hour of simulated time
## At 60t/s makes 1 hour simulated time take one real second
## 24*60 = 1440 = ticks in a day
## 24*60*30 = 43200 = ticks in a month
## 24*60*365 = 525600 = ticks in a year

#17518kW/year
#2kW/hour

signal tick_enviroment()
signal tick_internal_power()
signal tick_trade_power()
signal tick_deficit_power()
signal tick_excess_power()



signal tick(stage: Enums.TickStage)

func _physics_process(_delta: float) -> void:
	emit_ticks()

func emit_ticks() -> void:
	emit_signal("tick_enviroment")
	emit_signal("tick_internal_power")
	emit_signal("tick_trade_power")
	emit_signal("tick_deficit_power")
	emit_signal("tick_excess_power")


func old_emit_ticks() -> void: ##TODO: Make signals discreete (one signal per thing, not this mess)
	#Update enviroment (eg. Weather)
	emit_signal("tick", Enums.TickStage.ENVIROMENT)
	
	#Produce/Consume Power
	emit_signal("tick", Enums.TickStage.INTERNAL_POWER)
	
	#Trade Power
	emit_signal("tick", Enums.TickStage.TRADE_POWER)
	
	#Handle Deficit Power (Also handles trade from the new contracts at this step)
	emit_signal("tick", Enums.TickStage.DEFICIT_POWER)
	
	#Handle Excess Power
	emit_signal("tick", Enums.TickStage.EXCESS_POWER)

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
	if Settings.speed > 0:
		for i in range(Settings.speed):
			if Settings.speed == 0: break
			emit_ticks()

func emit_ticks() -> void:
	#Update enviroment (eg. Weather)
	emit_signal("tick_enviroment")
	#Produce/Consume Power
	emit_signal("tick_internal_power")
	#Trade Power
	emit_signal("tick_trade_power")
	#Handle Deficit Power (Also handles trade from the new contracts at this step)
	emit_signal("tick_deficit_power")
	#Handle Excess Power
	emit_signal("tick_excess_power")

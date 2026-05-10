extends Node




var speed: int = 1 #How many times one round of ticks is sent each _physics_process call

var inflation: float = 1.02 ## How fast the price of power grows each year

var degregation_speed: float = 0.005 ## How fast the efficiency of solar panels degrade each year after the first
var degregation_speed_year_one: float = 0.03 ## How fast the efficiency of the solar panel degrades the first year
var degregation_factor: float: ##Current solar power efficiency.
	get():
		var years: float = Stats.time / 8760.0
		if years < 1.0:
			return (1-degregation_speed_year_one) ** years
		return (1-degregation_speed_year_one) * ((1-degregation_speed) ** (years-1))



func connect_speed_button(btn: OptionButton) -> void:
	btn.item_selected.connect(change_speed)

func change_speed(id: int) -> void:
	match id:
		0: speed = 0
		1: speed = 1
		2: speed = 24
		3: speed = 168
		4: speed = 720
		5: speed = 8760

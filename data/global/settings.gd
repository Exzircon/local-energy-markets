extends Node




var speed: int = 1
#Speeds:
# 1 -> Default speeds | 1 second = 1 hour of simulated time
# 12 -> 12x speed | 1 second = 12 hours of simulated time
# 24 -> 24x speed | 1 second = 1 day of simulated time
# 60 -> 60x speed | 1 second = 60 hours of simulated time
# 300 -> 300	 | 1s = 300hours
# -1 -> Uncapped

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

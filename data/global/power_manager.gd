extends Node

var requesting_power: Dictionary = {}
var providing_power: Dictionary = {}


#signal request_power
#signal provide_power
func _ready() -> void:
	TimeTracker.connect("Tick", tick)

func request_power(agent, amount: float) -> void:
	requesting_power[agent] = amount

func provide_power(agent, amount: float) -> void:
	providing_power[agent] = amount


func pre_tick() -> void:
	requesting_power = {}
	providing_power = {}


func tick(tick: int) -> void:
	pass

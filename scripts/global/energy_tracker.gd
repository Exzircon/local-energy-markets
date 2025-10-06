extends Node

var total_consumption: float = 0.0
var total_generation: float = 0.0

var buildings: Array = []

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if len(buildings) == 0:
		buildings = get_tree().get_nodes_in_group("Building")
		return
	

func get_total_generation() -> float:
	var generation: float = 0
	for building in buildings:
		generation += building.generation
	return generation

func get_total_consumption() -> float:
	var consumption: float = 0
	for building in buildings:
		consumption += building.consumption
	return consumption

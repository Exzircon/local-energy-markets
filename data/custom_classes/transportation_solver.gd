extends Node
class_name  TransportationSolver

var matrix: Array = []
var supply: Array = []
var demand: Array = []

var suppliers: Array = []
var demanders: Array = []


func setup(agents: Array[Building]) -> void:
	for agent in agents:
		match agent.power_state:
			agent.PowerStates.EXCESS: 
				suppliers.append(agent)
			agent.PowerStates.BALANCED: pass
			agent.PowerStates.DEFICIT: 
				demanders.append(agent)
	for agent in suppliers:
		supply.append(agent.batt)

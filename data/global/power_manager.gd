extends Node
##Global Script

##Array for storing all buildings for quicker lookup
var buildings: Array = []

## Variable for storing which map is currently in use, the map in question handles the update
var map: Map

##Array of all connections between buildings
var connections: Array = []

## Function called by a building to request power
## If a single provider is not able to provide the neccessary power, 
##  it repeats the request with a shared load between multiple buildings.
## A maxiumum of 4 providers are allowed to share power to the same requester
func request_power(requester: Building, depth: int = 1) -> void:
	if depth > 4: return
	var possible_providers: Array = []
	for building in buildings:
		if building == requester: continue
		if building in requester.recieving_from: continue
		if building.willing_to_provide_power(requester, 1.0 / depth):
			possible_providers.append(building)
	if len(possible_providers) < depth:
		request_power(requester, depth + 1)
	else:
		for i in range(depth):
			create_connection(possible_providers[i], requester)
#Ignore symbols that are not tested for

## Creates a connection between two buildings,
##  updating their respective sendind to and recieving from Array with relevant information
## Also creates the visual sfx of power flowing between the buildings
func create_connection(provider: Building, requester: Building) -> void:
	var power_path: ParticlePath2D = ParticlePath2D.new()
	power_path.top_level = true
	power_path.z_index = -1
	power_path.curve = Curve2D.new()
	power_path.curve.add_point(provider.global_position)
	power_path.curve.add_point(requester.global_position)
	provider.add_child(power_path)
	
	var connection: Array = [provider, requester, power_path]
	provider.sending_to.append(requester)
	requester.recieving_from.append(provider)
	connections.append(connection)

## Removes the connection between two buildings, if one exists
func break_connection(reciever: Building, provider: Building) -> void:
	for i in range(len(connections)):
		var connection = connections[i]
		if not reciever in connection or not provider in connection: continue
		connections[i][2].queue_free()
		reciever.remove_connection(provider)
		provider.remove_connection(reciever)
		connections.remove_at(i)
		break


## On "ui_accept" ("Enter" by default), prints global power stats to the console
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEvent:
		if event.is_action_pressed("ui_accept"):
			print()
			var total_consumption: float = 0
			var max_possible_production: float = 0
			for building in buildings:
				total_consumption += building.consumption
				max_possible_production += building.num_solar_panels * 5.0
			print("Total Consumption: ", total_consumption)
			print("Max Production: ", max_possible_production)




 

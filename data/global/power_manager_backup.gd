extends Node
##Depricated backup


#TODO: REMOVE TICK FUNCTIONALITY, RUN EVERYTHING IN PHYSICS_PROCEES INSTEAD

#Array for storing all buildings for quicker lookup
var buildings: Array = []

var particle_paths: Array[ParticlePath2D] = []
var bfs: BreadthFirstSearch #TODO: OLD
var map: Map #TODO: OLD
#var ts: TransportationSolver = TransportationSolver.new()

var connections: Array = []

#Signals
@warning_ignore("unused_signal")
#signal request_power(agent: Building, amount: float)
#signal request_provider(agent: Building, amount: float)
#signal selected_provider(agent: Building, amount: float)


func _ready() -> void:
	print(buildings)
	#ts.solve()

func _draw_power_path(start: int, goal: int) -> void:
	var path = bfs.search(start, goal)
	#bfs.highlight_path(path)
	var p_path: ParticlePath2D = ParticlePath2D.new()
	p_path.top_level = true
	p_path.z_index = -1
	p_path.curve = Curve2D.new()
	for idx in path:
		p_path.curve.add_point(bfs.nodes[idx].global_position)
	particle_paths.append(p_path)
	bfs.nodes[start].add_child(p_path)

func _clear_power_paths() -> void:
	for p_path in particle_paths:
		p_path.queue_free()
	particle_paths = []



func request_power(agent: Building, amount: float, preexisting_connections: Array) -> bool:
	var possible_providers: Array[Building] = []
	var exclusion_array: Array[Building] = []
	for connection in preexisting_connections:
		exclusion_array.append(connection[0])
	for building in buildings:
		if building == agent or building in exclusion_array: continue
		if len(building.external_connections ) >= 3: continue
		if building.power_excess > 0 and building.power_delta > 0:
			possible_providers.append(building)
	if len(possible_providers) <= 0: return false
	possible_providers.sort_custom(sort_by_power_delta)
	#var best_provider: Building = get_least_excessive_provider(possible_providers, amount)
	create_connection(possible_providers[0], agent, amount)
	return true

func get_least_excessive_provider(providers: Array[Building], amount: float) -> Building:
	var best_provider: Building = null
	var best_delta: float = INF
	for provider in providers:
		if provider.power_delta < best_delta and provider.power_delta > amount:
			best_provider = provider
			best_delta = provider.power_delta
	if not best_provider:
		best_delta = 0
		for provider in providers:
			if provider.power_delta > best_delta:
				best_provider = provider
				best_delta = provider.power_delta
	return best_provider

func sort_by_power_delta(a: Building, b: Building):
	if a.power_delta > b.power_delta: return true
	return false


func create_connection(provider: Building, requester: Building, amount: float) -> void:
	var power_path: ParticlePath2D = ParticlePath2D.new()
	power_path.top_level = true
	power_path.z_index = -1
	power_path.curve = Curve2D.new()
	power_path.curve.add_point(provider.global_position)
	power_path.curve.add_point(requester.global_position)
	provider.add_child(power_path)
	
	var connection: Array = [provider, requester, amount, power_path]
	provider.external_connections.append([requester, -amount])
	requester.external_connections.append([provider, amount])
	connections.append(connection)

func break_all_connections(agent: Building) -> void:
	var idx_to_remove: Array[int] = []
	for i in range(len(connections)):
		var connection: Array = connections[i]
		if agent in connection:
			connection[0].remove_connection(connection[1])
			connection[1].remove_connection(connection[0])
			connection[3].queue_free()
			idx_to_remove.append(i)
	idx_to_remove.reverse()
	for idx in idx_to_remove:
		connections.remove_at(idx)
	
	
	
	return
	for connection in connections:
		if agent == connection[0]: #Handle agent is provider
			connection[3].free()
			var requester = connection[1]
			requester.remove_connection(connection[0])
		elif agent == connection[1]: #Handle agent is provider
			connection[3].free()
			var provider = connection[0]
			provider.remove_connection(connection[1])
	

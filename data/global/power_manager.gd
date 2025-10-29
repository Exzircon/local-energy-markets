extends Node

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
	pass

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



func request_power(agent: Building, depth: int = 1) -> void:
	if depth > 4: return
	var possible_providers: Array = []
	for building in buildings:
		if building == agent: continue
		if building in agent.recieving_from: continue
		if building.willing_to_provide_power(agent, 1.0 / depth):
			possible_providers.append(building)
	if len(possible_providers) < depth:
		request_power(agent, depth + 1)
	else:
		for i in range(depth):
			create_connection(possible_providers[i], agent)

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

func break_connection(reciever: Building, provider: Building, reason: String = " - ") -> void:
	print()
	print("Rec: ", reciever, " | Pro: ", provider, " | Reason: ", reason)
	for connection in connections:
		print(connection)
	for i in range(len(connections)):
		if not connections[i]: print("WAH!")
		var connection = connections[i]
		if not reciever in connection or not provider in connection: continue
		connections[i][2].queue_free()
		reciever.remove_connection(provider)
		provider.remove_connection(reciever)
		connections.remove_at(i)
		break


func create_connection_old(provider: Building, requester: Building, amount: float) -> void:
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
			connection[2].queue_free()
			idx_to_remove.append(i)
	idx_to_remove.reverse()
	for idx in idx_to_remove:
		connections.remove_at(idx)

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




 

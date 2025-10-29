extends Node

#TODO: REMOVE TICK FUNCTIONALITY, RUN EVERYTHING IN PHYSICS_PROCEES INSTEAD

#Array for storing all buildings for quicker lookup
var buildings: Array = []

var particle_paths: Array[ParticlePath2D] = []
var bfs: BreadthFirstSearch #TODO: OLD
var map: Map #TODO: OLD
#var ts: TransportationSolver = TransportationSolver.new()

func _ready() -> void:
	print(buildings)
	#ts.solve()

func _physics_process(delta: float) -> void:
	#distribute_power()
	balance_grid()

func distribute_power() -> void:
	var has_excess: Array[Building] = []
	var has_deficit: Array[Building] = []
	for building in buildings:
		#print(building.battery_percentage)
		if building.power_state == building.PowerStates.EXCESS:
			has_excess.append(building)
		elif building.power_state == building.PowerStates.DEFICIT:
			has_deficit.append(building)
	for building in has_deficit:
		var cost_arr: Array = get_cost_array(building, has_excess)
		var cheapest_idx: int = _get_lowest_idx(cost_arr)
		var provider = has_excess[cheapest_idx]
		building.current_power += provider.send_power(building, building.power_delta)

func balance_grid() -> void:
	_clear_power_paths()
	for building in buildings:
		var excluded_providers: Array[Building] = []
		while building.power_state == building.PowerStates.DEFICIT:
			if excluded_providers.size() > 1: break
			var provider = get_best_provider(building, excluded_providers)
			if not provider: break
			excluded_providers.append(provider)
			building.current_power += provider.send_power(building, building.power_delta + 1.0)
			_draw_power_path(buildings.find(building), buildings.find(provider))

func get_best_provider(agent: Building, exclusion_list: Array[Building]) -> Building:
	var best_provider: Building = null
	var best_cost: float = INF
	for building in buildings:
		if building == agent: continue
		if building in exclusion_list: continue
		if building.power_state != building.PowerStates.EXCESS: continue
		var cost: float = 0.0
		cost += building.position.distance_to(agent.position) / 100
		cost -= building.power_excess / 100
		if cost < best_cost:
			best_cost = cost
			best_provider = building
	return best_provider

func get_cost_array(agent: Building, has_excess: Array) -> Array:
	var cost_arr: Array = []
	for building in has_excess:
		var cost: float = 0.0
		cost += agent.global_position.distance_to(building.global_position) / 50.0
		cost -= building.battery_percentage - building.power_share_treshold
		
		cost_arr.append(cost)
	return cost_arr

func _get_lowest_idx(arr: Array) -> int:
	if len(arr) == 0: return -1
	var lowest_idx: int = 0
	var lowest_amount: float = arr[0]
	for i in range(1, len(arr)):
		if arr[i] < lowest_amount:
			lowest_amount = arr[i]
			lowest_idx = i
	return lowest_idx




func add_to_power_tracker(agent) -> void:
	buildings.append(agent)

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

func get_largest_key(dict: Dictionary) -> Variant:
	var largest_key
	var largest_amount: float = 0.0
	for key in dict.keys():
		#print("-------------------------------------------------------")
		#print(key)
		if dict[key] > largest_amount:
			largest_amount = dict[key]
			largest_key = key
	if not largest_key: return dict.keys()[0]
	return largest_key

func get_smallest_key(dict: Dictionary) -> Variant:
	var smalllest_key
	var smalllest_amount: float = 0.0
	for key in dict.keys():
		#print("-------------------------------------------------------")
		#print(key)
		if dict[key] < smalllest_amount:
			smalllest_amount = dict[key]
			smalllest_key = key
	if not smalllest_key: return dict.keys()[0]
	return smalllest_key

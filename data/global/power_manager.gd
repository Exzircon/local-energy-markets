extends Node

var power_dict: Dictionary = {}

var particle_paths: Array[ParticlePath2D] = []
var bfs: BreadthFirstSearch
var map: Map

func _ready() -> void:
	TimeTracker.connect("Tick", tick)
	TimeTracker.connect("Pre_Tick", pre_tick)
	TimeTracker.connect("Post_Tick", post_tick)

func add_to_power_tracker(agent, amount: float) -> void:
	power_dict[agent] = amount

func pre_tick() -> void:
	power_dict = {}
	_clear_power_paths()


func tick() -> void:
	pass

func post_tick() -> void:
	#print("WAH!")
	#_draw_power_path(0, 8)
	#print("Power: ", power_dict)
	#print()
	#print("Balance: ", get_grid_balance())
	#balance_grid()
	balance_grid_by_consumption()
	#print()
	#print("Power Post: ", power_dict)

func balance_grid() -> void:
	for key in power_dict.keys():
		while power_dict[key] < 0.0:
			var prov = get_largest_key(power_dict)
			if power_dict[prov] <= 0: 
				print("Power_deficit")
				return
			var amount = min(-power_dict[key], power_dict[prov])
			power_dict[key] = power_dict[key] + amount
			power_dict[prov] = power_dict[prov] - amount
			_draw_power_path(bfs.nodes.find(prov), bfs.nodes.find(key))
			#print(bfs.nodes.find(key))





func balance_grid_by_consumption() -> void:
	var iteration: int = 0
	while not is_grid_balanced():
		if iteration > power_dict.size() * 3:
			print(power_dict)
			break
		else:
			iteration += 1
		var req = get_smallest_key(power_dict)
		var prov = get_largest_key(power_dict)
		if power_dict[prov] <= 0: 
			print("Power_deficit: ", get_grid_balance())
			break
		var amount = min(-power_dict[req], power_dict[prov])
		power_dict[req] = power_dict[req] + amount
		power_dict[prov] = power_dict[prov] - amount
		req.external_power += amount
		prov.external_power -= amount
		_draw_power_path(bfs.nodes.find(prov), bfs.nodes.find(req))
	






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

func is_grid_balanced() -> bool:
	var num_pos: int = 0
	var num_neg: int = 0
	for key in power_dict.keys():
		if power_dict[key] > 0:
			num_pos += 1
		elif power_dict[key] < 0:
			num_neg += 1
	#print(num_pos," ",num_neg)
	if num_pos == 0 or num_neg == 0:
		return true
	return false



func get_grid_balance() -> float:
	var balance: float = 0.0
	for key in power_dict.keys():
		balance += power_dict[key]
	return balance

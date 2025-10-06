extends Node


var path_range: float = 100.0
var max_connections: int = 3

var buildings: Array[Building] = []
var graph: Dictionary[int, Array] = {}

var updating_graph: bool = false
var curr_idx: int = 0
var batch_size: int = 500

var lines: Array[Line2D] = []
var path_lines: Array[Line2D] = []
var path_lines_arr: Array[Array] = []

var verifying_graph: bool = false
var disconnected_nodes: Array = []


var thread_amount: int = 32
var threads_finished: int = 0
var threads: Array[Thread] = []
var mutex: Mutex = Mutex.new()


var state: States = States.IDLE

enum States {
	IDLE,
	UPDATING_GRAPH,
	VERIFYING_GRAPH,
	VERIFYING_GRAPH_MT
}




func _init() -> void:
	for i in thread_amount:
		threads.append(Thread.new())




func _process(_delta: float) -> void:
	match state:
		States.UPDATING_GRAPH: state_updating_graph()
		States.VERIFYING_GRAPH: state_verifying_graph()
		States.VERIFYING_GRAPH_MT: state_threaded()
		_: return
	#return
	
	if verifying_graph:
		clear_path_lines()
		for thread in threads:
			if not thread.is_alive(): 
				#thread.start(create_path_line.bind(bfs_search(0, curr_idx)))
				thread.start(call_deferred.bind())
			curr_idx += 1
		#create_path_line(bfs_search(0, curr_idx))
		
		if curr_idx >= len(buildings) - 1:
			verifying_graph = false
			if len(disconnected_nodes) == 0:
				print("Graph successfully verified!")
			else:
				print(len(disconnected_nodes), " failed to verify")
		curr_idx += 2
	
	

#region State functions
func state_updating_graph() -> void:
	for i in batch_size:
		if curr_idx >= len(buildings):
			state = States.VERIFYING_GRAPH_MT
			#create_path_line(bfs_search(buildings[0], buildings[1]))
			ensure_two_way_connections()
			create_web()
			print("Done updating graph")
			curr_idx = 1
			break
		else:
			pass
			#print("Updated idx: ", curr_idx, " - i: ", i)
		update_graph_at(curr_idx)
		curr_idx += 1

func state_verifying_graph() -> void:
	clear_path_lines()
	create_path_line(bfs_search(0, curr_idx))
	if curr_idx >= len(buildings) - 1:
		state = States.IDLE
		if len(disconnected_nodes) == 0:
			print("Graph successfully verified!")
		else:
			print(len(disconnected_nodes), " failed to verify")
	curr_idx += 1

func state_threaded() -> void:
	if threads_finished > 0: return
	path_lines_arr = []
	for i in range(thread_amount):
		if curr_idx >= len(buildings) -1:
			state = States.IDLE
			if len(disconnected_nodes) == 0:
				print("Graph successfully verified!")
			else:
				print(len(disconnected_nodes), " failed to verify")
			break
		if threads[i].is_alive(): continue
		threads[i].start(thread_func.bind(curr_idx))
		#print("Checking idx: ", curr_idx)
		curr_idx += 1
		
		
func thread_func(idx: int) -> void:
	var result = bfs_search(0, idx)
	mutex.lock()
	path_lines_arr.append(result)
	threads_finished += 1
	#print("Thread ", threads_finished, " done")
	if threads_finished >= thread_amount:
		call_deferred("thread_done")
	mutex.unlock()

func thread_done() -> void:
	clear_path_lines()
	for path in path_lines_arr:
		create_path_line(path)
	#print("All finished, destroying thread objects")
	threads_finished = 0
	for thread in threads:
		thread.wait_to_finish()

#endregion






func update_graph_at(idx: int) -> void:
	#var building = buildings[idx]
	graph[idx] = get_closest_neighbours(idx)

func update_graph() -> void:
	'''
	Function for starting graph update.
	The update is spread over multiple frames for performance reasons.
	Called by the building manager when all buildings are sucessfully loaded
	'''
	state = States.UPDATING_GRAPH
	curr_idx = 0
	print("Started graph update")

func get_closest_neighbours(idx: int, amount: int = max_connections) -> Array:
	'''
	Function for returning the "amount" closest neighbours of buildings[idx]
	'''
	
	var closest_nodes: Array = []
	var closest_dists: Array = []
	for i in range(len(buildings)):
		if i == idx: continue
		var dist = buildings[i].global_position.distance_to(buildings[idx].global_position)
		if len(closest_nodes) < amount:
			closest_nodes.append(i)
			closest_dists.append(dist)
			continue
		var furthest_idx: int = get_furthest_idx(closest_dists)
		if dist < closest_dists[furthest_idx]:
			closest_nodes.append(i)
			closest_dists.append(dist)
			closest_nodes.pop_at(furthest_idx)
			closest_dists.pop_at(furthest_idx)
	return closest_nodes

func get_furthest_idx(arr: Array) -> int:
	'''
	Helper function to get the index of the biggest value in arr
	'''
	var idx: int = 0
	for i in range(len(arr)):
		if arr[i] > arr[idx]:
			idx = i
	return idx

func add_to_array(building: Building) -> void:
	buildings.append(building)
	#if not building in buildings:
	#	buildings.append(building)

func bfs_search(start: int, goal: int) -> Array:
	'''
	Breath First Search algorithm, guaranteed to find the shortest possible path.
	'''
	#print("BFSearch start!")
	#print("Wat?: ", goal)
	var visited: Array = []
	var path: Array = []
	var queue = [[start]]
	var node: int = 0
	var neighbours: Array = []
	while queue:
		path = queue.pop_front()
		node = path[-1]
		#print("Node: ", node)
		if not node in visited:
			neighbours = graph[node]
			for neighbour in neighbours:
				var new_path = path.duplicate()
				new_path.append(neighbour)
				queue.append(new_path)
				if neighbour == goal:
					#print("BFSearch done!")
					return new_path
			visited.append(node)
	print("Oops! Failed to find path - ", goal)
	disconnected_nodes.append(goal)
	buildings[goal].scale = Vector2.ONE * 0.1
	return path

func ensure_two_way_connections() -> void:
	for i in range(len(buildings)):
		var indexes: Array = graph[i]
		for idx in indexes:
			if not i in graph[idx]:
				graph[idx].append(i)


#region Pathing visualization functions
func create_web() -> void:
	'''
	Creates a visual representation of the graph connections
	'''
	for i in range(len(buildings)):
		for j in graph[i]:
			create_line(buildings[i], buildings[j])

func create_line(...args: Array) -> void:
	var line: Line2D = Line2D.new()
	args[0].add_sibling(line)
	lines.append(line)
	line.default_color = Color(1.0, 1.0, 1.0, 0.3)
	line.width = 2
	line.z_index = -10
	for building in args:
		line.add_point(building.global_position)

func create_path_line(path: Array) -> void:
	var line: Line2D = Line2D.new()
	buildings[path[0]].add_sibling(line)
	path_lines.append(line)
	line.default_color = Color.MAGENTA
	line.width = 10
	line.z_index = -1
	for idx in path:
		line.add_point(buildings[idx].global_position)


func clear_lines() -> void:
	for line in lines:
		line.queue_free()
	lines = []

func clear_path_lines() -> void:
	for line in path_lines:
		line.queue_free()
	path_lines = []
#endregion

#region Depricated functions for historic preservation
func get_closest_neighbours_old(idx: int, amount: int = max_connections) -> Array:
	var closest_nodes: Array = []
	var closest_dists: Array = []
	for node in buildings:
		if node == buildings[idx]: continue
		var dist = node.global_position.distance_to(buildings[idx].global_position)
		if len(closest_nodes) < amount:
			closest_nodes.append(node)
			closest_dists.append(dist)
			continue
		var furthest_idx: int = get_furthest_idx(closest_dists)
		if dist < closest_dists[furthest_idx]:
			closest_nodes.append(node)
			closest_dists.append(dist)
			closest_nodes.pop_at(furthest_idx)
			closest_dists.pop_at(furthest_idx)
	return closest_nodes


func get_closest_neighbours_older(building: Building, amount: int = max_connections) -> Array:
	var closest_neighbours: Array = []
	for i in range(amount):
		closest_neighbours.append(get_closest_neighbour(building, closest_neighbours))
	return closest_neighbours

func get_closest_neighbour(building: Building, ignore_list: Array = []) -> Building:
	var closest_dist: float = INF
	var closest_building: Building = null
	for neighbour in buildings:
		if neighbour == building: continue
		if neighbour in ignore_list: continue
		var dist: float = neighbour.global_position.distance_to(building.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_building = neighbour
	return closest_building





#endregion

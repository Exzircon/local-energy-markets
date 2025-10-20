extends Node
class_name BreadthFirstSearch

var nodes: Array = []
var graph: Dictionary[int, Array] = {}

var lines: Array[Line2D] = []
var highlight_lines: Array[Line2D] = []

func create_graph() -> Dictionary[int, Array]:
	var new_graph: Dictionary[int, Array] = {}
	for i in range(len(nodes)):
		new_graph[i] = get_closest_neighbours(i)
	for i in range(len(nodes)):
		var indexes: Array = new_graph[i]
		for idx in indexes:
			if not i in new_graph[idx]:
				new_graph[idx].append(i)
	return new_graph

func get_closest_neighbours(idx: int, amount: int = 2) -> Array:
	'''
	Function for returning the "amount" closest neighbours of nodes[idx]
	'''
	var closest_nodes: Array = []
	var closest_dists: Array = []
	for i in range(len(nodes)):
		if i == idx: continue
		var dist = nodes[i].global_position.distance_to(nodes[idx].global_position)
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

func search(start: int, goal: int) -> Array:
	'''
	Breath First Search algorithm, guaranteed to find the shortest possible path.
	'''
	#print("BFSearch start!")
	#print("Wat?: ", goal)
	return [start, goal]
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
	return []

func verify_graph() -> bool:
	for i in range(len(nodes) - 1):
		if len(search(0, i+1)) == 0:
			print("Failed to verify graph at: ", i)
			return false
	return true




func set_nodes(new_nodes: Array) -> void:
	nodes = new_nodes
	graph = create_graph()
	verify_graph()
	create_web()

func create_web() -> void:
	'''
	Creates a visual representation of the graph connections
	'''
	clear_lines()
	for i in range(len(nodes)):
		for j in graph[i]:
			create_line(nodes[i], nodes[j])


func create_line(...args: Array) -> void:
	var line: Line2D = Line2D.new()
	args[0].add_sibling(line)
	lines.append(line)
	line.default_color = Color(1.0, 1.0, 1.0, 0.3)
	line.width = 2
	#line.z_index = -1
	for building in args:
		line.add_point(building.position)

func clear_lines() -> void:
	for line in lines:
		line.queue_free()
	lines = []


func highlight_path(path: Array) -> void:
	for line in highlight_lines:
		line.queue_free()
	highlight_lines = []
	var line: Line2D = Line2D.new()
	nodes[path[0]].add_sibling(line)
	highlight_lines.append(line)
	line.default_color = Color.from_hsv(0.888, 1.0, 2.0, 1.0)
	line.width = 2.0
	for idx in path:
		line.add_point(nodes[idx].global_position)
		
		
		

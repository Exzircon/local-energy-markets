extends Node2D

var agent_path = preload("res://stuff/agent.tscn")

@export_category("Agent Manager")
@export_group("Spawning Behaviour")
@export_range(0, 1000, 1, "or_greater") var num_buildings: int = 5000
@export_range(1, 1000, 1, "or_greater") var spawn_speed: int = 50
@export var spawn_spacing: float = 30.0
var spawn_radius: float = 300.0
var rem_buildings: int = 0

@export_group("K-Means")
@export var K: int = 10
var k_free_nodes: Array[Agent] = []
var k_groups: Array = []
@export var k_iterations: int = 15
@export var k_shift_frames: int = 15

var current_lines: Array = []


var palette: Array[Color] = []

#Time controls
var time_start: float = 0.0
var time_current: float = 0.0
var settle_frames: int = 1


#States
var state: States = States.SPAWNING
enum States {
	SPAWNING,
	ADJUSTING,
	KMEANS,
	IDLE
}

func _ready() -> void:
	palette = create_palette()
	time_start = Time.get_unix_time_from_system()
	rem_buildings = num_buildings
	spawn_radius = sqrt((num_buildings * 86 * spawn_spacing)/PI)
	
	
	#area = PI * r * r
	#area = num * b_size * 3
	#r*r = PI / (num * b_size * 3)
	#r = sqrt(PI / (num * b_size * 3))
	
	
	print("Spawn Radius: ", spawn_radius)


func _physics_process(delta: float) -> void:
	time_current = Time.get_unix_time_from_system() - time_start
	match state:
		States.SPAWNING:
			_state_spawning(delta)
		States.ADJUSTING:
			_state_adjusting(delta)
		States.KMEANS:
			_state_kmeans(delta)
		States.IDLE: pass
	
	#else:
	#	var time_end : float = Time.get_unix_time_from_system()
	#	print("Done! - took: ", time_end - time_start, " seconds")
	#	save_positions()
	#	self.process_mode = Node.PROCESS_MODE_DISABLED

func _state_spawning(delta: float) -> void:
	if rem_buildings > 0:
		print("placing ", min(spawn_speed, rem_buildings), " houses - "
		, rem_buildings, " remain - delta: ",
		 str("%0.4f" % delta), " - time: ", 
		str("%0.4f" % time_current), "s"
		)
		for i in range(min(spawn_speed, rem_buildings)):
			spawn_house()
		rem_buildings -= min(spawn_speed, rem_buildings)
	else:
		SignalBus.changeAgentState.emit(1)
		state = States.ADJUSTING
		print("Placed ", num_buildings," buildings in: ", str("%0.4f" % time_current), "s")
		for child in get_children():
			if child is Agent:
				k_free_nodes.append(child)


func _state_adjusting(_delta: float) -> void:
	if all_children_settled():
		settle_frames -= 1
	if settle_frames < 1:
		SignalBus.changeAgentState.emit(0)
		state = States.KMEANS
		_create_initial_sentroids()
		greedy_place()
		update_colors()
		print("Children settled in: ", str("%0.4f" % time_current), "s")


func _state_kmeans(_delta: float) -> void:
	if k_iterations > 0:
		k_iterations -= 1
		for group in k_groups:
			k_free_nodes.append(group[0])
		var new_sentroids: Array[Node2D] = []
		for i in range(K):
			new_sentroids.append(_get_center_node(k_groups[i]))
		k_groups = []
		var sentroid_indexes: Array = []
		for sentroid in new_sentroids:
			sentroid_indexes.append(k_free_nodes.find(sentroid))
		sentroid_indexes.sort()
		sentroid_indexes.reverse()
		for i in range(K):
			k_groups.append([k_free_nodes.pop_at(sentroid_indexes[i])])
		greedy_place()
		update_colors()
	elif k_shift_frames > 0:
		k_shift_frames -= 1
		for i in range(K):
			var sentroid = k_groups[i][0]
			for point in k_groups[i]:
				if point == sentroid: continue
				point.shift_towards(sentroid.global_position)
		#draw_home_lines()
	else:
		state = States.IDLE
		save_positions("res://1k_data.dat")
		print("Grouped all buildings in: ", str("%0.4f" % time_current), "s")


### Spawning Funcitons
func spawn_house() -> void:
	var agent = agent_path.instantiate()
	add_child(agent)
	agent.global_position = get_rand_pos(spawn_radius)
	#agent.modulate = Color.from_hsv(lerpf(0, 1, randf()), 0.8, 0.9)

func get_rand_pos(i_range: float) -> Vector2:
	#Returns a random Vector2 position withing range, with equal distribution
	var theta : float = randf() * 2 * PI
	return Vector2(cos(theta), sin(theta)) * sqrt(randf()) * i_range



### Adjusting Functions
func all_children_settled() -> bool:
	for child in get_children():
		if len(child.in_arr) > 0: return false
	return true


### K-Means Functions
func _create_initial_sentroids() -> void:
	k_free_nodes.shuffle()
	for i in range(K):
		k_groups.append([k_free_nodes.pop_back()])

func greedy_place() -> void:
	for point in k_free_nodes:
		var distances: Array = []
		for i in range(K):
			distances.append(point.global_position.distance_squared_to(k_groups[i][0].global_position))
		var closest_distance: float = INF
		var closest_idx: int = 0
		for i in range(len(distances)):
			if distances[i] < closest_distance:
				closest_distance = distances[i]
				closest_idx = i
		k_groups[closest_idx].append(point)

func _get_center_node(group: Array) -> Node2D:
	var total_x: float = 0
	var total_y: float = 0
	for point in group:
		total_x += point.global_position.x
		total_y += point.global_position.y
	var avg_point: Vector2 = Vector2(total_x/len(group), total_y/len(group))
	var closest_distance: float = INF
	var closest_index: int = 0
	for i in range(len(group)):
		var curr_distance: float = group[i].global_position.distance_squared_to(avg_point)
		if curr_distance < closest_distance:
			closest_distance = curr_distance
			closest_index = i
	return group[closest_index]

func create_bad_palette() -> Array:
	var new_palette: Array[Color] = []
	for i in range(K):
		var color_array = [0.4, 0.4, 0.4]
		for j in range(randi_range(0, 2)+1):
			color_array[j] = randf_range(0.4, 1.0)
		color_array.shuffle()
		new_palette.append(Color(color_array[0],color_array[1],color_array[2]))
	return new_palette

func create_palette() -> Array:
	var new_palette: Array[Color] = []
	for i in range(K):
		new_palette.append(Color.from_hsv(lerpf(0, 1, i / float(K)), 0.8, 0.9))
	return new_palette


func update_colors() -> void:
	for i in range(K):
		for point in k_groups[i]:
			point.modulate = palette[i]

func draw_home_lines() -> void:
	clear_lines()

	for group in k_groups:
		for point in group:
			var line: Line2D = Line2D.new()
			#line.modulate = Color(1, 1, 1, 0.02)
			line.modulate = point.modulate * 0.4
			line.add_point(point.global_position)
			line.add_point(group[0].global_position)
			add_child(line)
			current_lines.append(line)

func clear_lines() -> void:
	for line in current_lines:
		line.queue_free()
	current_lines = []



### Misc Functions
func save_positions(save_path: String = "res://save_data.dat") -> void:
	var positions : Array[Vector2] = []
	for ag in get_children():
		positions.append(ag.global_position)
	var file := FileAccess.open(save_path, FileAccess.WRITE_READ)
	file.store_var(positions)
	file.close()

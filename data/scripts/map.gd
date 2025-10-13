extends Sprite2D

var bfs = BreadthFirstSearch.new()


#TEST: PARTICLEPATH TEST
var particle_paths: Array[ParticlePath2D] = []



func _ready() -> void:
	bfs.set_nodes(get_children())
	#for i in range(bfs.nodes.size() - 1):
	#	test(0, i+1)
	test(0, 28)

	#for idx in rand_path:
	#	bfs.nodes[idx].scale = Vector2.ONE * 0.3
	


@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	pass
	


func test(a: int, b: int) -> void:
	var path = bfs.search(a, b)
	#bfs.highlight_path(path)
	var p_path: ParticlePath2D = ParticlePath2D.new()
	p_path.top_level = true
	p_path.z_index = -1
	p_path.curve = Curve2D.new()
	for idx in path:
		p_path.curve.add_point(bfs.nodes[idx].global_position)
	particle_paths.append(p_path)
	bfs.nodes[a].add_child(p_path)
	
	
	


func _rand_highlight() -> void:
	var a: int = randi_range(0, bfs.nodes.size() - 1)
	var b: int = randi_range(0, bfs.nodes.size() - 1)
	while a == b:
		b = randi_range(0, bfs.nodes.size() - 1)
	var path = bfs.search(a, b)
	bfs.highlight_path(path)

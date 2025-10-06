extends Node2D



var house_path = preload("res://buildings/house.tscn")

@export_category("Building Manager")
@export var load_from_file: bool = true
@export var num_buildings: int = 50
@export var spawn_radius: float = 300.0


func _ready() -> void:
	if load_from_file:
		_spawn_houses_from_file()
	else:
		for i in range(num_buildings):
			spawn_house()
	Pathing.update_graph()

func spawn_house() -> void:
	var house = house_path.instantiate()
	add_child(house)
	house.global_position = get_rand_pos(spawn_radius)
	house.num_solar_panels = randi_range(0, 8)
	Pathing.add_to_array(house)

func get_rand_pos(i_range: float) -> Vector2:
	return Vector2(randf_range(-i_range, i_range), randf_range(-i_range, i_range))


func spawn_house_at(pos: Vector2) -> void:
	var house = house_path.instantiate()
	add_child(house)
	house.global_position = pos
	house.num_solar_panels = randi_range(0, 8)
	Pathing.add_to_array(house)


func _spawn_houses_from_file() -> void:
	var file := FileAccess.open("res://data/5k_data.dat", FileAccess.READ)
	var positions: Array[Vector2] = file.get_var(true)
	print("Houses placed: ", len(positions))
	for pos in positions:
		spawn_house_at(pos)
	file.close()

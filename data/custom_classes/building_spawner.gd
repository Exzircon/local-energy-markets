extends Node2D
@export_category("Building Spawner")
@export var folder_path: String
@export var ignore_list: Array[String]




func _ready() -> void:
	print("WAHOO!")
	load_data()

func load_data() -> void:
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				continue
			else:
				if not file_name.substr(len(file_name)-4, 4) == ".csv":
					file_name = dir.get_next()
					continue
				if file_name in ignore_list: 
					file_name = dir.get_next()
					continue
				create_building(file_name)
			file_name = dir.get_next()


func create_building(file_name: String) -> void:
	#print(folder_path+file_name)
	var building: Building = Building.new()
	building.name = file_name.substr(0, len(file_name)-4)
	building.consumption_csv = folder_path+file_name
	add_sibling.call_deferred(building)
	building.global_position = get_rand_pos(300)
	
func get_rand_pos(i_range: float = 300) -> Vector2:
	#Returns a random Vector2 position withing range, with equal distribution
	var theta : float = randf() * 2 * PI
	return Vector2(cos(theta), sin(theta)) * sqrt(randf()) * i_range

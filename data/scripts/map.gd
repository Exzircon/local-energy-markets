extends Sprite2D
class_name Map
##Map node that containts all the buildings, as well as managing the .csv files


@export_category("Map")
@export var csv_match_error_margin: int = 2


const csv_folder_path: String = "res://dataset"
## Variable for storing the file names from the dataset folder
var files: Array[String] = []

func _init() -> void:
	PowerManager.map = self #Makes sure this map is active in the PowerManager
	load_file_names() #Loads the file names of .csv files in res://dataset/ into the files Array

##Loads the file names of .csv files in res://dataset/ into the files Array
func load_file_names() -> void:
	var dir := DirAccess.open(csv_folder_path)
	if not dir: return #Early escape if dir not found
	files = [] #Resets the file list for new loads
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir(): #Prints the name of  any sub-directories found, does NOT search through them
			print("Found directory: ", file_name) 
		else:
			if not ".import" in file_name and ".csv" in file_name: #Make sure only .csv files are loaded
				#print("Found file: ", file_name)
				files.append(file_name.left(len(file_name)-4))
		file_name = dir.get_next()

## Returns the .csv file path that has the closest matching name to the agent.
## Returns null if no file matches within a given error margin
## Called by buildings to get their .csv file to load into their power consumption curve
func get_matching_csv(agent_name: String) -> Variant: #Returns String or Null
	agent_name = agent_name.remove_chars("& ").to_lower()
	var result: Array = get_closest_match(agent_name)
	if result[1] > csv_match_error_margin:
		return null
	return csv_folder_path +"/"+ result[0] + ".csv"


## Returns an array containting the file name with the closest matching name to the building,
##  as well as the mathcing score (lower is better)
func get_closest_match(building_name: String) -> Array:
	var closest_match: String
	var closest_score: int = 9999 #Arbitrarily high starting value
	for file_name in files:
		#print(file_name)
		var score = get_match_score(building_name, file_name)
		if score < closest_score:
			closest_score = score
			closest_match = file_name
	if closest_score > csv_match_error_margin:
		print("Name: ", building_name, " | Match: ", closest_match," | Score: ", closest_score)
	return [closest_match, closest_score]


## Retruns how closly two strings resemble eachother. (Lower score means better match)
## Works by counting letters, so "aab" and "baa" gets a perfect score of 0.
func get_match_score(a: String, b: String) -> int:
	var score: int = 0
	var hashmap: Dictionary = {}
	#Initialize Hashmap
	var alphabet_lower: String = "abcdefghijklmnopqrstuvwxyzæøå"
	for sym in alphabet_lower:
		hashmap[sym] = 0
	for sym in a.to_lower():
		if not sym in alphabet_lower: continue #Ignore symbols that are not tested for
		hashmap[sym] = hashmap[sym] + 1
	#print(hashmap)
	for sym in b.to_lower():
			if not sym in alphabet_lower: continue #Ignore symbols that are not tested for
			hashmap[sym] = hashmap[sym] - 1
	#print(hashmap)
	for sym in alphabet_lower:
		score += absi(hashmap[sym])
	return score

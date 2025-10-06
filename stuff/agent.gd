extends Sprite2D
class_name Agent
'''
Script for the placed agents, these are made as Sprite2D for performance and debugging reasons.
RigidBody2D and CharacterBody2D was also tested but had worse performance. 


'''


@onready var area : Area2D = $Area2D

var in_arr: Array = [] #Array for storing which other agents are within Area2D

### Unsued variables
#var push_force: Vector2 = Vector2(10.0, 10.0)
#@export var range: float = 100.0 #This range is deprecated in favor of changing the CollisionShape2D of tha area node instead

@export var speed: float = 400 #speed factor of how fast this agent is pushed away from other agents

var state: States = States.IDLE #Current state
enum States {
	IDLE, #State for when the agent isn't doing anything
	SOFT, #State for when the agent should be soft colliding with other nearby agents
}

func _ready() -> void:
	###Connects the Area2D node to their corresponing function, 
	### as well as connecting to the SignalBus to recieve state changes
	area.connect("area_entered", entered)
	area.connect("area_exited", exit)
	SignalBus.connect("changeAgentState", change_state)

func _physics_process(delta: float) -> void:
	#global_position += speed * delta
	if state == States.SOFT:
		global_position += _soft_collision() * speed * delta




func _soft_collision_bad() -> Vector2:
	'''
	Bad attempt at optimizing the soft collisions, left unused
	'''
	#var arr: Array[Vector2] = []
	var dir: Vector2 = Vector2.ZERO
	for ag in in_arr:
		dir += ag.global_position.direction_to(global_position)
		#arr.append(ag.global_position.direction_to(global_position))
	return dir

func _soft_collision() -> Vector2:
	'''
	Function for preventing self from overlapping with other agents
	Returns direction self needs to be moved to move away from all other agents in Area2D.
	direction is scaled so that closer agents have a bigger effect on the dir vector scale and direction 
	'''
	var dir: Vector2 = Vector2.ZERO
	for ag in in_arr:
		#Closer agents have bigger effect on dir
		dir += ag.global_position.direction_to(global_position) * (100 / ag.global_position.distance_to(global_position))
	return dir #Using .normalized() results in significant performance improvements (about 9x faster) but creates weird holes in the final placements

func shift_towards(goal: Vector2) -> void:
	'''
	Function for moving self closer to "goal", without overlapping with other agents
	'''
	global_position += global_position.direction_to(goal) * 0.7
	global_position += _soft_collision() * 5



### Functions called by signals
func entered(agent: Area2D) -> void:
	'''
	Appends agent who entered areas radius to the in_arr
	'''
	if agent.get_parent() == self: return
	in_arr.append(agent.get_parent())
	#print(agent.name, " entered: ", self.name, " - ", in_arr)

func exit(agent: Area2D) -> void:
	'''
	Removes agent who exitet areas radius from the in_arr
	'''
	if agent.get_parent() == self: return
	in_arr.remove_at(in_arr.find(agent.get_parent()))
	#print(agent.name, " exited: ", self.name, " - ", in_arr)

func change_state(new_state: int = 0) -> void:
	'''
	Changes current state to recieved state
	'''
	match new_state:
		0: state = States.IDLE
		1: state = States.SOFT
		_: state = States.IDLE

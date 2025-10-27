extends Node

signal Tick()
signal Pre_Tick()
signal Post_Tick()

var time_frames: int = 20 #1 second
var current_frame: int = time_frames

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if current_frame > 0:
		current_frame -= 1
	else:
		current_frame = time_frames
		emit_tick()


func emit_tick() -> void:
	Pre_Tick.emit()
	Tick.emit()
	Post_Tick.emit()



func _input(event: InputEvent) -> void:
	if event is InputEvent:
		if event.is_action_pressed("ui_accept"):
			emit_tick()

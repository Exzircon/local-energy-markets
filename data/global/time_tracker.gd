extends Node


signal Tick()
signal Pre_Tick()
signal Post_Tick()

func emit_tick() -> void:
	Pre_Tick.emit()
	Tick.emit()
	Post_Tick.emit()



func _input(event: InputEvent) -> void:
	if event is InputEvent:
		if event.is_action_pressed("ui_accept"):
			emit_tick()

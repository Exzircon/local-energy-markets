extends PanelContainer

var mouse_inside: bool = false


func _init() -> void:
	mouse_entered.connect(entered)
	mouse_exited.connect(exited)
	hide()

func entered() -> void:
	#show()
	mouse_inside = true


func exited() -> void:
	#hide()
	mouse_inside = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and mouse_inside:
			SignalBus.emit_signal("display_stats", get_parent())

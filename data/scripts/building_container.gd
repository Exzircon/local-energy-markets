extends PanelContainer


func _init() -> void:
	mouse_entered.connect(entered)
	mouse_exited.connect(exited)
	hide()

func entered() -> void:
	show()


func exited() -> void:
	hide()

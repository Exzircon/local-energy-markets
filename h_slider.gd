extends HSlider

@onready var btn := $"../CheckButton"

var btn_pressed: bool = false



func _physics_process(_delta: float) -> void:
	if btn.button_pressed:
		GenerationFactor.factor = value

extends Sprite2D
class_name Building

@export_category("Building Stats")
@export var consumption: float = 10.0
@export var generation: float = 0.0:
	get():
		return num_solar_panels * 2.0 * GenerationFactor.factor + generation
@export var num_solar_panels: int = 0

var satisfaction: float:
	get():
		return generation / consumption


@export_group("Colors")
@export var low_color: Color = Color.RED
@export var mid_color: Color = Color.YELLOW
@export var high_color: Color = Color.GREEN


func _physics_process(delta: float) -> void:
	_update_color()

func _update_color() -> void:
	if satisfaction > 1.0:
		modulate = mid_color.lerp(high_color, satisfaction - 1.0)
	else:
		modulate = low_color.lerp(mid_color, satisfaction)
	#print(satisfaction)

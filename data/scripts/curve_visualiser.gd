extends Line2D

@export_category("Curve Visualiser")
@export var desired_width: float = 300.0



var building: Building
var curve_actually_exsists: bool = false

func _ready() -> void:
	if not get_parent() is Building: return
	building = get_parent()
	#print(building.consumption_curve)
	#if building.consumption_curve and not curve_actually_exsists:
	#	update_line(building.consumption_curve)

func _physics_process(delta: float) -> void:
	if building.consumption_curve and not curve_actually_exsists:
		update_line(building.consumption_curve)

func update_line(curve: Curve) -> void:
	if curve.point_count > 0:
		curve_actually_exsists = true
	curve.get_value_range()
	for i in range(curve.point_count):
		add_point(Vector2(i, -curve.sample(float(i)) * 10))
	if points.size() == 0: return
	var x_wide = points[points.size()-1][0]
	print("x_wide: ", x_wide)
	scale.x = desired_width / x_wide
	

extends Camera2D


var speed: float = 400.0
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var move_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var move_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = Vector2(move_x, move_y)
	var velocity = direction.normalized() * speed
	global_position += velocity * delta



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#zoom += Vector2.ONE / 100
			zoom += zoom * 0.01
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#zoom -= Vector2.ONE / 100
			zoom -= zoom * 0.01

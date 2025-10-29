extends Camera2D


@export_category("Camera Movement")
@export var speed: float = 400.0
var direction: Vector2 = Vector2.ZERO

@export var zoom_speed: float = 1.0
var target_zoom: Vector2 = Vector2.ONE
var target_scale: Vector2 = Vector2.ONE
var zoom_smoothing: float = 0.135

func _physics_process(delta: float) -> void:
	var move_x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var move_y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = Vector2(move_x, move_y)
	var velocity = direction.normalized() * speed
	global_position += velocity * delta
	
	zoom = lerp(zoom, target_zoom, zoom_smoothing)
	scale = lerp(scale, target_scale, zoom_smoothing)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			#zoom += Vector2.ONE / 100
			target_zoom += target_zoom * 0.01 * zoom_speed
			target_scale -= target_scale * 0.01 * zoom_speed
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			#zoom -= Vector2.ONE / 100
			target_zoom -= target_zoom * 0.01 * zoom_speed
			target_scale += target_scale * 0.01 * zoom_speed

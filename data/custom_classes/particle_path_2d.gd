extends Path2D
class_name ParticlePath2D

@export_category("ParticlePath2D")
@export var speed: float = 75.0
@export var count: int = 5
@export var texture: Texture2D = preload("res://assets/icons/Energy.png")
@export var texture_scale: float = 0.1
@export var texture_spacing: float = 10.0

var tex_size: float = 20.0
var particles: Array[PathFollow2D] = []




func _ready() -> void:
	#var c: float = 0
	var length: float = curve.get_baked_length()
	@warning_ignore("narrowing_conversion")
	count = length / (texture.get_width() * texture_scale + texture_spacing)
	count = max(1, count)
	
	for i in range(count):
		add_particle(i)


func _physics_process(delta: float) -> void:
	for particle in particles:
		particle.progress += speed * delta





func add_particle(offset_idx: int = 0) -> void:
	var particle : PathFollow2D = PathFollow2D.new()
	particles.append(particle)
	add_child(particle)
	var sprite = Sprite2D.new()
	sprite.texture = texture
	particle.add_child(sprite)
	particle.loop = true
	particle.rotates = false
	sprite.scale = Vector2.ONE * texture_scale
	sprite.global_rotation = 0
	#sprite.modulate = Color.from_hsv(0.131, 0.792, 1.0, 1.0)
	particle.progress_ratio = 1.0 / count * offset_idx

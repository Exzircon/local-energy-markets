extends Sprite2D
class_name Building

@export_category("Building Stats")
@export var consumption: float = 10.0
@export var generation: float = 0.0:
	get():
		return num_solar_panels * 5.0 + generation
@export var num_solar_panels: int = 0

var satisfaction: float:
	get():
		return generation / consumption

#TODO: Add Battery functionality to houses
var capacity: float = 0.0
var max_capacity: float = 100.0

@export_group("Colors")
@export var low_color: Color = Color.RED
@export var mid_color: Color = Color.YELLOW
@export var high_color: Color = Color.GREEN




#region Child Nodes
@onready var panel_container: PanelContainer = $PanelContainer
@onready var name_label: Label = $PanelContainer/VBoxContainer/NameLabel
@onready var consumption_label: Label = $PanelContainer/VBoxContainer/ConsumptionLabel
@onready var production_label: Label = $PanelContainer/VBoxContainer/ProductionLabel

@onready var hover_area: Area2D = $HoverArea
@onready var collision_shape_2d: CollisionShape2D = $HoverArea/CollisionShape2D
#endregion





func _ready() -> void:
	TimeTracker.connect("Tick", tick)
	name_label.text = name
	hover_area.connect("mouse_entered", mouse_entered)
	hover_area.connect("mouse_exited", mouse_exited)

func mouse_entered() -> void:
	panel_container.show()

func mouse_exited() -> void:
	panel_container.hide()

func tick(tick: int) -> void:
	if consumption > generation:
		PowerManager.request_power(self, consumption - generation)
	elif consumption < generation:
		PowerManager.provide_power(self, generation - consumption)

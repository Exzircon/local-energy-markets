extends PanelContainer
@onready var speed_option_button: OptionButton = $SettingsVBoxContainer/SpeedButtonsHBoxContainer/SpeedOptionButton
@onready var pause_after_option_button: OptionButton = $SettingsVBoxContainer/PauseAfterButtonsHBoxContainer/PauseAfterOptionButton

var pause_after: float = 0.0

func _ready() -> void:
	Settings.connect_speed_button(speed_option_button)
	pause_after_option_button.item_selected.connect(pause_after_selected)
	TickEngine.tick_enviroment.connect(enviroment_tick)
	pause_after_selected(0)

func pause_after_selected(id: int) -> void:
	match id:
		0: pause_after = 99999999999999999.0
		1: pause_after = 168.0
		2: pause_after = 720.0
		3: pause_after = 8760.0
		4: pause_after = 175320.0

func enviroment_tick() -> void:
	if Stats.time >= pause_after:
		#print("PAUSE: ", Stats.time, " - " ,pause_after)
		speed_option_button.select(0)
		speed_option_button.emit_signal("item_selected", 0)

extends PanelContainer
@onready var speed_option_button: OptionButton = $SettingsVBoxContainer/SpeedButtonsHBoxContainer/SpeedOptionButton
@onready var pause_after_option_button: OptionButton = $SettingsVBoxContainer/PauseAfterButtonsHBoxContainer/PauseAfterOptionButton
@onready var pause_saved_line_edit: LineEdit = $SettingsVBoxContainer/PauseSavedHBoxContainer/PauseSavedLineEdit

var pause_after: float = 0.0
var pause_saved: float = 0.0
var old_text: String = ""

func _ready() -> void:
	Settings.connect_speed_button(speed_option_button)
	pause_after_option_button.item_selected.connect(pause_after_selected)
	TickEngine.tick_enviroment.connect(enviroment_tick)
	pause_after_selected(0)
	pause_saved_line_edit.text_changed.connect(force_numerical_input)
	pause_saved_line_edit.text_submitted.connect(amount_saved_submit)

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


func force_numerical_input(new_text: String) -> void:
	if new_text.length() == 0: 
		old_text = new_text
		return
	print("Old Text: ", old_text, " --- New Text: ", new_text)
	if not new_text.is_valid_float():
		pause_saved_line_edit.text = old_text
		pause_saved_line_edit.cancel_ime()
	else:
		old_text = new_text

func amount_saved_submit(text: String) -> void:
	pass

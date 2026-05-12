extends PanelContainer
@onready var speed_option_button: OptionButton = $SettingsVBoxContainer/SpeedButtonsHBoxContainer/SpeedOptionButton
@onready var pause_after_option_button: OptionButton = $SettingsVBoxContainer/PauseAfterButtonsHBoxContainer/PauseAfterOptionButton
@onready var pause_saved_line_edit: LineEdit = $SettingsVBoxContainer/PauseSavedHBoxContainer/PauseSavedLineEdit

@onready var inflation_scroll_bar: HScrollBar = $SettingsVBoxContainer/InflationHBoxContainer/InflationHScrollBar
@onready var inflation_value_label: Label = $SettingsVBoxContainer/InflationHBoxContainer/InflationValueLabel



var pause_after: float = 0.0
var pause_saved: float = -1.0
var old_text: String = ""
var last_speed_state: int = 1

func _ready() -> void:
	Settings.connect_speed_button(speed_option_button)
	speed_option_button.item_selected.connect(save_speed_state)
	speed_option_button.item_selected.emit(speed_option_button.selected)
	pause_after_option_button.item_selected.connect(pause_after_selected)
	TickEngine.tick_enviroment.connect(enviroment_tick)
	pause_after_selected(0)
	pause_saved_line_edit.text_changed.connect(force_numerical_input)
	pause_saved_line_edit.text_submitted.connect(amount_saved_submit)
	inflation_scroll_bar.value_changed.connect(inflation_change)
	inflation_scroll_bar.value_changed.emit(Settings.inflation)

func pause_after_selected(id: int) -> void:
	match id:
		0: pause_after = 99999999999999999.0
		1: pause_after = 168.0
		2: pause_after = 720.0
		3: pause_after = 8760.0
		4: pause_after = 8760.0 * 20.0
		5: pause_after = 8760.0 * 25.0
		5: pause_after = 8760.0 * 30.0

func enviroment_tick() -> void:
	if Stats.time >= pause_after:
		#print("PAUSE: ", Stats.time, " - " ,pause_after)
		do_pause()
	if pause_saved > 0.0 and Stats.money_saved_total > (pause_saved * 100):
		do_pause()
		

func do_pause() -> void:
	speed_option_button.select(0)
	speed_option_button.emit_signal("item_selected", 0)

func force_numerical_input(new_text: String) -> void:
	if new_text.length() == 0: 
		old_text = new_text
		return
	#print("Old Text: ", old_text, " --- New Text: ", new_text)
	if not new_text.is_valid_float():
		pause_saved_line_edit.text = old_text
		pause_saved_line_edit.cancel_ime()
	else:
		old_text = new_text

func amount_saved_submit(text: String) -> void:
	if text == "":
		pause_saved = -1.0
		return
	if not text.is_valid_float(): return
	pause_saved = text.to_float()
	

func _toggle_pause() -> void:
	if speed_option_button.get_selected_id() == 0:
		#Is paused, do unpause
		speed_option_button.select(last_speed_state)
		speed_option_button.item_selected.emit(last_speed_state)
		return
	speed_option_button.select(0)
	speed_option_button.item_selected.emit(0)

func save_speed_state(id: int) -> void:
	if id == 0: return
	last_speed_state = id
	speed_option_button.release_focus() 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()
		#DO PAUSE

func inflation_change(new_value: float) -> void:
	Settings.inflation = new_value
	inflation_value_label.text = str("%20.0f" % ((new_value - 1.0)*100)) + "%"

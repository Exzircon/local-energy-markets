extends LineEdit
class_name FloatLineEdit


var old_text: String = ""

func _ready() -> void:
	text_changed.connect(force_numerical_input)
	text_submitted.connect(value_selected)

func force_numerical_input(new_text: String) -> void:
	if new_text.length() == 0: 
		old_text = new_text
		return
	#print("Old Text: ", old_text, " --- New Text: ", new_text)
	if not new_text.is_valid_float():
		text = old_text
		cancel_ime()
	else:
		old_text = new_text

func value_selected(new_float: String) -> void:
		clear()
		placeholder_text = new_float

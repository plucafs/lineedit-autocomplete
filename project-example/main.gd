extends Control

@onready var keys: Label = %Keys
@onready var line_edit_autocomplete: AutocompleteLineEdit = %LineEditAutocomplete
@onready var words: Label = %Words
@onready var case_insensitive_check_box: CheckBox = %CaseInsensitiveCheckBox

func _ready() -> void:
	case_insensitive_check_box.toggled.connect(
		func(state: bool):
			line_edit_autocomplete.case_insensitive = state
	)

	case_insensitive_check_box.button_pressed = line_edit_autocomplete.case_insensitive
	line_edit_autocomplete.grab_focus()
	words.text = "Try: " + " | ".join(line_edit_autocomplete.words_list)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		keys.text = "Key: " + event.as_text_keycode()

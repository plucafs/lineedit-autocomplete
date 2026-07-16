extends Control

@onready var keys: Label = %Keys
@onready var line_edit_autocomplete: AutocompleteLineEdit = %LineEditAutocomplete
@onready var words: Label = %Words

func _ready() -> void:
	line_edit_autocomplete.grab_focus()
	words.text = "Try: " + " | ".join(line_edit_autocomplete.words_list)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		keys.text = "Key: " + event.as_text_keycode()

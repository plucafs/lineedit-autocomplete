@icon("res://LineEditAutocomplete.svg")
extends LineEdit
class_name LineEditAutocomplete

const SPACE := " "

@export var words_list := PackedStringArray([])
## You need to take care to add the spaces
@export var words_separator := SPACE
## Simplify adding new words on linedit focus
@export var on_enter_focus_caret_to_the_end := true
## Sort the words array alphabetically
@export var sort_words_list := true
## The text checked against the words is lowered
@export var input_text_to_lower := false

var text_buffer := ""
var is_key_backspace_pressed := false
var is_key_delete_pressed := false
var is_key_space_pressed := false


func _ready() -> void:
	connect("text_changed", _on_text_changed)


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.is_pressed():
		return
	
	var _text := text
	match event.keycode:
		KEY_DELETE:
			is_key_delete_pressed = true
			return
		KEY_BACKSPACE:
			is_key_backspace_pressed = true
			return
		KEY_SPACE:
			is_key_space_pressed = true
			return
		KEY_ENTER:
			if get_selected_text().length() == 0:
				return
			caret_column = _text.length()
			text_buffer = _text
			deselect()
			get_viewport().set_input_as_handled()
		KEY_TAB:
			if get_selected_text().length() == 0:
				return
			caret_column = _text.length()
			text_buffer = _text
			deselect()
			get_viewport().set_input_as_handled()
		_:
			text_buffer = _text
			is_key_backspace_pressed = false
			is_key_delete_pressed = false


## Handles only lowercase words
func _on_text_changed(text_changed: String) -> void:
	var _words_list := words_list
	if sort_words_list:
		_words_list.sort()
	text_changed = text_changed.strip_edges()
	if input_text_to_lower:
		text_changed = text_changed.to_lower()
	var has_words_separator := text_changed.contains(words_separator)
	var other_tags := []

	if has_words_separator:
		var words_separator_in_text := text_changed.count(words_separator)
		if words_separator_in_text == text_changed.length():
			text = ""
			return

		var all_text_tags := text_changed.split(words_separator, false)
		text_changed = all_text_tags[-1]
		all_text_tags.resize(all_text_tags.size() - 1)
		other_tags = all_text_tags

	if text_changed.contains(SPACE):
		text = text_buffer
		caret_column = text_buffer.length()
		return

	text_buffer = text_changed
	
	if is_key_backspace_pressed:
		return

	if is_key_delete_pressed:
		return
	
	if is_key_space_pressed:
		is_key_space_pressed = false
		return
		
	var ordered_words_list = Array(_words_list)\
		.filter(func(word):
			return word.begins_with(text_changed) && not word == text_changed)
	
	if ordered_words_list.is_empty():
		return

	var _text_length = text_changed.length()
	if _text_length == 0:
		return
		
	var suggestion_single_tag = text_changed + ordered_words_list[0].erase(0, _text_length)
	var suggestion_multi_tags = ordered_words_list[0].erase(0, _text_length)
	
	if has_words_separator:
		text = words_separator.join(other_tags) + words_separator + text_changed
		var start_caret_column = text.length()
		text += suggestion_multi_tags
		select(start_caret_column, -1)
		caret_column = start_caret_column
		return

	text = suggestion_single_tag
	select(_text_length, -1)
	caret_column = _text_length


func _on_focus_entered() -> void:
	if on_enter_focus_caret_to_the_end:
		caret_column = text.length()

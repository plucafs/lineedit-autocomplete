class_name AutocompleteLineEdit
extends LineEdit

const SPACE := " "
var words_separator := SPACE

## The list of words to match against the last word of the LineEdit
## for suggestions
@export var words_list := PackedStringArray([])

## Simplifies adding new words to the LineEdit when it grabs the focus
@export var on_focus_move_caret_to_end := true

## Sorts the words array alphabetically
@export var sort_words_list := true

## Makes the match case insensitive.[br]
## e.g. [ABC] will be suggested when or `AB` or `ab` is typed
@export var case_insensitive := false

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


func _on_text_changed(text_changed: String) -> void:
	var words_list_dup := Array(words_list)
	if sort_words_list:
		words_list_dup.sort_custom(func(a, b): return a.naturalnocasecmp_to(b) < 0)
	text_changed = text_changed.strip_edges()
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

#TODO Handle spaces inside match words
	if is_key_space_pressed:
		is_key_space_pressed = false
		return

	var ordered_words_list = Array(words_list_dup)\
		.filter(func(word: String):
			if case_insensitive:
				return word.to_lower().begins_with(text_changed.to_lower()) && word != text_changed
			return word.begins_with(text_changed) && word != text_changed)

	if ordered_words_list.is_empty():
		return

	var text_changed_length = text_changed.length()
	if text_changed_length == 0:
		return

	var first_suggestion: String = ordered_words_list[0]
	var text_suggestion_single_tag: String = text_changed + first_suggestion.erase(0, text_changed_length)
	var text_suggestion_multi_tags: String = first_suggestion.erase(0, text_changed_length)

	if has_words_separator:
		var suggestion_fragment: String = first_suggestion.erase(
			text_changed_length,
			first_suggestion.length()
		)
		if case_insensitive && text_changed != suggestion_fragment:
			text_changed = suggestion_fragment
		text = words_separator.join(other_tags) + words_separator + text_changed
		var start_caret_column := text.length()
		text += text_suggestion_multi_tags
		select(start_caret_column, -1)
		caret_column = start_caret_column
		return

	text = ordered_words_list[0]
	select(text_changed_length, -1)
	caret_column = text_changed_length


func _on_focus_entered() -> void:
	if on_focus_move_caret_to_end:
		caret_column = text.length()

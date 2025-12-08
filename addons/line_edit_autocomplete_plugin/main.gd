@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("LineEditAutocomplete", "LineEdit", preload("uid://cxtdun3ap68qx"), preload("uid://bytv0vn5bkfuj"))


func _exit_tree():
	remove_custom_type("LineEditAutocomplete")

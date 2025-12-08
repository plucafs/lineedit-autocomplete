@tool
extends Control

@onready var keys: Label = %Keys

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		keys.text = "Key: " + event.as_text_keycode()

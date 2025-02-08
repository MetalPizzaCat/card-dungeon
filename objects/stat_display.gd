
extends Control
class_name StatDisplay

@export var max_value: int = 5:
	get:
		return _max_value
	set(value):
		_max_value = value
		update_display()


@export var current_value: int = 5:
	get:
		return _current_value
	set(value):
		_current_value = value
		update_display()

@export var full_texture: Texture
@export var empty_texture: Texture

@onready var box : HBoxContainer = $HBoxContainer

var _max_value: int
var _current_value: int

var icons : Array[TextureRect] = []

func update_display() -> void:
	if box == null:
		return
	for icon in icons:
		box.remove_child(icon)
		icon.queue_free()
	icons.clear()

	for i in range(max_value):
		var icon = TextureRect.new()
		box.add_child(icon)
		icons.append(icon)
		icon.texture = full_texture if i < current_value else empty_texture 
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		

extends Control
class_name DiscardedCardControl

var target_pos: Vector2
var target_rot: float
var start_pos: Vector2
var start_rot: float
var current_movement_time: float = 0
var moving: bool = false

@export var movement_time: float = 1

@export var card_offset: Vector2 = Vector2.ZERO

func add_card(card: PlayableCard) -> void:
	add_child(card)
	card.position = card_offset

func _process(delta: float) -> void:
	if not moving:
		return
	current_movement_time += delta
	global_position = lerp(start_pos, target_pos, current_movement_time / movement_time)
	rotation_degrees = lerp(start_rot, target_rot, current_movement_time / movement_time)
	if current_movement_time > movement_time:
		moving = false


func move_to(from_pos: Vector2, from_rot: float, to_pos: Vector2, to_rot: float) -> void:
	global_position = from_pos
	rotation_degrees = 0
	start_pos = from_pos
	start_rot = from_rot
	target_pos = to_pos
	target_rot = to_rot
	moving = true
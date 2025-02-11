extends Control
class_name PlayableCard

signal card_used(card: Card, playable_id: int)

@onready var name_label: Label = $NameLabel
@onready var health_label: Label = $HealthLabel
@onready var mana_label: Label = $ManaLabel
@onready var description: RichTextLabel = $RichTextLabel

@onready var background: TextureRect = $Background
@onready var item_icon: TextureRect = $Item
@onready var button: Button = $Button


@export var card: Card:
	get:
		return _card
	set(value):
		_card = value
		if value != null:
			name_label.text = value.name
			description.text = value.description
			health_label.text = str(-value.health_cost)
			mana_label.text = str(-value.mana_cost)
			match value.background:
				Card.BackgroundType.ITEM:
					background.texture = item_bg
				Card.BackgroundType.ENEMY:
					background.texture = enemy_bg
				Card.BackgroundType.SPELL:
					background.texture = spell_bg
			item_icon.texture = value.icon

var _card: Card
var _playable: bool = true

@export var card_id: int = -1
@export var movement_time: float = 0.2

var playable: bool:
	get:
		return _playable
	set(value):
		button.disabled = not value
		_playable = value

@export_group("Card textures")
@export var item_bg: Texture
@export var enemy_bg: Texture
@export var spell_bg: Texture

var target_pos: Vector2
var target_rot: float
var start_pos: Vector2
var start_rot: float
var current_movement_time: float = 0
var moving: bool = false

func _on_button_pressed() -> void:
	if playable:
		card_used.emit(card, card_id)

func _process(delta: float) -> void:
	if not moving:
		return
	current_movement_time = min(current_movement_time + delta, movement_time)
	global_position = lerp(start_pos, target_pos, current_movement_time / movement_time)
	rotation_degrees = lerp(start_rot, target_rot, current_movement_time / movement_time)
	if current_movement_time >= movement_time:
		global_position = target_pos
		rotation_degrees = target_rot
		moving = false
	

func move_from_to(from_pos: Vector2, from_rot: float, to_pos: Vector2, to_rot: float) -> void:
	start_pos = from_pos
	start_rot = from_rot
	target_pos = to_pos
	target_rot = to_rot
	current_movement_time = 0
	moving = true
	global_position = from_pos
	rotation_degrees = from_rot

func move_to(to_pos: Vector2, to_rot: float) -> void:
	start_pos = global_position
	start_rot = rotation_degrees
	target_pos = to_pos
	target_rot = to_rot
	current_movement_time = 0
	moving = true

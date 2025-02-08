extends Control
class_name PlayableCard

signal card_used(card: Card, playable_id: int)

@onready var name_label: Label = $NameLabel
@onready var health_label: Label = $HealthLabel
@onready var mana_label: Label = $ManaLabel
@onready var description: RichTextLabel = $RichTextLabel

@onready var background: TextureRect = $Background
@onready var item_icon: TextureRect = $Item
@onready var button : Button = $Button


@export var card: Card:
	get:
		return _card
	set(value):
		_card = value
		if value != null:
			name_label.text = value.name
			description.text = value.description
			health_label.text = str(value.health_cost)
			mana_label.text = str(value.mana_cost)
			match value.background:
				Card.BackgroundType.Item:
					background.texture = item_bg
				Card.BackgroundType.Enemy:
					background.texture = enemy_bg
				Card.BackgroundType.Spell:
					background.texture = spell_bg
			item_icon.texture = value.icon

var _card: Card
var _playable : bool = true

@export var card_id: int = -1

var playable : bool:
	get:
		return _playable
	set(value):
		button.disabled = not value
		_playable = value

@export_group("Card textures")
@export var item_bg: Texture
@export var enemy_bg: Texture
@export var spell_bg: Texture

func _on_button_pressed() -> void:
	if playable:
		card_used.emit(card, card_id)

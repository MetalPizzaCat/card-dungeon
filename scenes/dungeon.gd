extends Control


@export var hand_size: int = 5
@export var card_prefab: PackedScene
@export var possible_cards: Array[Card] = []

var used_cards: Array[PlayableCard] = []
var deck: Array[Card] = []
@export var deck_size: int = 6

var playable_cards: Array[PlayableCard] = []

@onready var hand_box: HBoxContainer = $Hand
@onready var player: Player = $Player
@onready var card_spawn_pos: Control = $CardSpawnPos

@onready var deck_size_label: Label = $DeckDisplay/CardsRemainingLabel
@onready var deck_display: Control = $DeckDisplay/InfoBg

@onready var health_display: StatDisplay = $HealthDisplay
@onready var mana_display: StatDisplay = $ManaDisplay

@onready var manager : Manager = get_node("/root/GameManager")

@onready var current_deck_size: int:
	get:
		return _current_deck_size
	set(value):
		_current_deck_size = value
		if deck_size_label != null:
			deck_size_label.text = str(current_deck_size)
		deck_display.visible = value > 0

var _current_deck_size: int

func draw_card() -> bool:
	if possible_cards.is_empty():
		printerr("Can't draw")
		return false
	if current_deck_size <= 0:
		return false
	var card = possible_cards.pick_random()
	var playable = card_prefab.instantiate() as PlayableCard
	hand_box.add_child(playable)
	playable_cards.append(playable)
	playable.card_used.connect(use_card)
	playable.card = card
	current_deck_size -= 1
	
	return true


func _ready() -> void:
	if manager.difficulty != null:
		print("playing: %s" % manager.difficulty.name)
	current_deck_size = deck_size
	draw_initial_cards()
	health_display.max_value = player.max_health
	health_display.current_value = player.health
	mana_display.max_value = player.max_mana
	mana_display.current_value = player.mana

	
func draw_initial_cards() -> void:
	if possible_cards.is_empty():
		printerr("No cards to draw")
		return
	for i in range(hand_size):
		if draw_card():
			_re_id_cards()
		else:
			break
		

func use_card(card: Card, id: int) -> void:
	if card.mana_cost <= player.mana:
		player.apply_effect(card)

	var playable: PlayableCard = playable_cards[id]
	hand_box.remove_child(playable)
	# we need to add visual card into discarded pile
	_add_discarded_card(playable)
	# remove the card from hand
	playable_cards.erase(playable)
	
	_re_id_cards()
	draw_card()

func _add_discarded_card(card: PlayableCard) -> void:
	used_cards.append(card)
	card_spawn_pos.add_child(card)
	card.playable = false
	card.rotation_degrees = randf_range(-70, 120)
	card.position = Vector2(randf_range(-20, 20), randf_range(-20, 20))
	if used_cards.size() > 6:
		card_spawn_pos.remove_child(used_cards[0])
		used_cards[0].queue_free()
		used_cards.remove_at(0)

func _re_id_cards() -> void:
	var i = 0
	for card in playable_cards:
		card.card_id = i
		i += 1


func _on_player_health_changed(health: int) -> void:
	health_display.current_value = health


func _on_player_mana_changed(mana: int) -> void:
	mana_display.current_value = mana


func _on_player_max_health_changed(max_health: int) -> void:
	health_display.max_value = max_health


func _on_player_max_mana_changed(max_mana: int) -> void:
	mana_display.max_value = max_mana

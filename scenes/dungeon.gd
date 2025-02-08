extends Control


@export var hand_size : int = 5
@export var card_prefab : PackedScene
@export var possible_cards : Array[Card] = []

var used_cards : Array[Card] = []
var deck : Array[Card] = []
var player_hand : Array[Card] = []

@onready var hand_box : HBoxContainer = $Hand

func draw_card() -> void:
	pass


func _ready() -> void:
	draw_initial_cards()

	
func draw_initial_cards() -> void:
	if possible_cards.is_empty():
		printerr("No cards to draw")
		return
	for i in range(hand_size):
		var card = possible_cards.pick_random()
		var playable = card_prefab.instantiate() as PlayableCard
		hand_box.add_child(playable)
		playable.card = card
		playable.card_id = i
		

func use_card(card : Card, id : int) -> void:
	if id > deck.size():
		printerr("Attempted to play card outside of player's hand")
	
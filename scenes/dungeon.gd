extends Control


## Max amount of cards that  player can hold
@export var hand_size: int = 5
## How much space should there be from top left corner of one card to the next
@export var space_between_cards : int = 200
## Prefab for the cards that player can interact with
@export var card_prefab: PackedScene
## Prefab used for proper rotation animation for the discarded cards
@export var discarded_card_control_prefab : PackedScene
## What cards to fallback to if no difficultly is selected
@export var possible_cards: Array[Card] = []
## Card to spawn when player is in a very bad position
@export var health_card : Card
## Path to the scene to return on loss/victory. Has to be specified as a path to avoid cyclical dependency in resource
@export_file("*.tscn") var main_scene_path: String

var used_cards: Array[DiscardedCardControl] = []
var deck: Array[Card] = []
var bad_cards : Array[Card] = []

var deck_size: int:
	get:
		return manager.difficulty.deck_size if (manager != null and manager.difficulty != null) else 6

var playable_cards: Array[PlayableCard] = []

@onready var hand_box: Control = $HandPosition
@onready var player: Player = $Player
@onready var card_spawn_pos: Control = $CardSpawnPos

@onready var deck_size_label: Label = $DeckDisplay/CardsRemainingLabel
@onready var deck_display: Control = $DeckDisplay

@onready var health_display: StatDisplay = $HealthDisplay
@onready var mana_display: StatDisplay = $ManaDisplay

@onready var manager: Manager = get_node("/root/GameManager")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var item_sound_player: AudioStreamPlayer = $Sounds/ItemCardSound
@onready var spell_sound_player: AudioStreamPlayer = $Sounds/SpellCardSound
@onready var enemy_sound_player: AudioStreamPlayer = $Sounds/EnemyCardSound

@onready var current_floor_label : Label  = $FloorInfoBox/CurrentFloorLabel
@onready var total_floors_label : Label = $FloorInfoBox/TotalFloorsLabel

@onready var new_card_spawn_pos: Control = $NewCardSpawnPos

@onready var current_deck_size: int:
	get:
		return _current_deck_size
	set(value):
		_current_deck_size = value
		if deck_size_label != null:
			deck_size_label.text = str(current_deck_size)
		deck_display.visible = value > 0

var _current_deck_size: int

var clear_count: int = 0


func draw_card() -> bool:
	if possible_cards.is_empty():
		printerr("Can't draw")
		return false
	if current_deck_size <= 0:
		return false
	var enemy_count = playable_cards.filter(func(p : PlayableCard) : return p.card.background == Card.BackgroundType.ENEMY).size()
	var card_pool : Array[Card] = []
	if enemy_count > 3 and player.health > 3:
		card_pool = possible_cards.filter(func(p : Card) : return p.background == Card.BackgroundType.ITEM)
	elif enemy_count > 2 and player.health < 2:
		card_pool = [health_card]
	elif enemy_count > 3 and player.health < 5 or enemy_count > 1 and player.health < 2:
		card_pool = possible_cards.filter(func(p : Card) : return p.background == Card.BackgroundType.ITEM || p.background == Card.BackgroundType.SPELL)
	else:
		card_pool = possible_cards
	card_pool = card_pool.filter(func(p : Card):return p not in bad_cards)
	if card_pool.is_empty():
		card_pool = [health_card]
	var card = card_pool .pick_random()
	var playable = card_prefab.instantiate() as PlayableCard
	hand_box.add_child(playable)
	playable.move_from_to(
		new_card_spawn_pos.global_position, 
		-90,
		hand_box.global_position + Vector2(playable_cards.size() * space_between_cards, 0), 
		0)
	playable_cards.append(playable)
	playable.card_used.connect(use_card)
	playable.card = card
	current_deck_size -= 1
	return true


func _ready() -> void:
	manager.update_volume()
	animation_player.play("fade_in")
	if manager.difficulty != null:
		print("playing: %s" % manager.difficulty.name)
		possible_cards.clear()
		possible_cards.append_array(manager.difficulty.deck_additions[clear_count].cards)
		total_floors_label.text = str(manager.difficulty.required_deck_clears)
		current_floor_label.text = '1'
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
	for i in range(0, hand_size):
		await get_tree().create_timer(0.1).timeout
		if draw_card():
			_re_id_cards()
		else:
			break
		

func use_card(card: Card, id: int) -> void:
	if card.mana_cost <= player.mana:
		match card.background:
			Card.BackgroundType.ITEM:
				item_sound_player.play()
			Card.BackgroundType.SPELL:
				spell_sound_player.play()
			Card.BackgroundType.ENEMY:
				enemy_sound_player.play()
		if card.effect == Card.Effect.CLEAR_HAND:
			_on_player_hand_clear_used()
			return
	if player.has_duplication:
		player.has_duplication = false
	else:
		var playable: PlayableCard = playable_cards[id]
		# we need to add visual card into discarded pile
		_add_discarded_card(playable)
		# remove the card from hand
		playable_cards.erase(playable)
		_re_id_cards()
		draw_card()
		if playable_cards.is_empty():
			_start_next_round()
	if player.has_fire:
		player.has_fire = false
		bad_cards.append(card)
	if card.mana_cost <= player.mana:
		player.apply_effect(card)


func _start_next_round() -> void:
	animation_player.play("next_round")
	_clear_discarded_cards()
	current_deck_size = deck_size
	clear_count += 1
	current_floor_label.text = str(clear_count + 1)
	if clear_count < manager.difficulty.deck_additions.size():
		possible_cards.append_array(manager.difficulty.deck_additions[clear_count].cards)
	if clear_count >= manager.difficulty.required_deck_clears:
		_end_game()
		return
	used_cards.clear()
	draw_initial_cards()
	

func _end_game() -> void:
	animation_player.play("victory")


func _clear_discarded_cards() -> void:
	for card in used_cards:
		card_spawn_pos.remove_child(card)
		card.queue_free()
	used_cards.clear()

func _add_discarded_card(card: PlayableCard) -> void:
	var start_pos = card.global_position
	hand_box.remove_child(card)
	if discarded_card_control_prefab == null:
		card.queue_free()
		return
	var cntrl = discarded_card_control_prefab.instantiate() as DiscardedCardControl
	cntrl.add_card(card)
	cntrl.global_position = start_pos
	used_cards.append(cntrl)
	card_spawn_pos.add_child(cntrl)
	card.playable = false
	cntrl.move_to(start_pos, 0, card_spawn_pos.global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20)), randf_range(-70, 120))
	
	if used_cards.size() > 6:
		card_spawn_pos.remove_child(used_cards[0])
		used_cards[0].queue_free()
		used_cards.remove_at(0)

func _re_id_cards() -> void:
	var i = 0
	for card in playable_cards:
		if card.card_id != i:
			card.global_position = hand_box.global_position + Vector2(i * space_between_cards, 0)
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


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file(main_scene_path)
	#get_tree().change_scene_to_packed(main_menu_scene)


func _on_player_died() -> void:
	animation_player.play("loss")


func _on_player_hand_clear_used() -> void:
	for card in playable_cards:
		hand_box.remove_child(card)
		_add_discarded_card(card)
	playable_cards.clear()
	draw_initial_cards()
	if playable_cards.is_empty():
		_start_next_round()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(main_scene_path)

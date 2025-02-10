extends Control


@export var hand_size: int = 5
@export var card_prefab: PackedScene
@export var possible_cards: Array[Card] = []
@export_file("*.tscn") var main_scene_path: String

var used_cards: Array[PlayableCard] = []
var deck: Array[Card] = []

var deck_size: int:
	get:
		return manager.difficulty.deck_size if (manager != null and manager.difficulty != null) else 6

var playable_cards: Array[PlayableCard] = []

@onready var hand_box: HBoxContainer = $Hand
@onready var player: Player = $Player
@onready var card_spawn_pos: Control = $CardSpawnPos

@onready var deck_size_label: Label = $DeckDisplay/CardsRemainingLabel
@onready var deck_display: Control = $DeckDisplay/InfoBg

@onready var health_display: StatDisplay = $HealthDisplay
@onready var mana_display: StatDisplay = $ManaDisplay

@onready var manager: Manager = get_node("/root/GameManager")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var item_sound_player : AudioStreamPlayer = $Sounds/ItemCardSound
@onready var spell_sound_player : AudioStreamPlayer = $Sounds/SpellCardSound
@onready var enemy_sound_player : AudioStreamPlayer = $Sounds/EnemyCardSound

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
	var card = possible_cards.pick_random()
	var playable = card_prefab.instantiate() as PlayableCard
	hand_box.add_child(playable)
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
		hand_box.remove_child(playable)
		# we need to add visual card into discarded pile
		_add_discarded_card(playable)
		# remove the card from hand
		playable_cards.erase(playable)
		_re_id_cards()
		draw_card()
		if playable_cards.is_empty():
			_start_next_round()
			
	if card.mana_cost <= player.mana:
		player.apply_effect(card)
	if player.has_fire:
		player.has_fire = false
		possible_cards.erase(card)


func _start_next_round() -> void:
	animation_player.play("next_round")
	_clear_discarded_cards()
	current_deck_size = deck_size
	clear_count += 1
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
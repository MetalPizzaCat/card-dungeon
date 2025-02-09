extends Node
class_name Player
signal died

signal health_changed(health: int)
signal mana_changed(mana: int)
signal max_health_changed(max_health: int)
signal max_mana_changed(max_mana: int)
signal hand_clear_used


@export var max_health: int = 4;


@export var max_mana: int = 4;

var mana: int = 4:
    get:
        return _mana
    set(value):
        _mana = min(max_mana, max(0, value))
        mana_changed.emit(_mana)

var health: int = 4:
    get:
        return _health
    set(value):
        _health = min(max_health, max(0, value))
        health_changed.emit(_health)

var _health: int = 4
var _mana: int = 4


var damage_modifier: int = 1
var max_hp_modifier: int = 0
var has_fire: bool = false
var has_duplication: bool = false
var has_bell: bool = false
var has_shield: bool = false

func add_health(hp: int) -> void:
    health = min(max_health, max(0, health + hp))
    if health <= 0:
        died.emit()

func add_mana(val: int) -> void:
    mana = min(max_mana, max(0, mana + val))

func swap_stats() -> void:
    var h = health
    health = mana
    mana = h

func apply_effect(card: Card) -> void:
    if has_shield:
        has_shield = false
        return
    add_health(-card.health_cost)
    add_mana(-card.mana_cost)
    if has_bell:
        has_bell = false
        return
    match card.effect:
        Card.Effect.NONE:
           return
        Card.Effect.SWAP_HEALTH_AND_MANA:
            swap_stats()
        Card.Effect.INVERT_MANA:
            mana = max_mana - mana
        Card.Effect.ADD_DAMAGE_TO_NEXT_ATTACK:
            damage_modifier += card.damage_modifier
        Card.Effect.SHIELD:
            has_shield = true
        Card.Effect.PREVENT_NEXT_EFFECT:
            has_bell = true
        Card.Effect.DESTROY_NEXT_CARD:
            has_fire = true
        Card.Effect.CLEAR_HAND:
            hand_clear_used.emit()
        Card.Effect.DUPLICATE:
            has_duplication = true
        Card.Effect.ADD_DAMAGE_TO_MAX_HP:
            max_hp_modifier += 2
        Card.Effect.CLEAR_ALL_EFFECTS:
           max_hp_modifier = 0
           damage_modifier = 1
           has_fire = false
           has_duplication = false
           has_bell = false
           has_shield = false
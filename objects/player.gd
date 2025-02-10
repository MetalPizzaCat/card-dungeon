extends Node
class_name Player
signal died

signal health_changed(health: int)
signal mana_changed(mana: int)
signal max_health_changed(max_health: int)
signal max_mana_changed(max_mana: int)


@export var shield_icon: Control
@export var bell_icon: Control
@export var fire_icon: Control
@export var duplicator_icon: Control

@export var max_hp_modifier_label: Label
@export var damage_modifier_label: Label

@export var max_health: int:
    get:
        return _max_health
    set(value):
        _max_health = value
        health = min(max_health, health)
        max_health_changed.emit(value)
        if max_health <= 0:
            died.emit()


@export var max_mana: int:
    get:
        return _max_mana
    set(value):
        _max_mana = value
        mana = min(max_mana, mana)
        max_mana_changed.emit(value)

var mana: int = 5:
    get:
        return _mana
    set(value):
        _mana = min(max_mana, max(0, value))
        mana_changed.emit(_mana)

var health: int = 5:
    get:
        return _health
    set(value):
        _health = min(max_health, max(0, value))
        health_changed.emit(_health)
        if _health <= 0:
            died.emit()

var _health: int = 5
var _mana: int = 5
var _max_health: int = 5
var _max_mana: int = 5
var _has_fire: bool = false
var _has_duplication: bool = false
var _has_bell: bool = false
var _has_shield: bool = false
var _damage_modifier: int = 0
var _max_hp_modifier: int = 0


var damage_modifier: int = 0:
    get:
        return _damage_modifier
    set(value):
        _damage_modifier = value
        if damage_modifier_label != null:
            damage_modifier_label.text = str(value)


var max_hp_modifier: int = 0:
    get:
        return _max_hp_modifier
    set(value):
        _max_hp_modifier = value
        if max_hp_modifier_label != null:
            max_hp_modifier_label.text = str(value)


var has_fire: bool:
    get:
        return _has_fire
    set(value):
        _has_fire = value
        if fire_icon != null:
            fire_icon.visible = value


var has_duplication: bool:
    get:
        return _has_duplication
    set(value):
        _has_duplication = value
        if duplicator_icon != null:
            duplicator_icon.visible = value

        
var has_bell: bool:
    get:
        return _has_bell
    set(value):
        _has_bell = value
        if bell_icon != null:
            bell_icon.visible = value


var has_shield: bool:
    get:
        return _has_shield
    set(value):
        _has_shield = value
        if shield_icon != null:
            shield_icon.visible = value


func swap_stats() -> void:
    var h = health
    health = mana
    mana = h
    if health <= 0:
        died.emit()

func get_save_data() -> Dictionary:
    return {
        "damage_modifier": damage_modifier,
        "max_hp_modifier": max_hp_modifier,
        "has_fire": has_fire,
        "has_duplication": has_duplication,
        "has_bell": has_bell,
        "has_shield": has_shield,
        "health": health,
        "max_health": max_health,
        "mana": mana,
        "max_mana": max_mana
    }

func apply_effect(card: Card) -> void:
    if has_shield:
        has_shield = false
        return
    if card.health_cost > 0:
        health -= (card.health_cost + damage_modifier)
    else:
        health -= card.health_cost
    mana -= card.mana_cost

    if card.max_hp_change < 0:
        max_health += card.max_hp_change - max_hp_modifier
    else:
        max_health += card.max_hp_change
    max_mana += card.max_mp_change

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
            return
            #hand_clear_used.emit()
        Card.Effect.DUPLICATE:
            has_duplication = true
        Card.Effect.ADD_DAMAGE_TO_MAX_HP:
            max_hp_modifier += 2
        Card.Effect.CLEAR_ALL_EFFECTS:
           max_hp_modifier = 0
           damage_modifier = 0
           has_fire = false
           has_duplication = false
           has_bell = false
           has_shield = false
extends Node
class_name Player
signal died

@export var health: int = 4;
@export var max_health: int = 4;

@export var mana: int = 4;
@export var max_mana: int = 4;

func add_health(hp: int) -> void:
    health = min(max_health, max(0, health + hp))
    if health <= 0:
        died.emit()

func add_mana(val : int) -> void:
    mana = min(max_mana, max(0, mana + val))
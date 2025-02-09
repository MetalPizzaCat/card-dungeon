extends Resource

class_name Card

enum Effect {
    NONE,
    SWAP_HEALTH_AND_MANA,
    INVERT_MANA,
    ADD_DAMAGE_TO_NEXT_ATTACK,
    SHIELD,
    PREVENT_NEXT_EFFECT,
    DESTROY_NEXT_CARD,
    CLEAR_HAND,
    DUPLICATE,
    ADD_DAMAGE_TO_MAX_HP,
    CLEAR_ALL_EFFECTS
}

enum BackgroundType{
    Item,
    Enemy,
    Spell
}

@export var name: String = "MISSINGNAME"
@export var description : String

@export var health_cost: int = 0
@export var mana_cost: int = 0

@export var effect : Effect = Effect.NONE

@export var background : BackgroundType = BackgroundType.Item
@export var icon : Texture

@export_group("Special")
@export var max_hp_change : int = 0
@export var max_mp_change : int = 0
@export var damage_modifier : int = 0

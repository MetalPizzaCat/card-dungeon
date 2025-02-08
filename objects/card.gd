extends Resource

class_name Card

enum Effect {
    
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

@export var background : BackgroundType = BackgroundType.Item
@export var icon : Texture
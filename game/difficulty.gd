extends Resource
class_name Difficulty


@export var name: String = "Easy"
@export var description: String = ""

@export var deck_size : int = 12

@export var required_deck_clears : int = 4

## Additions to the global deck after each clear. First addition is used as the initial deck,
## while further additions are only for expansion [br]
## Additions after `required_deck_clears` are ignored
@export var deck_additions : Array[Deck] = []
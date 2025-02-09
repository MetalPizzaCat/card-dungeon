extends Button
class_name DifficultyButton

signal selected(difficulty : Difficulty)

var difficulty : Difficulty:
    get:
        return _difficulty
    set(value):
        _difficulty = value
        text = value.name

var _difficulty : Difficulty

func _ready() -> void:
    pressed.connect(_selected)

func _selected() -> void:
    selected.emit(difficulty)
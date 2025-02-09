extends Control

@export var difficulties : Array[Difficulty] = []

@onready var options_box : VBoxContainer = $OptionsContainer

var buttons : Array[DifficultyButton] = []

func _ready() -> void:
	for option in difficulties:
		var btn = DifficultyButton.new()
		options_box.add_child(btn)
		buttons.append(btn)
		btn.difficulty = option
		
		


func _on_exit_button_pressed() -> void:
	get_tree().quit()

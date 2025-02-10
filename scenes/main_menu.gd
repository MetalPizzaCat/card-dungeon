extends Control

@export var difficulties : Array[Difficulty] = []
@export var card_scene : PackedScene

@onready var options_box : VBoxContainer = $OptionsContainer/DifficultyOptions

@onready var manager : Manager = get_node("/root/GameManager")
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var unlocked_difficulties : int = 0

var buttons : Array[DifficultyButton] = []

func _ready() -> void:
	for option in difficulties:
		var btn = DifficultyButton.new()
		options_box.add_child(btn)
		buttons.append(btn)
		btn.difficulty = option
		btn.selected.connect(_difficulty_selected)
		

func _difficulty_selected(diff : Difficulty) -> void:
	manager.difficulty = diff
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(card_scene)


func _on_exit_button_pressed() -> void:
	get_tree().quit()

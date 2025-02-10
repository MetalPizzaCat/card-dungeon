extends Control

@onready var music_button: Button = $MusicButton
@onready var sound_button: Button = $SoundButton


@onready var manager: Manager = get_node("/root/GameManager")

func _on_sound_button_pressed() -> void:
	match manager.sound_volume:
		Manager.Volume.NORMAL:
			manager.sound_volume = Manager.Volume.LOW
			sound_button.text = "Low"
		Manager.Volume.LOW:
			manager.sound_volume = Manager.Volume.MUTED
			sound_button.text = "Mute"
		Manager.Volume.MUTED:
			manager.sound_volume = Manager.Volume.NORMAL
			sound_button.text = "High"
	manager.update_volume()

func _on_music_button_pressed() -> void:
	match manager.music_volume:
		Manager.Volume.NORMAL:
			manager.music_volume = Manager.Volume.LOW
			music_button.text = "Low"
		Manager.Volume.LOW:
			manager.music_volume = Manager.Volume.MUTED
			music_button.text = "Mute"
		Manager.Volume.MUTED:
			manager.music_volume = Manager.Volume.NORMAL
			music_button.text = "High"
	manager.update_volume()

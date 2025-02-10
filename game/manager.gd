extends Node
class_name Manager


enum Volume {
	NORMAL,
	LOW,
	MUTED
}

var difficulty: Difficulty = null


var normal_volume: float = 0
var low_volume: float = -12

var music_volume: Volume = Volume.NORMAL
var sound_volume: Volume = Volume.NORMAL

@onready var sound_bus_id: int = AudioServer.get_bus_index("Sound")
@onready var music_bus_id: int = AudioServer.get_bus_index("Music")

func update_volume() -> void:
    _update_volume_for_channel(sound_bus_id, sound_volume)
    _update_volume_for_channel(music_bus_id, music_volume)

func _update_volume_for_channel(bus_id: int, volume: Volume) -> void:
    match volume:
        Volume.NORMAL:
            AudioServer.set_bus_mute(bus_id, false)
            AudioServer.set_bus_volume_db(bus_id, normal_volume)
        Volume.LOW:
            AudioServer.set_bus_mute(bus_id, false)
            AudioServer.set_bus_volume_db(bus_id, low_volume)
        Volume.MUTED:
             AudioServer.set_bus_mute(bus_id, true)
extends Node

var music_volume : float = 1.0
var sfx_volume : float = 1.0

@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var sfx_bus_id = AudioServer.get_bus_index("SFX")

func _ready() -> void:
	load_settings()
	apply_settings()

func set_music_volume(volume : float) -> void:
	music_volume = volume
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(music_volume))
	AudioServer.set_bus_mute(music_bus_id, music_volume < 0.05)
	
	save_settings()

func set_sfx_volume(volume : float) -> void:
	sfx_volume = volume
	AudioServer.set_bus_volume_db(sfx_bus_id, linear_to_db(sfx_volume))
	AudioServer.set_bus_mute(sfx_bus_id, sfx_volume < 0.05)
	
	save_settings()
	
func apply_settings() -> void:
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)

func save_settings() -> void:
	SettingsManager.settings["volume"] = {
		"music_volume" : music_volume,
		"sfx_volume" : sfx_volume
	}
	SettingsManager.save_settings()

func load_settings() -> void:
	var volume_settings = SettingsManager.settings["volume"]
	music_volume = volume_settings["music_volume"]
	sfx_volume = volume_settings["sfx_volume"]
	

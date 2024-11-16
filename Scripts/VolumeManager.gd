extends Node

var music_volume : float = 1.0
var sfx_volume : float = 1.0

@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var sfx_bus_id = AudioServer.get_bus_index("SFX")

const SETTINGS_PATH = "user://audio_settings.json"

var json_instance = JSON.new()

func _ready() -> void:
	apply_settings()

func set_music_volume(volume : float) -> void:
	music_volume = volume
	AudioServer.set_bus_volume_db(music_bus_id, linear_to_db(music_volume))
	AudioServer.set_bus_mute(music_bus_id, music_volume < 0.05)

func set_sfx_volume(volume : float) -> void:
	sfx_volume = volume
	AudioServer.set_bus_volume_db(sfx_bus_id, linear_to_db(sfx_volume))
	AudioServer.set_bus_mute(sfx_bus_id, sfx_volume < 0.05)
	
func apply_settings() -> void:
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		var settings = {
			"music_volume" : music_volume,
			"sfx_volume" : sfx_volume
		}
		file.store_string(JSON.stringify(settings))
		file.close()

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if file:
			var result = json_instance.parse(file.get_as_text())
			if result.error == OK:
				var settings = result.result
				if settings.has("music_volume"):
					music_volume = settings["music_volume"]
				if settings.has("sfx_volume"):
					sfx_volume = settings["sfx_volume"]
		file.close()

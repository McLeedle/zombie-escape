extends Node

const SETTINGS_PATH = "user://settings.cfg"

var settings = {
	"volume" : {
		"music_volume" : 1.0,
		"sfx_volume" : 1.0
	},
	"display" : {
		"resolution_index" : 0,
		"fullscreen" : false
	}
}

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			if parsed.error == OK:
				settings = parsed.result
			file.close()
		else:
			print("Failed to load settings file.")

func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))
		file.close()
	else:
		print("Failed to save settings file")

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

func ensure_directory_exists():
	# Get the user data directory (Platform dependent)
	var user_data_dir = OS.get_user_data_dir()
	
	# Make sure the path is properly formatted
	var settings_dir = user_data_dir.plus_file("Zombie Escape")
	
	var dir = DirAccess.open(settings_dir)
	if not dir.dir_exists(settings_dir):
		# If the directory doesn't exist, create it
		dir.make_dir(settings_dir)
		
func save_settings() -> void:
	ensure_directory_exists() # Ensure the directory exists
	
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))
		file.close()
	else:
		print("Failed to save settings file")

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

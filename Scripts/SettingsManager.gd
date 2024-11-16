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

var is_initialized = false # Prevent saving before initialization
signal settings_ready

func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			
			var parsed = JSON.parse_string(content)
			if parsed != null:
				settings = parsed
				print("Settings loaded successfully.")
				apply_window_settings()  # Apply window settings immediately after loading
			else:
				print("Failed to parse settings file: Invalid JSON format.")
		else:
			print("Failed to open settings file.")
	else:
		print("Settings file not found at: ", SETTINGS_PATH)
	
	# Apply settings after loading them
	apply_window_settings()
	
	VolumeManager.set_music_volume(settings["volume"]["music_volume"])
	VolumeManager.set_sfx_volume(settings["volume"]["sfx_volume"])
	
	is_initialized = true
	emit_signal("settings_ready")


func save_settings() -> void:
	if not is_initialized:
		print("SettingsManager: Initialization incomplete, skipping save.")
		return
		
	ensure_directory_exists()  # Ensure the directory exists

	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))
		file.close()
		print("Settings saved successfully.")
	else:
		print("Failed to save settings file.")

func ensure_directory_exists():
	# Get the user data directory (platform dependent)
	var user_data_dir = OS.get_user_data_dir()

	# Manually combine paths using string concatenation or Directory functions
	var settings_dir = user_data_dir

	# Log the directory path for debugging
	print("Checking for directory: ", settings_dir)

	# Open the directory and check if it exists
	var dir = DirAccess.open(user_data_dir)  # Open the base directory
	if not dir.dir_exists(settings_dir):
		# If the directory doesn't exist, create it
		if dir.make_dir(settings_dir) == OK:
			print("Directory created: ", settings_dir)
		else:
			print("Failed to create directory.")
	else:
		print("Directory exists: ", settings_dir)

# Function to apply the resolution and fullscreen settings after loading
func apply_window_settings() -> void:
	# Load resolution settings
	var resolution_index = settings["display"]["resolution_index"]
	var fullscreen = settings["display"]["fullscreen"]

	# Define possible resolutions
	var resolutions = [
		Vector2(1280, 720),  # 720p
		Vector2(1920, 1080)  # 1080p
	]

	# Apply the resolution
	if resolution_index >= 0 and resolution_index < resolutions.size():
		DisplayServer.window_set_size(resolutions[resolution_index])
		print("Applied resolution: ", resolutions[resolution_index])

	# Apply fullscreen mode
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		print("Applied fullscreen mode.")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		print("Applied windowed mode.")

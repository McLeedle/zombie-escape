extends Node

# List of resolutions
var resolutions = [
	Vector2(1280, 720),
	Vector2(1920, 1080)
]

var current_resolution_index : int = 0
var is_fullscreen : bool = false

func _ready() -> void:
	await SettingsManager.settings_ready
	# Load saved settings from SettingsManager
	load_settings()
	apply_window_settings()

func load_settings() -> void:
	var display_settings = SettingsManager.settings["display"]
	current_resolution_index = display_settings["resolution_index"]
	is_fullscreen = display_settings["fullscreen"]	

func apply_window_settings():
	DisplayServer.window_set_size(resolutions[current_resolution_index])
	
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func set_resolution(index : int) -> void:
	if index >= 0 and index < resolutions.size():
		current_resolution_index = index
		DisplayServer.window_set_size(resolutions[current_resolution_index])
		save_settings()
		
func set_fullscreen(enabled : bool) -> void:
	is_fullscreen = enabled
	if is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()

func get_current_resolution_index() -> int:
	return current_resolution_index

func is_fullscreen_mode() -> bool:
	return is_fullscreen

func save_settings() -> void:
	SettingsManager.settings["display"] = {
		"resolution_index" : current_resolution_index,
		"fullscreen" : is_fullscreen
	}
	SettingsManager.save_settings()

extends Control

@onready var menu_music : AudioStreamPlayer = get_node("MenuMusic")
@onready var resolution_dropdown : OptionButton = get_node("Panel/ScreenSettings/ResolutionDropdown")
@onready var fullscreen_checkbox : CheckBox = get_node("Panel/ScreenSettings/CheckBox")
@onready var music_slider : HSlider = get_node("Panel/MusicSlider")
@onready var sfx_slider : HSlider = get_node("Panel/SFXSlider")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu_music.stream.loop = true
	menu_music.play()

	# Load settings first
	SettingsManager.load_settings()

	# Disconnect signals to avoid accidental saves
	music_slider.disconnect("value_changed", Callable(self, "_on_music_slider_value_changed"))
	sfx_slider.disconnect("value_changed", Callable(self, "_on_sfx_slider_value_changed"))
	resolution_dropdown.disconnect("item_selected", Callable(self, "_on_resolution_dropdown_item_selected"))
	fullscreen_checkbox.disconnect("toggled", Callable(self, "_on_fullscreen_checkbox_toggled"))

	# Set UI elements based on loaded settings
	music_slider.value = SettingsManager.settings["volume"]["music_volume"]
	sfx_slider.value = SettingsManager.settings["volume"]["sfx_volume"]

	# Populate resolution dropdown
	for res in DisplayManager.resolutions:
		resolution_dropdown.add_item(str(res.x) + "x" + str(res.y))

	resolution_dropdown.select(DisplayManager.get_current_resolution_index())
	print("Resolution Dropdown Index: ", DisplayManager.get_current_resolution_index())  # Debug print
	fullscreen_checkbox.set_pressed(DisplayManager.is_fullscreen_mode())
	print("Fullscreen Mode: ", DisplayManager.is_fullscreen_mode())  # Debug print

	# Reconnect signals after initialization
	music_slider.connect("value_changed", Callable(self, "_on_music_slider_value_changed"))
	sfx_slider.connect("value_changed", Callable(self, "_on_sfx_slider_value_changed"))
	resolution_dropdown.connect("item_selected", Callable(self, "_on_resolution_dropdown_item_selected"))
	fullscreen_checkbox.connect("toggled", Callable(self, "_on_fullscreen_checkbox_toggled"))


func _on_resolution_dropdown_item_selected(index : int) -> void:
	DisplayManager.set_resolution(index)
	SettingsManager.save_settings()

func _on_fullscreen_checkbox_toggled(pressed : bool) -> void:
	DisplayManager.set_fullscreen(pressed)
	SettingsManager.save_settings()

func _on_music_slider_value_changed(value: float) -> void:
	SettingsManager.settings["volume"]["music_volume"] = value
	VolumeManager.set_music_volume(value)
	
func _on_sfx_slider_value_changed(value: float) -> void:
	SettingsManager.settings["volume"]["sfx_volume"] = value
	VolumeManager.set_sfx_volume(value)
	
func _on_normal_button_pressed() -> void:
	DifficultyManager.difficulty = DifficultyManager.Difficulty.NORMAL
	start_game()

func _on_hard_button_pressed() -> void:
	DifficultyManager.difficulty = DifficultyManager.Difficulty.HARD
	start_game()

func _on_impossible_button_pressed() -> void:
	DifficultyManager.difficulty = DifficultyManager.Difficulty.IMPOSSIBLE
	start_game()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func start_game() -> void:
	menu_music.stop()
	get_tree().change_scene_to_file("res://Scenes/Levels/main.tscn")
	SettingsManager.load_volume_settings()

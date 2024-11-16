extends Control

@onready var menu_music : AudioStreamPlayer = get_node("MenuMusic")
@onready var resolution_dropdown : OptionButton = get_node("Panel/ScreenSettings/ResolutionDropdown")
@onready var fullscreen_checkbox : CheckBox = get_node("Panel/ScreenSettings/CheckBox")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu_music.stream.loop = true
	menu_music.play()
	
	for res in DisplayManager.resolutions:
		resolution_dropdown.add_item(str(res.x) + "x" + str(res.y))
	
	resolution_dropdown.select(DisplayManager.get_current_resolution_index())
	fullscreen_checkbox.set_pressed(DisplayManager.is_fullscreen_mode())

func _on_resolution_dropdown_item_selected(index : int) -> void:
	DisplayManager.set_resolution(index)
	SettingsManager.save_settings()

func _on_fullscreen_checkbox_toggled(pressed : bool) -> void:
	DisplayManager.set_fullscreen(pressed)
	SettingsManager.save_settings()

func _on_music_slider_value_changed(value: float) -> void:
	VolumeManager.set_music_volume(value)
	
func _on_sfx_slider_value_changed(value: float) -> void:
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

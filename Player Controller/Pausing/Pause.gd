extends Node

@onready var pause_panel : Panel = get_node("Panel")
@onready var music_slider : HSlider = get_node("Panel/MusicSlider")
@onready var sfx_slider : HSlider = get_node("Panel/SFXSlider")

var is_paused : bool = false

func _ready() -> void:
	SettingsManager.load_settings()
	music_slider.value = SettingsManager.settings["volume"]["music_volume"]
	sfx_slider.value = SettingsManager.settings["volume"]["sfx_volume"]
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()
		
func toggle_pause() -> void:
	if is_paused:
		unpause()
	else:
		pause()

func pause():
	is_paused = true
	pause_panel.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Engine.time_scale = 0
	
	SettingsManager.load_settings()
	VolumeManager.set_music_volume(SettingsManager.settings["volume"]["music_volume"])
	VolumeManager.set_sfx_volume(SettingsManager.settings["volume"]["sfx_volume"])

func unpause():
	is_paused = false
	pause_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Engine.time_scale = 1

func _on_music_slider_value_changed(value : float) -> void:
	SettingsManager.settings["volume"]["music_volume"] = value
	VolumeManager.set_music_volume(value)
	SettingsManager.save_settings()
	
func _on_sfx_slider_value_changed(value : float) -> void:
	SettingsManager.settings["volume"]["sfx_volume"] = value
	VolumeManager.set_sfx_volume(value)
	SettingsManager.save_settings()

func _on_resume_button_pressed() -> void:
	unpause()

func _on_main_menu_button_pressed() -> void:
	SettingsManager.save_settings()
	get_tree().change_scene_to_file("res://Scenes/Levels/menu.tscn")

func _on_quit_button_pressed() -> void:
	SettingsManager.save_settings()
	get_tree().quit()

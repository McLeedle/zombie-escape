extends Control

@onready var menu_music: AudioStreamPlayer = get_node("MenuMusic")
@onready var menu_music_stream : AudioStream = menu_music.stream

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	menu_music_stream.loop = true
	menu_music.play()

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

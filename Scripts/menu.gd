extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
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
	get_tree().change_scene_to_file("res://Scenes/Levels/main.tscn")

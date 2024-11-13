extends Control

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/main.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

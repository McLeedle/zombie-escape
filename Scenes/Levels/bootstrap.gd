extends Node

func _ready() -> void:
	print("Bootstrap: Initializing settings...")
	SettingsManager.load_settings()
	print("Settings after loading: ", SettingsManager.settings)
	call_deferred("change_to_main_menu")

func change_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/menu.tscn")

extends Node

@export var key_item : Item
@export var keys_to_win : int = 1

@onready var info_text : Label = get_node("InfoText")
@onready var win_screen : Panel = get_node("WinScreen")
@onready var lose_screen : Panel = get_node("LoseScreen")
@onready var inventory : Inventory = get_node("Player/Inventory")
@onready var enemy_spawner : Node = get_node("EnemySpawner")

var game_over : bool = false

func _ready() -> void:
	Engine.time_scale = 1
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_info_text()
	GlobalSignals.connect("item_collected", Callable(self, "_on_item_collected"))
	
func _on_item_collected(_item: Item):
		update_info_text()
		
		if inventory.get_number_of_item(key_item) >= keys_to_win:
			GlobalSignals.car_key_collected.emit()
	
func update_info_text():
	info_text.text = "Find your Car Keys."
	var _key_count = inventory.get_number_of_item(key_item)
	
	if inventory.get_number_of_item(key_item) == keys_to_win:
		info_text.text = "Get back to your Car."
	
func win_game():
	game_over = true
	win_screen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Engine.time_scale = 0

func lose_game():
	game_over = true
	lose_screen.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Engine.time_scale = 0

func _on_play_again_button_pressed() -> void:
	enemy_spawner.enemies_spawned = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_q_play_again_button_pressed() -> void:
	enemy_spawner.enemies_spawned = false
	get_tree().reload_current_scene()

func _on_q_quit_button_pressed() -> void:
	get_tree().quit()

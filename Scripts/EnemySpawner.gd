extends Node

var enemies_spawned : bool = false

@export var normal_spawn_positions : Array = [Vector3(-1.543, 0.095, -25.62)]
@export var hard_spawn_positions : Array = [Vector3(-1.543, 0.095, -25.62), Vector3(-26.81, 0.095, 0.521)]
@export var impossible_spawn_positions : Array = [Vector3(-1.543, 0.095, -25.62), Vector3(-26.81, 0.095, 0.521), Vector3(32.416, 0.095, 24.278)]

@onready var zombie_scene : PackedScene = preload("res://Scenes/Actors/zombie.tscn")

func _ready() -> void:
	if not enemies_spawned:
		spawn_enemies()

func spawn_enemies():
	if enemies_spawned:
		print("Enemies already spawned. Skipping.")
		return
		
	print("Spawning enemies...")
	var spawn_positions : Array
	
	match DifficultyManager.difficulty:
		DifficultyManager.Difficulty.NORMAL:
			spawn_positions = normal_spawn_positions
		DifficultyManager.Difficulty.HARD:
			spawn_positions = hard_spawn_positions
		DifficultyManager.Difficulty.IMPOSSIBLE:
			spawn_positions = impossible_spawn_positions
	
	for pos in spawn_positions:
		var zombie = zombie_scene.instantiate()
		zombie.position = pos
		add_child(zombie)
	
	enemies_spawned = true
	print("Enemies spawned successfully.")

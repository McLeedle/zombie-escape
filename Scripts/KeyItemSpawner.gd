extends Node3D

@export var normal_key_positions : Array = [Vector3(-6.869, 0.064, -26.12)]
@export var hard_key_positions : Array = [Vector3(-6.869, 0.064, -26.12), Vector3(-0.881, 0.064, -21.70), Vector3(22.477, 0.064, -3.211)]
@export var impossible_key_positions : Array = [Vector3(-6.869, 0.064, -26.12), Vector3(-0.881, 0.064, -21.70), Vector3(22.477, 0.064, -3.211), Vector3(24.656, 0.064, 12.88), Vector3(-31.06, 0.064, -1.874), Vector3(-11.81, 0.064, -31.26)]

@onready var key_item_scene : PackedScene = preload("res://Items/World Items/WorldItem_Keys.tscn")

var key_item_spawned : bool = false
var key_item_scale : Vector3 = Vector3(0.12, 0.12, 0.12)

func _ready() -> void:
	if not key_item_spawned:
		spawn_key_item()

func spawn_key_item() -> void:
	if key_item_spawned:
		print("Key item already spawned. Skipping.")
		return
	
	print("Spawning key item...")
	var key_positions : Array
	
	match  DifficultyManager.difficulty:
		DifficultyManager.Difficulty.NORMAL:
			key_positions = normal_key_positions
		DifficultyManager.Difficulty.HARD:
			key_positions = hard_key_positions
		DifficultyManager.Difficulty.IMPOSSIBLE:
			key_positions = impossible_key_positions
	
	# Pick a random spawn position from the list of available positions for the current difficutly
	var spawn_position = key_positions[randi() % key_positions.size()]
	
	# Instantiate the key item scene and set its position
	var key_item = key_item_scene.instantiate()
	key_item.position = spawn_position
	
	# Apply the scale to the key item
	key_item.scale = key_item_scale
	
	# Add it to the scene
	add_child(key_item)
	
	key_item_spawned = true
	print("Key item spawned successfully.")

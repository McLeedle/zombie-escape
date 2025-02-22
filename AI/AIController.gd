class_name AIController
extends CharacterBody3D

@export var walk_speed : float = 1.0
@export var run_speed : float = 2.5

var running : bool = false
var is_stopped : bool = false
var look_at_player : bool = false
var game_over_triggered : bool = false

var move_direction : Vector3
var target_y_rot : float

@onready var agent : NavigationAgent3D = get_node("NavigationAgent3D")
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player : PlayerController = get_tree().get_nodes_in_group("Player")[0]
@onready var anim_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var raycast : RayCast3D = get_node("RayCast3D")
@onready var game_over = get_node("/root/Main")

# Audio References
@onready var breathing_sound : AudioStreamPlayer3D = get_node("Breathing")
@onready var running_sound : AudioStreamPlayer3D = get_node("Running")
@onready var grunt_sound : AudioStreamPlayer3D = get_node("Grunt")
@onready var gasp_sound : AudioStreamPlayer3D = get_node("Gasp")
var breathing_sound_stream : AudioStreamOggVorbis
var running_sound_stream : AudioStreamOggVorbis
var grunt_sound_stream : AudioStreamOggVorbis
var gasp_sound_stream : AudioStreamOggVorbis

var player_distance : float
var stuck_timer : float = 0.0
var stuck_threshold : float = 1.0

func _ready() -> void:
	game_over_triggered = false
	setup_audio_stream()

func _process(_delta):
	if player:
		player_distance = position.distance_to(player.position)

func _physics_process(_delta):
	# If the AI's velocity is small or zero, increase the stuck timer
	if velocity.length() < 0.1:
		stuck_timer += _delta
	else:
		stuck_timer = 0
	
	# check for obstacles using raycasting
	if raycast.is_colliding():
		stuck_timer += _delta
	
	# If the AI hasn't moved for a while (and is colliding), handle stuck behavior
	if stuck_timer > stuck_threshold:
		handle_stuck_behavior()
	
	# Apply gravity.
	if not is_on_floor():
		velocity.y -= gravity * _delta
	
	var target_pos = agent.get_next_path_position()
	var move_dir = global_position.direction_to(target_pos)
	move_dir.y = 0
	move_dir = move_dir.normalized()
	
	# Don't move if we're done with navigation or is stopped.
	if agent.is_navigation_finished() or is_stopped:
		move_dir = Vector3.ZERO
	
	var current_speed = walk_speed
	
	if running:
		current_speed = run_speed
	
	# Set velocity.
	velocity.x = move_dir.x * current_speed
	velocity.z = move_dir.z * current_speed
	
	# Rotate to velocity or player.
	if !look_at_player and velocity.length() > 0:
		target_y_rot = atan2(velocity.x, velocity.z)
	elif look_at_player:
		var player_dir = (player.position - position)
		target_y_rot = atan2(player_dir.x, player_dir.z)
	
	rotation.y = lerp_angle(rotation.y, target_y_rot, 0.1)
	
	move_and_slide()
	

func handle_stuck_behavior():
	reset_navigation()
	
func reset_navigation():
	# Calculate new path
	var new_target = get_new_target_position()
	move_to_position(new_target)
	
func get_new_target_position() -> Vector3:
	var random_offset = Vector3(randf_range(-5,5), 0, randf_range(-5,5))
	var new_position = player.position + random_offset
	return new_position
	
func move_to_position(to_position : Vector3, _adjust_pos : bool = true):
	if not agent:
		agent = get_node("NavigationAgent3D")
		
	is_stopped = false
	
	var map = get_world_3d().navigation_map
	var adjusted_to_position = NavigationServer3D.map_get_closest_point(map, to_position)
	agent.target_position = adjusted_to_position
	agent.target_position = to_position

func play_walk_animation():
	anim_player.play("Walk")

func play_run_animation():
	anim_player.play("Run")

func setup_audio_stream():
	# Load the audio stream resources
	breathing_sound.stream.loop = true
	running_sound.stream.loop = true
	breathing_sound.play()
	running_sound.play()
		
func handle_player_caught():
	if gasp_sound.is_playing():
		return
	if gasp_sound:
		gasp_sound.play()

func _on_gasp_finished() -> void:
	lose_game()

func lose_game():
	game_over_triggered = true
	stop_all_audio()
	game_over.lose_game()

func stop_all_audio():
	if breathing_sound.is_playing():
		breathing_sound.stop()
	if running_sound.is_playing():
		running_sound.stop()
	if grunt_sound.is_playing():
		grunt_sound.stop()
	if gasp_sound.is_playing():
		gasp_sound.stop()

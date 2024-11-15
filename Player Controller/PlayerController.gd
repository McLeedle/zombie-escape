class_name PlayerController
extends CharacterBody3D

@export_group("Movement")
@export var max_speed : float = 4.0
@export var acceleration : float = 20.0
@export var braking : float = 20.0
@export var air_acceleration : float = 4.0
@export var jump_force : float = 5.0
@export var gravity_modifier : float = 1.5
@export var max_run_speed : float = 6.0

@export_group("Camera")
@export var look_sensitivity : float = 0.005

var is_running : bool = false
var camera_look_input : Vector2

# Node References
@onready var camera : Camera3D = get_node("Camera3D")
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier
@onready var flashlight_light : SpotLight3D = get_node("Camera3D/flashlight/SpotLight3D")

# Sound Node References
@onready var breath_normal : AudioStreamPlayer3D = get_node("BreathNormal")
@onready var breath_run : AudioStreamPlayer3D = get_node("BreathRun")
@onready var footsteps_walk : AudioStreamPlayer3D = get_node("FootstepsWalk")
@onready var footsteps_run : AudioStreamPlayer3D = get_node("FootstepsRun")
@onready var flashlight_off : AudioStreamPlayer3D = get_node("FlashlightOff")
@onready var flashlight_on : AudioStreamPlayer3D = get_node("FlashlightOn")

var breath_normal_stream : AudioStreamOggVorbis
var breath_run_stream : AudioStreamOggVorbis
var footsteps_walk_stream : AudioStreamOggVorbis
var footsteps_run_stream : AudioStreamOggVorbis

var is_playing_breath_normal : bool = false
var is_playing_breath_run : bool = false
var is_playing_footsteps_walk : bool = false
var is_playing_footsteps_run : bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	setup_audio_stream()
	stop_playing_audio()
	
	# Start the breath_normal sound when the game begins (player is still)
	if not breath_normal.playing:
		breath_normal.play()
		is_playing_breath_normal = true

func setup_audio_stream() -> void:
	# Load the audio stream resources
	breath_normal_stream = load("res://Assets/Audio/SFX/OGG/Breathing_slow.ogg")
	breath_run_stream = load("res://Assets/Audio/SFX/OGG/Breathing_fast.ogg")
	footsteps_walk_stream = load("res://Assets/Audio/SFX/OGG/Footsteps_walking.ogg")
	footsteps_run_stream = load("res://Assets/Audio/SFX/OGG/Footsteps_running.ogg")
	
	# Assign the stream to the AudioStreamPlayer3D nodes
	breath_normal.stream = breath_normal_stream
	breath_run.stream = breath_run_stream
	footsteps_walk.stream = footsteps_walk_stream
	footsteps_run.stream = footsteps_run_stream
		
	# Set the loop property on the AudioStream resource
	breath_normal_stream.loop = true
	breath_run_stream.loop = true
	footsteps_walk_stream.loop = true
	footsteps_run_stream.loop = true

func stop_playing_audio() -> void:
	breath_normal.stop()
	breath_run.stop()
	footsteps_walk.stop()
	footsteps_run.stop()
	
	# Reset flags
	is_playing_breath_normal = false
	is_playing_breath_run = false
	is_playing_footsteps_walk = false
	is_playing_footsteps_run = false
	
func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	if Input.is_action_just_pressed("flashlight"):
		if flashlight_light.visible == true:
			flashlight_light.visible = false
			flashlight_off.position = global_position
			flashlight_off.play()
		else:
			flashlight_light.visible = true
			flashlight_on.position = global_position
			flashlight_on.play()
		
	# Movement
	var move_input = Input.get_vector("move_left","move_right","move_forward","move_backward")
	var move_dir = (transform.basis * Vector3(move_input.x, 0, move_input.y)).normalized()
	
	is_running = Input.is_action_pressed("sprint")
	
	var target_speed = max_speed
	
	if is_running:
		target_speed = max_run_speed
		var run_dot = -move_dir.dot(transform.basis.z)
		run_dot = clamp(run_dot, 0, 1)
		move_dir *= run_dot
		
		# Update position of audio players
		update_audio_positions()
		
		# Play running sounds, but only if they aren't already playing
		if not breath_run.playing:
			breath_run.play()
			is_playing_breath_run = true
		if not footsteps_run.playing:
			footsteps_run.play()
			is_playing_footsteps_run = true
		
		# Stop walking sounds if running
		if breath_normal.playing:
			breath_normal.stop()
			is_playing_breath_normal = false
		if footsteps_walk.playing:
			footsteps_walk.stop()
			is_playing_footsteps_walk = false
		
	else:
		# Update position of audio players
		update_audio_positions()
		
		if move_dir.length() > 0:
			if not breath_normal.playing:
				breath_normal.play()
				is_playing_breath_normal = true
			if not footsteps_walk.playing:
				footsteps_walk.play()
				is_playing_footsteps_walk = true
		
		else:
			# Stop walking sounds if not moving
			if footsteps_walk.playing:
				footsteps_walk.stop()
				is_playing_footsteps_walk = false
			
			# Keep breath_normal playing when idle
			if not breath_normal.playing:
				breath_normal.play()
				is_playing_breath_normal = true
		
		if breath_run.playing:
			breath_run.stop()
			is_playing_breath_run = false
		if footsteps_run.playing:
			footsteps_run.stop()
			is_playing_footsteps_run = false
		
	var current_smoothing = acceleration
	
	if not is_on_floor():
		current_smoothing = air_acceleration
	elif not move_dir:
		current_smoothing = braking
	
	var target_velocity = move_dir * target_speed
	
	velocity.x = lerp(velocity.x, target_velocity.x, current_smoothing * delta)
	velocity.z = lerp(velocity.z, target_velocity.z, current_smoothing * delta)
	
	move_and_slide()
	
	# Camera view/looking
	rotate_y(camera_look_input.x * -look_sensitivity)
	camera.rotate_x(-camera_look_input.y * look_sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	camera_look_input = Vector2.ZERO
	
	# Update audio position during movement
	update_audio_positions()

func update_audio_positions() -> void:
	# Keep the position of all audio sources synchronized with player position
	breath_normal.position = global_position
	breath_run.position = global_position
	footsteps_walk.position = global_position
	footsteps_run.position = global_position
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_look_input = event.relative

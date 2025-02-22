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
@onready var breath_run : AudioStreamPlayer3D = get_node("BreathRun")
@onready var footsteps_walk : AudioStreamPlayer3D = get_node("FootstepsWalk")
@onready var footsteps_run : AudioStreamPlayer3D = get_node("FootstepsRun")
@onready var flashlight_off : AudioStreamPlayer3D = get_node("FlashlightOff")
@onready var flashlight_on : AudioStreamPlayer3D = get_node("FlashlightOn")

var is_playing_breath_run : bool = false
var is_playing_footsteps_walk : bool = false
var is_playing_footsteps_run : bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	setup_audio_stream()
	stop_playing_audio()
	
func setup_audio_stream() -> void:
	breath_run.stream.loop = true
	footsteps_walk.stream.loop = true
	footsteps_run.stream.loop = true


func stop_playing_audio() -> void:
	breath_run.stop()
	footsteps_walk.stop()
	footsteps_run.stop()
	
	# Reset flags
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
			flashlight_off.play()
		else:
			flashlight_light.visible = true
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
				
		# Play running sounds, but only if they aren't already playing
		# If the player is running, play the running sounds and stop the walking sounds.
		# We only play the running sounds if they're not already playing to prevent overlap.
		if not breath_run.playing:
			breath_run.play()
			is_playing_breath_run = true
		if not footsteps_run.playing:
			footsteps_run.play()
			is_playing_footsteps_run = true
		
		# Stop walking sounds if running
		if footsteps_walk.playing:
			footsteps_walk.stop()
			is_playing_footsteps_walk = false
		
	else:
		if move_dir.length() > 0:
			if not footsteps_walk.playing:
				footsteps_walk.play()
				is_playing_footsteps_walk = true
		
		else:
			# Stop walking sounds if not moving
			if footsteps_walk.playing:
				footsteps_walk.stop()
				is_playing_footsteps_walk = false
		
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
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_look_input = event.relative

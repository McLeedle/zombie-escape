extends State

var home_position : Vector3
@export var min_wander_range : float = 4
@export var max_wander_range : float = 6
@export var chase_range : float = 8
@export var min_wait_time : float = 0.2
@export var max_wait_time : float = 2.5

func initialize ():
	super.initialize()

# Called when we enter into the state.
func enter():
	super.enter()
	home_position = controller.position
	_new_wander_position()
	controller.play_run_animation()

# Called when we exit the state.
func exit():
	super.exit()

# Called every frame while in the state.
func update(_delta):
	# State transitions.
	if controller.player_distance < chase_range:
		state_machine.set_state("Chase")

# Called every physics update while in the state.
func physics_update(_delta):
	pass

func navigation_complete():
	await get_tree().create_timer(randf_range(min_wait_time, max_wait_time)).timeout
	
	if not active:
		return
	
	_new_wander_position()

func _new_wander_position ():
	var new_position = home_position + _random_offset() * randf_range(min_wander_range, max_wander_range)
	controller.move_to_position(new_position)

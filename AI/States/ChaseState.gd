extends State

@export var attack_range : float = 1.0
@export var lose_interest_range : float = 7.0

var path_update_rate : float = 0.1
var last_path_update_time : float

func enter():
	super.enter()
	controller.running = true
	controller.play_run_animation()
	
	if controller.grunt_sound and !controller.grunt_sound.is_playing():
		controller.grunt_sound.play()

func exit():
	super.exit()
	controller.running = false

# Called every frame while in the state.
func update(_delta):
	if controller.game_over_triggered:
		return
		
	# Update the path to the player every 0.1 seconds.
	if Time.get_unix_time_from_system() - last_path_update_time > path_update_rate:
		controller.move_to_position(controller.player.position, false)
		last_path_update_time = Time.get_unix_time_from_system()
	
	# State transitions.
	if controller.player_distance > lose_interest_range:
		state_machine.set_state("Wander")
		
	if controller.player_distance < attack_range:
		controller.handle_player_caught()

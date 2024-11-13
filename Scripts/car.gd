extends InteractableObject

@export var required_item : String = "Car Keys"

func _ready() -> void:
	GlobalSignals.connect("car_key_collected", Callable (self, "_on_key_collected"))
	
func _on_key_collected():
	can_interact = true

func interact():
	if can_interact:
		get_node("/root/Main").win_game()

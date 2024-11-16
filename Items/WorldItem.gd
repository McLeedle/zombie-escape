extends InteractableObject

@export var item_name : String

@onready var keypickup : AudioStreamPlayer3D = get_node("KeyPickup")

func interact ():
	if keypickup:
		keypickup.play()
		keypickup.connect("finished", Callable(self, "_on_sound_finished"))
	else:
		_on_sound_finished()
		
	var item_path = "res://Items/Item Data/" + item_name + ".tres"
	var item = load(item_path) as Item
	if item:
		GlobalSignals.on_give_player_item.emit(item, 1)
		GlobalSignals.item_collected.emit(item)

func _on_sound_finished():
	queue_free()
	

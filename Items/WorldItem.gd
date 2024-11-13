extends InteractableObject

@export var item_name : String

func interact ():
	var item_path = "res://Items/Item Data/" + item_name + ".tres"
	var item = load(item_path) as Item
	if item:
		GlobalSignals.on_give_player_item.emit(item, 1)
		GlobalSignals.item_collected.emit(item)
		queue_free()

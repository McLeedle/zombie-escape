extends InteractableObject

@export var item_name : String

func interact ():
	var item_path = "res://Items/Item Data/" + item_name + ".tres"
	var item = load(item_path) as Item
	if item:
		print("Item loaded: ", item.display_name)
		GlobalSignals.on_give_player_item.emit(item, 1)
		GlobalSignals.item_collected.emit(item)
		queue_free()
	else:
		print("Failed to load item at path:", item_path)

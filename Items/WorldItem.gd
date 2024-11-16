extends InteractableObject

@export var item_name : String

@onready var keypickup : AudioStreamPlayer3D = get_node("KeyPickup")
@onready var model : Node = get_node("Model")
@onready var collision_shape : CollisionShape3D = get_node("CollisionShape3D")

func interact ():
	if keypickup:
		keypickup.play()
		keypickup.connect("finished", Callable(self, "_on_sound_finished"))
		model.visible = false
		collision_shape.disabled = true
	else:
		_on_sound_finished()
		
	var item_path = "res://Items/Item Data/" + item_name + ".tres"
	var item = load(item_path) as Item
	if item:
		GlobalSignals.on_give_player_item.emit(item, 1)
		GlobalSignals.item_collected.emit(item)

func _on_sound_finished() -> void:
	queue_free()

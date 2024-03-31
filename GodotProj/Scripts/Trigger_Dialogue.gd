extends Area2D

signal crossed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(Callable(onAreaEntered))

func onAreaEntered(area: Area2D) -> void:
	if ((area.collision_layer == 2)
	and (area.get_parent() is CarController)):
		emit_signal("crossed")

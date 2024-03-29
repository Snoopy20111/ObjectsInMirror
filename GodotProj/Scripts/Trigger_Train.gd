extends Area2D

signal playerCrossed


func _ready() -> void:
	area_entered.connect(Callable(onAreaEntered))

func onAreaEntered(area: Area2D) -> void:
	# If it's the player, change the scene
	# Brittle as hell methods to see if this is the Player Car
	if ((area.collision_layer == 2)
	and (area.get_parent() is CarController)):
		emit_signal("playerCrossed")

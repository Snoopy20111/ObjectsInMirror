extends Area2D

signal playerCrossed


func _ready():
	area_entered.connect(Callable(onAreaEntered))

func onAreaEntered(area: Area2D):
	# If it's the player, change the scene
	# Brittle as hell methods to see if this is the Player Car
	if ((area.collision_layer == 2)
	and (area.get_parent().name == "PlayerCar")):
		emit_signal("playerCrossed")

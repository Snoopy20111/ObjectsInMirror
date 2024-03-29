extends Line2D

@export var pointDistanceThreshold:float = 10
@export var maxPoints:int = 200

var parentPosition:Vector2
var lastGlobalPosition:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level = true
	parentPosition = get_parent().global_position
	lastGlobalPosition = parentPosition

func _physics_process(_delta: float) -> void:
	parentPosition = get_parent().global_position
	if ((lastGlobalPosition - parentPosition).length() < pointDistanceThreshold):
		return
	add_point(parentPosition)
	lastGlobalPosition = parentPosition
	if points.size() > maxPoints:
		remove_point(0)

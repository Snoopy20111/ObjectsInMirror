extends ColorRect
class_name AutoResizeColorRect

# Size in pixels / units to go over the window size
@export var bleed_size: int = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().get_root().size_changed.connect(viewport_resized)

func viewport_resized() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	set_deferred("size", viewport_size + Vector2(bleed_size,bleed_size))

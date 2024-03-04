extends Node

@export var fullscreen_effects: Array

func _ready():
	# Replaces the NodePaths with actual referenced nodes
	# Feels like a dangerous move, but saves some memory and
	# simplifies the code below
	for i in fullscreen_effects.size():
		fullscreen_effects[i] = get_node(fullscreen_effects[i]) as ColorRect

### Specific Utilities ###
func setFullscreenShaderActive(effect: int, is_active: bool = true) -> void:
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return
	if (is_active == null):
		push_error("value given was null")
		return
	fullscreen_effects[effect].visible = is_active

func setFullscreenShaderParam(effect: int, param_name: String, new_value) -> void:
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return
	if (new_value == null):
		push_error("value given was null")
		return
	# Don't know of any way to error-check names and types of shader params,
	# So we just have to hope Godot will throw meaningful errors
	var my_material = fullscreen_effects[effect].get_material()
	my_material.set_shader_parameter(param_name, new_value)

func getFullscreenShaderParam(effect: int, param_name: String):
	if (effect > fullscreen_effects.size()):
		push_error("effect value outside array range")
		return
		
	# Don't know of any way to error-check names and types of shader params,
	# So we just have to hope Godot will throw meaningful errors
	return fullscreen_effects[effect].get_material().get_shader_parameter(param_name)

#func retarget_camera2D(_new_target: Node2D):
	##Set camera to target given object
	#pass


### Utilities ###
func reparent_other(child:Node, new_parent:Node) -> void:
	child.reparent(new_parent)

func findByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className):
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, className, result)

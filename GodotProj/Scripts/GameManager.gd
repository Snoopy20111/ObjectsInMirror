extends Node

var is_paused: bool = false

### Utilities ###
func reparent_other(child:Node, new_parent:Node) -> void:
	child.reparent(new_parent)

func findByClass(node: Node, className : String, result : Array) -> void:
	if node.is_class(className):
		result.push_back(node)
	for child in node.get_children():
		findByClass(child, className, result)

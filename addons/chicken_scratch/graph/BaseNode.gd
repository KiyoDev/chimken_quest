@tool
class_name BaseNode extends GraphNode


signal slots_removed(node : BaseNode, from_port : int);

signal node_close_requested(node : BaseNode);


func _on_resize_request(new_minsize):
#	print_debug("new_minsize - %s" % [new_minsize]);
	custom_minimum_size = new_minsize;
	reset_size(); # ensures window size updates to correct minimum, even if it gets resized from adding/removing children


func _on_close_request():
	print_debug("base close request");
	node_close_requested.emit(self);


func _on_dragged(from, to):
	print_debug("dragging '%s' [%s->%s] %s" % [name, from, to, position]);

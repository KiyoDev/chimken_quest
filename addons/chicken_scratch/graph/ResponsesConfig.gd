@tool
class_name ResponsesConfig extends VBoxContainer


@export var SlotCount : SpinBox;
@export var add_response : Button;


func set_response_count(value : int):
	SlotCount.value = value;
	
#func connect_to_value_changed(callable : Callable, flags := CONNECT_PERSIST):
#	SlotCount.value_changed.connect(callable, flags);
#
#	print_debug("connect - %s" % [SlotCount.value_changed.get_connections()]);

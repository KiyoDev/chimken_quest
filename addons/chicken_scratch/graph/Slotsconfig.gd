@tool
class_name ResponseConfig extends VBoxContainer


@export var SlotCount : SpinBox;


func set_response_count(value : int):
	SlotCount.value = value;
	
#func connect_to_value_changed(callable : Callable, flags := CONNECT_PERSIST):
#	SlotCount.value_changed.connect(callable, flags);
#
#	print_debug("connect - %s" % [SlotCount.value_changed.get_connections()]);

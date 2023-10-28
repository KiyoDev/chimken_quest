@tool
class_name SlotsConfig extends VBoxContainer


@export var SlotCount : SpinBox;


#func connect_to_value_changed(callable : Callable, flags := CONNECT_PERSIST):
#	SlotCount.value_changed.connect(callable, flags);
#
#	print_debug("connect - %s" % [SlotCount.value_changed.get_connections()]);

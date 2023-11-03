@tool
class_name RootNode extends GraphNode


signal node_close_request(node : DialogueNode);


@export var ConditionConfig : HBoxContainer;
@export var ConditionCount : SpinBox;

@export var condition_element : PackedScene;


var curr_condition_count := 1;

var condition_elements = [];


func _init():
	print_debug("init dialogue node");



func _exit_tree():
	print_debug("'%s' exiting tree..." % [name]);


# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("ready");
	add_child(condition_element.instantiate());
	set_slot_enabled_right(ConditionConfig.get_index() + 1, true);


func set_from_dict(dict : Dictionary):
	var condition_count : int = dict.conditions.size();
	ConditionCount.value = condition_count;
	
	var index := 1;
	for condition in dict.conditions:
		var con : ConditionElement = get_child(index + ConditionConfig.get_index());
		con.condition.text = condition.condition;
		index += 1;
	
	position_offset = Vector2(dict.metadata.position.x, dict.metadata.position.y);
	custom_minimum_size = Vector2(dict.metadata.custom_minimum_size.x, dict.metadata.custom_minimum_size.y);
	print_debug("root[%s] - %s" % [dict.name, dict.metadata.position]);


func to_dict() -> Dictionary:
	var dict := {};
	
	dict["name"] = name;
	# TODO: add connections; but maybe is just managed by the graph editor itself
	# response index = node port for the editor connections
	dict["conditions"] = [];
	print("hhh '%s'" % [get_children()]);
	for index in range(ConditionConfig.get_index() + 1, get_child_count()):
		var child : ConditionElement = get_child(index);
		print("lakdhgjklad '%s', '%s'" % [child.condition.name, child.condition.text]);
		dict["conditions"].append({
			"condition": child.condition.text
		});
#			print_debug("responses - %s" % [get_responses()]);
#	return "{\"name\":\"%s\"}" % [];
	dict["metadata"] = {
		"position": {"x": position_offset.x, "y": position_offset.y},
		"custom_minimum_size": {"x": custom_minimum_size.x, "y": custom_minimum_size.y}
	};
	return dict;


func _clone(flags := 0b0111):
	var node := super.duplicate(flags);
	return node;


func _on_resize_request(new_minsize):
#	print("new_minsize - %s" % [new_minsize]);
	custom_minimum_size = new_minsize;
	reset_size(); # ensures window size updates to correct minimum, even if it gets resized from adding/removing children


func _on_close_request():
	# FIXME: add confirmation menu before actually deleting
	print_debug("Cannot close root node.");


func _on_dragged(from, to):
	print_debug("dragging '%s' [%s->%s] %s" % [name, from, to, position]);


func _on_count_value_changed(value):
	print("change condition count");
	print_debug("v=%s, c=%s, %s" % [value, curr_condition_count, ConditionConfig.get_index()]);
	if(value > curr_condition_count):
		# ignore base ele and slot config ele
		var curr_last_index := curr_condition_count + ConditionConfig.get_index() + 1;
#		for i in value - curr_resp_slots:
		for i in range(curr_last_index, value + ConditionConfig.get_index() + 1):
			print("5 - %s=%s" % [curr_last_index + i, is_slot_enabled_right(curr_last_index + i)]);
#			print_debug("value > curr [count=%s, i=%s, last=%s, slot_config=%s, rsp=%s]" % [get_child_count(), i, curr_last_index, response_config.get_index(), response_elements]);
			var new_condition = condition_element.instantiate();
			condition_elements.append(new_condition);
			add_child(new_condition);
			set_slot_enabled_right(i, true);
#			set_slot_enabled_right(curr_last_index + i, true);
	elif(value < curr_condition_count):
		for i in range(get_child_count() - 1, ConditionConfig.get_index() + value, -1):
			print_debug("value < curr [%s, %s]" % [get_child_count(), i]);
			remove_child(get_child(i));
			condition_elements.pop_back(); # -(text.index + config.index)
#			condition_elements.remove_at(i - (ConditionConfig.get_index() + 2)); # -(text.index + config.index)
	curr_condition_count = value;
	reset_size();

@tool
class_name RootNode extends GraphNode


signal node_closed(node : DialogueNode);


@export var ConditionConfig : HBoxContainer;
@export var ConditionCount : SpinBox;
@export var ConditionEle : VBoxContainer;


var curr_condition_count := 1;

var condition_elements = [];


func _init():
	print_debug("init dialogue node");



func _exit_tree():
	print_debug("'%s' exiting tree..." % [name]);


# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("ready");
	
#	if(dialogue == null):
#		dialogue = Dialogue.new();
#	else:
#		Speaker.text = dialogue.speaker;
#		Text.text = dialogue.text;
	
	# Set type options to Type enum values
	
#	TypeOptions.clear();
#	for type in Type.keys():
#		TypeOptions.add_item(type, Type[type]);
#	type = Type.Dialogue;
#
#	response_elements.append(get_child(slots_config.get_index() + 1));
	
#	hide_offer_slots();
#	hide_response_slots();
#	update_node_options();


func to_dict() -> Dictionary:
	var dict := {};
	
	dict["name"] = name;
	# TODO: add connections; but maybe is just managed by the graph editor itself
	# response index = node port for the editor connections
	dict["conditions"] = [];
	for index in range(ConditionConfig.get_index() + 1, get_child_count()):
		var child : ConditionElement = get_child(index);
		var condition := {
			"condition": child.condition.text
		};
		dict["conditions"].append(condition);
#			print_debug("responses - %s" % [get_responses()]);
#	return "{\"name\":\"%s\"}" % [];
	dict["metadata"] = {
		"position": {"x": position_offset.x, "y": position_offset.y},
		"custom_minimum_size": {"x": custom_minimum_size.x, "y": custom_minimum_size.y}
	};
	return dict;


func clone_from_template() -> DialogueNode:
#	print_debug("cloning from template");
#	var tmp : DialogueNodeTemplate = template.instantiate().duplicate(0b0111);
#	var node : DialogueNode = duplicate(0b0111);
#	node.curr_resp_slots = 1;
#	node.curr_item_count = 1;
#
#	var off_cfg : OfferConfig = tmp._OfferConfig;
#	off_cfg.reparent(node);
#	node.offer_config = off_cfg;
#	node.item_offerings = off_cfg.Offerings;
#	node.offer_element = off_cfg.Offerings.get_child(0);
#
#	var off_fail = tmp.OfferingFail;
#	off_fail.reparent(node);
#	node.offering_fail = off_fail;
#
#	var slots_cfg : SlotsConfig = tmp.SlotsConfig;
#	slots_cfg.reparent(node);
#	node.slots_config = slots_cfg;
#
#	tmp.Response.reparent(node);
#
#	node.on_create();
#
#	return node;
	return null;


func on_create():
#	print_debug("on_create");
#	TypeOptions.clear();
#	for type in Type.keys():
#		TypeOptions.add_item(type, Type[type]);
#	type = Type.Dialogue;
#
#	response_elements.append(get_child(slots_config.get_index() + 1));
#
#	offer_config.ItemCount.value_changed.connect(_on_item_count_value_changed, CONNECT_PERSIST);
#	slots_config.SlotCount.value_changed.connect(_on_slot_count_value_changed, CONNECT_PERSIST);
##	slots_config.connect_to_value_changed(_on_slot_count_value_changed);
#	print_debug("init offers - %s" % [offer_config.ItemCount.value_changed.get_connections()]);
#	print_debug("init responses - %s" % [slots_config.SlotCount.value_changed.get_connections()]);
#
#	# enable all slots after adding children nodes
#	for i in get_child_count():
#		set_slot_enabled_right(i, true);
#
#	hide_offer_slots();
#	hide_response_slots();
#	update_node_options();
	reset_size();


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
#			print_debug("value > curr [count=%s, i=%s, last=%s, slot_config=%s, rsp=%s]" % [get_child_count(), i, curr_last_index, slots_config.get_index(), response_elements]);
			var new_condition = ConditionEle.duplicate(0b0111);
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

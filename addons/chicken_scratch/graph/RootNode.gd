@tool
class_name RootNode extends GraphNode


signal node_closed(node : DialogueNode);


@export var TypeOptions : OptionButton;
@export var Speaker : LineEdit;
@export var Text : TextEdit;
@export var Hidden : Control;

#var offer_config : OfferConfig;
#var item_offerings : VBoxContainer;
#var offer_element : OfferElement;
#var offering_fail : HBoxContainer;
#var slots_config : SlotsConfig;
#
#
#@export var template : PackedScene;
### Item name from element can be used by front end dialogue manager to grab items it needs
##@export var offering_element : PackedScene; 
#@export var response_element : PackedScene;
#
#
#@export var type := Type.Dialogue;
#@export var dialogue : DialogueBase;


#var curr_resp_slots := 1;
#var curr_item_count := 1;
#
#var response_elements : Array[ResponseElement] = [];


func _init():
	print_debug("init dialogue node");



func _exit_tree():
	print_debug("'%s' exiting tree..." % [name]);
	for child in Hidden.get_children():
		child.reparent(self);


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
	print_debug("_on_close_request");
	node_closed.emit(self);
	queue_free();



func _on_dragged(from, to):
	print_debug("dragging '%s' [%s->%s] %s" % [name, from, to, position]);


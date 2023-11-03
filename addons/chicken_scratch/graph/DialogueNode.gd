@tool
class_name DialogueNode extends GraphNode


signal node_closed(node : DialogueNode);

signal slots_removed(node : DialogueNode, from_port : int);

signal type_changed(type : Type);


enum Type {
	Dialogue,
	Offer,
	Response
}


@export var TypeOptions : OptionButton;
@export var Speaker : LineEdit;
@export var Text : TextEdit;
@export var Hidden : Control;


#@export var TypeOptions : OptionButton;
#@export var Speaker : LineEdit;
#@export var Text : TextEdit;
#@export var Hidden : Control;

var offer_config : OfferConfig;
var item_offerings : VBoxContainer;
var offer_element : OfferElement;
var offering_fail : HBoxContainer;
var response_config : ResponseConfig;


@export var template : PackedScene;
## Item name from element can be used by front end dialogue manager to grab items it needs
#@export var offering_element : PackedScene; 
@export var response_element : PackedScene;


@export var type := Type.Dialogue;
	
@export var dialogue : DialogueBase;


var curr_resp_slots := 1;
var curr_item_count := 1;

var response_elements : Array[ResponseElement] = [];


func _init():
	print_debug("init dialogue node");



func _exit_tree():
	print_debug("'%s' exiting tree..." % [name]);
	for child in Hidden.get_children():
		child.reparent(self);


# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("ready");
#	type_changed.connect(_on_type_changed);
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
#	response_elements.append(get_child(response_config.get_index() + 1));
	
#	hide_offer_slots();
#	hide_response_slots();
#	update_node_options();


func set_type(value):
	if(value == type): return;
	
	print_debug("type change - %s->%s" % [Type.keys()[type], Type.keys()[value]]);
	hide_previous_options(type);
	reset_size();
	type = value;
	print_debug("on type option - %s, %s" % [type, Type.keys()[value]]);
	TypeOptions.select(value);
	update_node_options();
	reset_size();


func get_type():
	return type;


func set_speaker(speaker : String):
	Speaker.text = speaker;


func set_dialogue(text : String):
	Text.text = text;


func clone_from_template() -> DialogueNode:
	print_debug("cloning from template");
	var tmp : DialogueNodeTemplate = template.instantiate();
	curr_resp_slots = 1;
	curr_item_count = 1;
	
	var off_cfg : OfferConfig = tmp._OfferConfig;
	off_cfg.reparent(self);
	offer_config = off_cfg;
	item_offerings = off_cfg.Offerings;
	offer_element = off_cfg.Offerings.get_child(0);
	
	var off_fail = tmp.OfferingFail;
	off_fail.reparent(self);
	offering_fail = off_fail;
	
	var slots_cfg : ResponseConfig = tmp.ResponseConfig;
	slots_cfg.reparent(self);
	response_config = slots_cfg;
	
	tmp.Response.reparent(self);
	
	on_create();
	
	return self;


func on_create():
	print_debug("on_create");
	TypeOptions.clear();
	for type in Type.keys():
		TypeOptions.add_item(type, Type[type]);
	type = Type.Dialogue;
	
	response_elements.append(get_child(response_config.get_index() + 1));
	
	offer_config.ItemCount.value_changed.connect(_on_item_count_value_changed, CONNECT_PERSIST);
	response_config.SlotCount.value_changed.connect(_on_slot_count_value_changed, CONNECT_PERSIST);
#	response_config.connect_to_value_changed(_on_slot_count_value_changed);
	print_debug("init offers - %s" % [offer_config.ItemCount.value_changed.get_connections()]);
	print_debug("init responses - %s" % [response_config.SlotCount.value_changed.get_connections()]);
	
	# enable all slots after adding children nodes
	for i in get_child_count():
		set_slot_enabled_right(i, true);
	
	hide_offer_slots();
	hide_response_slots();
	update_node_options();
	reset_size();


static func new_from_dict(scn : PackedScene, dict : Dictionary, graph : GraphEdit) -> DialogueNode:
	var node : DialogueNode = scn.instantiate().clone_from_template();
	node.name = dict.name.replace("@", "_");
	graph.add_child(node);
	node.set_type(DialogueNode.Type[dict.type]);
	node.Speaker.text = dict.speaker;
	node.Text.text = dict.text;
#	print_debug("add new node=%s, %s" % [position, node]);
	var pos := Vector2(dict.metadata.position.x, dict.metadata.position.y);
	node.position_offset = pos;
#	node.position_offset = Vector2(dict.metadata.position.x, dict.metadata.position.y);
	print_debug("new from dict - %s" % [dict]);
	match(node.type):
		Type.Dialogue:
			pass;
		Type.Offer:
			var count = dict.properties.offerings.size();
			node.offer_config.set_item_count(count);
			# Update node's properties to saved properties
			var index := 0;
			for offering in dict.properties.offerings:
				var off : OfferElement = node.item_offerings.get_child(index);
				off.ItemName.text = offering.item_name;
				off.ItemType.text = offering.item_type;
				off.Quantity.value = offering.quantity;
				index += 1;
		Type.Response:
			var count = dict.properties.responses.size();
			node.response_config.set_response_count(count);
			# Update node's properties to saved properties
			var index := node.response_config.get_index() + 1;
			for response in dict.properties.responses:
				var resp : ResponseElement = node.get_child(index);
				resp.Text.text = response.text;
				index += 1;
		_:
			push_error("Invalid type found in dictionary - %s" % [JSON.stringify(dict, "", false)]);
	return node;


func from_dict(dict : Dictionary):
	type = dict.type;
	Speaker.text = dict.speaker;
	Text.text = dict.text;
	match(type):
		Type.Dialogue:
			pass;
		Type.Offer:
			for offering in dict.properties.offerings:
				pass;
			pass;
		Type.Response:
			pass;
		_:
			push_error("Invalid type found in dictionary - %s" % [JSON.stringify(dict, "", false)]);
	pass;


func to_dict() -> Dictionary:
	var dict := {};
	
#	print("a - %s" % [Speaker.text]);
	
#	dict["name"] = str(name).replace("@", "_");
	dict["name"] = name;
	dict["type"] = Type.keys()[type];
	dict["speaker"] = Speaker.text;
	dict["text"] = Text.text;
	dict["properties"] = {};
	match(type):
		Type.Dialogue:
			# TODO: add connections?
			pass;
		Type.Offer:
			dict["properties"]["offerings"] = [];
			for offer in offer_config.get_offers():
				var item := {}

				item["item_name"] = offer.ItemName.text;
				item["item_type"] = offer.ItemType.text;
				item["quantity"] = offer.Quantity.value;

				dict["properties"]["offerings"].append(item);
			# TODO: add connections
		Type.Response:
			# TODO: add connections; but maybe is just managed by the graph editor itself
			# response index = node port for the editor connections
			dict["properties"]["responses"] = [];
			for index in range(response_config.get_index() + 1, get_child_count()):
				var child : ResponseElement = get_child(index);
				var response := {"text": child.text()};
				dict["properties"]["responses"].append(response);
#			print_debug("responses - %s" % [get_responses()]);
			pass;
#	return "{\"name\":\"%s\"}" % [];
	dict["metadata"] = {
		"position": {"x": position_offset.x, "y": position_offset.y},
		"custom_minimum_size": {"x": custom_minimum_size.x, "y": custom_minimum_size.y}
	};
	return dict;


func to_string_pretty() -> String:
	return JSON.stringify(to_dict(), "\t", false);


func _to_string():
	return JSON.stringify(to_dict(), "", false);


func update_node_options():
	match(type):
		Type.Dialogue:
			set_slot_enabled_right(0, true);
		Type.Offer:
#			set_slot_enabled_right(0, false);
			offer_config.reparent(self);
			offering_fail.reparent(self);
			offer_config.show();
			offering_fail.show();
			print_debug("g - %s, %s" % [offer_config.get_index(), offering_fail.get_index()]);
			set_slot_enabled_right(offer_config.get_index(), true);
			set_slot_enabled_right(offering_fail.get_index(), true);
		Type.Response:
			response_config.reparent(self);
			response_config.show();
			set_slot_enabled_right(response_config.get_index(), false); # config index = first response slot
#			for index in range(response_config.get_index() + 1, get_child_count()):
			# TODO: GraphNode slot count changes depending on visible children
#			for index in range(response_config.get_index() + 1, get_child_count()):
			print_debug("switching to  resp - [%s, %s]" % [get_connection_output_count(), response_elements]);
#			for index in range(Hidden.get_child_count() - 1, -1, -1):
			var index := 0;
			for child in response_elements:
#				var child := Hidden.get_child(index);
#				if(!(child is ResponseElement)): continue;
				child.reparent(self);
				child.show();
				set_slot_enabled_right(index + response_config.get_index() + 1, true);
#				set_slot_enabled_right(index - 2, true); # TODO: depends on if offer nodes are showing or not
				print_debug("resp - child[%s]=%s" % [index, child]);
#	print_debug("slo - count=%s, curr=%s" % [get_connection_output_count(), curr_resp_slots]);
	reset_size();
	
	
# fixed: response slot connections keep showing up below their actual spots
# - hidden controls before a node will mess with the slot position

func hide_previous_options(type : Type):
	match(type):
		Type.Dialogue:
			set_slot_enabled_right(0, false);
			slots_removed.emit(self, 0);
		Type.Offer:
			hide_offer_slots();
		Type.Response:
			hide_response_slots();
			

func hide_offer_slots():
	if(!offer_config.visible || !offering_fail.visible): return;
	
	print_debug("hiding offer - [%s]" % [get_connection_output_count()]);
	print_debug("hiding - [%s, %s]" % [get_connection_output_slot(0), get_connection_output_slot(1)]);

	offer_config.reparent(Hidden);
	offering_fail.reparent(Hidden);
	offer_config.hide();
	offering_fail.hide();
	slots_removed.emit(self, 0);
	slots_removed.emit(self, 1);


func hide_response_slots():
	if(!response_config.visible): return;
	for index in range(get_child_count() - 1, response_config.get_index(), -1):
		var child := get_child(index);
		print_debug("hiding resp[%s, %s]=%s" % [index - response_config.get_index() + 1, is_slot_enabled_right(index - response_config.get_index() + 1), child]);
		print_debug("%s, %s" % [is_slot_enabled_right(0), is_slot_enabled_right(1)])
#		set_slot_enabled_right(index - response_config.get_index() + 1, false);
		child.reparent(Hidden);
		child.hide();
		slots_removed.emit(self, index - (response_config.get_index() + 1));
	response_config.reparent(Hidden);
	response_config.hide();


func update_response_slots(value):
	print_debug("v=%s, c=%s, %s" % [value, curr_resp_slots, response_config.get_index()]);
	if(value > curr_resp_slots):
		# ignore base ele and slot config ele
		var curr_last_index := curr_resp_slots + response_config.get_index() + 1;
#		for i in value - curr_resp_slots:
		for i in range(curr_last_index, value + response_config.get_index() + 1):
			print("5 - %s=%s" % [curr_last_index + i, is_slot_enabled_right(curr_last_index + i)]);
			print_debug("value > curr [count=%s, i=%s, last=%s, slot_config=%s, rsp=%s]" % [get_child_count(), i, curr_last_index, response_config.get_index(), response_elements]);
			var new_resp = response_element.instantiate();
			response_elements.append(new_resp);
			add_child(new_resp);
			set_slot_enabled_right(i, true);
#			set_slot_enabled_right(curr_last_index + i, true);
	elif(value < curr_resp_slots):
		for i in range(get_child_count() - 1, response_config.get_index() + value, -1):
			print_debug("value < curr [%s, %s]" % [get_child_count(), i]);
			slots_removed.emit(self, i - 2);
			remove_child(get_child(i));
			response_elements.pop_back(); # -(text.index + config.index)
	curr_resp_slots = value;
	print_debug("slot count = %s, %s" % [value, response_elements]);


func update_item_count(value):
	print_debug("v=%s, c=%s" % [value, curr_item_count]);
	if(value > curr_item_count):
		for i in value - curr_item_count:
			var new_offer = offer_element.duplicate(0b0111);
			print_debug("new offer - %s" % [new_offer]);
#			item_offerings.append(new_offer);
			item_offerings.add_child(new_offer);
	elif(value < curr_item_count):
		for i in range(curr_item_count - 1, value - 1, -1):
			print_debug("value < curr [%s, %s]" % [get_child_count(), i]);
			item_offerings.remove_child(item_offerings.get_child(i));
	curr_item_count = value;
	print_debug("curr_item_count count = %s" % [curr_item_count]);


func slot_node_index(slot : int) -> int:
	# -1 since hiding elements changes slot indices
	return response_config.get_index() + slot;


func empty() -> DialogueNode:
	var node := super.duplicate(0b0111);
	node.type = Type.Dialogue;
	node.dialogue = Dialogue.new();
	print_debug("empty - %s" % [node.dialogue]);
	return node


func get_responses() -> Array[ResponseElement]:
	var responses : Array[ResponseElement] = [];
	
	for i in range(response_config.get_index() + 1, get_child_count()):
		var resp = get_child(i);
#		print_debug("a - %s" % resp);
		responses.append(resp);
	
	return responses;


func _clone(flags := 0b0111):
	var node := super.duplicate(flags);
	node.dialogue = dialogue.duplicate();
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


func _on_speaker_text_submitted(new_text):
	print_debug("speaker - %s" % [Speaker.text]);
	


func _on_dialogue_text_changed():
	print_debug("dialogue - %s" % [Text.text]);


func _on_test_print_pressed():
	print_debug("%s={type: %s,%s: '%s'}" % [name, type, Speaker.text, Text.text]);


func _on_dragged(from, to):
	print_debug("dragging '%s' [%s->%s] %s" % [name, from, to, position]);


func _on_type_options_item_selected(index):
#	var key = Type.keys()[index];
#	print_debug("on type option - %s" % [Type.get(key)]);
#	type = Type.get(key);
	# TODO: hide previous options
#	type_changed.emit(index);
	
	print_debug("type change - %s->%s" % [Type.keys()[type], Type.keys()[index]]);
	hide_previous_options(type);
	reset_size();
	type = index;
	print_debug("on type option - %s, %s" % [type, Type.keys()[index]]);
	TypeOptions.select(index);
	update_node_options();
	reset_size();


func _on_slot_count_value_changed(value):
#	print_debug("on slot count change");
	update_response_slots(value);
	reset_size();


func _on_item_count_value_changed(value):
#	print_debug("on item count change");
	update_item_count(value);
	reset_size();


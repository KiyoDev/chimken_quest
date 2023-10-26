@tool
class_name DialogueNode extends GraphNode


signal node_closed(node : DialogueNode);

signal slots_removed(node : DialogueNode, from_port : int);


enum Type {
	Dialogue,
	Offer,
	Response
}


@onready var TypeOptions : OptionButton = $VBoxContainer/HBoxContainer/TypeOptions;
@onready var Speaker : LineEdit = $VBoxContainer/Speaker;
@onready var Text : TextEdit = $VBoxContainer/ScrollContainer/Dialogue;
@onready var _OfferConfig : OfferConfig = $OfferConfig;
@onready var ItemOfferings : VBoxContainer = $OfferConfig/Offerings;
@onready var OfferingFail = $OfferingFail;
@onready var SlotsConfig : Control = $SlotsConfig;

@onready var Hidden = $VBoxContainer/Hidden;


@export var offering_config : PackedScene;
@export var offering_fail : PackedScene;
@export var slots_config : PackedScene;
@export var response_element : PackedScene;
## Item name from element can be used by front end dialogue manager to grab items it needs
@export var offer_element : PackedScene; 

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

# FIXME: SHIT KEEPS DISAPPEARING FROM PACKED SCENE

# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("ready");
#	resize_request.disconnect(_on_resize_request);
#	close_request.disconnect(_on_close_request);
	if(SlotsConfig == null):
		SlotsConfig = slots_config.instantiate().duplicate(0b0111);
		SlotsConfig.find_child("SlotCount").value_changed.connect(_on_slot_count_value_changed);
	
	
	if(dialogue == null):
		dialogue = Dialogue.new();
	else:
		Speaker.text = dialogue.speaker;
		Text.text = dialogue.text;
	
	# Set type options to Type enum values
	TypeOptions.clear();
	for type in Type.keys():
		TypeOptions.add_item(type, Type[type]);
	type = Type.Dialogue;
	
	response_elements.append(get_child(SlotsConfig.get_index() + 1));
	
	hide_offer_slots();
	hide_response_slots();
	update_node_options();


func to_dict() -> Dictionary:
	var dict := {};
	
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
			for offer in _OfferConfig.get_offers():
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
			for index in range(SlotsConfig.get_index() + 1, get_child_count()):
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
			_OfferConfig.reparent(self);
			OfferingFail.reparent(self);
			_OfferConfig.show();
			OfferingFail.show();
			print_debug("g - %s, %s" % [_OfferConfig.get_index(), OfferingFail.get_index()]);
			set_slot_enabled_right(_OfferConfig.get_index(), true);
			set_slot_enabled_right(OfferingFail.get_index(), true);
		Type.Response:
			SlotsConfig.reparent(self);
			SlotsConfig.show();
			set_slot_enabled_right(1, false);
#			set_slot_enabled_right(1, true);
#			for index in range(SlotsConfig.get_index() + 1, get_child_count()):
			# TODO: GraphNode slot count changes depending on visible children
#			for index in range(SlotsConfig.get_index() + 1, get_child_count()):
			print_debug("switching to  resp - [%s, %s]" % [get_connection_output_count(), response_elements]);
#			for index in range(Hidden.get_child_count() - 1, -1, -1):
			var index := 0;
			for child in response_elements:
#				var child := Hidden.get_child(index);
#				if(!(child is ResponseElement)): continue;
				child.reparent(self);
				child.show();
				set_slot_enabled_right(index + 2, true);
#				set_slot_enabled_right(index - 2, true); # TODO: depends on if offer nodes are showing or not
				print_debug("resp - child[%s]=%s" % [index, child]);
	print_debug("slo - count=%s, curr=%s" % [get_connection_output_count(), curr_resp_slots]);
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
	if(!_OfferConfig.visible || !OfferingFail.visible): return;
	
	print_debug("hiding offer - [%s]" % [get_connection_output_count()]);
#	set_slot_enabled_right(0, false);
#	set_slot_enabled_right(1, false);
	print_debug("hiding - [%s, %s]" % [get_connection_output_slot(0), get_connection_output_slot(1)]);

	_OfferConfig.reparent(Hidden);
	OfferingFail.reparent(Hidden);
	_OfferConfig.hide();
	OfferingFail.hide();
	slots_removed.emit(self, 0);
	slots_removed.emit(self, 1);


func hide_response_slots():
	if(!SlotsConfig.visible): return;
	for index in range(get_child_count() - 1, SlotsConfig.get_index(), -1):
		var child := get_child(index);
		print_debug("hiding resp[%s, %s]=%s" % [index - SlotsConfig.get_index() + 1, is_slot_enabled_right(index - SlotsConfig.get_index() + 1), child]);
		print_debug("%s, %s" % [is_slot_enabled_right(0), is_slot_enabled_right(1)])
#		set_slot_enabled_right(index - SlotsConfig.get_index() + 1, false);
		child.reparent(Hidden);
		child.hide();
		slots_removed.emit(self, index - (SlotsConfig.get_index() + 1));
	SlotsConfig.reparent(Hidden);
	SlotsConfig.hide();


func update_response_slots(value):
	print_debug("v=%s, c=%s" % [value, curr_resp_slots]);
	if(value > curr_resp_slots):
		# ignore base ele and slot config ele
		var curr_last_index := 2 + curr_resp_slots;
#		for i in value - curr_resp_slots:
		for i in range(curr_last_index, value + 2):
			print("5 - %s=%s" % [curr_last_index + i, is_slot_enabled_right(curr_last_index + i)]);
			print_debug("value > curr [count=%s, i=%s, last=%s, slot_config=%s, rsp=%s]" % [get_child_count(), i, curr_last_index, SlotsConfig.get_index(), response_elements]);
			var new_resp = response_element.instantiate();
			response_elements.append(new_resp);
			add_child(new_resp);
			set_slot_enabled_right(i, true);
#			set_slot_enabled_right(curr_last_index + i, true);
	elif(value < curr_resp_slots):
		for i in range(get_child_count() - 1, SlotsConfig.get_index() + value, -1):
			print_debug("value < curr [%s, %s]" % [get_child_count(), i]);
			remove_child(get_child(i));
			response_elements.remove_at(i - 2); # -(text.index + config.index)
	curr_resp_slots = value;
	print_debug("slot count = %s, %s" % [value, response_elements]);


func update_item_count(value):
#	print_debug("v=%s, c=%s" % [value, curr_resp_slots]);
	if(value > curr_item_count):
		for i in value - curr_item_count:
			var new_offer = OfferElement.instantiate();
#			ItemOfferings.append(new_offer);
			ItemOfferings.add_child(new_offer);
	elif(value < curr_item_count):
		for i in range(curr_item_count - 1, value, -1):
#			print_debug("value < curr [%s, %s]" % [get_child_count(), i]);
			ItemOfferings.remove_child(ItemOfferings.get_child(i));
#			response_elements.remove_at(i - 2); # -(text.index + config.index)
	curr_item_count = value;
	print_debug("curr_item_count count = %s" % [curr_item_count]);


func slot_node_index(slot : int) -> int:
	# -1 since hiding elements changes slot indices
	return SlotsConfig.get_index() + slot;


func empty() -> DialogueNode:
	var node := super.duplicate(0b0111);
	node.type = Type.Dialogue;
	node.dialogue = Dialogue.new();
	print_debug("empty - %s" % [node.dialogue]);
	return node


func get_responses() -> Array[ResponseElement]:
	var responses : Array[ResponseElement] = [];
	
	for i in range(SlotsConfig.get_index() + 1, get_child_count()):
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
	dialogue.speaker = new_text;


func _on_dialogue_text_changed():
	dialogue.text = Text.text;


func _on_test_print_pressed():
	print_debug("%s={type: %s,%s: '%s'}" % [name, type, Speaker.text, Text.text]);


func _on_dragged(from, to):
	print_debug("dragging '%s' [%s->%s] %s" % [name, from, to, position]);


func _on_type_options_item_selected(index):
#	var key = Type.keys()[index];
#	print_debug("on type option - %s" % [Type.get(key)]);
#	type = Type.get(key);
	# TODO: hide previous options
	print_debug("type change - %s->%s" % [Type.keys()[type], Type.keys()[index]]);
	hide_previous_options(type);
	reset_size();
	type = index;
	print_debug("on type option - %s, %s" % [type, Type.keys()[index]]);
	update_node_options();
	reset_size();


func _on_slot_count_value_changed(value):
	update_response_slots(value);
	reset_size();


func _on_item_count_value_changed(value):
	update_item_count(value);
	reset_size();

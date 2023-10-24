@tool
class_name DialogueNode extends GraphNode


signal node_closed(node : DialogueNode);

signal slots_changed(node : DialogueNode, from_port : int);

enum Type {
	Dialogue,
	Menu,
	Response
}


@onready var TypeOptions : OptionButton = $VBoxContainer/HBoxContainer2/TypeOptions;
@onready var Speaker : LineEdit = $VBoxContainer/Speaker;
@onready var Text : TextEdit = $VBoxContainer/ScrollContainer/Text;
@onready var SlotsConfig : Control = $SlotsConfig; # TODO: hide slots and config depending on option type

@onready var response_node = preload("res://addons/chicken_scratch/response_node.tscn");


@export var type := Type.Dialogue;
@export var dialogue : DialogueBase;


var current_slots := 1;


func _init():
	print_debug("init dialogue node");


# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("ready");
#	resize_request.disconnect(_on_resize_request);
#	close_request.disconnect(_on_close_request);
	
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
	
	update_node_options();


func update_node_options():
	match(type):
		Type.Dialogue:
			SlotsConfig.hide();
			for index in range(slot_node_index(0), get_child_count()):
				var child := get_child(index);
				child.hide();
				set_slot_enabled_right(0, true);
				set_slot_enabled_right(index, false);
				print_debug("child[%s]=%s" % [index, child]);
				slots_changed.emit(self, index - SlotsConfig.get_index() - 1);
		Type.Menu:
			pass;
		Type.Response:
			update_response_slots(current_slots);
			SlotsConfig.show();
			for index in range(slot_node_index(0), get_child_count()):
				var child := get_child(index);
				child.show();
				set_slot_enabled_right(0, false);
				set_slot_enabled_right(index, true);
				print_debug("child[%s]=%s" % [index, child]);
	print_debug("slo - %s" % [current_slots]);
	reset_size();


func update_response_slots(value):
	if(value > current_slots):
		var curr_last_index := slot_node_index(current_slots);
		for i in value - current_slots:
			print_debug("value > curr [%s, %s]" % [get_child_count(), i]);
			var new_resp = response_node.instantiate();
			add_child(new_resp);
			set_slot_enabled_right(curr_last_index + i, true);
	elif(value < current_slots):
		for i in range(get_child_count() - 1, SlotsConfig.get_index() + value, -1):
			print_debug("value < curr [%s, %s]" % [get_child_count(), i]);
			remove_child(get_child(i));
	current_slots = value;
	reset_size();
	print_debug("slot count = %s" % [value]);


func slot_node_index(slot : int) -> int:
	return SlotsConfig.get_index() + 1 + slot;


func empty() -> DialogueNode:
	var node := super.duplicate(0b0111);
	node.type = Type.Dialogue;
	node.dialogue = Dialogue.new();
	print_debug("empty - %s" % [node.dialogue]);
	return node


func _clone(flags := 0b0111):
	var node := super.duplicate(flags);
	node.dialogue = dialogue.duplicate();
	return node;



func _on_resize_request(new_minsize):
	custom_minimum_size = new_minsize;


func _on_close_request():
	# FIXME: add confirmation menu before actually deleting
	print_debug("_on_close_request");
	node_closed.emit(self);
	queue_free();
	

func _on_speaker_text_changed():
	dialogue.speaker = Speaker.text;


func _on_dialogue_text_changed():
	dialogue.text = Text.text;



func _on_test_print_pressed():
	print_debug("%s={type: %s,%s: '%s'}" % [name, type, Speaker.text, Text.text]);


func _on_dragged(from, to):
	print_debug("dragging '%s' [%s->%s] %s" % [name, from, to, position]);


func _on_type_options_item_selected(index):
	type = index;
#	var key = Type.keys()[index];
	print_debug("on type option - %s, %s" % [type, Type.keys()[index]]);
#	print_debug("on type option - %s" % [Type.get(key)]);
#	type = Type.get(key);
	update_node_options();


func _on_slot_count_value_changed(value):
	update_response_slots(value);

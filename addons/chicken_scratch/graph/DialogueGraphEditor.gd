@tool
class_name DialogueGraphEditor extends VBoxContainer

@onready var Graph : GraphEdit = $Graph;
@onready var FileMenu : MenuButton = %FileMenu;


#@export var dialogue_node_template : PackedScene;
@export var dialogue_node : PackedScene;
@export var right_click_menu : Container;


var node_dict : Dictionary = {};
var file_menu_items : Dictionary = {};


static var right_click_menu_open := false;

# TODO: open DialogueFile from disk and populate graph (adding nodes, adding connections, etc)
static var current_dialogue_file : DialogueFile;
 

func _ready():
	var popup := FileMenu.get_popup();
	popup.id_pressed.connect(_on_file_menu_opened);
	for i in popup.item_count:
		file_menu_items[i] = popup.get_item_text(i);
	print_debug("file_menu_items=%s" % [file_menu_items]);

# from graph to json
# TODO: on_graph_save, update DialogueFile and save to disk; .dngraph
func to_json():
	# TODO: have a DialogueGraphFile extends RefCounted that keeps track of currently loaded file?
	var graph := {
		"file_name": current_dialogue_file.name if current_dialogue_file else "",
		"connections": Graph.get_connection_list(),
		"nodes": get_graph_node_dicts()
	};
	
	var file = DialogueFile.new();
	
	file.from_json(JSON.stringify(graph, "\t", false));
	
#	print_debug("connections - %s" % [JSON.stringify(Graph.get_connection_list(), "\t", false)]);
#	var nodes := get_graph_nodes();
#	print_debug("nodes - %s" % [nodes]);
	var json := "";


func get_graph_node_dicts() ->  Array[Dictionary]:
	var nodes : Array[Dictionary] = [];
	for i in range(1, Graph.get_child_count()):
		nodes.append(Graph.get_child(i).to_dict());
	return nodes;


# FIXME: graph nodes are being instantiated at different locations if moving the viewport
func add_new_node(position := Vector2(0, 0)):
	var new_node : DialogueNode = dialogue_node.instantiate().clone_from_template();
#	var new_node : DialogueNode = dialogue_node.instantiate().duplicate(0b0111).empty();
	new_node.node_closed.connect(_on_graph_node_closed);
	new_node.slots_removed.connect(_on_graph_node_slots_removed);
	Graph.add_child(new_node);
	print_debug("add new node=%s, %s" % [position, new_node]);
#	new_node.global_position = position;
	new_node.position_offset = position;
	node_dict[new_node.name] = new_node; # cache node names
	
#	print_debug("add - node_dict=%s" % [node_dict]);
#	print_debug("new_node - %s, %s, %s, %s" % [position, new_node.position, new_node.global_position, new_node.position_offset]);



func _on_file_menu_opened(id : int):
	print_debug("opening file menu - %s" % [id]);
	match id:
		0: # Open
			# TODO: implement file open dialogue
			pass;
		1: # Save
			# TODO: implement file save dialogue
			pass;


func _on_add_node_pressed():
#	print_debug("on add - %s, %s" % [Graph, dialogue_node]);
	add_new_node();


func _on_graph_connection_request(from_node, from_port, to_node, to_port):
	print_debug("connection request - [%s, %s, %s ,%s]" % [from_node, from_port, to_node, to_port]);
	Graph.connect_node(from_node, from_port, to_node, to_port);


func _on_graph_disconnection_request(from_node, from_port, to_node, to_port):
	Graph.disconnect_node(from_node, from_port, to_node, to_port);


# TODO: figure out if theres a better way than looping through every node connection... maybe connect nodes to eachother to close those connections if the neighbor closes.
# Removes all connections related to the closed node
func _on_graph_node_closed(node : DialogueNode):
#	print_debug("node closed - %s, %s" % [node, Graph.get_connection_list()]);
	for connections in Graph.get_connection_list():
#		print_debug("connections - %s, %s" % [connections, typeof(connections)]);
		if(connections.from == node.name || connections.to == node.name):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);
	
	node_dict.erase(node.name);
	print_debug("del - node_dict=%s" % [node_dict]);


## When DailogueNode slots change
func _on_graph_node_slots_removed(node : DialogueNode, from_port : int):
	print_debug("node slot[%s] removed - %s" % [from_port, node.name]);
#	print_debug("node slot[%s] removed - %s, %s" % [from_port, node, Graph.get_connection_list()]);
	for connections in Graph.get_connection_list():
#		print_debug("connections - %s, %s" % [connections, typeof(connections)]);
		if(connections.from == node.name && connections.from_port == from_port):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);
	
#	node_dict.erase(node.name); # FIXME: change node_dict to support name and slots
	print_debug("node slot changed - '%s'=%s" % [node.name, from_port]);


func _on_get_connections_pressed():
	to_json();
#	print_debug("DialogueGraph - %s" % [to_json()]);


## Right click menu
func _on_graph_popup_request(position):
	print_debug("_on_graph_popup_request - %s, %s" % [position, right_click_menu_open]);
	if(right_click_menu_open):
		right_click_menu.set_position(position);
		right_click_menu.show();


## Add new node from menu
func _on_new_node_pressed():
	print_debug("_on_new_node_pressed - %s" % [right_click_menu.position]);
	# Add scroll offset and apply zoom value to position
	add_new_node((right_click_menu.position + Graph.scroll_offset) / Graph.zoom);
	right_click_menu_open = false;
	right_click_menu.hide();


func _on_right_click_menu_gui_input(event):
	if(event is InputEventMouseButton):
		if(event.is_pressed()):
			print_debug("right click menu input %s " % [event]);


func _on_graph_gui_input(event):
	if(event is InputEventMouseButton):
		if(event.is_pressed() && event.button_index == MOUSE_BUTTON_LEFT):
			print_debug("own left click %s, %s" % [event, right_click_menu_open]);
			if(right_click_menu_open):
				right_click_menu_open = false;
				right_click_menu.hide();
		if(event.is_pressed() && event.button_index == MOUSE_BUTTON_RIGHT):
			print_debug("own right click %s, %s" % [event, right_click_menu_open]);
			if(!right_click_menu_open):
				right_click_menu_open = true;
			else:
				right_click_menu_open = false;
				right_click_menu.hide();


# TODO: add confirmation request function
func _on_graph_delete_nodes_request(nodes):
	print_debug("graph delete request - %s" % [nodes]);
	for name in nodes:
		var node = node_dict[name];
		node._on_close_request();

# TODO: graph copy request
func _on_graph_copy_nodes_request():
	print_debug("graph copy request");


func _on_graph_tree_entered():
	print_debug("entering graph");


func _on_graph_tree_exited():
	print_debug("exiting graph");



func _on_root_node_pressed():
	print_debug("Add root node");

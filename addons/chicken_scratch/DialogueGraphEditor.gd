@tool
class_name DialogueGraphEditor extends VBoxContainer

@onready var Graph : GraphEdit = $Graph;
@onready var RightClickMenu : Container = $Graph/RightClickMenu;
@onready var FileMenu : MenuButton = %FileMenu;


var dialogue_node = preload("res://addons/chicken_scratch/dialogue_node.tscn");


var node_dict : Dictionary = {};
var file_menu_items : Dictionary = {};

static var right_click_menu_open := false;


func _ready():
	var popup := FileMenu.get_popup();
	popup.id_pressed.connect(_on_file_menu_opened);
	for i in popup.item_count:
		file_menu_items[i] = popup.get_item_text(i);
	print_debug("file_menu_items=%s" % [file_menu_items]);


func add_new_node(position := Vector2(0, 0)):
	var new_node : DialogueNode = dialogue_node.instantiate().empty();
	new_node.node_closed.connect(_on_graph_node_closed);
	new_node.slots_changed.connect(_on_graph_node_slots_changed);
	Graph.add_child(new_node);
	new_node.position_offset = position;
	node_dict[new_node.name] = new_node; # cache node names
	
	print_debug("add - node_dict=%s" % [node_dict]);
#	print_debug("new_node - %s, %s, %s, %s" % [position, new_node.position, new_node.global_position, new_node.position_offset]);


func _on_file_menu_opened(id : int):
	print_debug("opening file menu - %s, %s" % [id]);
	match id:
		0: # Open
			# TODO: implement file open dialogue
			pass;
		1: # Save
			# TODO: implement file save dialogue
			pass;


func _on_add_node_pressed():
	print_debug("on add - %s, %s" % [Graph, dialogue_node]);
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
func _on_graph_node_slots_changed(node : DialogueNode, from_port : int):
#	print_debug("node closed - %s, %s" % [node, Graph.get_connection_list()]);
	for connections in Graph.get_connection_list():
#		print_debug("connections - %s, %s" % [connections, typeof(connections)]);
		if(connections.from == node.name && connections.from_port == from_port):
			Graph.disconnect_node(connections.from, connections.from_port, connections.to, connections.to_port);
	
#	node_dict.erase(node.name); # FIXME: change node_dict to support name and slots
	print_debug("node slot changed - '%s'=%s" % [node.name, from_port]);


func _on_get_connections_pressed():
	print_debug("Graph Node connections - %s" % [Graph.get_connection_list()]);


## Right click menu
func _on_graph_popup_request(position):
	print_debug("_on_graph_popup_request - %s, %s" % [position, right_click_menu_open]);
	if(right_click_menu_open):
		RightClickMenu.set_position(position);
		RightClickMenu.show();


## Add new node from menu
func _on_new_node_pressed():
	print_debug("_on_new_node_pressed - %s" % [RightClickMenu.position]);
	add_new_node(RightClickMenu.position);
	right_click_menu_open = false;
	RightClickMenu.hide();


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
				RightClickMenu.hide();
		if(event.is_pressed() && event.button_index == MOUSE_BUTTON_RIGHT):
			print_debug("own right click %s, %s" % [event, right_click_menu_open]);
			if(!right_click_menu_open):
				right_click_menu_open = true;
			else:
				right_click_menu_open = false;
				RightClickMenu.hide();


# TODO: add confirmation request function
func _on_graph_delete_nodes_request(nodes):
	print_debug("graph delete request - %s" % [nodes]);
	for name in nodes:
		var node = node_dict[name];
		node._on_close_request();

# TODO: graph copy request
func _on_graph_copy_nodes_request():
	print_debug("graph copy request");

